require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @somchai = users(:somchai)
    @somying = users(:somying)
    @kitti = users(:kitti)
    @human_room = chat_rooms(:human_room)
    @ai_room = chat_rooms(:ai_room)
  end

  test "create review requires login" do
    post chat_room_reviews_path(@human_room), params: { rating: 5 }
    assert_redirected_to login_path
  end

  test "create review for peer chat" do
    sign_in_as(@somchai)

    assert_difference("Review.count", 1) do
      post chat_room_reviews_path(@human_room), params: { rating: 5, comment: "สอนเก่งมาก!" }
    end
    assert_redirected_to chat_room_path(@human_room)

    review = Review.last
    assert_equal @somchai, review.reviewer
    assert_equal @somying, review.reviewee
    assert_equal 5, review.rating
    assert_equal "สอนเก่งมาก!", review.comment
  end

  test "cannot review twice in same room" do
    sign_in_as(@somchai)

    post chat_room_reviews_path(@human_room), params: { rating: 5 }
    assert_difference("Review.count", 0) do
      post chat_room_reviews_path(@human_room), params: { rating: 4 }
    end
    assert_redirected_to chat_room_path(@human_room)
  end

  test "cannot review in AI room" do
    sign_in_as(@somchai)

    assert_no_difference("Review.count") do
      post chat_room_reviews_path(@ai_room), params: { rating: 5 }
    end
  end
end
