require "rails_helper"

describe "YahooService" do
  let(:user) { create(:user) }
  let(:service) { YahooService.new(user) }

  let(:user_teams_response) do
    {"fantasy_content"=>{"xml:lang"=>"en-US", "yahoo:uri"=>"/fantasy/v2/users;use_login=1/teams", "users"=>{"0"=>{"user"=>[{"guid"=>"abc123"}, {"teams"=>{"0"=>{"team"=>[[{"team_key"=>"164.l.111.t.4"}, {"team_id"=>"4"}, {"name"=>"foo"}, {"is_owned_by_current_login"=>1}, {"url"=>"http://example.com"}, {"team_logos"=>[{"team_logo"=>{"size"=>"large", "url"=>"http://example.com/example.png"}}]}, {"division_id"=>"2"}, {"waiver_priority"=>3}, [], {"number_of_moves"=>"20"}, {"number_of_trades"=>"1"}, {"roster_adds"=>{"coverage_type"=>"week", "coverage_value"=>"26", "value"=>"0"}}, [], {"managers"=>[{"manager"=>{"manager_id"=>"4", "nickname"=>"PC", "is_current_login"=>"1"}}]}]]}, "1"=>{"team"=>[[{"team_key"=>"164.l.112.t.3"}, {"team_id"=>"1"}, {"name"=>"bar"}, {"is_owned_by_current_login"=>1}, {"url"=>"http://example.com/2"}, {"team_logos"=>[{"team_logo"=>{"size"=>"large", "url"=>"http://example.com/2.png"}}]}, [], {"waiver_priority"=>7}, {"faab_balance"=>"6"}, {"number_of_moves"=>"47"}, {"number_of_trades"=>"6"}, {"roster_adds"=>{"coverage_type"=>"week", "coverage_value"=>12, "value"=>"0"}}, [], {"managers"=>[{"manager"=>{"manager_id"=>"1", "nickname"=>"A Yahoo User", "guid"=>"abc123", "is_commissioner"=>"1", "is_current_login"=>"1"}}]}]]}, "count"=>2}}]}, "count"=>1}, "time"=>"474.57ms", "copyright"=>"Data provided by Yahoo! and STATS, LLC", "refresh_rate"=>"60"}}
  end

  describe "#teams" do
    before do
      expect(service).to receive(:get).and_return(user_teams_response)
    end

    it "returns the count" do
      expect(service.teams.size).to eq 2
    end

    it "returns the team attributes" do
      team = service.teams.first
      expect(team.name).to eq("foo")
      expect(team.team_id).to eq("4")
    end
  end

  describe "#refresh_teams" do
    before do
      expect(service).to receive(:get)
                           .and_return(user_teams_response)
                           .at_least(1).times
    end

    it "saves the teams" do
      expect {
        service.refresh_teams
      }.to change(Team, :count).by(2)
    end

    it "saves the managers" do
      expect {
        service.refresh_teams
      }.to change(Manager, :count).by(2)
    end

    it "stores the attributes" do
      service.refresh_teams

      team = Team.find_by(yahoo_league_id: 111, yahoo_team_id: 4)
      expect(team.name).to eq("foo")
      expect(team.url).to eq("http://example.com")
      expect(team.yahoo_division_id).to eq(2)

      expect(team.managers.first.nickname).to eq("PC")
      expect(team.managers.first.yahoo_manager_id).to eq(4)
    end

    it "associates the current user" do
      service.refresh_teams

      team = Team.find_by(yahoo_league_id: 111, yahoo_team_id: 4)
      expect(team.managers.first.user).to eq(user)

    end

    it "does not duplicate" do
      service.refresh_teams

      expect {
        service.refresh_teams
      }.to change{Team.count + Manager.count}.by(0)
    end
  end
end
