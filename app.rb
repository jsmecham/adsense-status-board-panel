#
# Google AdSense Widget for Status Board
#

# Configuration --------------------------------------------------------------

enable :sessions

configure do

  set :consumer_key, ENV["GOOGLE_CLIENT_ID"]
  set :consumer_secret, ENV["GOOGLE_CLIENT_SECRET"]
  set :database, ENV["DATABASE_URL"] || "sqlite3:///db/database.db"
  set :styles_path, "#{File.dirname(__FILE__)}/public/styles"
  set :scripts_path, "#{File.dirname(__FILE__)}/public/scripts"
  set :session_secret, ENV["SESSION_SECRET"] unless ENV["SESSION_SECRET"].nil?

  #
  # Initialize the Google Client
  #
  client = Google::APIClient.new \
    application_name: "AdSense Status Board Widget",
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
  # TODO Add Validations...
end

# Google Client --------------------------------------------------------------

helpers do

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def user_credentials
    @authorization ||= (
      auth = settings.api_client.authorization.dup
      auth.redirect_uri = to("/auth/callback")
      auth.update_token!(session)
      auth
    )
  end

end

# Filters --------------------------------------------------------------------

before "/earnings/*" do
  # Ensure user has authorized the app
  unless user_credentials.access_token
    redirect "/login"
  end
end

after do
  # Serialize the access/refresh token to the session
  session[:access_token] = user_credentials.access_token
  session[:refresh_token] = user_credentials.refresh_token
  session[:expires_in] = user_credentials.expires_in
  session[:issued_at] = user_credentials.issued_at
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

  # # Authenticate the User by OAuth Access Token
  # if session[:user_id].nil?
  #   user = User.find_by(access_token: params[:token])
  #   return status 401 if user.nil?
  #   session[:user_id] = user.id
  # end

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
  result = settings.api_client.execute \
    api_method: settings.adsense.reports.generate,
    parameters: {
      "startDate" => @start_on.to_s,
      "endDate" => @end_on.to_s,
      "metric" => "EARNINGS"
    },
    authorization: user_credentials

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
  redirect user_credentials.authorization_uri.to_s, 303
end

get "/auth/callback" do

  # Exchange token
  user_credentials.code = params[:code] if params[:code]
  user_credentials.fetch_access_token!

  uid = user_credentials.decoded_id_token["id"]
  user = User.find_or_create_by(uid: uid) do |user|
    user.access_token = user_credentials.access_token
    user.refresh_token = user_credentials.refresh_token
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
