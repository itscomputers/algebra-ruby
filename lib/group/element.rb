module Group
  class Element
    attr_reader :value

    def self.can_build_from?(value)
      true
    end

    def self.identity
      raise NotImplementError, "implement in child class"
    end

    def self.from(value)
      raise ArgumentError unless can_build_from? value

      if value.is_a? self
        value
      else
        new value
      end
    end

    def initialize(value)
      @value = value
    end

    def operate_by(other_value)
      @value * other_value
    end

    def inverse
      raise NotImplementedError, "implement in child class"
    end

    def *(other)
      self.class.from operate_by(self.class.from(other).value)
    end

    def exp(exponent)
      raise ArgumentError unless exponent.is_a? Integer

      return exp(-exponent).inverse if exponent < 0
      return self.class.identity if exponent == 0
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

