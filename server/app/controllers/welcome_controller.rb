class WelcomeController < ApplicationController
  def index
    authorize :welcome, :index?
    @draft_leagues = League.interesting_draft.limit(10)
    @season_leagues = League.interesting_season.limit(10).to_a
    League.connection.clear_query_cache
    @season_leagues2 = League.interesting_season.limit(10).to_a
  end
end
