class DashboardController < ApplicationController
  before_action :require_login

  def show
    @user = current_user
    @matches = current_user.find_matches.limit(6)
    @chat_rooms = current_user.chat_rooms.includes(:messages).order(updated_at: :desc).limit(5)
  end
end
