class AddTicketKeyToTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :tickets, :ticket_key, :text
  end
end
