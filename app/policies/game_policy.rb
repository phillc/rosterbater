class GamePolicy < ApplicationPolicy
  def index?
    admin?
  end

  def refresh?
    admin?
  end

  def sync?
    admin?
  end

  def manage_ranking_profile?
    admin?
  end
end
