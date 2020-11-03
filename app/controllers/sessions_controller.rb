class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # if user&.authenticate(params[:session][:password])
    if user.try(:authenticate, params[:session][:password])
      handle_activated user
    else
      flash.now[:danger] = t "message.login_fail"
      render :new
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_path
  end

  private

  def handle_remember user
    params[:session][:remember_me] == "1" ? remember(user) : forget(user)
  end

  def handle_activated user
    if user.activated?
      log_in user
      handle_remember user
      redirect_back_or user
    else
      flash[:warning] = t "message.not_actived"
      redirect_to root_path
    end
  end
end
