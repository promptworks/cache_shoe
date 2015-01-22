module CacheShoe
  Configuration = Struct.new(:cache, :on_cache, :on_cache_clear, :logger) do
    def logger
      @logger ||= Logger.new(StringIO.new)
    end
  end
end
