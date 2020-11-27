require 'group/permutation'

class Symbol
  def dihedral_type
    to_s[0..2].to_sym
  end

  def dihedral_index
    to_s[4..].to_i
  end

  def dihedral?
    [:rot, :ref].include?(dihedral_type) && dihedral_index.is_a?(Integer)
  end
end

module Group
  class Dihedral < Group::Base
    Element = Class.new(Group::Element)
    element_class Element
    value_type Symbol
    identity_value :rot_0

    def self.for(sides:)
      raise ArgumentError unless sides > 2
      init_args :sides => sides
      new
    end

    def can_cast?(value)
      value.dihedral?
    end

    def elements
      @elements ||= (0...sides).flat_map do |index|
        [:rot, :ref].map { |type| elem_from type, index }
      end
    end

    def rotations
      @rotations ||= elements.select { |element| element.type == :rot }
    end

    def reflections
      @reflections ||= elements.select { |element| element.type == :ref }
    end

    def elem_from(type, index)
      elem "#{type}_#{index % sides}".to_sym
    end

    def value_inverse(a)
      case a.dihedral_type
      when :rot then elem_from :rot, -a.dihedral_index
      when :ref then a
      end
    end

    def value_operation(a, b)
      case [a, b].map(&:dihedral_type)
      when [:rot, :rot] then elem_from :rot, a.dihedral_index + b.dihedral_index
      when [:ref, :ref] then elem_from :rot, a.dihedral_index - b.dihedral_index
      when [:rot, :ref] then elem_from :ref, a.dihedral_index + b.dihedral_index
      when [:ref, :rot] then elem_from :ref, a.dihedral_index - b.dihedral_index
      end
    end

    class Element
      def type
        @value.dihedral_type
      end

      def index
        @value.dihedral_index
      end
    end
  end
end
