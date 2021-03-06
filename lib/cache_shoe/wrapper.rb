module CacheShoe
  # Responsible for wrapping methods for caching on the target module
  class Wrapper
    attr_reader :model,:method_name, :clear_on

    def initialize(model, method_name: nil, clear_on: nil)
      @model = model
      @method_name = method_name
      @clear_on = clear_on
    end

    def self.cache(model, method_name)
      new(model, method_name: method_name)
    end

    def self.clear(model, clear_on)
      if !clear_on.respond_to?(:key?) || clear_on.length == 0
        fail 'You must specify the clear_on triggers'
      end
      new(model, clear_on: clear_on)
    end

    def module
      wrap_the_method_to_cache if cache?
      create_cache_clear_wrapper_methods if clear?

      module_instance
    end

    private

    def cache?
      clear_on.nil?
    end

    def clear?
      method_name.nil?
    end

    def module_instance
      @module_instance ||= Module.new
    end

    def wrap_the_method_to_cache
      cached_method = method_name
      model_class = model
      module_instance.send :define_method, cached_method do |*args, &block|
        scope = Scope.new(
          model_class: model_class,
          args: args,
          block: block
        )
        Cacher.new(scope).fetch do
          super(*args, &block)
        end
      end
    end

    def create_cache_clear_wrapper_methods
      model_class = model
      clear_on.each do |clearing_method, key_extractors|
        module_instance.send :define_method, clearing_method do |*args, &block|
          scope = Scope.new(
            model_class: model_class,
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
