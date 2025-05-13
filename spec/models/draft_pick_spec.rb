require 'rails_helper'

RSpec.describe DraftPick, type: :model do
  describe "#yahoo_info" do
    describe "#vs_pick" do
      it "handles lack of player" do
        draft_pick = create(:draft_pick, pick: 3)

        expect(draft_pick.yahoo_info.vs_pick).to eq nil
      end

      describe "with a player" do
        let!(:player) { create(:player, draft_average_pick: 2) }

        it "is negative when too early" do
          draft_pick = create(:draft_pick, pick: 1, yahoo_player_key: player.yahoo_player_key)

          expect(draft_pick.yahoo_info.vs_pick).to eq -1
        end

        it "is 0 when on time" do
          draft_pick = create(:draft_pick, pick: 2, yahoo_player_key: player.yahoo_player_key)

          expect(draft_pick.yahoo_info.vs_pick).to eq 0
        end

        it "is positive when late" do
          draft_pick = create(:draft_pick, pick: 3, yahoo_player_key: player.yahoo_player_key)

          expect(draft_pick.yahoo_info.vs_pick).to eq 1
        end
      end
    end
  end

  describe "#ecr_ppr_info" do
    describe "#vs_pick" do
      let(:league) { create(:league) }
      it "handles lack of player" do
        draft_pick = create(:draft_pick, pick: 3, league: league)

        expect(draft_pick.ecr_ppr_info.vs_pick).to eq nil
      end

      describe "with a player" do
        let!(:player) { create(:player) }

        it "handles lack of ranking" do
          draft_pick = create(:draft_pick, pick: 3, yahoo_player_key: player.yahoo_player_key, league: league)

          expect(draft_pick.ecr_ppr_info.vs_pick).to eq nil
        end

        describe "with a ranking" do
          before do
            ranking_report = create(:ranking_report, :ppr, game: league.game)
            ranking_profile = create(:ranking_profile, yahoo_player_key: player.yahoo_player_key)
            create(:ranking, :ppr, rank: 2, ranking_profile: ranking_profile, ranking_report: ranking_report)
          end

          it "is negative when too early" do
            draft_pick = create(:draft_pick, pick: 1, yahoo_player_key: player.yahoo_player_key, league: league)

            expect(draft_pick.ecr_ppr_info.vs_pick).to eq -1
          end

          it "is 0 when on time" do
            draft_pick = create(:draft_pick, pick: 2, yahoo_player_key: player.yahoo_player_key, league: league)

            expect(draft_pick.ecr_ppr_info.vs_pick).to eq 0
          end

          it "is positive when late" do
            draft_pick = create(:draft_pick, pick: 3, yahoo_player_key: player.yahoo_player_key, league: league)

            expect(draft_pick.ecr_ppr_info.vs_pick).to eq 1
          end

          describe "with a auction_pick" do
            it "respects an auction pick" do
              league.is_auction_draft = true
              draft_pick = create(:draft_pick, pick: 1, auction_pick: 50, yahoo_player_key: player.yahoo_player_key, league: league)

              expect(draft_pick.ecr_ppr_info.vs_pick).to eq 48
            end
          end
        end
      end
    end
  end
end
