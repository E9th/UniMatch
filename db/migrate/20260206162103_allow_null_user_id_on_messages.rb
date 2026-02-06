class AllowNullUserIdOnMessages < ActiveRecord::Migration[8.1]
  def change
    change_column_null :messages, :user_id, true
    # Also remove the foreign key constraint and re-add it without NOT NULL
    # so that AI messages (user: nil) can be saved
  end
end
