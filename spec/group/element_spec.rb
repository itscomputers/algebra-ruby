require "group/element"

describe Group::Element do
  let(:value) { "value" }
  let(:element) { described_class.new(value) }

  let(:additive_class) do
    Class.new(described_class) do
      def self.identity
        new 0
      end

      def inverse
        self.class.new -@value
      end

      def operate_by(other_value)
        @value + other_value
      end
    end
  end

  describe "comparison" do
    context "when values are the same" do
      let(:other) { described_class.new(element.value) }

      it "considers them equal" do
        expect(element).to eq other
        expect(element).to_not be other
        expect(element == other).to be true
        expect(element.eql? other).to be true
      end
    end

    context "when values are different" do
      let(:other) { described_class.new("other_value") }

      it "considers them unequal" do
        expect(element).to_not eq other
        expect(element).to_not be other
        expect(element == other).to be false
        expect(element.eql? other).to be false
      end
    end
  end

  describe ".from" do
    subject { described_class.from(build_input) }

    context "when passing in an element" do
      let(:build_input) { element }
      it { is_expected.to eq build_input }
    end

    context "when not passing in an element" do
      let(:build_input) { value }
      it { is_expected.to_not eq build_input }
      it { is_expected.to eq element }
    end

    context "when value is not supported" do
      let(:build_input) { nil }
      before { allow(described_class).to receive(:can_build_from?) { build_input }.and_return(false) }
      it { expect { subject }.to raise_exception ArgumentError }
    end

    describe "compatibility of child classes" do
      let(:other_class) { Class.new(described_class) }
      let(:build_input) { other_class.new value }

      subject { additive_class.from build_input }

      it { is_expected.to_not eq build_input }

      it "has from input as a value" do
        expect(subject.value).to eq build_input
      end
    end
  end

  describe "#*" do
    let(:value) { 15 }
    let(:other_value) { 16 }
    let(:element) { additive_class.new value }
    let(:other_element) { additive_class.new other_value }

    subject { element * other_element }

    it { is_expected.to eq additive_class.new(value + other_value) }
  end

  describe "#inverse" do
    let(:value) { 15 }
    let(:element) { additive_class.new value }
    let(:inverse) { element.inverse }
    let(:identity) { additive_class.identity }

    it "satisifies the inverse relationship" do
      expect(element * inverse).to eq identity
    end
  end

  describe "#exp" do
    let(:value) { 5 }
    let(:element) { additive_class.new(value) }
    let(:identity) { additive_class.identity }

    context "when exponent is non-negative" do
      (0..20).each do |exponent|
        context "when exponent is #{exponent}" do
          it "is the same as performing the operation #{exponent} times" do
            expect(element.exp(exponent)).to eq(
              exponent.times.reduce(identity) { |acc, _val| acc * element }
            )
          end
        end
      end
    end

    context "when exponent is negative" do
      (0..20).each do |exponent|
        context "when exponent is #{-exponent}" do
          it "is the same as taking the positive exponent of the inverse" do
            expect(element.exp(-exponent)).to eq element.inverse.exp(exponent)
          end
        end
      end
    end
  end
end

