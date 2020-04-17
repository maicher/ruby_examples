# frozen_string_literal: true

require 'dry-struct'
require 'types'

class Nutrient < Dry::Struct
  attribute :value, Types::Strict::Integer
  attribute :unit, Types::Strict::String.enum('ug', 'mg', 'g', 'ml', 'l')

  def to_s
    [value, unit].join
  end
end
