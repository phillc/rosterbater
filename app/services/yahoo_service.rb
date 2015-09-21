class YahooService
  def initialize(user)
    @user = user
  end

  def get_yahoo_games
    get "/games;game_codes=nfl;seasons=#{(2012..Time.now.year).to_a.join(",")}"
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

  def get_yahoo_game_players(game, offset)
    #TODO: sort by rank and stop at 500?
    get "/game/#{game.yahoo_game_key}/players;out=draft_analysis;start=#{offset}"
  end

  def players(game)
    page_size = 25

    Enumerator.new do |yielder|
      offset = 0
      loop do
        player_docs = get_yahoo_game_players(game, offset).search("player")
        player_docs.each do |player_doc|
          yielder << YahooPlayer.new(player_doc)
        end

        break if player_docs.size < page_size
        offset = offset + page_size
      end
    end
  end

  def sync_game(game)
    players(game).map do |yahoo_player|
      player = game
                 .players
                 .where(yahoo_player_key: yahoo_player.player_key)
                 .first_or_initialize
      yahoo_player.update(player)

      player.save!
    end
  end

  def get_yahoo_user_games_leagues(games)
    get "/users;use_login=1/games;game_keys=#{games.map(&:yahoo_game_key).join(",")}/leagues"
  end

  def games_with_leagues(games)
    doc = get_yahoo_user_games_leagues(games)
    doc.search("game").map{ |game_doc| YahooGame.new(game_doc) }
  end

  def sync_leagues(games)
    @user.update! sync_started_at: Time.now

    games_with_leagues(games).each do |yahoo_game|
      yahoo_game.leagues.map do |yahoo_league|
        game = games.detect{ |g| g.yahoo_game_key.to_s == yahoo_game.game_key }
        league = League
                   .where(yahoo_league_key: yahoo_league.league_key,
                          game: game)
                   .first_or_initialize

        yahoo_league.update(league)
        league.users << @user unless league.users.include?(@user)
        league.save!
      end
    end

    @user.update! sync_finished_at: Time.now
  end

  def sync_league(league)
    league.update! sync_started_at: Time.now

    sync_league_details(league)

    #must make direct calls for sub-resources
    # sync_rosters(league)
    sync_league_matchups(league)
    league.update! sync_finished_at: Time.now
  end

  def get_yahoo_league_details(league)
    get "/league/#{league.yahoo_league_key};out=draftresults,settings,standings"
  end

  def league_details(league)
    league_doc = get_yahoo_league_details(league)
    YahooLeagueDetails.new(league_doc)
  end

  def sync_league_details(league)
    details = league_details(league)

    sync_league_settings(league, details)
    sync_league_teams(league, details)
    sync_league_draft_results(league, details)
  end

  def sync_league_settings(league, details)
    details.settings.update(league)
    league.save!
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
    league_draft_picks = league.draft_picks.all
    draft_results = details.draft_results
    draft_results.each do |yahoo_draft_result|
      pick = league.draft_picks.detect{ |draft_pick| draft_pick.pick == yahoo_draft_result.pick.to_i }
      pick ||= league.draft_picks.build

      yahoo_draft_result.update(pick)
    end

    league.assign_auction_picks if league.is_auction_draft?
    league.has_finished_draft = draft_results.any?
    league.save!
  end

  def get_yahoo_team_roster(team, week)
    # get "/team/#{team.yahoo_team_key};out=roster;week=#{week}"
  end

  def sync_rosters(league, week)
    #for each week... or perhaps just two most recent.
  end

  def get_yahoo_league_scoreboard(league)
    weeks = (1..(league.playoff_start_week - 1)).to_a
    get "/league/#{league.yahoo_league_key}/scoreboard;week=#{weeks.join(",")}"
  end

  def matchups(league)
    doc = get_yahoo_league_scoreboard(league)
    doc.search("matchup").map{ |matchup_doc| YahooMatchup.new(matchup_doc) }
  end

  def sync_league_matchups(league)
    league_matchups = league.matchups.to_a
    league.matchups = matchups(league).map do |yahoo_matchup|
      matchup = league_matchups
        .detect{ |league_matchup|
          (Set.new(league_matchup.matchup_teams.map(&:yahoo_team_key)) ==
            Set.new(yahoo_matchup.teams.map(&:team_key))) &&
          league_matchup.week == yahoo_matchup.week.to_i
        } || league.matchups.build

      yahoo_matchup.update(matchup)

      yahoo_matchup.teams.each do |yahoo_team|
        mt = matchup.matchup_teams.detect{ |matchup_team|
          matchup_team.yahoo_team_key == yahoo_team.team_key
        } || matchup.matchup_teams.build

        yahoo_team.update(mt)
      end

      matchup.save!

      matchup
    end
  end

  def get(path)
    Rails.logger.info "YahooService request: #{path}"
    retries = 0
    begin
      response = token.get path
    rescue OAuth::Problem => e
      if retries < 2
        if e.problem == "token_expired"
          refresh_token!
          retries = retries + 1
          retry
        elsif e.problem == "consumer_key_unknown"
          retries = retries + 1
          retry
        else
          raise
        end
      else
        raise
      end
    end
    Nokogiri::XML(response.body)
  end

  protected

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

    def leagues
      @doc.search("league").map{ |league_doc| YahooLeague.new(league_doc) }
    end
  end

  class YahooPlayer < Base
    attributes *%w(player_key
                   player_id
                   status
                   editorial_player_key
                   editorial_team_key
                   editorial_team_full_name
                   editorial_team_abbr
                   uniform_number
                   display_position
                   image_url
                   position_type
                   )

    def full_name
      at("name/full")
    end

    def first_name
      at("name/first")
    end

    def last_name
      at("name/last")
    end

    def ascii_first_name
      at("name/ascii_first")
    end

    def ascii_last_name
      at("name/ascii_last")
    end

    def bye_weeks
      @doc.search("bye_weeks/week").map(&:text)
    end

    def is_undroppable
      at("is_undroppable") == "1"
    end

    def eligible_positions
      @doc.search("eligible_positions/position").map(&:text)
    end

    def has_player_notes
      at("has_player_notes") == "1"
    end

    def draft_average_pick
      at("draft_analysis/average_pick")
    end

    def draft_average_round
      at("draft_analysis/average_round")
    end

    def draft_average_cost
      at("draft_analysis/average_cost")
    end

    def draft_percent_drafted
      at("draft_analysis/percent_drafted")
    end

    def update(player)
      player.yahoo_player_id = player_id
      %w(
        status
        editorial_player_key
        editorial_team_key
        editorial_team_full_name
        editorial_team_abbr
        uniform_number
        display_position
        image_url
        position_type
        full_name
        first_name
        last_name
        ascii_first_name
        ascii_last_name
        bye_weeks
        is_undroppable
        eligible_positions
        has_player_notes
        draft_average_pick
        draft_average_round
        draft_average_cost
        draft_percent_drafted
      ).each do |attribute|
        player.public_send("#{attribute}=", self.public_send(attribute))
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
      @doc.search("league/standings/teams/team").map{ |team_doc| YahooTeam.new(team_doc) }
    end

    def draft_results
      @doc
        .search("league/draft_results/draft_result")
        .map{ |result_doc| YahooDraftResult.new(result_doc) }
    end

    def settings
      YahooLeagueSettings.new(@doc.search("league/settings"))
    end
  end

  class YahooLeagueSettings < Base
    attributes *%w(trade_end_date
                   num_playoff_teams
                   num_playoff_consolation_teams
                   playoff_start_week
                  )

    def is_auction_draft
      at(:is_auction_draft) == "1"
    end

    def points_per_reception
      stat("11") || 0
    end

    def update(league)
      league.settings = settings_hash
      %w(
        points_per_reception
        is_auction_draft
        trade_end_date
        num_playoff_teams
        num_playoff_consolation_teams
        playoff_start_week
      ).each do |attribute|
        league.public_send("#{attribute}=", self.public_send(attribute))
      end
    end

    protected

    def stat(stat_id)
      settings_hash &&
        settings_hash["stat_modifiers"] &&
        (pair = settings_hash["stat_modifiers"]["stats"]["stat"].detect{ |stat| stat["stat_id"] == stat_id }) &&
        pair["value"]
    end

    def settings_hash
      @settings_hash ||= Hash.from_xml(@doc.to_xml)["settings"]
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
                   points_for
                   points_against
                   wins
                   losses
                   ties
                   rank
                  )
    def logo_url
      @doc.search("team_logo").at(:url).text
    end

    def managers
      @doc.search("manager").map{ |manager_doc| YahooManager.new(manager_doc) }
    end

    def has_clinched_playoffs
      at(:clinched_playoffs) == "1"
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
        has_clinched_playoffs
        points_for
        points_against
        wins
        losses
        ties
        rank
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
                   cost
                   team_key
                   player_key)

    def update(draft_pick)
      draft_pick.yahoo_team_key = team_key
      draft_pick.yahoo_player_key = player_key
      draft_pick.pick = pick.to_i
      draft_pick.cost = cost.to_i
      %w(
        round
      ).each do |attribute|
        draft_pick.public_send("#{attribute}=", self.public_send(attribute))
      end
    end
  end

  class YahooMatchup < Base
    attributes *%w(status
                   winner_team_key)

    def teams
      @doc.search("team").map{ |team_doc| YahooMatchupTeam.new(team_doc, self) }
    end

    def is_playoffs
      at(:is_playoffs) == "1"
    end

    def is_consolation
      at(:is_consolation) == "1"
    end

    def is_tied
      at(:is_tied) == "1"
    end

    def week
      at(:week)
    end

    def update(matchup)
      %w(
        week
        status
        is_playoffs
        is_consolation
        is_tied
      ).each do |attribute|
        matchup.public_send("#{attribute}=", self.public_send(attribute))
      end
    end
  end

  class YahooMatchupTeam < Base
    attributes *%w(team_key)

    def initialize(doc, matchup)
      super doc
      @matchup = matchup
    end

    def is_winner
      @matchup.winner_team_key == team_key
    end

    def points
      at("team_points/total")
    end

    def projected_points
      at("team_projected_points/total")
    end

    def update(matchup_team)
      matchup_team.yahoo_team_key = team_key

      %w(
        is_winner
        points
        projected_points
      ).each do |attribute|
        matchup_team.public_send("#{attribute}=", self.public_send(attribute))
      end
    end
  end
end
