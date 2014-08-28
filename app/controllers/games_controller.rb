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

  def sync
    game = Game.find(params[:id])
    authorize game, :sync?

    service.sync_game(game)

    redirect_to games_path, notice: "Synced game"
  end
end
