class Stat < ActiveRecord::Base
  validates :booking_id, presence: true, uniqueness: true
  validate :validate_booking_amount

  belongs_to :booking
  private

  def validate_booking_amount
    return true if self.booking && self.booking_amount == self.booking.amount
    self.errors.add(:base, "Booking amount doesn't match the actual amount")
  end
end
