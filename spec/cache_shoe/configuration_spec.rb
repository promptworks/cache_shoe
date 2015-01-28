RSpec.describe CacheShoe::Configuration do
  subject(:config) { described_class.new }

  describe "#logger" do
    it "provides a default logger" do
      expect(config.logger).to be_a(Logger)
    end
  end
end
