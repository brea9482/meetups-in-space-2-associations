class Meetup < ActiveRecord::Base
  validates :name, presence: true
  validates :description, presence: true
  validates :location, presence: true
  has_many :connections
  has_many :users, through: :connections
end
