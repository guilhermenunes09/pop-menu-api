class AddCascadeDeleteToRestaurantAssociations < ActiveRecord::Migration[8.0]
  def up
    remove_foreign_key :menus, :restaurants
    remove_foreign_key :menu_items, :restaurants

    add_foreign_key :menus, :restaurants, on_delete: :cascade
    add_foreign_key :menu_items, :restaurants, on_delete: :cascade
  end

  def down
    remove_foreign_key :menus, :restaurants
    remove_foreign_key :menu_items, :restaurants

    add_foreign_key :menus, :restaurants
    add_foreign_key :menu_items, :restaurants
  end
end
