class YahooService
  def initialize(user)
    @user = user
  end

  def get_yahoo_games
    get "/games;game_codes=nfl;seasons=2014,2013,2012"
  end

  def games
    doc = get_yahoo_games
    doc.search("game").map{ |game_doc| YahooGame.new(game_doc) }
  end

  def sync_games
    games.map do |yahoo_game|
      game = Game
               .where(yahoo_game_key: yahoo_game.game_key)
               .first_or_initialize
      yahoo_game.update(game)

      game.save!
      game
    end
  end

  def get_yahoo_user_leagues
    get "/users;use_login=1/games;game_keys=#{Game.all.map(&:yahoo_game_key).join(",")}/leagues"
  end

  def leagues
    doc = get_yahoo_user_leagues
    doc.search("league").map{ |league_doc| YahooLeague.new(league_doc) }
  end

  def sync_leagues
    leagues.map do |yahoo_league|
      league = League
                 .where(yahoo_league_key: yahoo_league.league_key)
                 .first_or_initialize

      yahoo_league.update(league)
      league.users << @user unless league.users.include?(@user)
      league.save!
      league
    end
  end

  def sync_league(league)
    sync_league_details(league)

    #must make direct calls for sub-resources
    # sync_rosters(league)
    # sync_players(league) # perhaps sync any remaining players I need?
  end

  def get_yahoo_league_details(league)
    get "/league/#{league.yahoo_league_key};out=teams,draftresults"
  end

  def league_details(league)
    league_doc = get_yahoo_league_details(league)
    YahooLeagueDetails.new(league_doc)
  end

  def sync_league_details(league)
    details = league_details(league)

    sync_league_teams(league, details)
    sync_league_draft_results(league, details)
  end

  def sync_league_teams(league, details)
    details.teams.each do |yahoo_team|
      team = league
               .teams
               .where(yahoo_team_key: yahoo_team.team_key)
               .first_or_initialize

      yahoo_team.update(team)

      team.managers.each do |manager|
        if !yahoo_team.managers.map(&:guid).include?(manager.yahoo_guid)
          manager.mark_for_destruction
        end
      end
      yahoo_team.managers.each do |yahoo_manager|
        manager =
          team.managers.detect{ |manager| manager.yahoo_guid == yahoo_manager.guid } ||
          team.managers.build

        yahoo_manager.update(manager)
      end

      team.save!
    end
  end

  def sync_league_draft_results(league, details)

  end

  # def get_yahoo_league_teams(league, team, week)
  #   get "/league/#{league.yahoo_league_key}/teams;out=roster"
  # end

  def sync_rosters(league)
    #for each week... or perhaps just two most recent.
  end

  def get_yahoo_league_players(league, offset)
    get "/league/#{league.yahoo_league_key}/players;start=#{offset}"
  end

  def players(league)
    page_size = 25

    Enumerator.new do |yielder|
      offset = 0
      loop do
        player_docs = get_yahoo_league_players(league, offset).search("player")
        player_docs.each do |player_doc|
          # yielder << YahooLeague.new(league_doc)
          yielder << player_doc
        end

        break if player_docs.size < page_size
      end
    end
  end

  def sync_players(league)
  end

  protected

  def get(path)
    retried = false
    begin
      response = token.get path
    rescue OAuth::Problem => e
      if e.problem == "token_expired" && !retried
        refresh_token!
        retried = true
        retry
      else
        raise
      end
    end
    Nokogiri::XML(response.body)
  end

  def oauth_consumer
    @oauth_consumer ||= begin
      options = {
        site: 'https://api.login.yahoo.com',
        scheme: :query_string,
        request_token_path: '/oauth/v2/get_request_token',
        access_token_path: '/oauth/v2/get_token',
        authorize_path: '/oauth/v2/request_auth'
      }
      consumer = OAuth::Consumer.new(APP_CONFIG[:yahoo][:key], APP_CONFIG[:yahoo][:secret], options)
      consumer.http.set_debug_output($stdout)
      consumer
    end
  end

  def fantasy_consumer
    @fantasy_consumer ||= begin
      options = {
        site: "http://fantasysports.yahooapis.com/fantasy/v2"
      }
      consumer = OAuth::Consumer.new(APP_CONFIG[:yahoo][:key], APP_CONFIG[:yahoo][:secret], options)
      consumer.http.set_debug_output($stdout)
      consumer
    end
  end

  def token
    OAuth::AccessToken.from_hash(fantasy_consumer, oauth_hash)
  end

  def oauth_hash
    {
      oauth_token: @user.yahoo_token,
      oauth_token_secret: @user.yahoo_token_secret
    }
  end

  def refresh_token!
    request_token = OAuth::RequestToken.new(oauth_consumer, oauth_hash)

    access_token = request_token.get_access_token({oauth_session_handle: @user.yahoo_session_handle, token: token})

    @user.update(yahoo_token: access_token.token, yahoo_token_secret: access_token.secret)
  end

  class Base
    def self.attributes(*attrs)
      attrs.each do |attr|
        self.class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{attr}
            at("#{attr}").presence
          end
        CODE
      end
    end

    def initialize(doc)
      @doc = doc
    end

    protected

    def at(key)
      @doc.at(key).try(:text)
    end
  end

  class YahooGame < Base
    attributes *%w(game_key
                   game_id
                   name
                   code
                   type
                   url
                   season)

    def update(game)
      game.yahoo_game_id = game_id
      game.game_type = type
      %w(
        name
        code
        url
        season
      ).each do |attribute|
        game.public_send("#{attribute}=", self.public_send(attribute))
      end
    end
  end

  class YahooLeague < Base
    attributes *%w(name
                   league_key
                   league_id
                   url
                   scoring_type
                   renew
                   renewed
                   num_teams
                   current_week
                   start_week
                   end_week
                   start_date
                   end_date)

    def update(league)
      league.yahoo_league_id = league_id
      %w(
        name
        url
        num_teams
        scoring_type
        renew
        renewed
        current_week
        start_week
        end_week
        start_date
        end_date
      ).each do |attribute|
        league.public_send("#{attribute}=", self.public_send(attribute))
      end
    end
  end

  class YahooLeagueDetails < Base
    def teams
      @doc.search("league/teams/team").map{ |team_doc| YahooTeam.new(team_doc) }
    end

    def draft_results
      @doc
        .search("league/draft_results/draft_result")
        .map{ |result_doc| YahooDraftResult.new(result_doc) }
    end
  end

  class YahooTeam < Base
    attributes *%w(name
                   team_key
                   team_id
                   url
                   waiver_priority
                   faab_balance
                   number_of_moves
                   number_of_trades
                  )
    def logo_url
      @doc.search("team_logo").at(:url).text
    end

    def managers
      @doc.search("manager").map{ |manager_doc| YahooManager.new(manager_doc) }
    end

    def update(team)
      team.yahoo_team_id = team_id
      %w(
        name
        url
        logo_url
        waiver_priority
        faab_balance
        number_of_moves
        number_of_trades
      ).each do |attribute|
        team.public_send("#{attribute}=", self.public_send(attribute))
      end
    end
  end

  class YahooManager < Base
    attributes *%w(image_url
                   guid
                   email)
    def name
      at(:nickname)
    end

    def is_commissioner
      at(:is_commissioner) == "1"
    end

    def update(manager)
      manager.yahoo_guid = guid
      %w(
        name
        image_url
        email
        is_commissioner
      ).each do |attribute|
        manager.public_send("#{attribute}=", self.public_send(attribute))
      end
    end
  end

  class YahooDraftResult < Base
    attributes *%w(pick
                   round
                   team_key
                   player_key)
  end
end
