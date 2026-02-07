class ReviewsController < ApplicationController
  before_action :require_login

  def create
    @chat_room = ChatRoom.find(params[:chat_room_id])
    other_user = @chat_room.other_member(current_user)

    unless other_user
      redirect_to chat_room_path(@chat_room), alert: "ไม่สามารถรีวิวได้"
      return
    end

    @review = Review.new(
      reviewer: current_user,
      reviewee: other_user,
      chat_room: @chat_room,
      rating: params[:rating].to_i,
      comment: params[:comment]
    )

    if @review.save
      redirect_to chat_room_path(@chat_room), notice: "ให้คะแนนสำเร็จ! ⭐"
    else
      redirect_to chat_room_path(@chat_room), alert: @review.errors.full_messages.first || "ไม่สามารถให้คะแนนได้"
    end
  end
end
