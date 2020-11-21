require "group/base"
require "group/element"
require "group/additive"

describe Group::Element do
  def cast(value)
    Group::AdditiveElement.from value, group
  end

  let(:value) { "value" }
  let(:element) { cast value }
  let(:group) { Group::Additive.new }

  describe ".from" do
    subject { Group::AdditiveElement.from build_input, group }

    context "when passing in an element" do
      let(:build_input) { element }
      it { is_expected.to eq build_input }
    end

    context "when passing in value" do
      let(:build_input) { value }
      it { is_expected.to_not eq build_input }
      it { is_expected.to eq element }
    end

    context "when value is not supported" do
      let(:build_input) { nil }
      before { allow_any_instance_of(described_class).to receive(:can_set?) { build_input }.and_return(false) }
      it { expect { subject }.to raise_exception ArgumentError }
    end

    describe "compatibility of child classes" do
      let(:other_class) { Class.new(described_class) }
      let(:build_input) { other_class.new value, group }

      it { is_expected.to_not eq build_input }

      it "has from input as a value" do
        expect(subject.value).to eq build_input
      end
    end
  end

  describe "comparison" do
    context "when values are the same" do
      let(:other) { cast element.value }

      it "considers them equal" do
        expect(element).to eq other
        expect(element).to_not be other
        expect(element == other).to be true
        expect(element.eql? other).to be true
      end
    end

    context "when values are different" do
      let(:other) { cast "other_value" }

      it "considers them unequal" do
        expect(element).to_not eq other
        expect(element).to_not be other
        expect(element == other).to be false
        expect(element.eql? other).to be false
      end
    end
  end

  describe "#*" do
    let(:value) { 15 }
    let(:other_value) { 16 }

    subject { element * cast(other_value) }

    it { is_expected.to eq cast(value + other_value) }
  end

  describe "#inverse" do
    let(:value) { 15 }
    let(:inverse) { element.inverse }

    it "satisifies the inverse relationship" do
      expect(element * inverse).to eq group.identity
    end

    it "has the inverse of the inverse as itself" do
      expect(inverse.inverse).to eq element
    end

    it "has the inverse of the identity as itself" do
      expect(group.identity.inverse).to eq group.identity
    end
  end

  describe "#exp" do
    let(:value) { 5 }

    context "when exponent is non-negative" do
      (0..20).each do |exponent|
        context "when exponent is #{exponent}" do
          it "is the same as performing the operation #{exponent} times" do
            expect(element.exp(exponent))
              .to eq exponent.times.reduce(group.identity) { |acc, _val| acc * element }
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

