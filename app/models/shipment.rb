class Shipment < ApplicationRecord
  belongs_to :line_item
end
