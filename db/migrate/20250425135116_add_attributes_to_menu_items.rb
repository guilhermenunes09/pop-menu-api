class AddAttributesToMenuItems < ActiveRecord::Migration[8.0]
  def change
    add_column :menu_items, :name, :string, null: false
    add_column :menu_items, :price, :decimal, null: false, precision: 10, scale: 2
    add_column :menu_items, :description, :text
    add_column :menu_items, :active, :boolean, default: true
  end
end
