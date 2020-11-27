require 'group/dihedral'

describe Group::Dihedral do
  let(:group) { described_class.for(sides: 5) }
  let(:rotations) { group.rotations }
  let(:reflections) { group.reflections }

  it "satisfies the identity relation" do
    group.elements.each do |element|
      expect(element * group.identity).to eq element
      expect(group.identity * element).to eq element
    end
  end

  it "satisfies the inverse relation" do
    group.elements.each do |element|
      expect(element * element.inverse).to eq group.identity
    end
  end

  it "satisfies the braid relation" do
    rotations.product(reflections).each do |(rot, ref)|
      expect(ref * rot * ref).to eq rot.inverse
    end
  end

  it "has the right orders" do
    rotations.each do |rot|
      expect(rot**group.sides).to eq group.identity
    end

    reflections.each do |ref|
      expect(ref**2).to eq group.identity
    end
  end
end

