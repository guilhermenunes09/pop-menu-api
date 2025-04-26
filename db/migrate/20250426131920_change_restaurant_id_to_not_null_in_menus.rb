class ChangeRestaurantIdToNotNullInMenus < ActiveRecord::Migration[8.0]
  def change
    change_column_null :menus, :restaurant_id, false
  end
end
