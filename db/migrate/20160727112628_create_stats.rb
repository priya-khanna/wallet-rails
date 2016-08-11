class CreateStats < ActiveRecord::Migration
  def change
    create_table :stats do |t|
      t.decimal :booking_amount, default: 0.0
      t.integer :booking_id
      t.decimal :paid_amount, default: 0.0
      t.decimal :amount_available, default: 0.0
      t.decimal :amount_due, default: 0.0
      t.timestamps null: false
    end
    add_index :stats, :booking_id
  end
end
