require 'rails_helper'

RSpec.describe Restaurant, type: :model do
  describe "associations" do
    it "has many menus" do
      restaurant = create(:restaurant)
      menu1 = create(:menu, restaurant: restaurant)
      menu2 = create(:menu, restaurant: restaurant)

      expect(restaurant.menus).to include(menu1, menu2)
    end

    it "has many menu items" do
      restaurant = create(:restaurant)
      menu_item1 = create(:menu_item, restaurant: restaurant)
      menu_item2 = create(:menu_item, restaurant: restaurant)

      expect(restaurant.menu_items).to include(menu_item1, menu_item2)
    end
  end

  describe "dependent destroy" do
    it "destroys associated menus when the restaurant is destroyed" do
      restaurant = create(:restaurant)
      menu = create(:menu, restaurant: restaurant)

      expect { restaurant.destroy }.to change(Menu, :count).by(-1)
    end

    it "destroys associated menu items when the restaurant is destroyed" do
      restaurant = create(:restaurant)
      menu_item = create(:menu_item, restaurant: restaurant)

      expect { restaurant.destroy }.to change(MenuItem, :count).by(-1)
    end
  end

  describe "validations" do
    let(:restaurant) { build(:restaurant) }

    it "is valid with a name" do
      restaurant.name = "Tasty Bites"
      expect(restaurant).to be_valid
    end

    it "is invalid without a name" do
      restaurant.name = nil
      expect(restaurant).not_to be_valid
      expect(restaurant.errors[:name]).to include("can't be blank")
    end

    context "when name is too long" do
      it "is invalid with more than 100 characters" do
        restaurant.name = "a" * 300
        expect(restaurant).not_to be_valid
        expect(restaurant.errors[:name]).to include("is too long (maximum is 200 characters)")
      end
    end

    context "when name is at maximum length" do
      it "is valid with exactly 200 characters" do
        restaurant.name = "a" * 100
        expect(restaurant).to be_valid
      end
    end
  end
end
