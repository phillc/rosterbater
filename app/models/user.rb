class User < ActiveRecord::Base
  has_and_belongs_to_many :leagues

  validates :yahoo_uid, presence: true, uniqueness: true

  def admin?
    yahoo_uid == "JBAMN3TTXS5EN3SAWHYJKRRGNU"
  end
end
