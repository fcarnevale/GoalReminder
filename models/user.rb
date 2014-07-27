require 'active_record'

class User < ActiveRecord::Base
  has_many :goals

  MOBILE_PHONE_REGEX = /\A\+\d{11}\z/
  validates_format_of :mobile_phone, with: MOBILE_PHONE_REGEX, on: :create

  def active_goals
    goals.where(active: true)
  end
end