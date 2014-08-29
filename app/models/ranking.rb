class Ranking < ActiveRecord::Base
  belongs_to :ranking_profile
  belongs_to :ranking_report
end
