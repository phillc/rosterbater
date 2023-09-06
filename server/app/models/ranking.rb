class Ranking < ActiveRecord::Base
  belongs_to :ranking_profile
  belongs_to :ranking_report

  validates :rank, :team, :position, :bye_week, presence: true
end
