
source "http://rubygems.org"

ruby "2.0.0"

gem "rake"
gem "rack-ssl", group: :production
gem "activesupport", require: "active_support/core_ext"

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
# Authentication
#
gem "omniauth", require: "omniauth"
gem "omniauth-google-oauth2"

#
# Google API Client
#
gem "google-api-client", "~> 0.7.1", require: "google/api_client"

#
# Sentry (for Error Reporting)
#
gem "sentry-raven", git: "https://github.com/getsentry/raven-ruby.git", group: :production
