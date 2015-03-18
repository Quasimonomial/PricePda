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
    
    if month.to_i < 1 || month.to_i > 12
      self.month = self.created_at.month 
      self.save
    else
      self.month = month
    end
    
    if year.to_i > 0
      self.year = year  
    else
      self.year = self.created_at.year
    end
    
    self.save
  end

  def assign_month_and_year
    self.month = self.created_at.month
    self.year = self.created_at.year
    self.save
  end
end
