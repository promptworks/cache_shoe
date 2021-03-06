module CacheShoe
  # Encapsulate the scope of a cached method, for determining cache keys and
  # what to clear
  class Scope
    attr_reader \
      :model_class,
      :clearing_method,
      :key_extractors,
      :args,
      :block

    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set "@#{key}", value
      end
    end

    # Any way to delete this?  Does the rails cache give us
    # any of this for free?
    def cache_key(a = args)
      [
        model_class.to_s,
        digest(a)
      ].join("::")
    end


    def key_extractors
      Array(@key_extractors)
    end

    private

    def digest(a)
      return 'empty' if a.empty?
      resolve_cache_key(a).to_s.downcase
    end

    def resolve_cache_key(obj)
      case obj
      when ::Array then obj.map { |v| resolve_cache_key v }
      when ::Hash
        obj.each_with_object({}) do |(k, v), memo|
          memo[resolve_cache_key(k)] = resolve_cache_key(v)
        end
      else
        obj
      end
    end
  end
end
