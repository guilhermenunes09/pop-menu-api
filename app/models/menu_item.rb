class MenuItem < ApplicationRecord
  belongs_to :menu

  validates :price, presence: true
end
