require_relative 'config/iodine.rb'

if ENV['RACK_ENV'] != 'development'
  require_relative 'app'
  run App.app
else
  require 'auto_reloader'
  # won't reload before 1s elapsed since last reload by default. It can be overridden in the reload! call below
  AutoReloader.activate reloadable_paths: [__dir__], delay: 1
  run ->(env) {
    AutoReloader.reload! do |unloaded|
      # by default, AutoReloader only unloads constants when a watched file changes;
      # when it unloads code before calling this block, the value for unloaded will be true.
      ActiveSupport::Dependencies.clear if unloaded && defined?(ActiveSupport::Dependencies)
      require_relative 'app'
      App.call env
    end
  }
end
