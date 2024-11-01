require 'roda'
require 'json'

class App < Roda
  plugin :common_logger, $stdout
  plugin :render

  route do |r|
    r.root do
      'Hello, world!'
    end

    r.get 'json' do
      response['Content-Type'] = 'application/json'
      { message: 'Hello, world!' }.to_json
    end

    r.get 'html' do
      messages = ["Good Morning", "Good Evening", "Good Night"]
      view 'index', locals: {messages:}
    end
  end
end
