class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  has_many :active_relationships, class_name: Relationship.name,
    foreign_key: :follower_id, dependent: :destroy
  has_many :passive_relationships, class_name: Relationship.name,
    foreign_key: :followed_id, dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed
  has_many :followers, through: :passive_relationships, source: :follower

  attr_accessor :remember_token, :activation_token, :reset_token
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze

  before_save :downcase_email
  before_create :create_activation_digest

  validates :name, presence: true,
    length: {maximum: Settings.model_user.maximum_name.to_i}
  validates :email, presence: true,
    length: {maximum: Settings.model_user.maximum_email.to_i},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: true
  validates :password, presence: true,
    length: {minimum: Settings.model_user.minimum_password.to_i},
    allow_nil: true

  has_secure_password

  # encrypted string with bcrypt
  def self.digest string
    cost = if ActiveModel::SecurePassword.min_cost
             BCrypt::Engine::MIN_COST
           else
             BCrypt::Engine.cost
           end
    BCrypt::Password.create string, cost: cost
  end

  # Create code re_token
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  # Save re_token to DB
  def remember
    self.remember_token = User.new_token
    update_column :remember_digest, User.digest(remember_token)
  end

  # Update key remember_digest in DB with value is nil
  def forget
    update_column :remember_digest, nil
  end

  # Converts email to all lower-case
  def downcase_email
    email.downcase!
  end

  # Creates and assigns the activation token and digest.
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(activation_token)
  end

  # Returns true if the given token matches the digest.
  def authenticated? attribute, token
    digest = send "#{attribute}_digest"
    return false if digest.nil?

    BCrypt::Password.new(digest).is_password? token
  end

  # Activates an account.
  def activate
    update_columns activated: true, activated_at: Time.zone.now
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Create reset pass token and save db
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns reset_digest: User.digest(reset_token),
                   reset_sent_at: Time.zone.now
  end

  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < Settings.model_user.time_life_token.hours.ago
  end

  def feed
    Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
  end

  # Follows a user.
  def follow other_user
    following << other_user
  end

  # Unfollows a user.
  def unfollow other_user
    following.delete other_user
  end

  # Returns if the current user is following the other_user or not
  def following? other_user
    following.include? other_user
  end
end
