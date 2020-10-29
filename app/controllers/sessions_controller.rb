class SessionsController < ApplicationController
  def new; end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    # if user&.authenticate(params[:session][:password])
    if user.try(:authenticate, params[:session][:password])
      log_in user
      handle_remember user
      redirect_to user
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
end
