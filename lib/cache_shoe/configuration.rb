module CacheShoe
  class Configuration < Struct.new(:cache, :on_cache, :on_cache_clear)
    attr_writer :logger

    def logger
      @logger ||= Logger.new(StringIO.new)
    end
  end
end
