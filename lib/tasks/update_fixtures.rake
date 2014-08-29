namespace :fixtures do
  class Recorder
    def save(name, doc)
      File.open("spec/fixtures/#{name}", 'w') {|f| f.write(doc.to_s) }
    end
  end

  class XMLRecorder < Recorder
    def clean(doc)
      doc.search("email").each do |node|
        node.content = Faker::Internet.email
      end

      doc.search("short_invitation_url").remove
      doc.search("password").remove
    end

    def save(name, doc)
      clean(doc)
      super
    end
  end

  class XLSRecorder < Recorder
  end

  desc "Update yahoo fixtures"
  task update_yahoo: :environment do
    user = User.first
    service = YahooService.new(user)
    recorder = XMLRecorder.new

    recorder.save("get_yahoo_games.xml", service.get_yahoo_games)

    league = user.leagues.where(yahoo_league_id: 31580).first
    recorder.save("get_yahoo_user_leagues.xml", service.get_yahoo_user_leagues)
    recorder.save("get_yahoo_league_details.xml", service.get_yahoo_league_details(league)) #tests take a long time, reduce draft picks size?

    game = Game.find_by(yahoo_game_key: 314) # 2013 fantasy football
    recorder.save("get_yahoo_game_players_1.xml", service.get_yahoo_game_players(game, 0))
    recorder.save("get_yahoo_game_players_2.xml", service.get_yahoo_game_players(game, 25))
    shortened_page = service.get_yahoo_game_players(game, 50)
    shortened_page.search(:player).last.remove
    recorder.save("get_yahoo_game_players_3.xml", shortened_page)
  end

  desc "Update ECR fixtures"
  task update_ecr: :environment do
    service = EcrRankingsService.new
    recorder = XLSRecorder.new

    recorder.save("get_standard_draft_rankings.xls", service.get_standard_draft_rankings)
    recorder.save("get_ppr_draft_rankings.xls", service.get_ppr_draft_rankings)
  end
end
