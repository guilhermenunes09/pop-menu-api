class Menu < ApplicationRecord
  belongs_to :restaurant

  has_many :menu_item_menus
  has_many :menu_items, through: :menu_item_menus

  validates :name, presence: true
end
