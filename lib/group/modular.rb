require 'group/base'
require 'group/element'
require 'util'

module Group
  class ModularGroup < Group::Base
    def self.for(modulus:)
      raise ArgumentError if modulus < 2

      init_args :modulus => modulus
      new
    end

    def cast(value)
      value % modulus
    end
  end

  class ModularAdditiveGroup < ModularGroup
    ModularAdditiveElement = Class.new(Group::Element)
    element_class ModularAdditiveElement
    value_type Integer
    identity_value 0
    value_operation { |a, b| a + b }
    value_inverse { |x| -x }
  end

  class ModularMultiplicativeGroup < ModularGroup
    ModularMultiplicativeElement = Class.new(Group::Element)
    element_class ModularMultiplicativeElement
    value_type Integer
    identity_value 1
    value_operation { |a, b| a * b }

    def value_inverse(value)
      Util.bezout(value, modulus).first
    end

    def can_cast?(value)
      modulus.gcd(value) == 1
    end
  end
end

