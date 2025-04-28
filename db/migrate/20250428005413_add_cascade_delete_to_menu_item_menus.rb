class AddCascadeDeleteToMenuItemMenus < ActiveRecord::Migration[8.0]
  def change
    remove_foreign_key :menu_item_menus, :menus
    remove_foreign_key :menu_item_menus, :menu_items

    add_foreign_key :menu_item_menus, :menus, on_delete: :cascade
    add_foreign_key :menu_item_menus, :menu_items, on_delete: :cascade
  end
end
