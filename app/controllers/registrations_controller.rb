class RegistrationsController < ApplicationController
  def new
    redirect_to dashboard_path if logged_in?
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.email = @user.email&.downcase

    if @user.save
      session[:user_id] = @user.id
      flash[:notice] = "สมัครสมาชิกสำเร็จ! ยินดีต้อนรับสู่ UniMatch 🎓"
      redirect_to edit_profile_path
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :name)
  end
end
