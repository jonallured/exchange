# frozen_string_literal: true

module ARTA
  class Shipment
    class << self
      def create(shipping_quote_id:)
        params = formatted_post_params(shipping_quote_id)
        ARTA::Client.post(url: '/shipments', params: params)
      end

      def formatted_post_params(shipping_quote_id)
        {
          shipment: {
            quote_id: shipping_quote_id
          }
        }
      end
    end
  end
end
