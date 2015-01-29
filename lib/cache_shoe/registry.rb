require 'singleton'

module CacheShoe
  class Registry
    include Singleton

    def self.register(*args)
      instance.register(*args)
    end

    def register(class_name, method_name)
      if registry[class_name].include?(method_name)
        fail "You already cached #{method_name} on #{class_name}"
      end

      registry[class_name] << method_name
    end

    private

    def registry
      @registry ||= Hash.new { |hash, key| hash[key] = [] }
    end
  end
end
