class AddAddressToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :street_address_line_1, :string
    add_column :users, :street_address_line_2, :string
    add_column :users, :city, :string
    add_column :users, :state, :string
    add_column :users, :zip_code, :string
  end
end
