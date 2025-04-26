class AddAttributesToMenus < ActiveRecord::Migration[8.0]
  def change
    add_column :menus, :name, :string
    add_column :menus, :description, :string
    add_column :menus, :active, :boolean, default: true
  end
end
