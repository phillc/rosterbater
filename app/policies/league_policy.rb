class LeaguePolicy < ApplicationPolicy
  def index?
    logged_in?
  end

  def refresh?
    logged_in? && (!user.sync_finished_at || user.sync_finished_at < 30.minutes.ago)
  end

  def show?
    true
  end

  def sync?
    logged_in? && (!league.sync_finished_at || league.sync_finished_at < 10.minutes.ago)
  end

  protected

  def league
    record
  end
end
