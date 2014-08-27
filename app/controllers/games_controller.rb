class GamesController < ApplicationController
  def index
    authorize :game, :index?
    @games = Game.order(season: :desc)
  end

  def refresh
    authorize :game, :refresh?
    service.sync_games

    redirect_to games_path, notice: "Refreshed games"
  end
end
