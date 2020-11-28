module Group
  class Element
    def self.method_missing(name, &block)
      define_method("_#{name}") do |*args, **metadata|
        block.call *args, **metadata
      end
    end

    attr_reader :value

    def initialize(value, **group_metadata)
      @value = value
      @metadata = group_metadata
    end

    def build(value)
      self.class.new(value, **@metadata)
    end

    def inspect
      @value.inspect
    end

    def to_s
      inspect
    end

    def inverse
      @inverse ||= build value_inverse(@value)
    end

    def *(other)
      build value_operation(@value, other.value)
    end

    def **(exponent)
      return inverse**(-exponent) if exponent < 0
      return build(identity_value) if exponent == 0
      return self if exponent == 1
      return self * self if exponent == 2
      return (self**(exponent / 2))**2 if exponent % 2 == 0
      self * self**(exponent - 1)
    end

    def eql?(other)
      @value == other.value &&
        self.class == other.class &&
        @metadata == other.instance_variable_get(:@metadata)
    end

    def ==(other)
      eql? other
    end

    def hash
      @value.hash
    end

    def value_type
      _value_type
    end

    def identity_value
      _identity_value(**@metadata)
    end

    def value_operation(a, b)
      _value_operation(a, b, **@metadata)
    end

    def value_inverse(a)
      _value_inverse(a, **@metadata)
    end

    private

    def _value_type
      self.class.value_type
    end

    def _identity_value(**metadata)
      self.class.identity_value(**metadata)
    end

    def _value_operation(a, b, **metadata)
      self.class.value_operation(a, b, **metadata)
    end

    def _value_inverse(a, **metadata)
      self.class.value_inverse(a, **metadata)
    end
  end
end

