require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  controller do
    def trigger_parameter_missing
      params.require(:required_param)
      head :ok
    end
  end

  describe "error handling" do
    describe "ParameterMissing" do
      before do
        routes.draw { get 'trigger_parameter_missing' => 'anonymous#trigger_parameter_missing' }
      end

      it "returns a clean 400 JSON response" do
        get :trigger_parameter_missing
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)).to eq({
          "status" => 400,
          "error" => "Bad Request",
          "message" => "Required parameter missing: required_param"
        })
      end
    end
  end
end
