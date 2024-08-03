require 'roda'
require 'json'

class App < Roda
  plugin :common_logger, $stdout

  route do |r|
    r.root do
      'Hello, world!'
    end

    r.get 'json' do
      response['Content-Type'] = 'application/json'
      { message: 'Hello, world!' }.to_json
    end
  end
end
