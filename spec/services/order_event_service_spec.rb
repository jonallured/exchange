require 'rails_helper'
require 'support/gravity_helper'

describe OrderEventService, type: :services do
    let(:user_id) { 'user-id' }
    let(:partner_id) { 'partner-id' }
    let(:amount_cents) { 200 }
    let(:note) { nil }
    let(:order_mode) { Order::OFFER }
    let(:state) { Order::PENDING }
    let(:state_reason) { nil }
    let(:order) { Fabricate(:order, seller_id: partner_id, seller_type: Order::PARTNER, buyer_id: user_id, state: state, state_reason: state_reason, mode: order_mode) }
    let!(:offer) { Fabricate(:offer, order: order, submitted_at: Time.now.utc,  amount_cents: 1000_00, tax_total_cents: 20_00, shipping_total_cents: 30_00, creator_id: user_id, from_id: user_id) }    

    before do
        order.send(:submit!)
    end
    describe '#events_for' do
        before do
            order.update!(last_offer: offer)
        end
        context "offer order" do
            shared_examples "order with 2 order events and one offer event" do 
                it "generates events" do
                    events = OrderEventService.events_for(order_id: order.id)
                    expect(events.length).to be 3
                    expect(events.map { | event | event.class.name.demodulize }).to eq ['OrderEvent', 'OfferEvent', 'OrderEvent']
                    expect(events[0].type).to eq "pending"
                    expect(events[2].type).to eq "submitted"
                    expect(events[1].offer.amount_cents).to eq  100000
                    expect(events[1].offer.from_participant).to eq "buyer"
                end
            end
            describe "order has 1 offer from buyer" do
                it_behaves_like "order with 2 order events and one offer event"
            end
            describe "order has 1 offer from buyer and pending offer from seller" do
                before do
                    seller_offer = OfferService.create_pending_counter_offer(offer, amount_cents: 20000, note: note, from_id: partner_id, creator_id: user_id, from_type: Order::PARTNER)
                    order.update!(last_offer: seller_offer)
                end
                it_behaves_like "order with 2 order events and one offer event"
            end
            describe "order has 1 offer from buyer and counter offer from seller" do
                before do
                    seller_offer = OfferService.create_pending_counter_offer(offer, amount_cents: 20000, note: note, from_id: partner_id, creator_id: user_id, from_type: Order::PARTNER)
                    order.update!(last_offer: seller_offer)
                    seller_offer.update!(submitted_at: Time.now.utc) # just update submitted_at instead of really accepting the offer which needs a lot of mocking
                end
                it "generates events" do
                    events = OrderEventService.events_for(order_id: order.id)
                    expect(events.length).to be 4
                    expect(events.map { | event | event.class.name.demodulize }).to eq ['OrderEvent', 'OfferEvent', 'OrderEvent', "OfferEvent"]
                    expect(events[3].offer.amount_cents).to eq  20000
                    expect(events[3].offer.from_participant).to eq "seller"
                end
                
            end
            describe "order has an accepted offer from seller" do
                before do
                    seller_offer = OfferService.create_pending_counter_offer(offer, amount_cents: 20000, note: note, from_id: partner_id, creator_id: user_id, from_type: Order::PARTNER)
                    order.update!(last_offer: seller_offer)
                    seller_offer.update!(submitted_at: Time.now.utc)
                    order.send(:approve!)
                end
                it "generates events" do
                    events = OrderEventService.events_for(order_id: order.id)
                    expect(events.length).to be 5
                    expect(events.map { | event | event.class.name.demodulize }).to eq ['OrderEvent', 'OfferEvent', 'OrderEvent', "OfferEvent", 'OrderEvent']
                    expect(events[0].type).to eq "pending"
                    expect(events[2].type).to eq "submitted"
                    expect(events[4].type).to eq "approved"
                    expect(events[1].offer.from_participant).to eq "buyer"
                    expect(events[3].offer.from_participant).to eq "seller"
                end
                
            end
        end
    end
end
