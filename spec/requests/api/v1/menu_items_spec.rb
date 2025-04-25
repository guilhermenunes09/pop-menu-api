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

  describe "GET /show" do
    context "when menu item exists" do
      it 'returns a specific menu item' do
        first_menu_item_id = menu_items.first.id

        get "/api/v1/menus/#{menu.id}/menu_items/#{first_menu_item_id}"

        expect(response).to have_http_status(:ok)
        menu_item = JSON.parse(response.body)

        expect(menu_item["id"]).to eq(first_menu_item_id)
      end
    end

    context "when menu item doesn't exist" do
      it 'returns a not found message' do
        first_menu_item_id = menu_items.first.id

        get "/api/v1/menus/#{menu.id}/menu_items/#{first_menu_item_id + 10}"
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to include("error" => "Menu Item Not Found")
      end
    end
  end

  describe "POST /create" do
    context "when params are valid" do
      it "creates a menu item" do
        first_menu_item_id = menu_items.first.id
        post "/api/v1/menus/#{menu.id}/menu_items", params: { menu_item: { name: "Name", price: 10 } }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(parsed_response['name']).to eq('Name')
      end
    end

    context "when params are not valid" do
      it "shows an error message" do
        post "/api/v1/menus/#{menu.id}/menu_items", params: { menu_item: { name: "Missing price" } }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(422)
        expect(parsed_response).to include("error" => "Not created")
      end
    end
  end
end
