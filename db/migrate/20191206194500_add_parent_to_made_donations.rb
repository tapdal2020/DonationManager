class AddParentToMadeDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :made_donations, :parent_txn, :string, default: ""
  end
end
