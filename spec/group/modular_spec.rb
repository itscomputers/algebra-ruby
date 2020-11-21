require "group/modular"

describe Group::ModularAdditiveGroup do
  let(:modulus) { 10 }
  let(:other_modulus) { 9 }
  let(:group) { described_class.for(modulus: modulus) }
  let(:other_group) { described_class.for(modulus: other_modulus) }

  def random
    Random.rand(-10**3..10**3)
  end

  describe "#modulus" do
    context "when modulus is less than 2" do
      let(:modulus) { Random.rand(-5..1) }
      it { expect { group }.to raise_exception ArgumentError }
    end

    it "has its own modulus" do
      expect(group.modulus).to eq modulus
      expect(other_group.modulus).to eq other_modulus
    end
  end

  describe "#identity" do
    it "has its identity" do
      expect(group.identity.value).to eq 0
      expect(other_group.identity.value).to eq 0
    end
  end

  describe "#cast" do
    let(:value) { random }

    it "casts according to its modulus" do
      expect(group.cast(value).value).to eq value % modulus
      expect(other_group.cast(value).value).to eq value % other_modulus
    end
  end

  describe "#op#" do
    let(:values) { 6.times.map { random } }

    it "adds according its modulus" do
      expect(group.op(*values).value).to eq values.sum % modulus
      expect(other_group.op(*values).value).to eq values.sum % other_modulus
    end
  end
end

