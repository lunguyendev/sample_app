class UsersController < ApplicationController
  before_action :logged_in_user, except: %i(new index create)
  before_action :load_user, except: %i(index new create)
  before_action :correct_user, only: %i(edit update)
  before_action :admin_user, only: :destroy

  def index
    @users = User.paginate page: params[:page], per_page: Settings.page.per_page
  end

  def show
    @microposts = @user.microposts.paginate page: params[:page],
     per_page: Settings.page.per_page
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = t "message.check_email"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update(user_params)
      flash[:success] = t "message.update_profile_success"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "message.user_delete"
    else
      flash[:warning] = t "message.user_delete_fail"
    end
    redirect_to users_path
  end

  def following
    @title = "Following"
    @user = User.find_by(id: params[:id])
    @users = @user.following.paginate page: params[:page],
      per_page: Settings.page.per_page
    render "show_follow"
  end

  def followers
    @title = "Followers"
    @user = User.find_by(id: params[:id])
    @users = @user.followers.paginate page: params[:page],
      per_page: Settings.page.per_page
    render "show_follow"
  end
  private

  def user_params
    params.require(:user)
          .permit(:name, :email, :password, :password_confirmation)
  end

  def correct_user
    redirect_to edit_user_path(current_user) unless current_user? @user
  end

  def load_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:warning] = t "message.show_user_warning"
    redirect_to root_path
  end

  def admin_user
    redirect_to root_path unless current_admin?
  end
end
