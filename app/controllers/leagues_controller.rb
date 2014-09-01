class LeaguesController < ApplicationController
  before_action :find_league, only: [:show, :draft_board]
  def index
    authorize :league, :index?
    @leagues = current_user.leagues
  end

  def refresh
    authorize :league, :refresh?

    YahooService.new(current_user).sync_leagues(Game.most_recent)
    # Game.all.each do |game|
    #   YahooService.new(current_user).sync_leagues(game)
    # end
    current_user.leagues.each do |league|
      YahooService.new(current_user).sync_league(league)
    end

    redirect_to leagues_path, notice: "Refreshed leagues"
  end

  def show
    authorize @league, :show?
  end

  def sync
    league = current_user.leagues.find(params[:id])
    authorize league, :sync?
    YahooService.new(current_user).sync_league(league)

    redirect_to league_path(league), notice: "Synced league"
  end

  def draft_board
    authorize @league, :show?

    @ranking_type = params[:ranking] || (@league.ppr? ? "ecr_ppr" : "ecr_standard")

    @picks =
      @league
        .draft_picks
        .order(pick: :asc)
        .each
        .with_object({}) do |draft_pick, acc|
          acc[draft_pick.team] ||= []

          info = case @ranking_type
            when "yahoo_adp"; draft_pick.yahoo_info
            when "ecr_standard"; draft_pick.ecr_standard_info
            when "ecr_ppr"; draft_pick.ecr_ppr_info
            end

          acc[draft_pick.team] << info
        end
  end

  protected

  def find_league
    @league = League.find(params[:id])
  end
end
