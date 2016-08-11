require_dependency "base_service"

class PaymentService < BaseService
  validates :amount, presence: true
  validates :booking, presence: true
  validate :validate_amount
  validate :validate_pay_form

  def update_without_transaction
    valid? &&
    create_wallet_payment &&
    create_online_payment &&
    create_giftcard_payment &&
    update_stats &&
    confirm_booking &&
    (@result = stat)
  end

  attr_reader :result

  private
  attr_reader :user, :params, :opts
  attr_writer :result

  def amount; params[:amount] ? params[:amount].to_f : 0; end
  def wallet_amount; params[:wallet_amount] ? params[:wallet_amount].to_f : 0; end
  def online_amount; params[:online_amount] ? params[:online_amount].to_f : 0; end
  def giftcard_amount; params[:giftcard_amount] ? params[:giftcard_amount].to_f : 0; end

  def create_wallet_payment
    return true unless wallet?
    payment = Payment.new(amount: wallet_amount, mode: params[:wallet_mode], completed_at: Time.zone.now, booking_id: booking.id)
    payment.save || merge_errors_from(payment)
  end

  def create_online_payment
    return true unless online?
    payment = Payment.new(amount: online_amount, mode: params[:online_mode], completed_at: Time.zone.now, booking_id: booking.id)
    payment.save || merge_errors_from(payment)
  end

  def create_giftcard_payment
    return true unless giftcard?
    payment = Payment.new(amount: giftcard_amount, mode: 'giftcard', completed_at: Time.zone.now, booking_id: booking.id)
    payment.save || merge_errors_from(payment)
  end

  def update_stats
    stat.assign_attributes(stat_params)
    stat.save || merge_errors_from(stat)
  end

  def confirm_booking
    return true if stat.amount_due > 0
    booking.update_attributes(state: 'confirmed') || merge_errors_from(booking)
  end

  def stat
    @_stat ||= Stat.find_by(booking_id: booking.id) || Stat.new
  end

  def stat_params
    { booking_id: booking.id, booking_amount: booking.amount,
      paid_amount: paid_amount,
      amount_available: diff_amount <= 0 ? -diff_amount : 0,
      amount_due: diff_amount > 0 ? diff_amount : 0 }
  end

  def paid_amount
    @_paid_amount ||= booking.payments.where.not(completed_at: nil).pluck(:amount).sum
  end

  def diff_amount
    @_diff_amount ||= booking.amount - paid_amount
  end

  def payment
    Payment.new(payment_params)
  end

  def booking
    @_booking ||= Booking.find_by(id: params[:booking_id])
  end

  def payment_params_for(mode)
    { amount: payment_amount, mode: payment_mode, completed_at: Time.zone.now }
  end

  def payment_for(mode)
    Payment.new(params_for())
  end

  def wallet?
    return true if wallet_amount > 0
    false
  end

  def online?
    return true if online_amount > 0
    false
  end

  def giftcard?
    return true if giftcard_amount > 0
    false
  end

  def validate_amount
    return true if amount == (wallet_amount + online_amount + giftcard_amount)
    self.errors.add(:base, "Payment amount doesnt match the individual payment entries")
    false
  end

  def validate_pay_form
    if params[:wallet_amount] && params[:wallet_amount].to_i > 0
      self.errors.add(:base, "Wallet mode should be selected to make payment via wallet") if params[:wallet_mode].blank?
    end
    if params[:online_amount] && params[:online_amount].to_i > 0
      self.errors.add(:base, "Online payment mode should be selected to make online payment") if params[:online_mode].blank?
    end
    return true if self.errors.blank?
    false
  end
end