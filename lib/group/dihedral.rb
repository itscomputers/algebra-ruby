require 'group/permutation'

module Group
  class Dihedral < Group::Base
    init_args :sides
    identity_value [:rot, 0]

    def valid_value?(value)
      [:rot, :ref].include?(value.first) && value.last.is_a?(Integer)
      true
    end

    def values
      @values = [:rot, :ref].product((0...@sides).to_a)
    end

    def rotations
      @rotations ||= elements.select { |element| element.type == :rot }
    end

    def reflections
      @reflection ||= elements.select { |element| element.type == :ref }
    end

    class Element < Group::Element
      def value_operation(a, b)
        result = case [a, b].map(&:first)
        when [:rot, :rot] then [:rot, a.last + b.last]
        when [:rot, :ref] then [:ref, a.last + b.last]
        when [:ref, :rot] then [:ref, a.last - b.last]
        when [:ref, :ref] then [:rot, a.last - b.last]
        end
        [result.first, result.last % @metadata[:sides]]
      end

      def value_inverse(a)
        case a.first
        when :rot then [:rot, -a.last % @metadata[:sides]]
        when :ref then a
        end
      end

      def type
        value.first
      end

      def index
        value.last
      end
    end
  end
end

