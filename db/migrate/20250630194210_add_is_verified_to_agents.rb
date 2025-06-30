class AddIsVerifiedToAgents < ActiveRecord::Migration[8.0]
  def change
    add_column :agents, :isVerified, :boolean, default: false
  end
end
