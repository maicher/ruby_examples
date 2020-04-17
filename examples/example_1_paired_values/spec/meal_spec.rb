# frozen_string_literal: true

require 'factories/meals'

RSpec.describe Meal do
  let(:meal) { FactoryBot.build(:meal) }

  describe '#proteins' do
    subject { meal.proteins }

    it { expect(subject).to be_a(Nutrient) }

    describe '#to_s' do
      subject { meal.proteins.to_s }

      it { expect(subject).to eq('25g') }
    end

    describe '#==' do
      subject { meal.proteins == other_meal.proteins }

      context 'when units match' do
        let(:other_meal) { FactoryBot.build(:meal, proteins_unit: 'g') }

        it { expect(subject).to be_truthy }
      end

      context 'when units does not match' do
        let(:other_meal) { FactoryBot.build(:meal, proteins_unit: 'mg') }

        it { expect(subject).to be_falsey }
      end
    end
  end
end
