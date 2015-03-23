# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      not null
#  password_digest        :string(255)      not null
#  session_token          :string(255)
#  price_range_percentage :integer
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)      not null
#  last_name              :string(255)      not null
#  hospital_name          :string(255)      not null
#  city                   :string(255)      not null
#  state                  :string(255)      not null
#  zip_code               :string(255)      not null
#  phone                  :string(255)
#  comparison_company_id  :integer
#  is_admin               :boolean
#  permission_level       :integer
#  activation_digest      :string(255)
#  activated              :boolean          default(FALSE)
#

class User < ActiveRecord::Base
  validates :email, :session_token, :password_digest, :first_name, :last_name, :hospital_name, :city, :state, :zip_code, presence: :true
  validates :email, :session_token, uniqueness: true
  validates :password, length: { minimum: 6, allow_nil: true }
  validates :price_range_percentage, :numericality => { :greater_than_or_equal_to => 0, less_than_or_equal_to: 100, allow_nil: true}

  after_initialize :ensure_session_token
  before_create :create_activation_digest
  before_save   :downcase_email

  has_many :prices, as: :pricer

  attr_accessor :password, :activation_token, :reset_token

  def self.find_by_credentials(email, password)
    user = User.find_by_email(email)
    if user && user.valid_password?(password)
      return user
    end
    nil
  end

  def downcase_email
    self.email = email.downcase
  end

  def build_price_report_email_hash
    #Goal: an array of hashes
    product_hashes = []
    products = Product.all.order(:id)
    products.each do |product|
      user_price = product.prices.where({pricer_type: "User", pricer_id: self.id}).first.price
      competitor_price = product.prices.where({pricer_type: "Company", pricer_id: self.comparison_company_id}).first.price
      if (100.0 * (user_price - competitor_price)/user_price) >= self.price_range_percentage
        product_hash = Hash.new
        product_hash[:id] = product.id
        product_hash[:category] = product.category
        product_hash[:name] = product.name
        product_hash[:dosage] = product.dosage
        product_hash[:package] = product.package
        product_hash[:user_price] = user_price.to_f
        product_hash[:competitor_price] = competitor_price.to_f
        product_hashes << product_hash
      end
    end 
    product_hashes
  end

  def create_reset_digest
    self.reset_token = SecureRandom.urlsafe_base64(16)
    update_attribute(:reset_digest,  BCrypt::Password.create(self.reset_token))
    update_attribute(:reset_sent_at, Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end


  def jsonify_this
    json_user = Jsonify::Builder.new(:format => :pretty)
  #json_user.id self.id
    json_user.price_range_percentage self.price_range_percentage
    json_user.comparison_company_id  self.comparison_company_id
    json_user.is_admin  self.is_admin
    return json_user.compile!
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def reset_token!
    self.session_token = SecureRandom.urlsafe_base64(16)
    self.save!
    self.session_token
  end

  def valid_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end

  def valid_activation?(activation_token)
    return false if self.activation_digest.nil?
    BCrypt::Password.new(self.activation_digest).is_password?(activation_token)
  end

  def valid_reset(reset_token)
    return false if self.reset_digest.nil?
    BCrypt::Password.new(self.reset_digest).is_password?(reset_token)
  end
  
  # Returns true if a password reset has expired.
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

  def create_activation_digest
    # Create the token and digest
    self.activation_token = SecureRandom.urlsafe_base64(16)
    self.activation_digest = BCrypt::Password.create(activation_token)
  end
  
  def ensure_session_token
    self.session_token ||= SecureRandom.urlsafe_base64(16)
  end
end
