class OrderEventService
  OfferEvent = Struct.new(:created_at, :offer, keyword_init: true)
  OrderEvent = Struct.new(:created_at, :type, :state_reason, keyword_init: true)

  def self.events_for(order_id:)
    order = Order.find(order_id)
    offer_events = offer_events(order)
    state_events = state_events(order)
    sorted_events(offer_events.concat(state_events))
  end

  def self.offer_events(order)
    order.offers.submitted.map { |offer| OfferEvent.new(created_at: offer.submitted_at, offer: offer) }
  end

  def self.state_events(order)
    order.state_histories.map do |state_history|
      OrderEvent.new(created_at: state_history.created_at, type: state_history.state, state_reason: state_history.reason)
    end
  end

  def self.sorted_events(events)
    events.sort_by(&:created_at)
  end
end
