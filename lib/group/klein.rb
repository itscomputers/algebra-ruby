require 'group/base'
require 'group/element'

module Group
  class Klein < Group::Base
    def valid_value?(value)
      values.include? value
    end

    def values
      @values ||= ["0", "1", "10", "11"]
    end

    class Element < Group::Element
      value_type { String }
      identity_value { '0' }
      value_operation { |a, b| (a.to_i(2) ^ b.to_i(2)).to_s(2) }
      value_inverse { |a| a }
    end
  end
end

