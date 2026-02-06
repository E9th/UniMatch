class ProfilesController < ApplicationController
  before_action :require_login

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(profile_params)
      flash[:notice] = "อัปเดตโปรไฟล์สำเร็จ! ✅"
      redirect_to dashboard_path
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :faculty, :strong_subject, :weak_subject,
                                  :study_style, :available_time, :bio)
  end
end
