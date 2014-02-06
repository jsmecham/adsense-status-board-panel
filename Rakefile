#
# Bundler Dependencies
#
require "bundler"
Bundler.require(:default, ENV["RACK_ENV"] || :development)

#
# ActiveRecord Tasks
#
require "./app"
require "sinatra/activerecord/rake"

# ----------------------------------------------------------------------------

desc "Pings PING_URL to keep a dyno alive"
task :dyno_ping do
  require "net/http"

  if ENV["PING_URL"]
    uri = URI(ENV["PING_URL"])
    Net::HTTP.get_response(uri)
  end
end
