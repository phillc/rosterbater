module Support
  module AuthHelper
    def login_as(user)
      session[:current_user_id] = user.id
    end

    def logout
      session[:current_user_id] = nil
    end
  end
end

