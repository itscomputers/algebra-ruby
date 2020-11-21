require 'group/base'
require 'group/element'
require 'group/additive'

describe Group::Base do
  describe "initialize" do
    let(:child_class) { Group::Additive }
    let(:group) { child_class.new }

    describe "#identity" do
      subject { group.identity.value }
      it { is_expected.to eq 0 }
      it { is_expected.to eq child_class.instance_variable_get(:@identity) }
    end

    describe "#cast" do
      let(:value) { 15 }
      let(:expected) { value }
      subject { group.cast(thing).value }

      context "on values" do
        let(:thing) { value }
        it { is_expected.to eq expected }
      end

      context "on elements" do
        let(:thing) { group.cast(value) }
        it { is_expected.to eq expected }
      end
    end

    describe "#binary_operation" do
      let(:value) { 15 }
      let(:other_value) { 16 }
      let(:expected) { value + other_value }
      subject { group.binary_operation(thing, other).value }

      context "on values" do
        let(:thing) { value }
        let(:other) { other_value }
        it { is_expected.to eq expected }
      end

      context "on elements" do
        let(:thing) { group.cast(value) }
        let(:other) { group.cast(other_value) }
        it { is_expected.to eq expected }
      end
    end

    describe "#inverse" do
      let(:value) { 15 }
      let(:expected) { -value }
      subject { group.inverse(thing).value }

      context "on values" do
        let(:thing) { value }
        it { is_expected.to eq expected }
      end

      context "on elements" do
        let(:thing) { group.cast(value) }
        it { is_expected.to eq expected }
      end

      describe "inverse relationships" do
        context "on values" do
          let(:thing) { value }

          it "multiplies with its inverse to the identity" do
            expect(group.inverse(thing) * group.cast(thing)).to eq group.identity
          end

          it "has the inverse of its inverse as itself" do
            expect(group.inverse(thing).inverse).to eq group.cast(thing)
          end
        end

        context "on values" do
          let(:thing) { group.cast(value) }

          it "multiplies with its inverse to the identity" do
            expect(group.inverse(thing) * thing).to eq group.identity
          end

          it "has the inverse of its inverse as itself" do
            expect(group.inverse(thing).inverse).to eq thing
          end
        end
      end
    end

    describe "#op" do
      let(:values) { [5, 6, 2, -3, 15, -55] }
      subject { group.op(*things).value }

      context "on values" do
        let(:things) { values }
        it { is_expected.to eq values.sum }
      end

      context "on things" do
        let(:things) { values.map { |val| group.cast(val) } }
        it { is_expected.to eq values.sum }
      end
    end

    describe "#exp" do
      let(:value) { 15 }

      context "when exponent is positive" do
        (0..10).each do |exponent|
          context "when exponent is #{exponent}" do
            let(:expected) { exponent * value }
            subject { group.exp(thing, exponent).value }

            context "on values" do
              let(:thing) { value }
              it { is_expected.to eq expected }
            end

            context "on things" do
              let(:thing) { group.cast(value) }
              it { is_expected.to eq expected }
            end
          end
        end
      end

      context "when exponent is negative" do
        (0..10).each do |exponent|
          context "when exponent is #{-exponent}" do
            let(:expected) { group.exp(group.inverse(thing), exponent) }
            subject { group.exp(thing, -exponent) }

            context "on values" do
              let(:thing) { value }
              it { is_expected.to eq expected }
            end

            context "on elements" do
              let(:thing) { group.cast(value) }
              it { is_expected.to eq expected }
            end
          end
        end
      end
    end
  end
end

