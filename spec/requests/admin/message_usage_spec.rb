require 'rails_helper'

RSpec.describe "Admin::MessageUsages", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/message_usage/index"
      expect(response).to have_http_status(:success)
    end
  end

end
