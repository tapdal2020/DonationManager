class AddRecurringBooleanToMadeDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :made_donations, :recurring, :boolean, default: false
  end
end
