class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.decimal :amount
      t.string :mode
      t.string :status
      t.integer :booking_id
      t.datetime :completed_at

      t.timestamps null: false
    end
    add_index :payments, :mode
    add_index :payments, :booking_id
    add_index :payments, :status
  end
end
