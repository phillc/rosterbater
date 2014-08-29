class WelcomeController < ApplicationController
  def index
    authorize :welcome, :index?
    @leagues = League
                 .where.not(synced_at: nil)
                 .limit(10)
                 .order("RANDOM()")
  end
end
