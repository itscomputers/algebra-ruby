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

    def letter_set
      @letter_set ||= (1..@letters).to_set
    end

    def can_cast?(value)
      value.to_set == letter_set
    end

    def elem_from_cyclic_form(cyclic_form_string)
      cycles = cyclic_form_string.gsub(/ +/, " ").split(/\) *\(/).map do |string|
        string.gsub(/[\(\)]/, "").split(" ").map(&:to_i)
      end
      op *cycles.map(&method(:from_cycle))
    end
    alias_method :cf, :elem_from_cyclic_form

    private

    def from_cycle(cycle)
      raise ArgumentError unless cycle.to_set.subset? letter_set
      result = identity_value
      [*cycle, cycle.first].each_cons(2) { |a, b| result[a - 1] = b }
      elem result
    end

    class PermutationElement
      def to_s
        to_cyclic_form
      end

      def to_cyclic_form
        return @to_cycles if @to_cycles
        @to_cycles = []
        left = @group.identity_value
        letter = nil
        until left.empty?
          if letter
            left.delete letter
            @to_cycles.last << letter
          else
            letter = left.shift
            @to_cycles << [letter]
          end
          next_letter = @value[letter - 1]
          letter = left.include?(next_letter) && next_letter
        end
        @to_cycles.reject { |cycle| cycle.size < 2 }.map { |cycle| "(#{cycle.join(" ")})" }.join(" ")
      end
    end
  end
end

