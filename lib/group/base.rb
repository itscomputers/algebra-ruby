module Group
  class Base
    def self.define_attribute(key, value)
      i_var = "@#{key}"
      instance_variable_set i_var, value
      define_method(key) do
        self.class.instance_variable_get i_var
      end
    end

    def self.element_class(value)
      define_attribute :element_class, value
    end

    def self.identity
      @element_class.identity
    end

    def identity
      element_class.identity
    end

    def cast(thing)
      element_class.from thing
    end

    def binary_operation(thing, other)
      cast(thing) * cast(other)
    end

    def inverse(thing)
      cast(thing).inverse
    end

    def op(*things)
      things.reduce(identity) { |acc, thing| binary_operation acc, thing }
    end

    def exp(thing, exponent)
      cast(thing).exp exponent
    end
  end
end

