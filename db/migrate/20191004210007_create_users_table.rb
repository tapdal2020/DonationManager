class CreateUsersTable < ActiveRecord::Migration[6.0]
  def change
    create_table :users_tables do |t|
      # first name
      # last name
      # email
      # hashed password
      # street address l1
      # street address l2
      # city
      # state
      # zip
    end

    # primary keys: email
  end
end
