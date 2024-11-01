require 'roda'
require 'json'
require "sequel"

DB = Sequel.sqlite
DB.create_table :items do
  primary_key :id
  String :name, unique: true, null: false
  Float :price, null: false
end
items = DB[:items]
items.insert(name: 'abc', price: rand * 100)
items.insert(name: 'def', price: rand * 100)
items.insert(name: 'ghi', price: rand * 100)

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

    r.get 'items' do
      items = DB[:items]
      view 'items', locals: {items: items.order(Sequel.function(:RANDOM)).all, count: items.count, avg_price: items.avg(:price)}
    end
  end
end
