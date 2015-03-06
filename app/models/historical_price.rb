# == Schema Information
#
# Table name: historical_prices
#
#  id          :integer          not null, primary key
#  price_id    :integer          not null
#  month       :integer
#  year        :integer
#  price_value :decimal(7, 2)    not null
#  created_at  :datetime
#  updated_at  :datetime
#

class HistoricalPrice < ActiveRecord::Base
  validates :price_value, :price_id, presence: true
  
  belongs_to :price

  def assign_custom_month_and_year month, year
    self.month = self.created_at.month || month
    self.year = self.created_at.year || year
    self.save
  end

  def assign_month_and_year
    self.month = self.created_at.month
    self.year = self.created_at.year
    self.save
  end
end
