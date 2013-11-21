class Manager < ActiveRecord::Base
  belongs_to :team
  belongs_to :user

  validates :team, :yahoo_manager_id, presence: true
end
