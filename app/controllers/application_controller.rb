class ApplicationController < ActionController::Base
  include SessionsHelper
  protect_from_forgery with: :exception
  before_action :set_locale
  def set_locale
    locale = params[:locale].to_s.strip.to_sym
    return I18n.locale = locale if I18n.available_locales.include?(locale)

    I18n.locale = I18n.default_locale
  end
end
