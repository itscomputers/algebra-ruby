require 'group/integer'
require 'group/permutation'
require 'group/klein'
require 'group/dihedral'

module Group
  def self.integer(operation, modulo: nil)
    if modulo.nil?
      case operation
      when :+ then Group::Integer::Additive.new
      when :* then Group::Integer::Multiplicative.new
      end
    else
      case operation
      when :+ then Group::Integer::Modular::Additive.for(modulus: modulo)
      when :* then Group::Integer::Modular::Multiplicative.for(modulus: modulo)
      end
    end
  end

  def self.permutation(letters:)
    Group::Permutation.for(letters: letters)
  end

  def self.klein
    Group::Klein.new
  end

  def self.dihedral(sides:)
    Group::Dihedral.for(sides: sides)
  end
end

