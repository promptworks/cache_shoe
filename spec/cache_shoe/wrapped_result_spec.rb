RSpec.describe CacheShoe::WrappedResult do
  subject(:wrapped_result) { described_class.new(value) }

  let(:value) { 123 }

  it "unwraps with #value" do
    expect(wrapped_result.value).to eq(value)
  end

  it "unwraps with #unwrap" do
    expect(wrapped_result.unwrap).to eq(value)
  end
end
