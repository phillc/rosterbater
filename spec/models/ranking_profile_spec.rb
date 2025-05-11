require 'rails_helper'

describe RankingProfile do
  let(:ranking_profile) { create(:ranking_profile) }

  describe "#link" do
    it "can find nothing" do
      create(:player, full_name: "unmatched", game: ranking_profile.game)
      expect(ranking_profile.player).to eq nil

      ranking_profile.link

      ranking_profile.reload
      expect(ranking_profile.player).to eq nil

    end
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

    it "ignores dots in the player" do
      ranking_profile.update! name: "Ty Hilton"
      player = create(:player, full_name: "T.Y. Hilton", game: ranking_profile.game)
      expect(ranking_profile.player).to eq nil

      ranking_profile.link

      ranking_profile.reload
      expect(ranking_profile.player).to eq player
    end

    it "ignores dots in the profile" do
      ranking_profile.update! name: "E.J. Manuel"
      player = create(:player, full_name: "EJ Manuel", game: ranking_profile.game)
      expect(ranking_profile.player).to eq nil

      ranking_profile.link

      ranking_profile.reload
      expect(ranking_profile.player).to eq player
    end

    it "ignores Jr." do
      ranking_profile.update! name: "Roy Helu"
      player = create(:player, full_name: "Roy Helu Jr.", game: ranking_profile.game)
      expect(ranking_profile.player).to eq nil

      ranking_profile.link

      ranking_profile.reload
      expect(ranking_profile.player).to eq player
    end

    %w(I II III IV V).each do |numeral| 
      it "ignores roman numeral #{numeral}" do
        ranking_profile.update! name: "Chris Herndon"
        player = create(:player, full_name: "Chris Herndon #{numeral}", game: ranking_profile.game)
        expect(ranking_profile.player).to eq nil

        ranking_profile.link

        ranking_profile.reload
        expect(ranking_profile.player).to eq player
      end

      it "doesn't assume a suffix is a roman numeral" do
        ranking_profile.update! name: "Chris Herndon"
        create(:player, full_name: "Chris Herndon#{numeral}", game: ranking_profile.game)
        expect(ranking_profile.player).to eq nil

        ranking_profile.link

        ranking_profile.reload
        expect(ranking_profile.player).to eq nil
      end
    end

    it "Timothy is Tim" do
      ranking_profile.update! name: "Timothy Wright"
      player = create(:player, full_name: "Tim Wright", game: ranking_profile.game)
      expect(ranking_profile.player).to eq nil

      ranking_profile.link

      ranking_profile.reload
      expect(ranking_profile.player).to eq player
    end
  end
end
