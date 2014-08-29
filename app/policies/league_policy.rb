class LeaguePolicy < ApplicationPolicy
  def index?
    logged_in?
  end

  def refresh?
    logged_in? && (!user.synced_at || user.synced_at < 30.minutes.ago)
  end

  def show?
    true
  end

  def sync?
    logged_in? && (!league.synced_at || league.synced_at < 30.minutes.ago)
  end

  protected

  def league
    record
  end
end
