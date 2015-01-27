module CacheShoe
  # Handles cache reads and invalidations
  class Cacher
    extend Forwardable
    def_delegators :scope,
      :args,
      :cache_key,
      :model_class,
      :clearing_method,
      :key_extractors

    attr_reader :scope

    def initialize(scope)
      @scope = scope
    end

    def fetch(&block)
      cache_hit = true
      result = cache.fetch cache_key do
        cache_hit = false
        on_cache_miss
        Result.new(yield)
      end
      on_cache_hit if cache_hit
      result.unwrap
    end

    def invalidate(&block)
      key_extractors.each do |key_extractor|
        begin
          cache_args = get_cache_args(key_extractor)
          cached_key = cache_key(cache_args)
          on_cache_clear cached_key
          logger.info "Clearing cache from #{clearing_method}: #{cached_key}"
          cache.delete cached_key
        rescue => error
          logger.error "Failed to clear cache from #{class_name}." \
            "#{clearing_method}, because the key extractor raised " \
            "#{error.inspect}"
        end
      end

      yield
    end

    private

    def on_cache_hit
      if config.on_cache
        config.on_cache.call(cache_key, :hit)
      end
      logger.info "cache hit #{cache_key}"
    end

    def on_cache_miss
      if config.on_cache
        config.on_cache.call(cache_key, :miss)
      end
      logger.info "cache miss #{cache_key}"
    end

    def get_cache_args(key_extractor)
      case key_extractor
      when PASS_THROUGH then args
      when Proc         then [key_extractor.call(*args)].flatten
      when Symbol       then [args.first.send(key_extractor)]
      else
        fail "Can't create a cache key from #{key_extractor.inspect}"
      end
    end

    def on_cache_clear(cached_key)
      return unless config.on_cache_clear

      config.on_cache_clear.call(cached_key, clearing_method)
    end

    def cache
      config.cache
    end

    def logger
      config.logger
    end

    def config
      CacheShoe.config
    end
  end
end
