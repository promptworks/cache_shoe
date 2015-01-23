module CacheShoe
  # Handles cache reads and invalidations
  class Cacher
    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def fetch
      cache_hit = true
      result = CacheShoe.cache.fetch(scope.cache_key) do
        cache_hit = false
        CacheShoe.on_cache_miss scope.cache_key
        Result.new(yield)
      end
      CacheShoe.on_cache_hit(scope.cache_key) if cache_hit
      result.unwrap
    end

    def invalidate
      CacheShoe.on_cache_clear(
        scope.class_name, scope.cached_method,
        scope.clearing_method, scope.key_extractors, *(scope.args))

      yield
    end
  end
end
