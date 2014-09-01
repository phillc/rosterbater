class WelcomeController < ApplicationController
  def index
    authorize :welcome, :index?
    @leagues = League.interesting.limit(10)
  end
end
