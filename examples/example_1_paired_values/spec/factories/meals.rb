# frozen_string_literal: true

require 'meal'

FactoryBot.define do
  factory :meal do
    name { 'Meal name' }
    proteins_value { 25 }
    proteins_unit { 'g' }
    fiber_value { 2 }
    fiber_unit { 'mg' }
  end
end
