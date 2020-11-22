require "group/modular"

describe Group::ModularAdditiveGroup do
  let(:modulus) { Random.rand(2..99) }
  let(:group) { described_class.for(modulus: modulus) }

  def random
    Random.rand(-10**3..10**3)
  end

  describe "#modulus" do
    subject { group.modulus }

    context "if modulus is 2 or greater" do
      it { is_expected.to eq modulus }
    end

    context "if modulus is 1 or less" do
      let(:modulus) { Random.rand(-5..1) }
      it { expect { group }.to raise_exception ArgumentError }
    end
  end

  describe "#identity" do
    subject { group.identity.value }
    it { is_expected.to eq 0 }
  end

  describe "#elem" do
    let(:value) { random }
    subject { group.elem(value).value }
    it { is_expected.to eq value % modulus }
  end

  describe "#inverse" do
    let(:value) { random }
    let(:inverse) { group.inverse(value) }

    it "has an inverse satisfying the inverse relation" do
      expect(group.op value, inverse).to eq group.identity
    end
  end

  describe "#op" do
    let(:values) { 6.times.map { random } }
    subject { group.op *values }
    it { is_expected.to eq group.elem(values.sum) }
  end

  describe "#exp" do
    let(:value) { random }

    it "is the same as multiplication" do
      [0, 1, -1, random.abs, -random.abs].each do |exponent|
        expect(group.exp value, exponent).to eq group.elem(value * exponent % modulus)
      end
    end
  end
end

describe Group::ModularMultiplicativeGroup do
  let(:modulus) { 20 }
  let(:group) { described_class.for(modulus: modulus) }
  let(:good_remainders) { (0...modulus).select { |val| modulus.gcd(val) == 1 } }
  let(:bad_remainders) { (0...modulus).to_a - good_remainders }
  let(:non_invertible) { Random.rand(0..30) * modulus + bad_remainders.sample }

  def random_invertible
    Random.rand(0..30) * modulus + good_remainders.sample
  end

  describe "#modulus" do
    subject { group.modulus }

    context "if modulus is 2 or greater" do
      it { is_expected.to eq modulus }
    end

    context "if modulus is 1 or less" do
      let(:modulus) { Random.rand(-5..1) }
      it { expect { group }.to raise_exception ArgumentError }
    end
  end

  describe "#identity" do
    subject { group.identity.value }
    it { is_expected.to eq 1 }
  end

  describe "#elem" do
    subject { group.elem(value) }

    context "when value is 0" do
      let(:value) { 0 }
      it { expect { subject }.to raise_exception ArgumentError }
    end

    context "when the value is invertible" do
      let(:value) { random_invertible }
      it { is_expected.to eq group.elem(value % modulus) }
    end

    context "when the value is not invertible" do
      let(:value) { non_invertible }
      it { expect { subject }.to raise_exception ArgumentError }
    end
  end

  describe "#inverse" do
    let(:value) { random_invertible }
    let(:inverse) { group.inverse(value) }

    it "has an inverse satisfying the inverse relation" do
      expect(group.op value, inverse).to eq group.identity
    end
  end

  describe "#op" do
    let(:values) { 6.times.map { random_invertible } }
    subject { group.op *values }
    it { is_expected.to eq group.elem(values.reduce(1) { |acc, val| acc * val }) }
  end

  describe "#exp" do
    let(:value) { random_invertible }

    it "is the same as exponentiation" do
      [0, 1, *(2..15).to_a.sample(3)].each do |exponent|
        expected = value**exponent % modulus
        expect(group.exp value, exponent).to eq group.elem(expected)
        expect(group.exp value, -exponent).to eq group.elem(expected).inverse
      end
    end
  end
end

