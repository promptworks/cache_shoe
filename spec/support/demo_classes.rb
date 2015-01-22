class Thing < Struct.new(:id, :name)
end

class BaseServiceExample
  attr_accessor :create_calls, :read_calls,
    :delete_calls, :storage

  def initialize
    self.create_calls = self.read_calls = self.delete_calls = 0
    self.storage = {}
  end

  def create(thing)
    @create_calls += 1
    @storage[thing.id] = thing
    thing
  end

  def read(id)
    @read_calls += 1
    @storage[id]
  end

  def delete(id)
    @delete_calls += 1
    @storage.delete(id)
  end
end

class ProcServiceExample < BaseServiceExample
  include CacheShoe
  cache_method :read, clear_on: {
    create: -> (thing) { thing.id }, delete: -> (id) { id }
  }
end

class CacheTwoMethodsExample < BaseServiceExample
  attr_accessor :read_hash_calls
  include CacheShoe
  cache_method :read, clear_on: {
    create: -> (thing) { thing.id }, delete: -> (id) { id }
  }

  cache_method :read_hash, clear_on: {
    create: -> (thing) { { id: thing.id } }, delete: -> (id) { { id: id } }
  }

  def initialize
    self.read_hash_calls = 0
    super
  end

  def read_hash(inputs)
    @read_hash_calls += 1
    @storage[inputs[:id]]
  end
end

class KeyServiceExample < BaseServiceExample
  include CacheShoe
  cache_method :read, clear_on: { create: :id, delete: PASS_THROUGH }
end

class MultiKeyClearExample < BaseServiceExample
  include CacheShoe
  cache_method :read, clear_on: {
    create: [:id, :name],
    delete: PASS_THROUGH
  }

  def create(thing)
    @create_calls += 1
    @storage[thing.id] = thing
    @storage[thing.name] = thing
    thing
  end
end

class BrokenExample < BaseServiceExample
  include CacheShoe
  cache_method :read, clear_on: {
    create: -> (_thing) { fail 'I am broken!' }
  }
end
