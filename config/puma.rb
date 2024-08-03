environment ENV.fetch('RACK_ENV') { 'development' }

# config/puma.rb
if ENV['RACK_ENV'] == 'production'
  stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true
end

threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
threads threads_count, threads_count
port ENV.fetch('PORT') { 3000 }
pidfile ENV.fetch('PIDFILE') { 'tmp/pids/server.pid' }
workers ENV.fetch('WEB_CONCURRENCY') { 2 }

preload_app!
