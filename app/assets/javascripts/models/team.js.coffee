window.APP.models.Team = class Team extends Backbone.Model
  defaults:
    name: "N/A"
    wins: 0
    losses: 0
    ties: 0
    unknowns: 0
    points_for: 0.0
    points_against: 0.0
    projection: 0.0

  incrementWins: ->
    @set("wins", @get("wins") + 1)

  incrementLosses: ->
    @set("losses", @get("losses") + 1)

  incrementTies: ->
    @set("ties", @get("ties") + 1)

  incrementUnknowns: ->
    @set("unknowns", @get("unknowns") + 1)

  addPointsFor: (amount) ->
    @set("last_points_for", amount)
    @set("points_for", (@get("points_for") + amount))

  pointsFor: ->
    @get("points_for").toFixed(2)

  addProjection: (amount) ->
    @set("last_projection", amount)
    @set("projection", (@get("projection") + amount))

  lastPerformance: ->
    @get("last_points_for") - @get("last_projection")

  performance: ->
    @get("points_for") - @get("projection")

  addPointsAgainst: (amount) ->
    @set("last_points_against", amount)
    @set("points_against", (@get("points_against") + amount))

  lastDifferential: ->
    @get("last_points_for") - @get("last_points_against")

  outcomes: ->
    results = []

    _.range(@get("unknowns") + 1).forEach (additionalWins) =>
      results.push
        wins: @get("wins") + additionalWins
        losses: @get("losses") + (@get("unknowns") - additionalWins)
        ties: @get("ties")

    results

window.APP.collections.TeamCollection = class TeamCollection extends Backbone.Collection
  model: Team
  comparator: (team1, team2) ->
    if team1.get("wins") == team2.get("wins")
      if team1.get("points_for") == team2.get("points_for")
        0
      else
        if team1.get("points_for") > team2.get("points_for") then -1 else 1
    else
      if team1.get("wins") > team2.get("wins") then -1 else 1

  resetRecords: ->
    @each (team) ->
      team.set("wins", 0)
      team.set("losses", 0)
      team.set("ties", 0)
      team.set("unknowns", 0)
      team.set("points_for", 0)
      team.set("points_against", 0)

  calculateRecords: (matchups) ->
    matchups.each (matchup) =>
      mteams = matchup.get("teams")
      teams = mteams.map (team) => @findWhere(id: team.id)

      _(mteams).each (mteam) ->
        team = _(teams).findWhere(id: mteam.id)
        opponent = _(mteams).find (mt) -> mt.id != mteam.id
        team.addPointsFor(parseFloat(mteam.points))
        team.addProjection(parseFloat(mteam.projected_points))
        team.addPointsAgainst(parseFloat(opponent.points))

      result = matchup.get("result")
      switch result
        when "unknown" then teams.map (team) -> team.incrementUnknowns()
        when "tie" then teams.map (team) -> team.incrementTies()
        else
          _.findWhere(teams, id: result).incrementWins()
          (_.find teams, (team) -> team.id != result).incrementLosses()
    @sort()
    @trigger "recalculated"

