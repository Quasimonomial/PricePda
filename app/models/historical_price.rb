# == Schema Information
#
# Table name: historical_prices
#
#  id       :integer          not null, primary key
#  price_id :integer          not null
#  month    :integer
#  year     :integer
#  price    :decimal(7, 2)    not null
#

class HistoricalPrice < ActiveRecord::Base
  validates :price, :price_id, :month, :year, presence: true

  belongs_to :price
end
