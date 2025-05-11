class InfoPolicy < ApplicationPolicy
  def show?
    admin?
  end
end
