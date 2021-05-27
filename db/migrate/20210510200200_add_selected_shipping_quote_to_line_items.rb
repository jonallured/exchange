class AddSelectedShippingQuoteToLineItems < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!
  
  def change
    add_reference(
      :line_items, 
      :selected_shipping_quote, 
      type: :uuid, 
      index: { algorithm: :concurrently }
    )
  end
end
