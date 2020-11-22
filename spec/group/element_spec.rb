require "group/base"
require "group/element"
require "group/additive"

describe Group::Element do
  let(:value) { 15 }
  let(:element) { group.elem value }
  let(:group) { Group::Additive.new }

  describe "comparison" do
    context "when class is the same" do
      context "when values are the same" do
        let(:other) { group.elem value }

        it "considers them equal" do
          expect(element).to eq other
          expect(element).to_not be other
          expect(element == other).to be true
          expect(element.eql? other).to be true
        end
      end

      context "when values are different" do
        let(:other) { group.elem(value + 1) }

        it "considers them unequal" do
          expect(element).to_not eq other
          expect(element).to_not be other
          expect(element == other).to be false
          expect(element.eql? other).to be false
        end
      end
    end

    context "when class is different" do
      let(:other) { Group::Element.new(value, group) }

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
    let(:other_element) { group.elem other_value }
    subject { element * other_element }

    it { is_expected.to eq group.elem(value + other_value) }
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

