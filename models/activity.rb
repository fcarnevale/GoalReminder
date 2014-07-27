require 'active_record'

class Activity < ActiveRecord::Base
  belongs_to :user
end