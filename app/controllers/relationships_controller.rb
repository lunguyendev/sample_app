class RelationshipsController < ApplicationController
  before_action :logged_in_user
  before_action :load_relationship, only: :destroy
  def create
    @user = User.find_by(id: params[:followed_id])
    if @user
      handle_follow @user
    else
      flash[:warning] = t "message.find_user_fail"
      redirect_to root_path
    end
  end

  def destroy
    @user = @relationship.followed
    current_user.unfollow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  private

  def handle_follow user
    current_user.follow(user)
    respond_to do |format|
      format.html{redirect_to user}
      format.js
    end
  end

  def load_relationship
    @relationship = Relationship.find_by id: params[:id]
    return if @relationship

    flash[:danger] = t "message.find_relationship_fail"
    redirect_to root_path
  end
end
