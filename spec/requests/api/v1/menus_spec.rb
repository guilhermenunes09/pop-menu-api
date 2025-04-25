require 'rails_helper'

RSpec.describe "Api::V1::Menus", type: :request do
  describe "GET /index" do
    before do
      create_list(:menu, 3)
    end

    it "returns a list of menus" do
      get '/api/v1/menus'

      expect(response).to have_http_status(:ok)

      menus = JSON.parse(response.body)

      expect(JSON.parse(response.body)).to be_an(Array)
      expect(menus.size).to eq(3)
    end
  end
end
