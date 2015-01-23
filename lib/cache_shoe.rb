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

  def self.cache
    config.cache
  end

  def self.logger
    config.logger
  end

  module ClassMethods
    def cache_method(method_name, clear_on: {})
      wrapper = CacheShoe::Wrapper.new(method_name, clear_on)
      prepend wrapper.module
    end
  end
end
