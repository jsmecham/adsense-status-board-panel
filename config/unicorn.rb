
#
# Spawn multiple worker processes to handle more concurrent
# requests. This can be overriden with the WEB_CONCURRENCY
# environment variable.
#
worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

#
# Limit the amount of time the app will spend on any request
# before it kills it. Heroku recommends a 15 second timeout,
# so we'll just go with that...
#
timeout 15

#
# Preload the application to reduce startup time for each
# individual worker process.
#
preload_app true

#
# Customize behavior of Unicorn and its forked workers.
#
before_fork do |server, worker|

  #
  # Intercept the TERM signal sent to Unicorn and send a QUIT
  # signal in its place. This will allow Unicorn to shut down
  # gracefully after handling any active requests.
  #
  Signal.trap "TERM" do
    Process.kill "QUIT", Process.pid
  end

  #
  # Disconnect this worker from the database.
  #
  # defined?(ActiveRecord::Base) and
  #   ActiveRecord::Base.connection.disconnect!

end

after_fork do |server, worker|

  #
  # Ignore any attempt TERM signals and wait for Unicorn to
  # send a QUIT signal to this worker.
  #
  Signal.trap "TERM" do
    # Do nothing...
  end

  #
  # Force a connection to be established to the database for
  # this worker.
  #
  # defined?(ActiveRecord::Base) and
  #   ActiveRecord::Base.establish_connection

end