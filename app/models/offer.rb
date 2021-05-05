class Offer < ApplicationRecord
  has_paper_trail versions: { class_name: 'PaperTrail::OfferVersion' }

  EXPIRATION = 3.days.freeze

  belongs_to :order
  belongs_to :responds_to, class_name: 'Offer', optional: true

  scope :submitted, -> { where.not(submitted_at: nil) }
  scope :pending, -> { where(submitted_at: nil) }

  def last_offer?
    order.last_offer == self
  end

  def submitted?
    submitted_at.present?
  end

  def buyer_total_cents
    return unless definite_total?

    amount_cents + shipping_total_cents + tax_total_cents
  end

  def from_participant
    if from_id == order.seller_id && from_type == order.seller_type
      Order::SELLER
    elsif from_id == order.buyer_id && from_type == order.buyer_type
      Order::BUYER
    else
      raise Errors::ValidationError, :unknown_participant_type
    end
  end

  def to_participant
    from_participant == Order::SELLER ? Order::BUYER : Order::SELLER
  end

  def awaiting_response_from
    return unless submitted?

    case from_participant
    when Order::BUYER then Order::SELLER
    when Order::SELLER then Order::BUYER
    end
  end

  def definite_total?
    [amount_cents, shipping_total_cents, tax_total_cents].all?(&:present?)
  end

  def offer_amount_changed?
    return false if responds_to.blank?

    amount_cents != responds_to.amount_cents
  end

  def defines_total?
    return false if responds_to.blank?

    definite_total? && !responds_to.definite_total?
  end
end
