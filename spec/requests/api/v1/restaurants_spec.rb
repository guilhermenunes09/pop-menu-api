require 'rails_helper'

RSpec.describe "Api::V1::Restaurants", type: :request do
  let!(:restaurants) { create_list(:restaurant, 3) }

  describe "GET /index" do
    it "returns a list of restaurants" do
      get "/api/v1/restaurants"

      expect(response).to have_http_status(:ok)
      parsed_restaurants = JSON.parse(response.body)

      expect(parsed_restaurants).to be_an(Array)
      expect(parsed_restaurants.size).to eq(3)
    end
  end

  describe "GET /show" do
    context "restaurant exists" do
      it "returns the selected restaurant" do
        first_restaurant_id = restaurants.first.id
        get "/api/v1/restaurants/#{first_restaurant_id}"

        expect(response).to have_http_status(:ok)
        restaurant = JSON.parse(response.body)

        expect(restaurant["id"]).to eq(first_restaurant_id)
      end
    end

    context "restaurant doesn't exist" do
      it "returns a not found message" do
        first_restaurant_id = restaurants.first.id
        get "/api/v1/restaurants/#{first_restaurant_id + 100}"

        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to include("error" => "Restaurant Not Found")
      end
    end
  end

  describe "POST /create" do
    context 'when params are valid' do
      it 'creates a restaurant' do
        post "/api/v1/restaurants", params: { restaurant: { name: 'Name' } }
        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(:created)
        expect(parsed_response['name']).to eq('Name')
      end
    end

    context 'when params are not valid' do
      it 'shows an error message' do
        post "/api/v1/restaurants", params: { restaurant: { description: 'Missing Name' } }

        parsed_response = JSON.parse(response.body)

        expect(response).to have_http_status(422)
        expect(parsed_response).to include("error" => "Not created")
      end
    end
  end

  describe "PUT /update" do
    context 'when restaurant exists' do
      it 'updates a restaurant' do
        first_restaurant_id = restaurants.first.id
        put "/api/v1/restaurants/#{first_restaurant_id}", params: { restaurant: { name: 'Name Updated' } }

        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:ok)
        expect(parsed_response['name']).to eq('Name Updated')
      end
    end

    context "when restaurant doesn't exist" do
      it 'shows an error message' do
        first_restaurant_id = restaurants.first.id
        put "/api/v1/restaurants/#{first_restaurant_id + 100}", params: { restaurant: { name: 'Name Updated' } }

        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to include("error" => "Restaurant Not Found")
      end
    end
  end

  describe "DELETE /destroy" do
    context 'when restaurant exists' do
      it 'deletes a restaurant' do
        first_restaurant_id = restaurants.first.id
        delete "/api/v1/restaurants/#{first_restaurant_id}"

        expect(Restaurant.exists?(first_restaurant_id)).to be false
      end
    end

    context "when restaurant doesn't exist" do
      it 'shows an error message' do
        first_restaurant_id = restaurants.first.id
        delete "/api/v1/restaurants/#{first_restaurant_id + 100}"

        parsed_response = JSON.parse(response.body)
        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to include("error" => "Restaurant Not Found")
      end
    end
  end

  describe "POST /import_json" do
    let(:valid_json_file) do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'valid_restaurant_data.json'),
        'application/json'
      )
    end

    let(:invalid_json_file) do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'fixtures', 'invalid_restaurant_data.json'),
        'application/json'
      )
    end

    context "with valid JSON file" do
      it "imports data successfully and returns the result" do
        post "/api/v1/restaurants/import_json", params: { file: valid_json_file }

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)

        expect(parsed_response["import_result"]["success"]).to be true
      end
    end

    context "with invalid JSON file" do
      it "returns errors and logs failure messages" do
        post "/api/v1/restaurants/import_json", params: { file: invalid_json_file }

        expect(response).to have_http_status(:ok)
        parsed_response = JSON.parse(response.body)

        expect(parsed_response["import_result"]["success"]).to be false
      end
    end

    context "without a file" do
      it "returns an error message" do
        post "/api/v1/restaurants/import_json"

        expect(response).to have_http_status(422)
        parsed_response = JSON.parse(response.body)

        expect(parsed_response).to include("error" => "No file uploaded")
      end
    end
  end

  private

  def valid_json_content
    <<~JSON
      {
        "restaurants": [
          {
            "name": "Poppo's Cafe",
            "menus": [
              {
                "name": "lunch",
                "menu_items": [
                  { "name": "Burger", "price": 9.00 }
                ]
              }
            ]
          }
        ]
      }
    JSON
  end

  def invalid_json_content
    <<~JSON
      {
        "restaurants": [
          {
            "name": "",
            "menus": [
              {
                "name": "",
                "menu_items": [
                  { "name": "", "price": null }
                ]
              }
            ]
          }
        ]
      }
    JSON
  end
end
