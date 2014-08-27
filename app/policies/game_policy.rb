class GamePolicy < ApplicationPolicy
  def index?
    admin?
  end

  def refresh?
    admin?
  end
end
