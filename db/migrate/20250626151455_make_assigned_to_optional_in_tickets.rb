class MakeAssignedToOptionalInTickets < ActiveRecord::Migration[8.0]
  def change
    # Remove the NOT NULL constraint
    change_column_null :tickets, :assigned_to_id, true

    # Drop and recreate the foreign key to make it optional
    remove_foreign_key :tickets, :agents
    add_foreign_key :tickets, :agents, column: :assigned_to_id, on_delete: :nullify
  end
end
