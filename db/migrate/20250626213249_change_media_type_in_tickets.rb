class ChangeMediaTypeInTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :tickets, :media_array, :text, array: true, default: []

    remove_column :tickets, :media
    rename_column :tickets, :media_array, :media
  end
end
