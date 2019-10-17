class CreateMadeDonations < ActiveRecord::Migration[6.0]
  def change
    create_table :made_donations do |t|
      t.belongs_to :user
      t.string :payment_id, null: false
      t.decimal :price, precision: 6, scale: 2, default: 0.00
      t.string :payer_id
      t.string :token
      t.timestamps
    end
  end
end
