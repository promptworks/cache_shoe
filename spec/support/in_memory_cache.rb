class InMemoryCache
  attr_accessor :store
  def initialize
    self.store = {}
  end

  def fetch(key, &block)
    return store[key] if store.has_key?(key)
    store[key] = yield
  end

  def delete(key)
    store.delete(key)
  end

  def clear
    self.store = {}
  end
end
