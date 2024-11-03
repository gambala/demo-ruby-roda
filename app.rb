require "roda"
require "json"
require "sequel"
require_relative "lib/cache"

DB = Sequel.sqlite('storage/database_file.sqlite3')
unless DB.table_exists?(:items)
  DB.create_table :items do
    primary_key :id
    String :name, unique: true, null: false
    Float :price, null: false
  end
  items = DB[:items]
  1000.times do |i|
    items.insert(name: "item_#{i}", price: rand * 100)
  end
end

CACHE = Cache.new(path: ":memory:")

class App < Roda
  plugin :common_logger, $stdout
  plugin :render, engine: "erubi"

  route do |r|
    r.root do
      "Hello, world!"
    end

    r.get "json" do
      response["Content-Type"] = "application/json"
      {message: "Hello, world!"}.to_json
    end

    r.get "html" do
      messages = ["Good Morning", "Good Evening", "Good Night"]
      view "index", locals: {messages:}
    end

    r.get "items" do
      items = DB[:items]
      scoped_items = items.order(Sequel.function(:RANDOM)).limit(5).all
      cache_path = scoped_items.map { |item| item[:id] }.join("-")
      CACHE.fetch(cache_path) do
        view "items", locals: {items: scoped_items, count: items.count, avg_price: items.avg(:price)}
      end
    end
  end
end
