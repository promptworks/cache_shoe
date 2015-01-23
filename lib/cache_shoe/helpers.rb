module CacheShoe
  module Helpers
    def wrap_the_method_to_cache(method_id)
      define_method method_id do |*args, &blk|
        class_name = self.class.name
        key_val = CacheShoe.cache_key(class_name, method_id, args)

        cache_hit = true
        result = CacheShoe.cache.fetch(key_val) do
          cache_hit = false
          CacheShoe.on_cache_miss key_val
          WrappedResult.new(super(*args, &blk))
        end
        CacheShoe.on_cache_hit(key_val) if cache_hit
        result.unwrap
      end
    end

    def create_cache_clear_wrapper_methods(cached_method, clear_on)
      clear_on.each do |clearing_method, key_extractors|
        define_method clearing_method do |*args, &blk|
          class_name = self.class.name
          CacheShoe.on_cache_clear(
            class_name, cached_method,
            clearing_method, key_extractors, *args)
          super(*args, &blk)
        end
      end
    end
  end
end
