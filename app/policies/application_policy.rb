class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def admin?
    user && user.admin?
  end

  def logged_in?
    !!user
  end
end

