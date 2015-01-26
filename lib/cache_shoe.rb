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

  module ClassMethods
    def cache_method(method_name, clear_on: {})
      wrapper = CacheShoe::Wrapper.new(method_name, clear_on)
      prepend wrapper.module
    end
  end
end
