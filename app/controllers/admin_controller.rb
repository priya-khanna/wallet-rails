class AdminController < ApplicationController

  def show
    if params[:booking_id]
      @booking = Booking.find_by(id: params[:booking_id])
      @add_charges = Hash[add_charge_options.map{|item| ["add_#{item}", item.humanize]}]
      @revert_charges = []
      @revert_charges = Hash[@booking.other_charges.map{|k,v| ["rem_#{k}", "#{k.humanize} - ₹ #{v.round}"]}] unless @booking.other_charges.blank?
    else
      @bookings = Booking.all.order(created_at: :desc).map{ |item| decorate_booking(item) }
    end
  end

  def settle
    if booking_service.update
      redirect_to booking_path(id: booking_service.result.id), flash: { success: "Booking successfully updated!" }
    else
      redirect_to admin_path, flash: { errors: booking_service.errors }
    end
  end

  private

  def booking_service
    @_booking_service ||= ::BookingSettleService.new(nil, params)
  end

  def decorate_booking(booking)
    {
      id: booking.id,
      amount: booking.amount.round,
      state: booking.state,
      booked_at: booking.created_at.strftime("%d %b %y %I:%M %P"),
    }
  end

  def add_charge_options
    %w(cleaning extension_fee late_fee damage_fee) - (@booking.other_charges || {}).keys
  end

end