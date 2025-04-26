require 'rails_helper'

RSpec.describe MenuItem, type: :model do
  let!(:restaurant) { create(:restaurant) }
  let!(:menu) { create(:menu, restaurant:) }

  describe "validations" do
    it "is valid with valid attributes" do
      menu_item = create(:menu_item, restaurant:)
      expect(menu_item).to be_valid
    end

    it "is invalid without a name" do
      menu_item = create(:menu_item, restaurant:)
      menu_item.name = nil
      expect(menu_item).not_to be_valid
    end
  end
end
