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

  save.(:get_yahoo_games, service.get_yahoo_games)

  league = user.leagues.where(yahoo_league_id: 31580).first
  save.(:get_yahoo_user_leagues, service.get_yahoo_user_leagues)
  save.(:get_yahoo_league_details, service.get_yahoo_league_details(league)) #tests take a long time, reduce draft picks size?

  game = Game.find_by(yahoo_game_key: 314) # 2013 fantasy football
  save.(:get_yahoo_game_players_1, service.get_yahoo_game_players(game, 0))
  save.(:get_yahoo_game_players_2, service.get_yahoo_game_players(game, 25))
  shortened_page = service.get_yahoo_game_players(game, 50)
  shortened_page.search(:player).last.remove
  save.(:get_yahoo_game_players_3, shortened_page)
end
