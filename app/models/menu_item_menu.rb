class MenuItemMenu < ApplicationRecord
  belongs_to :menu
  belongs_to :menu_item

  validates :menu_id, presence: true
  validates :menu_item_id, presence: true
end
