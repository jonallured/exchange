require 'rails_helper'

describe OfferAcceptService, type: :services do
  describe '#process!' do
    context 'with a submitted order' do
      let(:order) { Fabricate(:order, state: Order::SUBMITTED) }
      let(:offer) { Fabricate(:offer, order: order) }

      it 'updates the state of the order' do
        expect do
          OfferAcceptService.new(offer).process!
        end.to change { order.state }.from(Order::SUBMITTED).to(Order::APPROVED)
      end
    end
  end
end
