require 'group/base'
require 'group/element'
require 'util'

module Group::Integer
  class Additive < Group::Base
    AdditiveElement = Class.new(Group::Element)

    element_class AdditiveElement
    value_type Integer
    identity_value 0
    value_operation { |a, b| a + b }
    value_inverse { |x| -x }
  end

  class Multiplicative < Group::Base
    MultiplicativeElement = Class.new(Group::Element)

    element_class MultiplicativeElement
    value_type Integer
    identity_value 1
    value_operation { |a, b| a * b }
    value_inverse { |x| x }

    def can_cast?(value)
      value != 0
    end

    def cast(value)
      value > 0 ? 1 : -1
    end
  end

  #---------------------------

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

