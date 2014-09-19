require 'rails_helper'

describe LeaguePolicy do
  subject { LeaguePolicy }

  permissions :refresh? do
    it "denies if there is no user" do
      expect(subject).to_not permit(nil)
    end

    it "grants if the user is not synced" do
      expect(subject).to permit(build(:user, sync_started_at: nil, sync_finished_at: nil))
    end

    it "denies if the user recently hasn't finished a sync" do
      expect(subject).to_not permit(build(:user, sync_started_at: 2.minutes.ago, sync_finished_at: nil))
    end

    it "denies if the user recently finished a sync" do
      expect(subject).to_not permit(build(:user, sync_started_at: 2.minutes.ago, sync_finished_at: 1.minute.ago))
    end

    it "grants if the user finished a sync a while ago" do
      expect(subject).to permit(build(:user, sync_started_at: 45.minutes.ago, sync_finished_at: 44.minutes.ago))
    end

    it "denies if the user starts up another sync" do
      expect(subject).to_not permit(build(:user, sync_started_at: 2.minutes.ago, sync_finished_at: 44.minutes.ago))
    end
  end
end

