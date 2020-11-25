require 'group/permutation'

describe Group::Permutation do
  let(:group) { described_class.for letters: letters }
  let(:letters) { 5 }
  let(:identity_value) { (1..letters).to_a }

  describe "#identity" do
    it { expect(group.identity.value).to eq identity_value }
  end

  describe "#elem" do
    subject { group.elem value }

    context "when some value is not an integer" do
      let(:value) { [1, 2, 'c', 'd', 'e'] }
      it { expect { subject }.to raise_exception ArgumentError }
    end

    context "when the array is the wrong size" do
      let(:value) { [1, 2, 3] }
      it { expect { subject }.to raise_exception ArgumentError }
    end

    context "when the array has a repeat" do
      let(:value) { [1, 2, 2, 3, 5] }
      it { expect { subject }.to raise_exception ArgumentError }
    end

    context "when the array has an element out of range" do
      let(:value) { [1, 2, 3, 6, 5] }
      it { expect { subject }.to raise_exception ArgumentError }
    end
  end

  describe "#op" do
    let(:value) { [5, 4, 3, 2, 1] }
    let(:other) { [2, 4, 1, 3, 5] }
    let(:third) { [2, 3, 5, 1, 4] }

    it "composes permutations" do
      expect(group.op value, other).to eq group.elem [4, 2, 5, 3, 1]
    end

    it "can compose three permutations" do
      expect(group.op value, other, third).to eq group.elem [2, 5, 1, 4, 3]
    end

    context "when using cyclic form" do
      let(:cycles) { ["(1 3 4)(2 5)", "(5 2)", "(5 2 1 3)", "(1 4)(2 3)"] }
      subject { group.op *cycles.map { |v| group.cf v } }

      it { is_expected.to eq group.cf("(2 5)") }
      it "is the same as concatenation" do
        is_expected.to eq group.cf cycles.join("")
      end
    end
  end

  describe "#inverse" do
    it "satisfies the inverse relation for all permutations" do
      identity_value.permutation.each do |value|
        expect(group.op value, group.inverse(value)).to eq group.identity
      end
    end
  end

  describe "#exp" do
    let(:value) { identity_value.shuffle }
    let(:exponent) { identity_value.reduce(&:lcm) }

    it "is the identity with proper exponent" do
      expect(group.exp value, exponent).to eq group.identity
    end

    context "when 4-cycle" do
      let(:value) { [1, 4, 3, 2, 5] }

      it "gives identity at 4th power" do
        expect(group.exp value, 4).to eq group.identity
      end

      it "gives inverse at 3rd power" do
        expect(group.exp value, 3).to eq group.inverse(value)
      end
    end
  end

  describe "#from_cyclic_form" do
    subject { group.elem_from_cyclic_form cycles }

    context "when cyclic form is (1 2 5)(3 4)" do
      let(:cycles) { "(1 2 5) (3 4)" }
      it { is_expected.to eq group.elem([2, 5, 4, 3, 1]) }
      it { is_expected.to eq group.cf("(3 4) (1 2 5)") }
    end

    context "when cyclic form is (1 5)(2 4)" do
      let(:cycles) { "(1 5) (2 4)" }
      it { is_expected.to eq group.elem([5, 4, 3, 2, 1]) }
      it { is_expected.to eq group.cf("(2 4) (1 5)") }
      it { is_expected.to eq group.cf("(1 5) (2 4) (3)") }
      it { is_expected.to eq group.cf("(1 5) (3) (2 4)") }
      it { is_expected.to eq group.cf("(3) (1 5) (2 4)") }
    end

    context "when cyclic form is (1 4 3 5)" do
      let(:cycles) { "(1 4 3 5)" }
      it { is_expected.to eq group.elem([4, 2, 5, 3, 1]) }
      it { is_expected.to eq group.cf("(2) (1 4 3 5)") }
    end

    context "when cyclic form has spaces" do
      let(:cycles) { "( 1 2 ) ( 3 5 )" }
      it { is_expected.to eq group.cf("(1 2) (3 5)") }
    end
  end

  describe "PermutationElement#to_cyclic_form" do
    it "can be reversed by calling group.from_cyclic_form" do
      group.identity_value.permutation.each do |value|
        element = group.elem value
        expect(group.elem_from_cyclic_form element.to_cyclic_form).to eq element
      end
    end
  end
end

