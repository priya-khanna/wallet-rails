class WalletController < ApplicationController

  def show
    @stat = Stat.find_by(booking_id: params[:booking_id])
    @booking = Booking.find_by(id: params[:booking_id])
    @payments = @booking.blank? ? [] : @booking.payments
    @errors = []
  end

end