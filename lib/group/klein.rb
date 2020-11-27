require 'group/base'
require 'group/element'

module Group
  class Klein < Group::Base
    Element = Class.new(Group::Element)
    element_class Element
    value_type ::Integer
    value_condition { |a| 0 <= a && a < 4 }
    identity_value 0
    value_operation { |a, b| a ^ b }
    value_inverse { |a| a }

    def elements
      [0, 1, 2, 3].map(&method(:elem))
    end
  end
end

