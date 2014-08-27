class LeaguePolicy < ApplicationPolicy
  def index?
    logged_in?
  end

  def refresh?
    logged_in?
  end

  def show?
    true
  end

  def sync?
    logged_in?
  end
end
