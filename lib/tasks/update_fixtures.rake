desc "Update fixtures"
task update_fixtures: :environment do
  user = User.first
  service = YahooService.new(user)

  clean = ->(doc) {
    doc.search("email").each do |node|
      node.content = Faker::Internet.email
    end

    doc.search("short_invitation_url").remove
  }
  save = ->(name, doc) {
    clean.(doc)
    File.open("spec/fixtures/#{name}.xml", 'w') {|f| f.write(doc.to_s) }
  }

  league = user.leagues.where(yahoo_league_id: 31580).first
  save.(:get_yahoo_user_leagues, service.get_yahoo_user_leagues)
  save.(:get_yahoo_league_details, service.get_yahoo_league_details(league))
  # save.(:get_yahoo_league_teams, service.get_yahoo_league_teams(league))
  save.(:get_yahoo_league_players_1, service.get_yahoo_league_players(league, 0))
  save.(:get_yahoo_league_players_2, service.get_yahoo_league_players(league, 25))
  shortened_page = service.get_yahoo_league_players(league, 50)
  shortened_page.search(:player).last.remove
  save.(:get_yahoo_league_players_3, shortened_page)
end
