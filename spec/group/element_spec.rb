require "group/base"
require "group/element"

describe Group::Element do
  let(:test_class) do
    Class.new(described_class) do
      value_operation { |a, b|
        [
          a.first * b.first + 2 * a.last * b.last,
          a.first * b.last + a.last * b.first,
        ]
      }
      value_inverse { |a|
        norm = a.first**2 - 2*a.last**2
        [a.first / norm, -a.last / norm]
      }
    end
  end

  let(:metadata) { { :identity_value => [1, 0] } }
  let(:element) { test_class.new([3, 2], **metadata) }
  let(:identity) { element.build element.identity_value }

  describe "comparison" do
    context "when class is the same" do
      context "when values are the same" do
        let(:other) { element.build element.value }

        it "considers them equal" do
          expect(element).to eq other
          expect(element).to_not be other
          expect(element == other).to be true
          expect(element.eql? other).to be true
        end
      end

      context "when values are different" do
        let(:other) { element.build element.value.map { |x| x + 1 } }

        it "considers them unequal" do
          expect(element).to_not eq other
          expect(element).to_not be other
          expect(element == other).to be false
          expect(element.eql? other).to be false
        end
      end
    end

    context "when class is different" do
      let(:other) { Group::Element.new(element.value, **metadata) }

      it "considers them unequal" do
        expect(element).to_not eq other
        expect(element).to_not be other
        expect(element == other).to be false
        expect(element.eql? other).to be false
      end
    end
  end

  it "satisfies identity relation" do
    expect(element * identity).to eq element
    expect(identity * element).to eq element
  end

  it "satisfies inverse relation" do
    expect(element * element.inverse).to eq identity
    expect(element.inverse * element).to eq identity
  end

  describe "#exp" do
    context "when exponent is non-negative" do
      (0..10).each do |exponent|
        context "when exponent is #{exponent}" do
          it "is the same as performing the operation #{exponent} times" do
            expect(element**exponent)
              .to eq exponent.times.reduce(identity) { |acc, _val| acc * element }
          end
        end
      end
    end

    context "when exponent is negative" do
      (0..10).each do |exponent|
        context "when exponent is #{-exponent}" do
          it "is the same as taking the positive exponent of the inverse" do
            expect(element**(-exponent)).to eq element.inverse**exponent
          end
        end
      end
    end
  end
end

