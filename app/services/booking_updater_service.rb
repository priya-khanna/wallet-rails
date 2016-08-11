require_dependency "base_service"
class BookingUpdaterService < BaseService
  validates :booking, presence: true
  validates :stat, presence: { message: "We haven't received any payment, add money to wallet to continue." }
  validates :trigger, inclusion: { :in => %w(start end), message: "Invalid trigger %{value}."}
  validate :validate_booking_settled

  def update_without_transaction
    valid? &&
    update_booking &&
    refund_deposit &&
    (@result = { booking: booking, stat: stat })
  end

  private

  def trigger; params[:trigger]; end

  def update_booking
    bparams = { state: "#{trigger}ed" }
    bparams.merge!(refund_amount: 5000) if trigger == 'end'
    booking.update_attributes(bparams) || merge_errors_from(booking)
  end

  def refund_deposit
    return true unless trigger == 'end'
    stat.update_attributes(stat_params) || merge_errors_from(stat)
  end

  def stat_params
    diff_amount = stat.booking_amount - stat.paid_amount - booking.refund_amount
    {
      amount_available: diff_amount <= 0 ? -diff_amount : 0,
      amount_due: diff_amount > 0 ? diff_amount : 0
    }
  end

  def booking
    @_booking ||= Booking.find_by(id: params[:id])
  end

  def stat
    @_stat ||= Stat.find_by(booking_id: booking.id) || Stat.new(booking_id: booking.id)
  end

  def validate_booking_settled
    return true if trigger == 'end'
    return true if stat.amount_due <= 0
    self.errors.add(:payment, "Please settle the payment to proceed. User has outstanding amount of ₹ #{stat.amount_due}")
    return false
  end
end