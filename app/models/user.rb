class User < ActiveRecord::Base
  has_many :teams, through: :managers
  has_many :managers

  validates :uid, presence: true, uniqueness: true

  def remote_teams
    @remote_teams = service.get_teams
  end

  def service
    @service ||= YahooService.new(self)
  end
end
