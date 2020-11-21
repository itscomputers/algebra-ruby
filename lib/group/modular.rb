require 'group/base'
require 'group/element'
require 'util'

module Group
  module ModularElementMixin
    def set_value(value)
      @value = value % @group.modulus
    end
  end

  class ModularGroup < Group::Base
    def self.for(modulus:)
      raise ArgumentError if modulus < 2

      init_args :modulus => modulus
      new
    end
  end

  class ModularAdditiveElement < Group::Element
    include ModularElementMixin
    alias_method :operate_by, :operate_by_addition

    def self.inverse(value, _group)
      -value
    end
  end

  class ModularMultiplicativeElement < Group::Element
    include ModularElementMixin
    alias_method :operate_by, :operate_by_multiplication

    def self.inverse(value, group)
      Util::bezout(value, group.modulus).first
    end

    def can_set?(value)
      @group.modulus.gcd(value) == 1
    end
  end

  class ModularAdditiveGroup < ModularGroup
    element_class ModularAdditiveElement
    identity 0
  end

  class ModularMultiplicativeGroup < ModularGroup
    element_class ModularMultiplicativeElement
    identity 1
  end
end

