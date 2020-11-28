module Group
  class Base
    def self.init_args(*args)
      define_method(:init_args) do
        args
      end
    end

    def self.identity_value(value)
      instance_variable_set :@identity_value, value
      define_method(:identity_value) do
        self.class.instance_variable_get :@identity_value
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

    def metadata
      { **@metadata, :identity_value => identity_value }
    end

    def elem(thing)
      return thing if thing.class == element_class
      element_class.new(thing, **metadata)
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

    def identity_value
      @identity_value ||= self.class.identity_value(**@metadata)
    end
  end
end

