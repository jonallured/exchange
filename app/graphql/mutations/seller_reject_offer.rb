class Mutations::SellerRejectOffer < Mutations::BaseMutation
  null true

  argument :offer_id, ID, required: true

  field :order_or_error, Mutations::OrderOrFailureUnionType, 'A union of success/failure', null: false

  def resolve(offer_id:)
    offer = Offer.find(offer_id)
    order = offer.order

    authorize_seller_request!(order)

    Offers::RejectOfferService.new(offer: offer).process!

    { order_or_error: { order: order.reload } }
  rescue Errors::ApplicationError => e
    { order_or_error: { error: Types::ApplicationErrorType.from_application(e) } }
  end
end
