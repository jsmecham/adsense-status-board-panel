#
# Google AdSense Widget for Status Board
#

require "sinatra/reloader" if development?

# Configuration --------------------------------------------------------------

set :base_url, "https://adsense-status-board-widget.herokuapp.com"
set :consumer_key, ENV["GOOGLE_CLIENT_ID"]
set :consumer_secret, ENV["GOOGLE_CLIENT_SECRET"]
set :database_url, ENV["DATABASE_URL"] || "sqlite3://#{Dir.pwd}/database.db"

# Internal Configuration -----------------------------------------------------

set :styles_path, "#{File.dirname(__FILE__)}/public/styles"
set :scripts_path, "#{File.dirname(__FILE__)}/public/scripts"

# Sentry Setup (Optional) ----------------------------------------------------

if ENV["SENTRY_DSN"]
  Raven.configure do |config|
    config.dsn = ENV["SENTRY_DSN"]
  end
  use Raven::Rack
end

# DataMapper / Model Setup ---------------------------------------------------

DataMapper.setup(:default, settings.database_url)

class User
  include DataMapper::Resource
  property :id, Serial
  property :uid, String
  property :access_token, String, length: 255
  property :refresh_token, String, length: 255
  property :created_at, DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

# OmniAuth -------------------------------------------------------------------

use OmniAuth::Strategies::GoogleOauth2, settings.consumer_key, settings.consumer_secret, { :scope => "userinfo.email,adsense.readonly" }

# Google Client --------------------------------------------------------------

enable :sessions

helpers do

  def initialize_google_client
    client = Google::APIClient.new \
      :application_name => "Google AdSense Status Board Widget",
      :application_version => "1.0 Beta"
    client.authorization.access_token = current_user.access_token
    client.authorization.refresh_token = current_user.refresh_token
    client.authorization.client_id = settings.consumer_key
    client.authorization.client_secret = settings.consumer_secret
    client
  end

  def google_client
    @google_client ||= initialize_google_client
  end

  def adsense
    @adsense ||= google_client.discovered_api('adsense')
  end

  def current_user
    @current_user ||= User.get(session[:user_id]) if session[:user_id]
  end
end

# ----------------------------------------------------------------------------

get '/' do
  if current_user
    haml :index
  else
    redirect '/login'
  end
end

# Earnings -------------------------------------------------------------------

get "/earnings/:period" do |period|

  # Authenticate the User by OAuth Access Token
  if session[:user_id].nil?
    user = User.first(:access_token => params[:token])
    return status 401 if user.nil?
    session[:user_id] = user.id
  end

  # Period
  if period == "this_month"
    @start_on = Date.today.at_beginning_of_month
    @end_on = Date.today
  elsif period == "last_month"
    @start_on = Date.today.at_beginning_of_month.prev_month
    @end_on = Date.today.at_end_of_month.prev_month
  else
    @start_on = Date.today
    @end_on = Date.today
  end

  # Make an API call
  result = google_client.execute \
    :api_method => adsense.reports.generate,
    :parameters => {
      'startDate' => @start_on.to_s,
      'endDate' => @end_on.to_s,
      'metric' => "EARNINGS"
    }

  response = JSON.parse(result.body)
  @total_earnings = response["totals"][0]

  if request.xhr?
    haml :earnings, :layout => false
  else 
    haml :earnings, :layout => :widget
  end

end

# Authentication -------------------------------------------------------------

get '/auth/:name/callback' do
  auth = request.env["omniauth.auth"]
  user = User.first_or_create({ :uid => auth["uid"]}, {
    :uid => auth["uid"],
    :created_at => Time.now,
    :access_token => auth["credentials"]["token"],
    :refresh_token => auth["credentials"]["refresh_token"]
  })
  session[:user_id] = user.id
  redirect '/'
end

get "/login" do
  haml :login
end

get "/logout" do
  session[:user_id] = nil
  redirect '/'
end

# Process Assets -------------------------------------------------------------

get "/styles/:stylesheet.css" do |stylesheet|
  content_type "text/css"
  template = File.read(File.join(settings.styles_path, "#{stylesheet}.sass"))
  Sass::Engine.new(template).render
end

get "/scripts/:script.js" do |script|
  content_type "application/javascript"
  template = File.read(File.join(settings.scripts_path, "#{script}.coffee"))
  CoffeeScript.compile(template)
end
