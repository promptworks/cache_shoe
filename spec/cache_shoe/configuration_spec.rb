RSpec.describe CacheShoe::Configuration do
  subject(:config) { described_class.new }

  describe "#logger" do
    it "provides a default logger" do
      expect(config.logger).to be_a(Logger)
    end

    it "allows you to override the logger" do
      l = Logger.new(StringIO.new)
      config.logger = l
      expect(config.logger.object_id).to eql(l.object_id)
    end
  end
end
