
source "http://rubygems.org"

ruby "2.0.0"

gem "rack-ssl", group: :production
gem "activesupport", require: "active_support/core_ext"

#
# Sinatra
#
gem "sinatra"

#
# Persistence
#
gem "dm-core"
gem "dm-migrations"
gem "dm-timestamps"
gem "dm-sqlite-adapter", group: :development
gem "dm-postgres-adapter", group: :production
gem "sinatra-contrib", require: false

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
