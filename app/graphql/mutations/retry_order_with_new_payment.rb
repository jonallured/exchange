class Mutations::RetryOrderWithNewPayment < Mutations::BaseMutation
  null true

  argument :id, ID, required: true
  argument :credit_card_id, String, required: true

  field :order_or_error, Mutations::OrderOrFailureUnionType, 'A union of success/failure', null: false

  def resolve(id:, credit_card_id:)
    order = Order.find(id)
    authorize_buyer_request!(order)

    # Are there any more sanity checks we can do here?
    raise Errors::ValidationError.new(:invalid_state, state: order.state) unless order.state == Order::SUBMITTED && order.last_transaction_failed?

    order = OrderService.set_payment!(order, credit_card_id)

    # Will it always be the last offer?
    offer = order.last_offer
    OfferService.accept_offer(offer, current_user_id)

    { order_or_error: { order: order.reload } }
  rescue Errors::ApplicationError => e
    { order_or_error: { error: Types::ApplicationErrorType.from_application(e) } }
  end
end
