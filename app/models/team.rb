class Team < ActiveRecord::Base
  belongs_to :league
  has_many :managers, autosave: true

  validates :league, presence: true
  validates :yahoo_team_key, presence: true, uniqueness: true

  scope :by_rank, ->{ order(rank: :asc) }

  def as_json(options={})
    super(only: [:id, :name, :logo_url])
  end

  def stats
    @stats ||= TeamStats.new(self)
  end

  class TeamStats
    def initialize(team)
      @team = team
    end

    def mean
      return 0 unless scores.length > 0
      sum / scores.length
    end

    def variance
      return 0 unless scores.length > 0
      m = mean
      sum = scores.inject(0){ |acc, i| acc + (i - m) ** 2 }
      sum / (scores.length - 1).to_f
    end

    def std_dev
      return 0 unless scores.length > 0
      Math.sqrt(variance).round
    end

    def sum
      scores.sum
    end

    def scores
      @scores ||= @team.league.finished_matchup_teams.where(yahoo_team_key: @team.yahoo_team_key).map(&:points)
    end
  end
end
