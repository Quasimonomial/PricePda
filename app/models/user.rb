# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)
#  password_digest        :string(255)
#  session_token          :string(255)
#  price_range_percentage :integer
#  created_at             :datetime
#  updated_at             :datetime
#

class User < ActiveRecord::Base
  validates :email, :session_token, :password_digest, :first_name, :last_name, :hospital_name, :city, :state, :zip_code, presence: :true
  validates :email, :session_token, uniqueness: true
  validates :password, length: { minimum: 6, allow_nil: true }
  validates :price_range_percentage, :numericality => { :greater_than_or_equal_to => 0, less_than_or_equal_to: 100, allow_nil: true}

   after_initialize :ensure_session_token
  
  has_many :prices, as: :pricer

  attr_accessor :password

  def self.find_by_credentials(email, password)
    user = User.find_by_email(email)
    if user && user.valid_password?(password)
      return user
    end
    nil
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def valid_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def reset_token!
    self.session_token = SecureRandom.urlsafe_base64(16)
    self.save!
    self.session_token
  end

  private
  
  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64(16)
  end
end
