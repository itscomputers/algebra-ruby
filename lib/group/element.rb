module Group
  class Element
    attr_reader :value, :group

    def self.from(value, group=nil)
      if value.is_a? self
        value
      else
        new value, group
      end
    end

    def self.inverse(value, group)
      raise NotImplementedError, "need to implement in child class"
    end

    def initialize(value, group=nil)
      @group = group
      raise ArgumentError unless can_set?(value)
      set_value(value)
    end

    def build(value)
      self.class.from value, @group
    end

    def can_set?(value)
      true
    end

    def set_value(value)
      @value = value
    end

    def operate_by(other_value)
      raise NotImplementedError, "implement in child class"
    end

    def inverse
      self.class.from self.class.inverse(@value, @group), @group
    end

    def operate_by_addition(other_value)
      @value + other_value
    end

    def operate_by_multiplication(other_value)
      @value * other_value
    end

    def *(other)
      build operate_by(build(other).value)
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

