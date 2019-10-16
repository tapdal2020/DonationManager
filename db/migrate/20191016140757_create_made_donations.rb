class CreateMadeDonations < ActiveRecord::Migration[6.0]
  def change
    create_table :made_donations do |t|
      t.string :donor_email
      t.string :payment_id, null: false
      t.decimal :price, precision: 6, scale: 2, default: 0.00
      t.timestamps
    end
  end
end
