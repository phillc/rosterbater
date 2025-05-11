class GamesController < ApplicationController
  rescue_from Pundit::NotAuthorizedError do
    redirect_to root_path
  end

  def index
    authorize :game, :index?
    @games = Game.order(season: :desc)
  end

  def refresh
    authorize :game, :refresh?
    YahooService.new(current_user).sync_games

    redirect_to games_path, notice: "Refreshed games"
  end

  def sync
    game = Game.find(params[:id])
    authorize game, :sync?

    YahooService.new(current_user).sync_game(game)

    redirect_to games_path, notice: "Synced game"
  end

  def upload_rankings
    @game = Game.find(params[:id])
    authorize @game, :sync?
  end

  def update_rankings
    @game = Game.find(params[:id])
    authorize @game, :sync?

    EcrRankingsService.new.tap do |service|
      if standard = params[:rankings][:standard]
        service.sync_standard_draft_rankings(@game, standard.read)
      end
      if ppr = params[:rankings][:ppr]
        service.sync_ppr_draft_rankings(@game, ppr.read)
      end
      if half_ppr = params[:rankings][:half_ppr]
        service.sync_half_ppr_draft_rankings(@game, half_ppr.read)
      end
    end

    redirect_to games_path, notice: "Synced rankings"
  end

  def link_players
    game = Game.find(params[:id])
    authorize game, :sync?

    game.ranking_profiles.unlinked.map(&:link)

    redirect_to games_path, notice: "Linked players"
  end
end
