class CreateComments < ActiveRecord::Migration[8.0]
  def change
    create_table :comments do |t|
      t.text :content, null: false
      t.references :created_by, null: false, polymorphic: true, index: true
      t.references :ticket, null: false, foreign_key: true
      t.boolean :is_deleted, null: false, default: false

      t.timestamps
    end

    add_index :comments, [ :created_by_type, :created_by_id ]
  end
end
