require 'group/integer'
require 'group/permutation'

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
end

