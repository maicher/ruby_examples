# frozen_string_literal: true

require 'controller'

RSpec.describe Controller do
  let(:controller) { described_class.new(params) }

  describe '#index' do
    subject { controller.index }

    context 'with invalid params' do
      let(:params) do
        {
          page: 1,
          limit: 'sfsd'
        }
      end

      it { expect(subject).to be_truthy }

    end
  end
end
