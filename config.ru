#
# Load local environment variables from the .env file.
#
require 'dotenv'
Dotenv.load

#
# Load dependencies managed by Bundler.
#
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)

#
# Allow code to be reloaded in Development.
#
require "sinatra/reloader" if development?

#
# Restrict each request to no more than 10 seconds, per
# Heroku's recommendations.
#
use Rack::Timeout
Rack::Timeout.timeout = 10

#
# Force SSL to be used in Production.
#
use Rack::SSL if production?

#
# Run the Sinatra app!
#
require "./app"
run Sinatra::Application
