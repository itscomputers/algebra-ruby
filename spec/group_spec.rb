require 'group'

describe Group do
  shared_examples_for "satisfies group axioms" do
    let(:test_elements) do
      if defined?(elements)
        elements
      else
        group.elements
      end
    end

    it "satisfies identity relation for given elements" do
      test_elements.each do |element|
        expect(element * group.identity).to eq element
        expect(group.identity * element).to eq element
      end
    end

    it "satisfies associativity for given elements" do
      10.times do
        a, b, c = 3.times.map { test_elements.sample }
        expect(group.op(a, group.op(b, c))).to eq group.op(group.op(a, b), c)
      end
    end

    it "satisfies inverse relation for given elements" do
      test_elements.each do |element|
        expect(element * element.inverse).to eq group.identity
        expect(element.inverse * element).to eq group.identity
      end
    end
  end

  describe Group::Integer::Additive do
    let(:group) { described_class.new }
    let(:elements) { 10.times.map { random } }

    def random
      group.elem Random.rand(-10**3..10**3)
    end

    it_behaves_like "satisfies group axioms"
  end

  describe Group::Integer::Multiplicative do
    let(:group) { described_class.new }
    it_behaves_like "satisfies group axioms"
  end

  describe Group::Modular::Additive do
    let(:group) { described_class.new(modulus: 25) }
    it_behaves_like "satisfies group axioms"
  end

  describe Group::Modular::Multiplicative do
    let(:group) { described_class.new(modulus: modulus) }

    context "when modulus is prime" do
      let(:modulus) { 31 }
      it_behaves_like "satisfies group axioms"
    end

    context "when modulus is not prime" do
      let(:modulus) { 66 }
      it_behaves_like "satisfies group axioms"
    end
  end

  describe Group::Permutation do
    let(:group) { described_class.new(letters: 5) }
    it_behaves_like "satisfies group axioms"

    describe "cyclic form" do
      it "is reversible" do
        group.elements.each do |element|
          expect(group.elem_from_cycles element.cyclic_form).to eq element
        end
      end

      context "concatenated cyclic forms" do
        let(:elements) { group.elements.sample(10) }
        let(:string_of_cycles) { elements.map(&:cyclic_form).join(" ") }

        it "results in the same as multiplication" do
          expect(group.elem_from_cycles string_of_cycles).to eq group.op *elements
        end
      end
    end
  end

  describe Group::Klein do
    let(:group) { described_class.new }
    it_behaves_like "satisfies group axioms"
  end

  describe Group::Dihedral do
    let(:group) { described_class.new(sides: sides) }

    shared_examples "satisfies braid relations" do
      it do
        group.rotations.product(group.reflections).each do |(rot, ref)|
          expect(ref * rot).to eq rot.inverse * ref
        end
      end
    end

    context "when number of sides is odd" do
      let(:sides) { 5 }
      it_behaves_like "satisfies group axioms"
      it_behaves_like "satisfies braid relations"
    end

    context "when number of sides is even" do
      let(:sides) { 6 }
      it_behaves_like "satisfies group axioms"
      it_behaves_like "satisfies braid relations"
    end
  end
end

