class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if logged_in?
  end

  def create
    user = User.find_by(email: params[:email]&.downcase)

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "ยินดีต้อนรับกลับมา #{user.name}! 🎉"
      redirect_to dashboard_path
    else
      flash.now[:alert] = "อีเมลหรือรหัสผ่านไม่ถูกต้อง"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "ออกจากระบบเรียบร้อยแล้ว 👋"
    redirect_to root_path
  end
end
