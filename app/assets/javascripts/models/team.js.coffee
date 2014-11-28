window.APP.models.Team = class Team extends Backbone.Model
  defaults:
    name: "N/A"
    wins: 0
    losses: 0
    ties: 0
    unknowns: 0
    points_for: 0

  incrementWins: ->
    @set("wins", @get("wins") + 1)

  incrementLosses: ->
    @set("losses", @get("losses") + 1)

  incrementTies: ->
    @set("ties", @get("ties") + 1)

  incrementUnknowns: ->
    @set("unknowns", @get("unknowns") + 1)

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

  calculateRecords: (matchups) ->
    @resetRecords()
    matchups.each (matchup) =>
      teams = matchup.get("teams").map (team) => @findWhere(id: team.id)
      result = matchup.get("result")
      switch result
        when "unknown" then teams.map (team) -> team.incrementUnknowns()
        when "tie" then teams.map (team) -> team.incrementTies()
        else
          _.findWhere(teams, id: result).incrementWins()
          (_.find teams, (team) -> team.id != result).incrementLosses()
    @sort()
    @trigger "recalculated"

