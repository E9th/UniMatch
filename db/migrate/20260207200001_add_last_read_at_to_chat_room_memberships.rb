class AddLastReadAtToChatRoomMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :chat_room_memberships, :last_read_at, :datetime
  end
end
