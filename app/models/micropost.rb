class Micropost < ApplicationRecord
  belongs_to :user
  scope :created_at_desc, ->{order created_at: :desc}
  scope :compare_user_id, ->(id){where user_id: id}
  has_one_attached :image

  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.micropost.maximum}
  validates :image, content_type: {in: %i(gif png jpg jpeg),
                                   message: I18n.t("message.type_img")},
    size: {less_than: Settings.avt.size_img.megabytes,
           message: I18n.t("message.size_img")}

  def display_image
    image.variant resize_to_limit: [Settings.avt.resize_limit_width,
      Settings.avt.resize_limit_height]
  end
end
