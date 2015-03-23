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
#  reset_digest           :string(255)
#  reset_sent_at          :datetime
#  abbreviation           :string(255)
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
