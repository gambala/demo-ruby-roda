environment ENV.fetch('RACK_ENV') { 'development' }

# config/puma.rb
if ENV['RACK_ENV'] == 'production'
  stdout_redirect 'log/puma.stdout.log', 'log/puma.stderr.log', true
end

# Optional: Set the log level
log_requests true
