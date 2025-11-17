require 'rails_helper'

RSpec.describe "Account::Payments", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/account/payments/index"
      expect(response).to have_http_status(:success)
    end
  end

end
