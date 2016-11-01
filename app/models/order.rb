class Order < ApplicationRecord
  before_save :default_order

  belongs_to :merchant

  scope :shipped, -> { where(shipping_status: 'Shipped') }

  validates :order_id, presence: true, length: { is: 12 }
  validates :phone_tail, presence: true, length: { is: 4 }

  def default_order
    self.last_changed_at  ||= Time.zone.now
    self.payment_status   ||= ''
    self.shipping_company ||= ''
    self.shipping_country ||= ''
    self.shipping_status  ||= ''
  end

  def delivered_in_days
    delivery = delivered_at.presence || estimated_delivery_at.presence
    if delivery.present? && order_time.present?
      (order_time - delivery).abs / 60 / 60 / 24
    else
      nil
    end
  end

  def delivery_status_class
    case delivery_status
    when 'delivered' then 'delivery-status-delivered'
    when 'pending' then 'delivery-status-pending'
    else
      'delivery-status-unknown'
    end
  end

  def masked_order_id
    order_id.present? ? "#{order_id.slice(0..-5)}****" : nil
  end

  def payment_status_class
    case payment_status
    when 'Pay Confirmed' then 'payment-status-pay-confirmed'
    when 'Pending' then 'payment-status-pending'
    else
      'payment-status-unknown'
    end
  end

  def pretty_shipping_company
    case shipping_company.downcase
    when 'tba' then 'Pending'
    when 'dhl' then 'DHL'
    when 'fedex' then 'FedEx'
    when 'sagawa' then 'Sagawa'
    else
      shipping_company.upcase
    end
  end

  def shipping_company_class
    valid_shipping_companies = %w[
      dhl fedex ups usps sagawa
    ]

    case shipping_company.downcase
    when 'tba' then 'shipping-company-pending'
    when *valid_shipping_companies then 'shipping-company-selected'
    else
      'shipping-company-unknown'
    end
  end

  def shipping_status_class
    case shipping_status.downcase.to_sym
    when :pending then 'shipping-status-pending'
    when :shipped then 'shipping-status-shipped'
    else
      'shipping-status-unknown'
    end
  end
end
