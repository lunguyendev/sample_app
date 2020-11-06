module UsersHelper
  def gravatar_for user, options = {size: Settings.avt.default_size}
    gravatar_id = Digest::MD5.hexdigest user.email.downcase
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag gravatar_url, alt: user.name, class: "gravatar"
  end

  def check_admin user
    return unless current_user.admin? && !current_user?(user)

    link_to t("users.delete"), user, method: :delete,
      data: {confirm: t("message.confirm_detele")}
  end

  def find_relationships_current_user
    current_user.active_relationships.find_by(followed_id: @user.id)
  end
end
