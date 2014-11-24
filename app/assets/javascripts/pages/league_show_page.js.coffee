window.LeagueShowPage = class LeagueShowPage
  bind: ->
    $("#league-teams").tablesorter(theme: "default")
    $("#league-matchup-teams").tablesorter(theme: "default")

