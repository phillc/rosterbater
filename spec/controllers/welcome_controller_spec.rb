require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do

  describe "GET 'index'" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

end
