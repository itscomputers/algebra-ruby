require 'group/element'
require 'group/base'

module Group::Modular
  class Additive < Group::Base
    <<~DESC
      Group of integers modulo a given modulus under modular addition
      - identity is 0
      - inverse is negation which is equivalent to subtraction from modulus

      Example:
        group = Group::Modular::Additive.new(modulus: 10)
        group.op(7, 8, 9) ~> (7 + 8 + 9) % 10 == 4
        group.inverse(8) ~> 2 since (8 + 2) % 10 == 0
        group.exp(8, 3) ~> 8 + 8 + 8 == 4
    DESC

    init_args :modulus
    identity_value 0

    def values
      (0...@modulus)
    end

    class Element < Group::Element
      value_operation { |a, b, **metadata| (a + b) % metadata[:modulus] }
      value_inverse { |a, **metadata| (-a) % metadata[:modulus] }
    end
  end

  class Multiplicative < Group::Base
    <<~DESC
      Group of invertible integers modulo a given modulus under modular multiplication
      - identity is 1
      - an integer is invertible if and only if it is relatively prime to the modulus
      - inverse is computed using the extended Euclidean algorithm, see Bezout's lemma

      Example:
        group = Group::Modular::Multiplicative.new(modulus: 10)
        four possible element values: { 1, 3, 7, 9 }
        group.op(3, 7, 9) ~> (3 * 7 * 9) % 10 == 9
        group.inverse(7) ~> 3 since (3 * 7) % 10 == 1
        group.exp(7, 3) ~> (7 * 7 * 7) % 10 == 3
    DESC

    init_args :modulus
    identity_value 1

    def valid_value?(value)
      value.gcd(@modulus) == 1
    end

    def value_superset
      (1...@modulus)
    end

    class Element < Group::Element
      value_operation { |a, b, **metadata| (a * b) % metadata[:modulus] }
      value_inverse { |a, **metadata| Util.bezout(a, metadata[:modulus]).first % metadata[:modulus] }
    end
  end
end

