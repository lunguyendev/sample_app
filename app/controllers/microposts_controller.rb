class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(index destroy create)
  before_action :correct_user, only: :destroy

  def index
    @micropost = current_user.microposts.build
    @feed_items = current_user.feed.paginate page: params[:page],
      per_page: Settings.page.per_page
    render "static_pages/home"
  end

  def create
    @micropost = current_user.microposts.build micropost_params
    @micropost.image.attach micropost_params[:image]
    handle_save_post
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t "micropost.mess.delete_succ"
      redirect_to request.referer || root_url
    else
      flash[:success] = t "micropost.mess.delete_fail"
      redirect_to root_url
    end
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end

  def correct_user
    @micropost = current_user.microposts.find_by id: params[:id]
    return if @micropost

    flash[:waring] = t "micropost.mess.no_post"
    redirect_to root_surl
  end

  def handle_save_post
    if @micropost.save
      flash[:success] = t "micropost.mess.create_succ"
      redirect_to root_url
    else
      @feed_items = current_user.feed.paginate page: params[:page],
        per_page: Settings.page.per_page
      render "static_pages/home"
    end
  end
end
