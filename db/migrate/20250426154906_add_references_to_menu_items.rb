class AddReferencesToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_reference :menu_items, :restaurant, null: true, foreign_key: true
  end
end
