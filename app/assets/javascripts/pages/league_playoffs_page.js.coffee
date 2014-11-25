class PlayoffsRouter extends Backbone.Router
  routes:
    "": "root"

  root: ->

window.LeaguePlayoffsPage = class LeaguePlayoffsPage
  constructor: (@teams) ->

  bind: ->
    window.router = new PlayoffsRouter({teams: @teams})
    Backbone.history.start()
