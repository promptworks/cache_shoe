module CacheShoe
  # Wraps any result value. Useful for deciding if a nil was from a cache miss
  # or the actual method result.
  Result = Struct.new(:value) do
    alias_method :unwrap, :value
  end
end
