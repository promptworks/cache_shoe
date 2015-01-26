RSpec.describe CacheShoe::Scope do
  subject(:scope) { described_class.new(options) }

  context "with a single key extractor" do
    let(:options) { { key_extractors: :foo } }

    it "wraps it in an array" do
      expect(scope.key_extractors).to match_array([:foo])
    end
  end
end
