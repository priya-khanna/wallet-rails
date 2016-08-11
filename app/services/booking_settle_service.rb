require_dependency "base_service"

class BookingSettleService < BaseService
   validates :booking, presence: true
   validates :stat, presence: { message: "We haven't received any payment, add money to wallet to continue." }
   validate :validate_misc_charges
   validate :validate_booking_state

  def update_without_transaction
    valid? &&
    update_booking &&
    update_stats &&
    (@result = booking)
  end

  private

  def update_booking
    booking.assign_attributes(booking_params)
    booking.save || merge_errors_from(booking)
  end

  def update_stats
    stat.assign_attributes(stat_params)
    stat.save || merge_errors_from(stat)
  end

  def booking_params
    other_charges = {}; remove_amount = 0
    if booking.other_charges
      remove_charges = params.select{|k,v| k.starts_with?('rem_') && v == '1'}.keys.map{|item| item.gsub('rem_', '')}
      other_charges = booking.other_charges.reject{|k| remove_charges.include?(k)}
      remove_amount = booking.other_charges.select{|k,_| remove_charges.include?(k)}.values.sum
    end
    add_charges = Hash[params.select{|k,v| !v.blank? && k.starts_with?('add_')}.map{|k,v| [k.gsub('add_',''), v.to_f]}]
    add_charges.merge!(params[:misc_desc] => params[:misc_charges].to_f) if params[:misc_charges].to_f > 0
    other_charges.merge!(add_charges)
    add_amount = add_charges.map{|k,v| v}.sum
    {
      amount: booking.amount - remove_amount + add_amount,
      other_charges: other_charges
    }
  end

  def stat_params
    diff_amount = booking.amount - stat.paid_amount
    {
      booking_amount: booking.amount,
      amount_due: diff_amount >= 0 ? diff_amount : 0,
      amount_available: diff_amount < 0 ? -(diff_amount) : 0
    }
  end

  def booking
    @_booking ||= Booking.find_by(id: params[:booking_id])
  end

  def stat
    @_stat ||= Stat.find_by(booking_id: booking.id) || Stat.new(booking_id: booking.id)
  end

  def validate_misc_charges
    if params[:misc_desc].blank? && !params[:misc_charges].blank?
      self.errors.add("Misc charges description is mandatory to add misc charges")
      false
    end
    true
  end

  def validate_booking_state
    return true if booking.state != 'ended'
    self.errors.add(:base, "The trip has ended, booking cannot be updated.")
    false
  end
end
