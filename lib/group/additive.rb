require 'group/base'
require 'group/element'

module Group
  class AdditiveElement < Group::Element
    def self.identity
      0
    end

    def operate_by(other_value)
      @value + other_value
    end

    def inverse
      self.class.new -@value
    end
  end

  class Additive < Group::Base
    element_class AdditiveElement
  end
end

