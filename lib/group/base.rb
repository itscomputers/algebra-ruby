module Group
  class Base
    def self.define_attribute(key, value, **options)
      i_var = "@#{key}"
      instance_variable_set i_var, value
      define_method(key) do
        result = self.class.instance_variable_get i_var
        options[:should_cast] ? cast(result) : result
      end
    end

    def self.element_class(value)
      define_attribute :element_class, value
    end

    def self.identity(value)
      instance_variable_set :@identity, value
    end

    def self.init_args(**args)
      define_attribute :init_args, args
    end

    attr_reader :identity

    def initialize
      if respond_to? :init_args
        init_args.each do |key, value|
          instance_variable_set "@#{key}", value
          self.class.define_method(key) do
            instance_variable_get "@#{key}"
          end
        end
      end
      @identity = cast self.class.instance_variable_get(:@identity)
    end

    def cast(thing)
      element_class.from thing, self
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

