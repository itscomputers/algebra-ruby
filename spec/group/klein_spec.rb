require 'group/klein'

describe Group::Klein do
  let(:group) { described_class.new }

  describe '#identity' do
    it "satisfies identity relation" do
      group.elements.each do |element|
        expect(element * group.identity).to eq element
      end
    end
  end

  describe '#elem' do
    it 'cannot be negative' do
      expect { group.elem Random.rand(-10..-1) }.to raise_exception ArgumentError
    end

    it 'cannot be 4 or more' do
      expect { group.elem Random.rand(4..10) }.to raise_exception ArgumentError
    end
  end

  describe '#inverse' do
    it "satisfies inverse relation" do
      group.elements.each do |element|
        expect(element * element.inverse).to eq group.identity
      end
    end
  end

  describe '#exp' do
    context 'when exponent is even' do
      let(:exponent) { 2 * Random.rand(-10..10) }

      it "is the identity" do
        group.elements.each do |element|
          expect(element ** exponent).to eq group.identity
        end
      end
    end

    context 'when exponent is odd' do
      let(:exponent) { 1 + 2 * Random.rand(-10..10) }

      it "is the itself" do
        group.elements.each do |element|
          expect(element ** exponent).to eq element
        end
      end
    end
  end
end
