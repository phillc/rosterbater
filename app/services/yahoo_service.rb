class YahooService
  def initialize(user)
    @user = user
  end

  def teams
    data = get "/users;use_login=1/teams?format=json"
    teams_info = data["fantasy_content"]["users"]["0"]["user"].detect{|hash| hash.keys.first == "teams"}["teams"]
    Enumerator.new(teams_info["count"].to_i) do |yielder|
      teams_info.except("count").each do |i, team_info|

        yielder << YahooTeam.new(team_info)
      end
    end
  end

  # def leagues
  #   data = get "/leagues;league_keys=#{teams.map(&:league_key).join(",")};out=standings?format=json"
  #   leagues_info = data["fantasy_content"]["leagues"]
  #   Enumerator.new(leagues_info["count"].to_i) do |yielder|
  #     leagues_info.except("count").each do |i, leagues_info|
  #       yielder << YahooLeague.new(leagues_info)
  #     end
  #   end
  # end

  def refresh_teams
    teams.each do |yahoo_team|
      ActiveRecord::Base.transaction do
        team = Team.where(yahoo_game_key: yahoo_team.game_key,
                          yahoo_league_id: yahoo_team.league_id,
                          yahoo_team_id: yahoo_team.team_id,
                          yahoo_division_id: yahoo_team.division_id)
                   .first_or_initialize

        team.name = yahoo_team.name
        team.url = yahoo_team.url
        team.save!

        managers = yahoo_team.managers.map do |yahoo_manager|
          manager = team
                      .managers
                      .where(yahoo_manager_id: yahoo_manager.manager_id)
                      .first_or_initialize

          manager.guid = yahoo_manager.guid
          manager.nickname = yahoo_manager.nickname
          manager.user = @user

          manager.save!
          manager
        end

        team.managers = managers
      end
    end
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
    JSON.parse(response.body)
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

  class YahooLeague
    attr_reader :info
    def initialize(info)
      @info = info
    end

    protected

    def attributes
      @attributes ||= begin
        @info["league"]
      end
    end
  end

  class YahooTeam
    attr_reader :game_key, :league_id, :team_id

    def initialize(info)
      @info = info
      @game_key, _, @league_id, _, @team_id = attributes[:team_key].split(".")
    end

    def league_key
      "#{game_key}.l.#{league_id}"
    end

    def division_id
      attributes[:division_id]
    end

    def name
      attributes[:name]
    end

    def url
      attributes[:url]
    end

    def managers
      attributes[:managers].map do |yahoo_manager|
        YahooManager.new(yahoo_manager)
      end
    end

    protected

    def attributes
      @attributes ||= begin
        @info["team"].first.inject({}) do |acc, v|
          if v.is_a?(Hash)
            acc.merge(v)
          else
            acc
          end
        end.with_indifferent_access
      end
    end
  end

  class YahooManager
    def initialize(info)
      @info = info
    end

    def manager_id
      attributes[:manager_id]
    end

    def guid
      attributes[:guid]
    end

    def nickname
      attributes[:nickname]
    end

    protected

    def attributes
      @info["manager"].with_indifferent_access
    end
  end
end
