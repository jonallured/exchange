class OfferAcceptService
  def initialize(offer)
    @offer = offer
  end

  def process!
    @offer.order.approve!
  end
end
