# == Schema Information
#
# Table name: companies
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#  enabled    :boolean          not null
#

class Company < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  has_many :prices, as: :pricer

  def self.build_name_hash
    companies = Company.all
    names_hash = Hash.new
    companies.each do |company|
      names_hash[company.name] = company.id
    end
    return names_hash
  end
end
