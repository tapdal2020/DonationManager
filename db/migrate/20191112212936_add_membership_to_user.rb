class AddMembershipToUser < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :membership, :string, default: "None"
  end
end
