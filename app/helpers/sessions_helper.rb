module SessionsHelper
  def log_in user
    session[:user_id] = user.id
  end

  # Get valid user to check is logged_in ?
  def current_user
    if user_id = session[:user_id]
      @current_user ||= User.find_by(id: session[:user_id])
    elsif user_id = cookies.signed[:user_id]
      user = User.find_by id: user_id
      if user&.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end

  # Check user exist ?
  def logged_in?
    current_user.present?
  end

  # Create
  def remember user
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Create function delete everything in Cookies
  def forget user
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logout and return null with session and cookies
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end
