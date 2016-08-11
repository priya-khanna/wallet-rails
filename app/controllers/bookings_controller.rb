require_dependency "app/services/booking_updater_service"
class BookingsController < ApplicationController

  def new
    @booking = Booking.new
  end

  def create
    amount = bparams[:fee] + bparams[:security_deposit]
    amount += bparams[:other_charges].values.sum unless bparams[:other_charges].blank?
    bparams.merge!(amount: amount)
    @booking = Booking.new(bparams)
    if @booking.save
      redirect_to new_payment_path(amount: @booking.amount, booking_id: @booking.id)
    else
      render :new
    end
  end

  def show
    @stat = Stat.find_by(booking_id: params[:id])
    @booking = Booking.find_by(id: params[:id])
    @payments = @booking.blank? ? [] : @booking.payments
  end

  def update
    @booking = Booking.find_by(id: params[:id])
    if booking_updater.update
      result = booking_updater.result
      flash_message = ''
      if result[:booking].state == 'ended'
        flash_message += result[:stat].amount_available > 0 ? "and ₹ #{result[:stat].amount_available.round} has been refunded to your wallet." : result[:stat].amount_due > 0 ? "and your amount due is #{result[:stat].amount_due.round} after security deposit refund" : "and your balance is cleared after security deposit refund"
      end
      redirect_to booking_path(id: result[:booking].id), flash: { success: "Your trip has #{result[:booking].state} #{flash_message}" }
    else
      redirect_to booking_path(id: @booking.id), flash: { errors: booking_updater.errors }
    end
  end

  private

  def bparams
    @_bparams ||= {
      fee: create_params[:fee].to_f,
      security_deposit: 5000,
      other_charges: create_params[:cleaning] == '1' ? { cleaning: 500 } : nil,
      state: 'initiated'
    }
  end

  def booking_updater
    @_booking_updater ||= BookingUpdaterService.new(nil, update_params)
  end

  def create_params
    @_create_params ||= params.permit(:fee, :cleaning)
  end

  def update_params
    @_update_params ||= params.permit(:id, :trigger)
  end
end
