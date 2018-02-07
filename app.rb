#
# Google AdSense Status Board Panel
#

# Configuration --------------------------------------------------------------

enable :sessions

configure do

  set :consumer_key, ENV["GOOGLE_CLIENT_ID"]
  set :consumer_secret, ENV["GOOGLE_CLIENT_SECRET"]
  set :database, ENV["DATABASE_URL"] || "sqlite3://#{URI.escape(File.dirname(__FILE__))}/db/database.db"
  set :styles_path, "#{File.dirname(__FILE__)}/public/styles"
  set :scripts_path, "#{File.dirname(__FILE__)}/public/scripts"
  set :session_secret, ENV["SESSION_SECRET"] unless ENV["SESSION_SECRET"].nil?

  #
  # Initialize the Google Client
  #
  client = Google::APIClient.new \
    application_name: "AdSense Status Board Panel",
    application_version: "1.0 Beta"
  client.authorization.client_id = settings.consumer_key
  client.authorization.client_secret = settings.consumer_secret
  client.authorization.scope = [
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/adsense.readonly"
  ]
  set :client, client

  #
  # Initialize the AdSense API
  #
  adsense = client.discovered_api("adsense", "v1.4")
  set :adsense, adsense

end

# Models ---------------------------------------------------------------------

class User < ActiveRecord::Base

  before_create do |user|
    require 'securerandom'
    user.auth_token = SecureRandom.urlsafe_base64(160)
  end

  def session
    {
      refresh_token: self.refresh_token,
      access_token: self.access_token,
      expires_in: self.access_token_expires_in,
      issued_at: self.access_token_issued_at
    }
  end

end

# Google Client --------------------------------------------------------------

helpers do

  def current_user
    @current_user ||= (
      if session[:user_id]
        User.find(session[:user_id])
      elsif params[:auth_token]
        User.find_by(auth_token: params[:auth_token])
      end
    )
  end

  def authorization
    @authorization ||= (
      auth = settings.client.authorization.dup
      auth.redirect_uri = to("/auth/callback")
      auth.update_token!(current_user.session) if current_user
      auth
    )
  end

end

# Filters --------------------------------------------------------------------

before "/earnings/*" do
  redirect "/login" unless current_user
end

after do
  return unless current_user
  current_user.update_attributes! \
    access_token: authorization.access_token,
    refresh_token: authorization.refresh_token,
    access_token_expires_in: authorization.expires_in,
    access_token_issued_at: authorization.issued_at
end

get "/" do
  if current_user
    haml :index
  else
    redirect "/login"
  end
end

# Earnings -------------------------------------------------------------------

get "/earnings/:period" do |period|

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
  result = settings.client.execute \
    api_method: settings.adsense.reports.generate,
    parameters: {
      "startDate" => @start_on.to_s,
      "endDate" => @end_on.to_s,
      "metric" => "EARNINGS"
    },
    authorization: authorization

  response = JSON.parse(result.body)
  # return response.inspect
  if response["error"]
    return response.inspect
  end

  @total_earnings = response["totals"][0]

  if request.xhr?
    haml :earnings, layout: false
  else
    haml :earnings, layout: :widget
  end

end

# Authentication -------------------------------------------------------------

get "/login" do
  haml :login
end

get "/logout" do
  session[:user_id] = nil
  session = nil
  redirect "/"
end


get "/auth" do
  redirect authorization.authorization_uri.to_s, 303
end

get "/auth/callback" do

  # Exchange token
  authorization.code = params[:code] if params[:code]
  authorization.fetch_access_token!

  uid = authorization.decoded_id_token["id"]
  user = User.find_or_create_by(uid: uid) do |user|
    user.access_token = authorization.access_token
    user.access_token_expires_in = authorization.expires_in
    user.access_token_issued_at = authorization.issued_at
    user.refresh_token = authorization.refresh_token
  end
  session[:user_id] = user.id

  redirect to('/')

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
