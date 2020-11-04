class PasswordResetsController < ApplicationController
  before_action :get_user, :valid_user, :check_expiration, only: %i(edit update)

  def new; end

  def create
    @user = User.find_by email: params[:password_reset][:email]
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = t "email.password.sendmail_succ"
      redirect_to root_path
    else
      flash.now[:danger] = t "email.password.sendmail_fail"
      render :new
    end
  end

  def edit; end

  def update
    if params[:user][:password].blank?
      @user.errors.add :password, t("message.input_blank")
      render :edit
    elsif @user.update user_params
      log_in @user
      flash[:success] = t "message.update_pass_succ"
      redirect_to @user
    else
      render :edit
    end
  end

  private

  def get_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t "message.show_user_warning"
    redirect_to root_path
  end

  def valid_user
    return unless @user.activated? && @user.authenticated?(:reset, params[:id])

    redirect_to root_path
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t "message.expired"
    redirect_to new_password_reset_path
  end
end
