class Payment < ActiveRecord::Base

  def self.modes
    %w(cc_avenue citrus mobiwik paytm giftcard)
  end

  belongs_to :booking
  validates :amount, presence: true
  validates :booking_id, presence: true

end
