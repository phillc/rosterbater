window.APP.models.Matchup = class Matchup extends Backbone.Model
  initialize: ->
    if @get("is_tied")
      @set("result", "tie")
    else if (winner = _.detect @get("teams"), (team) -> team.is_winner)
      @set("result", winner.id)
    else
      @set("result", "unknown")

window.APP.collections.MatchupCollection = class MatchupCollection extends Backbone.Collection
  model: Matchup
