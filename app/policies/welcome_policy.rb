class WelcomePolicy < Struct.new(:user, :welcome)
  def index?
    true
  end
end
