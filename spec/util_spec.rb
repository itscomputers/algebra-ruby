require "util"

describe Util do
  describe ".bezout" do
    def random
      Random.rand(2..10**3)
    end

    def satisfies_bezout_lemma_for(a, b)
      x, y = Util.bezout(a, b)
      expect(a*x + b*y).to eq a.gcd(b)
    end

    let(:a) { random }
    let(:b) { random }

    context "when both inputs are positive" do
      it { satisfies_bezout_lemma_for(a, b) }
    end

    context "when both inputs are negative" do
      it { satisfies_bezout_lemma_for(-a, -b) }
    end

    context "when first input is negative" do
      it { satisfies_bezout_lemma_for(-a, b) }
    end

    context "when second input is negative" do
      it { satisfies_bezout_lemma_for(a, -b) }
    end
  end
end
