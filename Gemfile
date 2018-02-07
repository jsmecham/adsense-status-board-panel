
source "http://rubygems.org"

ruby "~> 2.4.3"

gem "rake"
gem "activesupport", require: "active_support/core_ext"

#
# Unicorn App Server
#
gem "unicorn"

#
# Rack Middleware
#
gem "rack-timeout"
gem "rack-ssl", group: :production

#
# Persistence
#
gem "activerecord"
gem "sqlite3", group: :development
gem "pg", group: :production

#
# Sinatra
#
gem "sinatra"
gem "sinatra-contrib", require: false
gem "sinatra-activerecord"

#
# Assets
#
gem "haml"
gem "sass"
gem "coffee-script"

#
# Google API Client
#
gem "google-api-client", "~> 0.7.1", require: "google/api_client"

#
# Sentry (for Error Reporting)
#
gem "sentry-raven", git: "https://github.com/getsentry/raven-ruby.git", group: :production

#
# Local Environment Support
#
gem "dotenv"
gem "foreman"
