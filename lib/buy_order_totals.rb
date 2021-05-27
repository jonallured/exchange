class BuyOrderTotals
  def initialize(order, commission_exemption_amount_cents: nil)
    raise NotImplementedError unless order.mode == Order::BUY

    @order = order
    @commission_exemption_amount_cents = commission_exemption_amount_cents
  end

  def tax_total_cents
    @tax_total_cents ||= @order.line_items.map(&:sales_tax_cents).sum
  end

  def items_total_cents
    @items_total_cents ||= @order.line_items.map(&:total_list_price_cents).sum
  end

  def commission_fee_cents
    @commission_fee_cents ||= calculate_commission_fee_cents
  end

  def shipping_total_cents
    @shipping_total_cents ||= @order.line_items.map(&:shipping_total_cents).sum
  end

  def buyer_total_cents
    @buyer_total_cents ||= items_total_cents + shipping_total_cents.to_i + tax_total_cents.to_i
  end

  def transaction_fee_cents
    @transaction_fee_cents ||= @order.transaction_fee_cents || TransactionFeeCalculator.calculate(buyer_total_cents, @order.currency_code)
  end

  def seller_total_cents
    return unless buyer_total_cents && commission_fee_cents && transaction_fee_cents

    @seller_total_cents ||= buyer_total_cents - commission_fee_cents - transaction_fee_cents - calculate_remittable_sales_tax - adjustment_for_arta_shipping
  end

  private

  def adjustment_for_arta_shipping
    return 0 unless @order.fulfillment_type == Order::SHIP_ARTA

    shipping_total_cents.to_i
  end

  def calculate_remittable_sales_tax
    @order.line_items.select(&:should_remit_sales_tax).sum(&:sales_tax_cents)
  end

  def calculate_commission_fee_cents
    return @order.commission_fee_cents if @order.commission_fee_cents && @commission_exemption_amount_cents.nil?

    if @commission_exemption_amount_cents.present?
      exemption_running_total = @commission_exemption_amount_cents
      @order.line_items.each do |li|
        if exemption_running_total >= li.list_price_cents
          exemption_running_total -= li.list_price_cents
          li.update!(commission_fee_cents: 0)
        else
          commission_cents = (li.list_price_cents - exemption_running_total) * @order.commission_rate
          exemption_running_total = 0
          li.update!(commission_fee_cents: commission_cents)
        end
      end
    end

    @order.line_items.map(&:commission_fee_cents).sum
  end
end
