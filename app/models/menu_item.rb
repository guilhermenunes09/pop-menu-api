class MenuItem < ApplicationRecord
  belongs_to :restaurant
  has_many :menu_item_menus
  has_many :menus, through: :menu_item_menus

  validates :price, presence: true
  validates :restaurant_id, presence: true
  validates :name, presence: true, uniqueness: { scope: :restaurant_id }
end
