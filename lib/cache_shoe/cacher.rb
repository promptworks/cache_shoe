module CacheShoe
  # Handles cache reads
  class CacheReader
    def self.fetch(*args, &block)
      new(*args).fetch(&block)
    end

    attr_reader :object, :cached_method, :args, :block

    def initialize(object, cached_method, args, block)
      @object = object
      @cached_method = cached_method
      @args = args
      @block = block
    end

    def fetch
      cache_hit = true
      result = CacheShoe.cache.fetch(cache_key) do
        cache_hit = false
        CacheShoe.on_cache_miss cache_key
        Result.new(yield)
      end
      CacheShoe.on_cache_hit(cache_key) if cache_hit
      result.unwrap
    end

    private

    def cache_key
      CacheShoe.cache_key(class_name, cached_method, args)
    end

    def class_name
      object.class.name
    end
  end
end

