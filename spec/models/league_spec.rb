require 'rails_helper'

describe League do
  let(:league) { build(:league) }

  describe "#ppr?" do
    it "is true when the stat is there" do
      league.settings = {
        "stat_modifiers" => {
          "stats" => {
            "stat" => [
              { "stat_id" => "11", "value" => "1" }
            ]
          }
        }
      }

      expect(league.ppr?).to be true
    end

    it "is false when the stat is 0" do
      league.settings = {
        "stat_modifiers" => {
          "stats" => {
            "stat" => [
              { "stat_id" => "11", "value" => "0" }
            ]
          }
        }
      }

      expect(league.ppr?).to be false
    end

    it "is false when the stat is not there" do
      league.settings = {
        "stat_modifiers" => {
          "stats" => {
            "stat" => []
          }
        }
      }

      expect(league.ppr?).to be false
    end

    it "is false when the settings are not there" do
      league.settings = {}

      expect(league.ppr?).to be false
    end

    it "is false when the settings are nil" do
      league.settings = nil

      expect(league.ppr?).to be false
    end
  end
end
