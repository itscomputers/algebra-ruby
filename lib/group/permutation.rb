require 'group/base'
require 'group/element'

module Group
  class Permutation < Group::Base
    PermutationElement = Class.new(Group::Element)
    element_class PermutationElement
    value_type Array
    value_operation { |a, b| b.map { |val| a[val-1] } }
    value_inverse { |a| a.size.times.map { |idx| a.index(idx + 1) + 1 } }

    def self.for(letters:)
      raise ArgumentError if letters < 1
      init_args :letters => letters
      new
    end

    def identity_value
      (1..@letters).to_a
    end

    def can_cast?(value)
      value.to_set == identity_value.to_set
    end

    def from_cycles(cycles_string)
      cycles = cycles_string.gsub(/ +/, " ").split(/\) *\(/).map do |string|
        string.gsub(/[\(\)]/, "").split(" ").map(&:to_i)
      end
      op *cycles.map(&method(:from_cycle))
    end
    alias_method :cf, :from_cycles

    private

    def from_cycle(cycle)
      raise ArgumentError unless cycle.to_set.subset? identity_value.to_set
      result = identity_value
      [*cycle, cycle.first].each_cons(2) { |a, b| result[a - 1] = b }
      elem result
    end

    class PermutationElement
    end
  end
end

