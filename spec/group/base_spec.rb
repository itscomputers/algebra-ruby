require "group/base"
require "group/element"
require "group/additive"

describe Group::Base do
  let(:klass) { Class.new(described_class) }
  let(:group) { klass.new }

  describe "defined attributes" do
    def stores_as_class_variable
      expect(group.class.instance_variable_get "@#{attribute}").to eq value
    end

    def makes_accessible_on_instance
      expect(group.send attribute).to eq value
    end

    before { klass.send attribute, value }

    describe "element_class" do
      let(:attribute) { :element_class }
      let(:value) { Group::Element }
      it { stores_as_class_variable }
      it { makes_accessible_on_instance }
    end

    describe "value_type" do
      let(:attribute) { :value_type }
      let(:value) { Integer }
      it { stores_as_class_variable }
      it { makes_accessible_on_instance }
    end

    describe "identity_value" do
      let(:attribute) { :identity_value }
      let(:value) { 0 }
      it { stores_as_class_variable }
      it { makes_accessible_on_instance }
    end

    describe "init_args" do
      let(:attribute) { :init_args }
      let(:value) { { :modulus => 5, :max => 10 } }
      it { stores_as_class_variable }
      it { makes_accessible_on_instance }

      it "makes an instance method for each init arg" do
        value.each do |key, val|
          expect(group.send key).to eq val
        end
      end
    end
  end

  describe "defined methods" do
    describe "value_operation" do
      before { klass.send(:value_operation) { |a, b| a + b } }

      it "defines a value_operation method matching the block" do
        expect(group.value_operation 5, 8).to eq 13
      end
    end

    describe "value_inverse" do
      before { klass.send(:value_inverse) { |a| -a } }

      it "defines a value_inverse method matching the block" do
        expect(group.value_inverse -10).to eq 10
      end
    end
  end

  describe "initialize" do
    let(:klass) { Group::Additive }

    describe "#identity" do
      subject { group.identity.value }
      it { is_expected.to eq group.identity_value }
      it { is_expected.to eq klass.instance_variable_get(:@identity_value) }
    end

    describe "#elem" do
      let(:value) { 15 }
      subject { group.elem(thing).value }

      context "on values" do
        let(:thing) { value }

        context "when value is supported value type" do
          before { expect(value.class).to eq group.value_type }

          context "when value can be cast" do
            before { allow(group).to receive(:can_cast?).and_return true }
            it { is_expected.to eq value }
          end

          context "when value cannot be cast" do
            before { allow(group).to receive(:can_cast?).and_return false }
            it { expect { subject }.to raise_exception ArgumentError }
          end
        end

        context "when value is unsupported value type" do
          let(:value) { "value" }
          it { expect { subject }.to raise_exception ArgumentError }
        end
      end

      context "on elements" do
        let(:thing) { group.elem(value) }

        context "when element class is group's element class" do
          it { is_expected.to eq value }
        end

        context "when element class is not group's element class" do
          let(:thing) { Group::Element.new('value', 'group') }
          it { expect { subject }.to raise_exception ArgumentError }
        end
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
        let(:thing) { group.elem(value) }
        let(:other) { group.elem(other_value) }
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
        let(:thing) { group.elem(value) }
        it { is_expected.to eq expected }
      end

      describe "inverse relationships" do
        context "on values" do
          let(:thing) { value }

          it "multiplies with its inverse to the identity" do
            expect(group.inverse(thing) * group.elem(thing)).to eq group.identity
          end

          it "has the inverse of its inverse as itself" do
            expect(group.inverse(thing).inverse).to eq group.elem(thing)
          end
        end

        context "on values" do
          let(:thing) { group.elem(value) }

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
        let(:things) { values.map { |val| group.elem(val) } }
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
              let(:thing) { group.elem(value) }
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
              let(:thing) { group.elem(value) }
              it { is_expected.to eq expected }
            end
          end
        end
      end
    end
  end
end

