# frozen_string_literal: true

require 'create_meal'

RSpec.describe CreateMeal do
  describe '#call' do
    subject { described_class.new.call(params: params) }

    context '' do
      let(:params) do
        {
          name: 'Meal name',
          proteins: {
            value: 10,
            unit: unit
          },
          fiber: {
            value: 10,
            unit: 'mg'
          }
        }
      end

      context 'with missing unit' do
        let(:unit) { nil }

        it { expect(subject).to be_failure }
      end

      context 'with allowed unit' do
        let(:unit) { 'g' }

        it { expect(subject).to be_success }
      end

      context 'with unallowed unit' do
        let(:unit) { 'kg' }

        it { expect(subject).to be_failure }
      end
    end
  end
end
