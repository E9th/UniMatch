class CreateChatRooms < ActiveRecord::Migration[8.1]
  def change
    create_table :chat_rooms do |t|
      t.string :name
      t.boolean :is_ai_mode
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
