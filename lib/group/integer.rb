require 'group/base'
require 'group/element'
require 'util'

module Group::Integer
  class Additive < Group::Base
    <<~DESC
      The group of integers under addition.
      - identity is 0
      - inverse is negation

      Example
        group = Additive.new
        group.op(17, 8, -9) ~> 17 + 8 + -9 == 16
        group.inverse(8) ~> -8
        group.exp(17, 3) ~> 17 + 17 + 17 == 51
          (group exponentiation in additive groups is just multiplication)
    DESC

    AdditiveElement = Class.new(Group::Element)
    element_class AdditiveElement
    value_type Integer
    identity_value 0
    value_operation { |a, b| a + b }
    value_inverse { |x| -x }
  end

  class Multiplicative < Group::Base
    <<~DESC
      The group of invertible integers { 1, -1 } under multiplication
      - identity is 1
      - inverse is itself

      The group can also be thought of as nonzero integers modulo their sign
      - identity is `positive`, represented by 1
      - only other element is `negative`, represented by -1
      - multiplication table is
          `positive * positive ~> positive`
          `positive * negative ~> negative`
          `negative * negative ~> positive`

      Example
        group = Multiplicative.new
        group.op(1, -1, 1) ~> 1 * -1 * 1 == -1
        group.inverse(-1) ~> -1 since -1 * -1 == 1
        group.exp(-1, 3) ~> -1 * -1 * -1 ~> -1
    DESC

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
    <<~DESC
      Abstract class representing integers modulo a given modulus
      Elements have values that are remainders { 0, 1, 2, ..., modulus - 1 }
    DESC

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
    <<~DESC
      Group of integers modulo a given modulus under modular addition
      - identity is 0
      - inverse is negation which is equivalent to subtraction from modulus

      Example:
        group = ModularAdditiveGroup.for(modulus: 10)
        group.op(7, 8, 9) ~> (7 + 8 + 9) % 10 == 4
        group.inverse(8) ~> (-8) % 10 == 2
        group.exp(8, 3) ~> 8 + 8 + 8 == 4
    DESC

    ModularAdditiveElement = Class.new(Group::Element)
    element_class ModularAdditiveElement
    value_type Integer
    identity_value 0
    value_operation { |a, b| a + b }
    value_inverse { |x| -x }
  end

  class ModularMultiplicativeGroup < ModularGroup
    <<~DESC
      Group of invertible integers modulo a given modulus under modular multiplication
      - identity is 1
      - an integer is invertible if and only if it is relatively prime to the modulus
      - inverse is computed using the extended Euclidean algorithm, see Bezout's lemma

      Example:
        group = ModularMultiplicativeGroup.for(modulus: 10)
        four possible element values: { 1, 3, 7, 9 }
        group.op(3, 7, 9) ~> (3 * 7 * 9) % 10 == 9
        group.inverse(7) ~> 3 since group.op(3, 7) == 1
        group.exp(7, 3) ~> 7 * 7 * 7 == 3
    DESC

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

