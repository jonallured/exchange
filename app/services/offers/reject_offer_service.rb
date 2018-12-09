module Offers
  class RejectOfferService
    include OfferValidationService
    def initialize(offer:, reject_reason:)
      @offer = offer
      @reject_reason = reject_reason
    end

    def process!
      validate_is_last_offer!(@offer)
      validate_offer_is_from_buyer!(@offer)

      @offer.order.reject!(@reject_reason)
      instrument_offer_reject
      PostOrderNotificationJob.perform_later(@order.id, Order::CANCELED, nil)
    end

    private

    attr_reader :offer

    def instrument_offer_reject
      Exchange.dogstatsd.increment 'offer.reject'
    end
  end
end
