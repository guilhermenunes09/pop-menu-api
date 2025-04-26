require 'rails_helper'

RSpec.describe "Api::V1::Menus", type: :request do
  let!(:menus) { create_list(:menu, 3) }

  describe "GET /index" do
    it "returns a list of menus" do
      get '/api/v1/menus'

      expect(response).to have_http_status(:ok)
      parsed_menus = JSON.parse(response.body)

      expect(parsed_menus).to be_an(Array)
      expect(parsed_menus.size).to eq(3)
    end
  end

  describe "GET /show" do
    context "menu exists" do
      it "returns the selected menu" do
        first_menu_id = menus.first.id

        get "/api/v1/menus/#{first_menu_id}"

        expect(response).to have_http_status(:ok)
        menu = JSON.parse(response.body)

        expect(menu["id"]).to eq(first_menu_id)
      end
    end

    context "menu doesn't exist" do
      it "returns a not found message" do
        first_menu_id = menus.first.id
        get "/api/v1/menus/#{first_menu_id + 10}"
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to include("error" => "Menu Not Found")
      end
    end
  end

  describe "POST /create" do
    context 'when params are valid' do
      it 'creates a menu' do
        post '/api/v1/menus', params: { menu: { name: 'Name' } }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(parsed_response['name']).to eq('Name')
      end
    end

    context 'when params are not valid' do
      it 'shows an error message' do
        post '/api/v1/menus', params: { menu: { description: 'Missing Name' } }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(422)
        expect(parsed_response).to include("error" => "Not created")
      end
    end
  end

  describe "PUT /update" do
    context 'when menu exists' do
      it 'updates a menu' do
        first_menu_id = menus.first.id
        put "/api/v1/menus/#{first_menu_id}", params: { menu: { name: 'Name Updated' } }

        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response['name']).to eq('Name Updated')
      end
    end

    context "when menu doesn't exist" do
      it 'shows an error message' do
        first_menu_id = menus.first.id
        put "/api/v1/menus/#{first_menu_id + 10}", params: { menu: { name1: 'Name Updated' } }

        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to include("error" => "Menu Not Found")
      end
    end
  end

  describe "DELETE /destroy" do
    context 'when menu exists' do
      it 'deletes a menu' do
        first_menu_id = menus.first.id
        delete "/api/v1/menus/#{first_menu_id}"

        expect(Menu.exists?(first_menu_id)).to be false
      end
    end

    context "when menu doesn't exist" do
      it 'shows an error message' do
        first_menu_id = menus.first.id
        delete "/api/v1/menus/#{first_menu_id + 10}"

        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to include("error" => "Menu Not Found")
      end
    end
  end
end
