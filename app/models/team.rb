class Team < ActiveRecord::Base
  belongs_to :league
  has_many :managers, autosave: true

  validates :league, presence: true
  validates :yahoo_team_key, presence: true, uniqueness: true

  scope :by_rank, ->{ order(rank: :asc) }

  def as_json(options={})
    super(only: [:id, :name, :points_for])
  end
end
