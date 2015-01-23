module CacheShoe
  # Responsible for wrapping methods for caching on the target module
  class Wrapper
    attr_reader :method_name, :clear_on

    def initialize(method_name, clear_on)
      @method_name = method_name
      @clear_on = clear_on
    end

    def module
      wrap_the_method_to_cache
      create_cache_clear_wrapper_methods

      module_instance
    end

    private

    def module_instance
      @module_instance ||= Module.new
    end

    def wrap_the_method_to_cache
      cached_method = method_name

      module_instance.send :define_method, cached_method do |*args, &block|
        scope = Scope.new(
          object: self,
          cached_method: cached_method,
          args: args,
          block: block
        )

        Cacher.new(scope).fetch do
          super(*args, &block)
        end
      end
    end

    def create_cache_clear_wrapper_methods
      cached_method = method_name

      clear_on.each do |clearing_method, key_extractors|
        module_instance.send :define_method, clearing_method do |*args, &block|
          scope = Scope.new(
            object: self,
            cached_method: cached_method,
            clearing_method: clearing_method,
            key_extractors: key_extractors,
            args: args,
            block: block
          )

          Cacher.new(scope).invalidate do
            super(*args, &block)
          end
        end
      end
    end
  end
end
