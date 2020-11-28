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
        group.inverse(8) ~> -8 since 8 + -8 == 0
        group.exp(17, 3) ~> 17 + 17 + 17 == 51
          (group exponentiation in additive groups is just multiplication)
    DESC

    identity_value 0

    class Element < Group::Element
      value_operation { |a, b| a + b }
      value_inverse { |a| -a }
    end
  end

  class Multiplicative < Group::Base
    <<~DESC
      The group of invertible integers { 1, -1 } under multiplication
      - identity is 1
      - inverse is itself

      Example
        group = Multiplicative.new
        group.op(1, -1, 1) ~> 1 * -1 * 1 == -1
        group.inverse(-1) ~> -1 since -1 * -1 == 1
        group.exp(-1, 3) ~> -1 * -1 * -1 ~> -1
    DESC

    identity_value 1

    def valid_value?(value)
      value.abs == 1
    end

    def elements
      [1, -1].map(&method(:elem))
    end

    class Element < Group::Element
      value_operation { |a, b| a * b }
      value_inverse { |a| a }
    end
  end
end

