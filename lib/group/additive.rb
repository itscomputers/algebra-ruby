require 'group/base'
require 'group/element'

module Group
  class AdditiveElement < Group::Element
    def self.inverse(value, _group)
      -value
    end
    alias_method :operate_by, :operate_by_addition
  end

  class Additive < Group::Base
    element_class AdditiveElement
    identity 0
  end
end

