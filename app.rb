#
# Google AdSense Widget for Status Board
#

# Configuration --------------------------------------------------------------

configure do

  set :consumer_key, ENV["GOOGLE_CLIENT_ID"]
  set :consumer_secret, ENV["GOOGLE_CLIENT_SECRET"]
  set :database, ENV["DATABASE_URL"] || "sqlite3:///db/database.db"
  set :styles_path, "#{File.dirname(__FILE__)}/public/styles"
  set :scripts_path, "#{File.dirname(__FILE__)}/public/scripts"
  set :session_secret, ENV["SESSION_SECRET"] unless ENV["SESSION_SECRET"].nil?

end

# Models ---------------------------------------------------------------------

class User < ActiveRecord::Base
  # TODO Add Validations...
end

# OmniAuth -------------------------------------------------------------------

require 'omniauth'
use OmniAuth::Strategies::GoogleOauth2, settings.consumer_key, settings.consumer_secret, { :scope => "userinfo.email,adsense.readonly" }

# Google Client --------------------------------------------------------------

enable :sessions

helpers do

  def initialize_google_client
    client = Google::APIClient.new \
      :application_name => "AdSense Status Board Widget",
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
    @adsense ||= google_client.discovered_api("adsense", "v1.3")
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
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
    user = User.find_by(access_token: params[:token])
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
  user = User.find_or_create_by(uid: auth["uid"])do |user|
    user.uid = auth["uid"]
    user.access_token = auth["credentials"]["token"]
    user.refresh_token = auth["credentials"]["refresh_token"]
  end
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
