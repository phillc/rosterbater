class User < ActiveRecord::Base
  include Syncable

  has_and_belongs_to_many :leagues

  validates :yahoo_uid, presence: true, uniqueness: true

  def admin?
    APP_CONFIG[:yahoo][:all_admin] || yahoo_uid == APP_CONFIG[:yahoo][:admin_uid]
  end
end
