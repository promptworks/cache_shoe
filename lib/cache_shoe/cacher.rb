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

  class CacheWriter
    def self.fetch(*args, &block)
      new(*args).fetch(&block)
    end

    attr_reader :object, :cached_method, :clearing_method, :key_extractors, :args, :block

    def initialize(object, cached_method, clearing_method, key_extractors, args, block)
      @object = object
      @cached_method = cached_method
      @clearing_method = clearing_method
      @key_extractors = key_extractors
      @args = args
      @block = block
    end

    def fetch
      CacheShoe.on_cache_clear(
        class_name, cached_method,
        clearing_method, key_extractors, *args)
      yield
    end

    def class_name
      object.class.name
    end
  end
end
