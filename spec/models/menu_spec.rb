require 'rails_helper'

RSpec.describe Menu, type: :model do
  describe "validations" do
    it "is valid with valid attributes" do
      menu = build(:menu, name: "Lunch Menu")
      expect(menu).to be_valid
    end

    it "is invalid without a name" do
      menu = build(:menu, name: nil)
      expect(menu).not_to be_valid
      expect(menu.errors[:name]).to include("can't be blank")
    end
  end

  describe "associations" do
    it "belongs to a restaurant" do
      restaurant = create(:restaurant)
      menu = create(:menu, restaurant:)
      expect(menu.restaurant).to eq(restaurant)
    end

    it "has many menu items through menu_item_menus" do
      restaurant = create(:restaurant)
      menu = create(:menu, restaurant: restaurant)
      menu_item1 = create(:menu_item, restaurant: restaurant)
      menu_item2 = create(:menu_item, restaurant: restaurant)

      menu.menu_items << menu_item1
      menu.menu_items << menu_item2

      expect(menu.menu_items).to include(menu_item1, menu_item2)
    end
  end
end
