class League < ActiveRecord::Base
  include Syncable

  belongs_to :game
  has_many :teams
  has_many :draft_picks, autosave: true
  has_many :matchups, dependent: :destroy
  has_many :matchup_teams, through: :matchups
  has_many :finished_matchup_teams, ->(league){ where("status = 'postevent'") }, through: :matchups, source: "matchup_teams"
  has_and_belongs_to_many :users

  default_scope { order(start_date: :desc) }

  scope :unsynced, ->{ where(sync_finished_at: nil) }
  scope :interesting_draft, -> {
    joins(:draft_picks)
      .where.not(sync_finished_at: nil)
      .group("leagues.id")
      .having("count(leagues.id) > 0")
      .order(Arel.sql("RANDOM()"))
  }
  scope :interesting_season, -> {
    joins(:matchups)
      .where.not(sync_finished_at: nil)
      .where(start_week: 1)
      .group("leagues.id")
      .having("count(leagues.id) > 0")
      .order(Arel.sql("RANDOM()"))
  }
  scope :active, -> { where(game_id: Game.by_season.first(2)) }

  validates :name,
            :game,
            :yahoo_league_key,
            :yahoo_league_id, presence: true

  def assign_auction_picks
    picks = draft_picks.sort_by(&:cost)
    num_picks = picks.size
    picks.each.with_object({ count: 0, pick: num_picks, last_cost: nil}) do |draft_pick, info|
      info[:pick] = num_picks - info[:count] unless info[:last_cost] == draft_pick.cost
      info[:count] = info[:count] + 1
      info[:last_cost] = draft_pick.cost

      draft_pick.auction_pick = info[:pick]
    end
  end

  def past_leagues
    league = self
    result = []
    while league
      league = league.last_league
      result << league
    end
    result.compact
  end

  def last_league
    renew && self.class.find_by(yahoo_league_key: renew.split("_").join(".l."))
  end

  def weeks_in_a_season
    playoff_start_week - 1
  end

  def weeks_remaining
    playoff_start_week - current_week
  end

  def complete?
    teams.any? && sync_finished_at?
  end
end
