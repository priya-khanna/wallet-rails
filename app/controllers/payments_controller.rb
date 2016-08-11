require_dependency "app/services/payment_service"
class PaymentsController < ApplicationController
  def new
    @payment = Payment.new(amount: params[:amount], booking_id: params[:booking_id])
    @errors ||= []
  end

  def create
    @payment = Payment.new
    @errors = []
    if payment_service.update
      stat = payment_service.result
      if stat.amount_due > 0
        redirect_to new_payment_path(amount: stat.amount_due, booking_id: stat.booking_id), flash: { success: "You need to pay the outstanding amount of Rs. #{stat.amount_due} to confirm the booking." }
      else
        redirect_to booking_path(id: stat.booking_id)
      end
    else
      @errors = payment_service.errors
      render :new
    end
  end

  private

  def payment_service
    @_payment_service ||= PaymentService.new(nil, payment_params)
  end

  def payment_params
    params.permit(:amount, :wallet_amount, :wallet_mode, :online_amount, :online_mode, :giftcard_amount, :booking_id)
  end
end
