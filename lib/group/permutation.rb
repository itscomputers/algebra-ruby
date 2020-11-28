require 'group/base'
require 'group/element'

module Group
  class Permutation < Group::Base
    init_args :letters

    def identity_value
      (1...@letters).to_a
    end

    def letter_set
      @value_set ||= identity_value.to_set
    end

    def valid_value?(value)
      value.to_set == letter_set
    end

    def values
      identity_value.permutation
    end

    def elem_from_cycles(string_of_cycles)
      cycles = string_of_cycles.gsub(/ +/, " ").split(/\) *\(/).map do |string|
        string.gsub(/[\(\)]/, "").split(" ").map(&:to_i)
      end
      op *cycles.map(&method(:elem_from_cycle_array))
    end
    alias_method :cf, :elem_from_cycles

    private

    def elem_from_cycle_array(cycle_array)
      raise ArgumentError unless cycle_array.to_set.subset? letter_set
      result = identity_value
      [*cycle_array, cycle_array.first].each_cons(2) { |a, b| result[a - 1] = b }
      elem result
    end

    class Element < Group::Element
      value_operation { |a, b| b.map { |val| a[val-1] } }
      value_inverse { |a| a.size.times.map { |idx| a.index(idx+1) + 1 } }

      def cyclic_form
        return @cyclic_form if @cyclic_form

        @cyclic_form = []
        left = (1...@metadata[:letters]).to_a
        letter = nil
        until left.empty?
          if letter
            left.delete letter
          else
            letter = left.shift
            @cyclic_form << []
          end
          @cyclic_form.last << letter
          next_letter = @value[letter - 1]
          letter = left.include?(next_letter) && next_letter
        end

        @cyclic_form
          .reject { |cycle| cycle.size < 2 }
          .map { |cycle| "(#{cycle.join(" ")})" }.join(" ")
      end
    end
  end
end

