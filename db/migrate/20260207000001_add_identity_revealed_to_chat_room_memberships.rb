class AddIdentityRevealedToChatRoomMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :chat_room_memberships, :identity_revealed, :boolean, default: false, null: false
  end
end
