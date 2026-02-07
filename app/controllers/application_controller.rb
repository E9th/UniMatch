class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :logged_in?, :unread_chat_count

  # Online status ping endpoint
  def ping
    if logged_in?
      current_user.update_column(:last_seen_at, Time.current)
    end
    head :ok
  end

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    !!current_user
  end

  def require_login
    unless logged_in?
      flash[:alert] = "กรุณาเข้าสู่ระบบก่อน"
      redirect_to login_path
    end
  end

  def unread_chat_count
    return 0 unless logged_in?
    @unread_chat_count ||= begin
      count = 0
      current_user.chat_room_memberships.includes(chat_room: :messages).each do |membership|
        last_read = membership.last_read_at || membership.created_at
        unread = membership.chat_room.messages.where("created_at > ? AND (user_id != ? OR user_id IS NULL)", last_read, current_user.id).count
        count += unread
      end
      count
    end
  end
end
