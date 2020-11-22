require "group/additive"

describe Group::Additive do
  let(:group) { described_class.new }

  def random
    Random.rand(-10**3..10**3)
  end

  describe "#identity" do
    it { expect(group.identity.value).to eq 0 }
  end

  describe "#inverse" do
    let(:value) { random }
    subject { group.inverse value }

    it { is_expected.to eq group.elem(-value) }
  end

  describe "#op" do
    let(:values) { 6.times.map { random } }
    subject { group.op *values }

    it { is_expected.to eq group.elem(values.sum) }
  end

  describe "#exp" do
    let(:value) { random }
    let(:exponent) { random }
    subject { group.exp value, exponent }

    it { is_expected.to eq group.elem(value * exponent) }
  end
end

