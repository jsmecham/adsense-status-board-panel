
#
# Spawn multiple worker processes to handle more concurrent requests. This can
# be overriden with the WEB_CONCURRENCY environment variable.
#
workers Integer(ENV['WEB_CONCURRENCY'] || 2)

#
# Spawn multiple threads per worker process to handle more concurrent requests.
# This can be overridden with the MAX_THREADS environment variable.
#
threads_count = Integer(ENV['MAX_THREADS'] || 5)
threads threads_count, threads_count

#
# Preload the application to reduce startup time for each individual worker
# process.
#
preload_app!

#
# Specify the default port for the application. This can be overridden with the
# PORT environment variable.
#
port ENV['PORT'] || 3000

#
# Specify the default environment for the application. This can be overridden
# with the RACK_ENV environment variable.
#
environment ENV['RACK_ENV'] || 'development'

on_worker_boot do

  #
  # Force a connection to be established to the database for each worker
  # process.
  #
  # ActiveRecord::Base.establish_connection

end
