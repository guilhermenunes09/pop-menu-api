class Restaurant < ApplicationRecord
  has_many :menus
  has_many :menu_items

  validates :name, presence: true
end
