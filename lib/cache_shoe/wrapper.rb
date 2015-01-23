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
        class_name = self.class.name
        key_val = CacheShoe.cache_key(class_name, cached_method, args)

        cache_hit = true
        result = CacheShoe.cache.fetch(key_val) do
          cache_hit = false
          CacheShoe.on_cache_miss key_val
          Result.new(super(*args, &block))
        end
        CacheShoe.on_cache_hit(key_val) if cache_hit
        result.unwrap
      end
    end

    def create_cache_clear_wrapper_methods
      cached_method = method_name

      clear_on.each do |clearing_method, key_extractors|
        module_instance.send :define_method, clearing_method do |*args, &block|
          class_name = self.class.name
          CacheShoe.on_cache_clear(
            class_name, cached_method,
            clearing_method, key_extractors, *args)
          super(*args, &block)
        end
      end
    end
  end
end
