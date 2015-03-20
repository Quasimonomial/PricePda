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
#  first_name             :string(255)
#  last_name              :string(255)
#  hospital_name          :string(255)
#  city                   :string(255)
#  state                  :string(255)
#  zip_code               :string(255)
#  phone                  :string(255)
#  comparison_company_id  :integer
#  is_admin               :boolean
#

class User < ActiveRecord::Base
  validates :email, :session_token, :password_digest, :first_name, :last_name, :hospital_name, :city, :state, :zip_code, presence: :true
  validates :email, :session_token, uniqueness: true
  validates :password, length: { minimum: 6, allow_nil: true }
  validates :price_range_percentage, :numericality => { :greater_than_or_equal_to => 0, less_than_or_equal_to: 100, allow_nil: true}

  after_initialize :ensure_session_token
  before_create :create_activation_digest

  has_many :prices, as: :pricer

  attr_accessor :password

  def self.find_by_credentials(email, password)
    user = User.find_by_email(email)
    if user && user.valid_password?(password)
      return user
    end
    nil
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
