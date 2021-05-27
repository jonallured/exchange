class ShippingQuote < ApplicationRecord
  belongs_to :shipping_quote_request
  has_one :line_item, foreign_key: :selected_shipping_quote_id, dependent: :destroy, inverse_of: :shipping_quotes
end
