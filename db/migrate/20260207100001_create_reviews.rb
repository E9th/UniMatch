class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :reviewer, null: false, foreign_key: { to_table: :users }
      t.references :reviewee, null: false, foreign_key: { to_table: :users }
      t.references :chat_room, null: false, foreign_key: true
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end

    add_index :reviews, [:reviewer_id, :chat_room_id], unique: true
  end
end
