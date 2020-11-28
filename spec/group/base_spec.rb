require "group/base"
require "group/element"

describe Group::Base do
  let(:group) { test_class.new }
  let(:value) { "value" }
  let(:test_class) do
    Class.new(described_class) do
      Element ||= Class.new Group::Element

      def self.identity_value
        ""
      end

      def valid_value?(value)
        value != "invalid"
      end

      def element_class
        Element
      end
    end
  end

  before do
    group.element_class.define_method(:value_type) { String }
    group.element_class.define_method(:value_operation) { |a, b| "#{b}#{a}" }
    group.element_class.define_method(:value_inverse) { |a| "#{a.upcase}" }
  end

  describe "#initialize" do
    context "without metadata" do
      it "stores empty metadata" do
        expect(group.instance_variable_get(:@metadata)).to be_empty
      end
    end

    context "with metadata" do
      let(:metadata) { { :cool => "thing", :something => "else" } }
      let(:group) { test_class.new(**metadata) }
      let(:test_class) do
        Class.new(described_class) do
          init_args :cool, :something

          def element_class
            Class.new(Group::Element)
          end
        end
      end

      it "stores the metadata" do
        expect(group.instance_variable_get(:@metadata)).to eq metadata
      end

      it "stores each value as an instance variable" do
        metadata.each do |key, value|
          expect(group.instance_variable_get("@#{key}")).to eq value
        end
      end
    end
  end

  describe "#elem" do
    subject { group.elem thing }

    context "when just a value" do
      let(:thing) { value }

      it "builds an element with that value" do
        expect(subject).to be_a Group::Element
        expect(subject.value).to eq value
      end
    end

    context "when already an element" do
      let(:thing) { group.elem value }
      it { is_expected.to eq thing }
    end
  end

  describe "#identity" do
    subject { group.identity }
    it { is_expected.to eq group.elem "" }
  end

  describe "#inverse" do
    subject { group.inverse(value) }
    it { is_expected.to eq group.elem "VALUE" }
  end

  describe "#op" do
    subject { group.op *elements }
    let(:elements) { ["a", "b", "c"].map { |s| group.elem s } }
    it { is_expected.to eq group.elem "cba" }
  end

  describe "#exp" do
    subject { group.exp element, exponent }
    let(:element) { group.elem "abc" }

    context "when the exponent is 0" do
      let(:exponent) { 0 }
      it { is_expected.to eq group.elem "" }
    end

    context "when the exponent is 1" do
      let(:exponent) { 1 }
      it { is_expected.to eq group.elem "abc" }
    end

    context "when the exponent is 6" do
      let(:exponent) { 6 }
      it { is_expected.to eq group.elem "abcabcabcabcabcabc" }
    end

    context "when the exponent is 7" do
      let(:exponent) { 7 }
      it { is_expected.to eq group.elem "abcabcabcabcabcabcabc" }
    end

    context "when the exponent is -1" do
      let(:exponent) { -1 }
      it { is_expected.to eq group.elem "ABC" }
    end

    context "when the exponent is -6" do
      let(:exponent) { -6 }
      it { is_expected.to eq group.elem "ABCABCABCABCABCABC" }
    end

    context "when the exponent is -7" do
      let(:exponent) { -7 }
      it { is_expected.to eq group.elem "ABCABCABCABCABCABCABC" }
    end
  end

  describe "#values" do
    subject { group.values }

    context "when value_superset is defined" do
      let(:value_superset) { ["okay", "invalid", "also okay"] }
      before { allow(group).to receive(:value_superset).and_return value_superset }
      it { is_expected.to match_array value_superset - ["invalid"] }
    end

    context "when value_superset is not defined" do
      it { is_expected.to be_nil }
    end
  end

  describe "#elements" do
    subject { group.elements }
    let(:values) { ["a", "b", "c"] }
    before { allow(group).to receive(:values).and_return values }
    it { is_expected.to eq values.map { |val| group.elem val } }
  end
end

