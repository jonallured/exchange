class Mutations::AcceptOffer < Mutations::BaseMutation
  null true

  argument :id, ID, required: true

  field :order_or_error, Mutations::OrderOrFailureUnionType, 'A union of success/failure', null: false

  def resolve(id:)
    offer = Offer.find(id)
    OfferAcceptService.new(offer).process!
    order = offer.order
    {
      # order_or_error: { error: Types::ApplicationErrorType.from_application(e) }
      order_or_error: { order: order.reload }
    }
    # validate_seller_request!(order)
    # OrderApproveService.new(order, context[:current_user]['id']).process!
    # {
    #   order_or_error: { order: order.reload }
    # }
  # rescue Errors::ApplicationError => e
    # { order_or_error: { error: Types::ApplicationErrorType.from_application(e) } }
  end
end
