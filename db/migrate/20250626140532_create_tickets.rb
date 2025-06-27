class CreateTickets < ActiveRecord::Migration[8.0]
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.references :created_by, null: false, foreign_key: { to_table: :users }, index: true
      t.references :assigned_to, null: false, foreign_key: { to_table: :agents }, index: true
      t.text :media
      t.datetime :deadline
      t.string :status, null: false, default: 'ACTIVE'
      t.boolean :has_user_deleted, null: false, default: false

      t.timestamps
    end

    add_index :tickets, :status
    add_index :tickets, :deadline
  end
end
