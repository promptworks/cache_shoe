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
      on_cache_clear

      yield
    end

    private

    def get_cache_args(key_extractor, *args)
      case key_extractor
      when PASS_THROUGH then args
      when Proc         then [key_extractor.call(*args)].flatten
      when Symbol       then [args.first.send(key_extractor)]
      else
        fail "Can't create a cache key from #{key_extractor.inspect}"
      end
    end

    def on_cache_clear
      scope.key_extractors.each do |key_extractor|
        begin
          cache_args = get_cache_args(key_extractor, *(scope.args))
          cached_key = scope.cache_key(cache_args)
          logger.info "Clearing cache from #{scope.clearing_method}: #{cached_key}"
          if config.on_cache_clear
            config.on_cache_clear.call(
              cached_key, scope.clearing_method)
          end
          config.cache.delete cached_key
        rescue
          logger.error "Failed to clear cache from #{scope.class_name}." \
            "#{scope.clearing_method}, because the key extractor raised"
        end
      end
    end

    def config
      CacheShoe.config
    end

    def logger
      CacheShoe.logger
    end
  end
end
