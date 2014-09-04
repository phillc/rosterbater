class League < ActiveRecord::Base
  belongs_to :game
  has_many :teams
  has_many :draft_picks, autosave: true
  has_and_belongs_to_many :users

  scope :unsynced, ->{ where(synced_at: nil) }
  scope :interesting, -> {
    joins(:draft_picks)
      .where.not(synced_at: nil)
      .where(is_auction_draft: [false, nil])
      .group("leagues.id")
      .having("count(leagues.id) > 0")
      .order("RANDOM()")
  }

  validates :name,
            :game,
            :yahoo_league_key,
            :yahoo_league_id, presence: true

  def ppr?
    return false unless settings && !settings.empty?

    stat = settings["stat_modifiers"]["stats"]["stat"].detect{ |stat| stat["stat_id"] == "11" }
    !!stat && (stat["value"] == "1")
  end

  def assign_auction_picks
    draft_picks.sort_by(&:cost).reverse.each.with_index do |draft_pick, i|
      draft_pick.auction_pick = i + 1
    end
  end
end
