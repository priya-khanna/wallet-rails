class Booking < ActiveRecord::Base
  def self.states
    %w(initiated confirmed started ended)
  end

  validates :state, inclusion: { in: self.states }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :fee, presence: true, numericality: { greater_than: 0 }
  validates :security_deposit, presence: true, numericality: { greater_than_or_equal_to: 5000 }
  validates :refund_amount, numericality: { greater_than_or_equal_to: 0 }, allow_blank: true
  validates :refund_amount, presence: true, if: :ended?
  has_one :stat
  has_many :payments
  validate :validate_amount

  delegate :initiated?, :confirmed?, :started?, :ended?, to: :state_inquiry

  private

  def validate_amount
    booking_amount = self.security_deposit + self.fee
    booking_amount += self.other_charges.map{|k,v| v}.sum if self.other_charges
    return true if self.amount == booking_amount
    self.errors.add(:amount, "Invalid booking amount, verify and try again.")
    false
  end

  def state_inquiry
    self.state.to_s.inquiry
  end
end
