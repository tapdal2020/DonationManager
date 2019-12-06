class AddFrequencyToMadeDonations < ActiveRecord::Migration[6.0]
  def change
    add_column :made_donations, :frequency, :string
  end
end
