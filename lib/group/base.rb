module Group
  class Base
    def self.init_args(*args)
      define_method(:init_args) do
        args
      end
    end

    def initialize(**metadata)
      @metadata = metadata
      if self.respond_to? :init_args
        init_args.each do |arg|
          if metadata.key? arg
            instance_variable_set "@#{arg}", metadata[arg]
          else
            raise ArgumentError, "requires named parameter #{arg} to initialize"
          end
        end
      end
    end

    def elem(thing)
      return thing if thing.class == element_class

      unless thing.class == value_type
        raise ArgumentError, "got #{thing.class}, expected #{value_type}"
      end
      unless valid_value? thing
        raise ArgumentError, "invalid value #{thing}"
      end

      element_class.new(thing, **@metadata)
    end

    def identity
      @identity ||= elem identity_value
    end

    def inverse(thing)
      elem(thing).inverse
    end
    alias_method :inv, :inverse

    def op(*things)
      things.reduce(identity) { |acc, thing| binary_operation acc, thing }
    end

    def exp(thing, exponent)
      elem(thing)**exponent
    end

    def valid_value?(value)
      true
    end

    def value_superset
      nil
    end

    def values
      value_superset&.select(&method(:valid_value?))
    end

    def elements
      @elements ||= values&.map(&method(:elem))
    end

    private

    def binary_operation(thing, other)
      elem(thing) * elem(other)
    end

    def element_class
      self.class::Element
    end

    def value_type
      dummy_element.value_type
    end

    def identity_value
      dummy_element.identity_value
    end

    def dummy_element
      element_class.new(nil, **@metadata)
    end
  end
end

