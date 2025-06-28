class AddIndexesToTickets < ActiveRecord::Migration[8.0]
  def change
     add_index :tickets, :assigned_to_id unless index_exists?(:tickets, :assigned_to_id)
    add_index :tickets, :status unless index_exists?(:tickets, :status)
  end
end
