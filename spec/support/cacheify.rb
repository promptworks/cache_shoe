RSpec.configure do |config|
  CACHE_ACTIONS = {}

  CacheShoe.config.on_cache = lambda do |cache_key, cache_hit|
    CACHE_ACTIONS[cache_key] ||= []
    CACHE_ACTIONS[cache_key] << { read: cache_hit }
  end

  CacheShoe.config.on_cache_clear = lambda do |cache_key, trigger_method|
    CACHE_ACTIONS[cache_key] ||= []
    CACHE_ACTIONS[cache_key] << { trigger_method => :clear }
  end

  config.before :all do
    CacheShoe.config.cache = ActiveSupport::Cache::MemoryStore.new
  end

  config.before :each do
    CacheShoe.config.cache.clear
    CACHE_ACTIONS.clear
  end

  config.after :each do
    if example.exception
      p "-" * 30
      p "Cache Actions"
      pp CACHE_ACTIONS
      p "-" * 30
    end
  end
end

RSpec::Matchers.define :have_cached do |*expected_cache_pattern|
  class << self
    attr_accessor :cache_key, :actual_cache_pattern
  end

  match do |service_instance, method, *args|
    self.cache_key = CacheShoe.cache_key(
      service_instance.class.name, method, args)
    self.actual_cache_pattern =
      (CACHE_ACTIONS[cache_key] || [{}]).flatten

    actual_cache_pattern == expected_cache_pattern
  end

  failure_message_for_should do |_service_instance, _method, *_args|
    "Expected cache pattern: #{expected_cache_pattern}, but got: " \
      "#{actual_cache_pattern} for " \
      "cache_key #{cache_key}"
  end
end
