class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.decimal :fee
      t.decimal :security_deposit
      t.decimal :amount
      t.decimal :refund_amount, default: 0.0
      t.string :state
      t.json :other_charges

      t.timestamps null: false
    end
    add_index :bookings, :state
  end
end
