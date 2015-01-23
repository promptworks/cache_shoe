module CacheShoe
  # Encapsulate the scope of a cached method, for determining cache keys and
  # what to clear
  class Scope
    attr_reader \
      :object,
      :cached_method,
      :clearing_method,
      :key_extractors,
      :args,
      :block

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set "@#{key}", value
      end
    end

    def cache_key
      CacheShoe.cache_key(class_name, cached_method, args)
    end

    def class_name
      object.class.name
    end
  end
end
