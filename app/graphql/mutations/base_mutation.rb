class Mutations::BaseMutation < GraphQL::Schema::RelayClassicMutation
  def validate_seller_request!(order)
    raise Errors::ValidationError, :not_found unless authorized_to_sell?(order)
  end

  def validate_buyer_request!(order)
    raise Errors::ValidationError, :not_found unless authorized_to_buy?(order)
  end

  private

  def authorized_to_sell?(order)
    current_user_is_on_seller = context[:current_user]['partner_ids'].include?(order.seller_id)
    order.seller_type != Order::USER && current_user_is_on_seller
  end

  def authorized_to_buy?(order)
    context[:current_user]['id'] == order.buyer_id
  end
end
