RSpec.describe CacheShoe::Scope do
  subject(:scope) { described_class.new(options) }

  let(:options) {
    { object: object, cached_method: cached_method, args: args }
  }

  let(:object) { Object.new }
  let(:cached_method) { :foo }
  let(:args) { ["abc"] }

  describe "#cache_key" do
    subject(:cache_key) { scope.cache_key }

    context "with all types of arguments" do
      def method_with_lots_of_args(first = nil, *second, third: nil, **fourth)
        local_variables.map { |var| instance_eval(var.to_s) }
      end

      let(:args) {
        method_with_lots_of_args(
          "first", 2, 3, third: true, fourth: false, fifth: :sym
        )
      }

      it "stringifys each argument" do
        expect(cache_key).to eq(
          'Object::foo::["first", [2, 3], true, {:fourth=>false, :fifth=>:sym}]'
        )
      end
    end

    context "with upper case arguments" do
      let(:other_scope) { described_class.new(args: ["ABC"]) }

      it "does not generate the same cache key" do
        expect(cache_key).to_not eq(other_scope.cache_key)
      end
    end
  end

  describe "#class_name" do
    it "derives from the object" do
      expect(scope.class_name).to eq("Object")
    end
  end

  describe "#key_extractors" do
    context "with a single key extractor" do
      let(:options) { { key_extractors: :foo } }

      it "wraps it in an array" do
        expect(scope.key_extractors).to match_array([:foo])
      end
    end
  end
end
