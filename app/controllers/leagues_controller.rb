class LeaguesController < ApplicationController
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
    @league = League.find(params[:id])
    authorize @league, :show?
  end

  def sync
    league = current_user.leagues.find(params[:id])
    authorize league, :sync?
    service.sync_league(league)

    redirect_to league_path(league), notice: "Synced league"
  end
end
