#
# Load Dependencies
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
# Monitor for errors using Sentry in Production.
#
if ENV["SENTRY_DSN"]
  Raven.configure do |config|
    config.dsn = ENV["SENTRY_DSN"]
  end
  use Raven::Rack
end

#
# Run the Sinatra app!
#
require "./app"
run Sinatra::Application
