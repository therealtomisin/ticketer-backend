class AddIsVerifiedToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :isVerified, :boolean, default: false
  end
end
