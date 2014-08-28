class LeaguesController < ApplicationController
  before_action :find_league, only: [:show, :draft_board]
  def index
    authorize :league, :index?
    @leagues = current_user.leagues
  end

  def refresh
    authorize :league, :refresh?
    service.sync_leagues

    redirect_to leagues_path, notice: "Refreshed leagues"
  end

  def show
    authorize @league, :show?
  end

  def sync
    league = current_user.leagues.find(params[:id])
    authorize league, :sync?
    service.sync_league(league)

    redirect_to league_path(league), notice: "Synced league"
  end

  def draft_board
    authorize @league, :show?

    @picks =
      @league
        .draft_picks
        .order(pick: :asc)
        .each
        .with_object({}) do |draft_pick, acc|
          acc[draft_pick.team] ||= []
          acc[draft_pick.team] << draft_pick
        end
  end

  protected

  def find_league
    @league = League.find(params[:id])
  end
end
