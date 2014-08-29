require 'rails_helper'

describe RankingProfile do
  let(:ranking_profile) { create(:ranking_profile) }

  describe "#link" do
    it "finds a player with the same name" do
      player = create(:player, full_name: ranking_profile.name, game: ranking_profile.game)
      expect(ranking_profile.player).to eq nil

      ranking_profile.link

      ranking_profile.reload
      expect(ranking_profile.player).to eq player
    end

    it "finds defenses" do
      create(:ranking, position: "DST", ranking_profile: ranking_profile)
      player = create(:player, display_position: "DEF",
                               editorial_team_full_name: ranking_profile.name,
                               game: ranking_profile.game)
      expect(ranking_profile.player).to eq nil

      ranking_profile.link

      ranking_profile.reload
      expect(ranking_profile.player).to eq player

    end
  end
end
