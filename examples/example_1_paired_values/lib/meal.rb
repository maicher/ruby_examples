# frozen_string_literal: true

require 'nutrient'

class Meal
  attr_accessor :name, :proteins_value, :proteins_unit, :fiber_value, :fiber_unit

  def proteins
    Nutrient.new(
      value: proteins_value,
      unit: proteins_unit
    )
  end

  def proteins=(nutrient)
    self.proteins_value = nutrient.value
    self.proteins_unit = nutrient.unit
  end

  def fiber
    Nutrient.new(
      value: fiber_value,
      unit: fiber_unit
    )
  end

  def fiber=(nutrient)
    self.fiber_value = nutrient.value
    self.fiber_unit = nutrient.unit
  end
end
