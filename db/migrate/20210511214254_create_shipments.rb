class CreateShipments < ActiveRecord::Migration[6.1]
  def change
    create_table :shipments, id: :uuid do |t|
      t.references :line_item, foreign_key: true, type: :uuid
      t.bigint :price_cents, null: false
      t.string :price_currency, null: false
      t.integer :external_id, null: false
      t.jsonb :response_payload
      t.string :internal_reference
      t.string :public_reference
      t.string :booked_at

      t.timestamps
    end
  end
end
