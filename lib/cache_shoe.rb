require 'logger'

require 'cache_shoe/configuration'
require 'cache_shoe/cacher'
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

  module ClassMethods
    def cache_method(model, method_name)
      assert_no_double_caching(model, method_name)
      wrapper = CacheShoe::Wrapper.cache(model, method_name)
      prepend wrapper.module
    end

    def cache_clear(model, clear_on)
      wrapper = CacheShoe::Wrapper.clear(model, clear_on)
      prepend wrapper.module
    end

    private

    def assert_no_double_caching(model, method_name)
      @cached_methods ||= []
      cache_key = "#{model}::#{method_name}"
      if @cached_methods.include?("#{cache_key}")
        throw "You already cached #{cache_key}"
      end
      @cached_methods << cache_key
    end
  end
end

