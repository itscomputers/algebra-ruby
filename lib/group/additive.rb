require 'group/base'
require 'group/element'

module Group
  class Additive < Group::Base
    AdditiveElement = Class.new(Group::Element)

    element_class AdditiveElement
    value_type Integer
    identity_value 0
    value_operation { |a, b| a + b }
    value_inverse { |x| -x }
  end
end

