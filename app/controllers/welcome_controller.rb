class WelcomeController < ApplicationController
  def index
    authorize :welcome, :index?
  end
end
