require "litestack"

class Cache < Litecache
  def fetch(key, expires_in = nil, &block)
    value = get(key)
    return value if value
    value = yield
    set(key, value, expires_in)
    value
  end
end
