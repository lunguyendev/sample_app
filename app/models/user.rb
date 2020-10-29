class User < ApplicationRecord
  attr_accessor :remember_token
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze
  before_save{self.email = email.downcase}

  validates :name, presence: true,
    length: {maximum: Settings.model_user.maximum_name.to_i}
  validates :email, presence: true,
    length: {maximum: Settings.model_user.maximum_email.to_i},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: true
  validates :password, presence: true,
    length: {minimum: Settings.model_user.minimum_password.to_i}

  has_secure_password

  # Create an encrypted password with bcrypt
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

  # Check: is re_digest in DB with re_token in cookie same ?
  def authenticated? remember_token
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  # Update key remember_digest in DB with value is nil
  def forget
    update_column :remember_digest, nil
  end
end
