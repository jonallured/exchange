require 'rails_helper'

describe ARTA::Shipment do
  describe '.formatted_post_params' do
    before do
      allow(ARTA::Client).to receive(:post)
    end

    context 'when preparing metadata' do
      let(:expected_formatted_params) do
        {
          shipment: {
            quote_id: 'hello-friend'
          }
        }
      end

      it 'returns properly formatted params' do
        expect(
          described_class.formatted_post_params('hello-friend')
        ).to eq(expected_formatted_params)
      end
    end
  end
end
