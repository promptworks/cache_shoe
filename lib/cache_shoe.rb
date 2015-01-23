require 'logger'

require 'cache_shoe/configuration'
require 'cache_shoe/cacher'
require 'cache_shoe/result'
require 'cache_shoe/scope'
require 'cache_shoe/wrapper'

module CacheShoe
  PASS_THROUGH = :_pass_through

  def self.included(base)
    class << base
      prepend ClassMethods
    end
  end

  def self.config
    @config ||= Configuration.new
    yield @config if block_given?
    @config
  end

  private

  def self.get_cache_args(key_extractor, *args)
    case key_extractor
    when PASS_THROUGH then args
    when Proc         then [key_extractor.call(*args)].flatten
    when Symbol       then [args.first.send(key_extractor)]
    else
      fail "Can't create a cache key from #{key_extractor.inspect}"
    end
  end

  def self.on_cache_hit(key_val)
    if config.on_cache
      config.on_cache.call(key_val, :hit)
    end
    logger.info "cache hit #{key_val}"
  end

  def self.on_cache_miss(key_val)
    if config.on_cache
      config.on_cache.call(key_val, :miss)
    end
    logger.info "cache miss #{key_val}"
  end

  def self.set_cache(key_val, cache_val)
    cache.write(key_val, nil_wrapper(cache_val))
    nil_wrapper(cache_val)
  end

  def self.cache_method_clear(key)
    cache.delete(key)
  end

  def self.cache
    config.cache
  end

  def self.logger
    config.logger
  end

  def self.on_cache_clear(scope)
    Array(scope.key_extractors).each do |key_extractor|
      begin
        cache_args = get_cache_args(key_extractor, *(scope.args))
        cached_key = scope.cache_key(cache_args)
        logger.info "Clearing cache from #{scope.clearing_method}: #{cached_key}"
        if config.on_cache_clear
          config.on_cache_clear.call(
            cached_key, scope.clearing_method)
        end
        cache_method_clear cached_key
      rescue
        logger.error "Failed to clear cache from #{scope.class_name}." \
          "#{scope.clearing_method}, because the key extractor raised"
      end
    end
  end

  module ClassMethods
    def cache_method(method_name, clear_on: {})
      wrapper = CacheShoe::Wrapper.new(method_name, clear_on)
      prepend wrapper.module
    end
  end
end
