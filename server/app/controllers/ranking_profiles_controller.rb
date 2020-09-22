class RankingProfilesController < ApplicationController
  before_action :find_game

  def index
    authorize @game, :manage_ranking_profile?
    @unlinked_profiles = @game.ranking_profiles.unlinked
  end

  protected

  def find_game
    @game = Game.find(params[:game_id])
  end
end
