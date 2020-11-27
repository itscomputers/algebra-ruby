module Group
  class Base
    def self.define_attribute(key, value)
      instance_variable_set "@#{key}", value
      define_method(key) do
        self.class.instance_variable_get "@#{key}"
      end
    end

    def self.element_class(klass)
      define_attribute :element_class, klass
    end

    def self.value_type(klass)
      define_attribute :value_type, klass
    end

    def self.value_condition(&block)
      define_method(:can_cast?) do |value|
        block.call value
      end
    end

    def self.identity_value(value)
      define_attribute :identity_value, value
    end

    def self.value_operation(&block)
      define_method(:value_operation) do |value, other|
        block.call value, other
      end
    end

    def self.value_inverse(&block)
      define_method(:value_inverse) do |value|
        block.call value
      end
    end

    def self.init_args(**args)
      define_attribute :init_args, args
    end

    def initialize
      if respond_to? :init_args
        init_args.each do |key, value|
          instance_variable_set "@#{key}", value
          self.class.define_method(key) do
            instance_variable_get "@#{key}"
          end
        end
      end
    end

    def inspect
      "<#{element_class.inspect} @identity=#{identity.inspect}>"
    end

    def elem(thing)
      return thing if thing.class == element_class

      raise ArgumentError, "got #{thing.class}, expected #{value_type}" if thing.class != value_type
      raise ArgumentError, "unsupported value" unless can_cast? thing

      element_class.new cast(thing), self
    end

    def cast(value)
      value
    end

    def can_cast?(value)
      true
    end

    def identity
      @identity ||= elem identity_value
    end

    def binary_operation(thing, other)
      elem(thing) * elem(other)
    end

    def inverse(thing)
      elem(thing).inverse
    end

    def op(*things)
      things.reduce(identity) { |acc, thing| binary_operation acc, thing }
    end

    def exp(thing, exponent)
      elem(thing).exp exponent
    end
  end
end

