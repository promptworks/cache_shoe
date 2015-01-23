RSpec.describe CacheShoe::Result do
  subject(:result) { described_class.new(value) }

  let(:value) { 123 }

  it "unwraps with #value" do
    expect(result.value).to eq(value)
  end

  it "unwraps with #unwrap" do
    expect(result.unwrap).to eq(value)
  end
end
