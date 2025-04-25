require 'rails_helper'

RSpec.describe "Api::V1::MenuItems", type: :request do
  let!(:menu) { create(:menu) }
  let!(:menu_items) { create_list(:menu_item, 3, menu: menu) }

  describe "GET /index" do
    it 'returns a list of menu items' do
      puts menu.inspect
      puts menu_items.inspect
    end
  end
end
