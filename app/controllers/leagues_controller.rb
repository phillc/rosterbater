class LeaguesController < ApplicationController
  before_action :find_league, only: [:show, :draft_board, :playoffs, :parity]

  def index
    authorize :league, :index?
    @leagues = current_user.leagues.active
  end

  def refresh
    authorize :league, :refresh?

    YahooService.new(current_user).sync_leagues(Game.all)
    # Game.all.each do |game|
    #   YahooService.new(current_user).sync_leagues(game)
    # end
    current_user.leagues.active.each do |league|
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

    @ranking_type = params[:ranking] || case @league.points_per_reception
                                          when 1 then "ecr_ppr"
                                          when 0 then "ecr_standard"
                                          when 0.5 then "ecr_half_ppr"
                                          else "ecr_standard"
                                        end

    @picks =
      @league
        .draft_picks
        .order(auction_pick: :asc, pick: :asc)
        .each
        .with_object({}) do |draft_pick, acc|
          acc[draft_pick.team] ||= []

          info = case @ranking_type
            when "yahoo_adp"; draft_pick.yahoo_info
            when "ecr_standard"; draft_pick.ecr_standard_info
            when "ecr_ppr"; draft_pick.ecr_ppr_info
            when "ecr_half_ppr"; draft_pick.ecr_half_ppr_info
            end

          acc[draft_pick.team] << info
        end
  end

  def playoffs
    authorize @league, :show?

    @matchups = @league.matchups
    @teams = @league.teams
  end

  def parity
    authorize @league, :show?

    @matchups = @league.matchups
    @teams = @league.teams
  end

  protected

  def find_league
    @league = League.find(params[:id])
  end
end
