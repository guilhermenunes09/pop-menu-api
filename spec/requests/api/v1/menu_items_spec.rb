require 'rails_helper'

RSpec.describe "Api::V1::MenuItems", type: :request do
  let!(:menu) { create(:menu) }
  let!(:menu_items) { create_list(:menu_item, 3, menu: menu) }

  describe "GET /index" do
    it 'returns a list of menu items' do
      get "/api/v1/menus/#{menu.id}/menu_items"

      expect(response).to have_http_status(:ok)
      parsed_menus = JSON.parse(response.body)

      expect(parsed_menus).to be_an(Array)
      expect(parsed_menus.size).to eq(3)
    end
  end
end
