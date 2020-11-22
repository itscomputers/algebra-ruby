module Group
  class Element
    attr_reader :value, :group

    def initialize(value, group)
      @group = group
      set_value(value)
    end

    def set_value(value)
      @value = value
    end

    def inverse
      group.elem group.value_inverse(@value)
    end

    def *(other)
      group.elem group.value_operation @value, other.value
    end

    def exp(exponent)
      raise ArgumentError unless exponent.is_a? Integer

      return exp(-exponent).inverse if exponent < 0
      return @group.identity if exponent == 0
      return self if exponent == 1
      return self * self if exponent == 2
      return exp(exponent / 2).exp(2) if exponent % 2 == 0
      self * exp(exponent - 1)
    end

    def eql?(other)
      self.class == other.class && @value == other.value
    end

    def ==(other)
      eql? other
    end

    def hash
      @value.hash
    end
  end
end

