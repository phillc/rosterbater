class ParityView extends Backbone.View
  template: _.template """
    <ul>
      <% _.each(path, function(node) { %>
        <li>
          <% if(node.matchup) { %>
            beat
          <% } %>
          <%= node.teamName %>
          <% if(node.matchup) { %>
            in week:
            <%= node.matchup.get("week") %>
          <% } %>
        </li>
      <% }); %>
    </ul>
  """

  initialize: ({@path}) ->

  render: ->
    @$el.html @template(path: @path)

window.LeagueParityPage = class LeagueParityPage
  constructor: ({@matchups, @teams}) ->

  bind: ->
    matchups = new window.APP.collections.MatchupCollection(@matchups)
    teams = new window.APP.collections.TeamCollection(@teams)

    nodes = {}
    matchups.each (matchup) ->
      result = matchup.get("result")

      if result != "unknown" && result != "tie"
        loser = _.find matchup.get("teams"), (team) -> team.id != result
        nodes[result] ||= []
        nodes[result].push(teamId: loser.id, matchup: matchup)

    # Order is to ensure teams with fewer wins are searched first
    orderedTeamIds = _.chain(nodes)
      .keys()
      .sortBy (teamId) -> nodes[teamId].length
      .value()

    orderedTeamIds = orderedTeamIds[0..5]

    #Search the most likely start. Then show if possible, if not search starting with all the other teams.

    window.nodes = nodes
    # idsPath = @search(nodes, orderedTeamIds[0], orderedTeamIds[0], orderedTeamIds[1..])
    # path = @search(nodes, orderedTeamIds, [])
    path = @search(nodes, orderedTeamIds[1..], [{ teamId: orderedTeamIds[0] }])
    _.each path, (node) ->
      node.teamName = teams.findWhere(id: node.teamId).get("name")

    window.path = path
    console.log "PATH: ", path

    parityView = new ParityView(el: $("#parity"), path: path)
    parityView.render()

  search: (nodes, neededTeamIds, currentPath) ->
    console.log "Current Path", currentPath
    console.log "NEEDED:", neededTeamIds.length, neededTeamIds

    tail = _.last(currentPath)

    if _.isEmpty(neededTeamIds)
      console.log "TERMINATED!"
      #if doesn't come back
      # return []
      # else
      ending = _.findWhere nodes[tail.teamId], teamId: currentPath[0].teamId

      return currentPath.concat([ending])

    longestPath = []

    _.each neededTeamIds, (neededTeamId) =>
      console.log "checking from to:", tail.teamId, neededTeamId
      console.log "they beat:", nodes[tail.teamId]

      if beatenTeam = _.findWhere(nodes[tail.teamId], teamId: neededTeamId)
        console.log "beaten: ", beatenTeam
        newNeededTeamIds = _.reject neededTeamIds, (teamId) -> teamId == beatenTeam.teamId
        newCurrentPath = currentPath.concat([beatenTeam])

        path = @search(nodes, newNeededTeamIds, newCurrentPath)
        if path.length > longestPath.length
          console.log "FOUND NEWER!"
          longestPath = path


    return longestPath


  # search: (nodes, orderedTeamIds, currentPath) ->
  #   console.log "searching", currentPath

  #   neededTeamIds = _.reject orderedTeamIds, (teamId) -> !!_.findWhere(currentPath, teamId: teamId)
  #   console.log "NEEDED:", neededTeamIds, neededTeamIds.length

  #   if _.isEmpty(neededTeamIds)
  #     #if doesn't come back
  #     # return []
  #     # else
  #     ending = nodes[_.last(currentPath)].findWhere(teamId: currentPath[0].teamId)

  #     return currentPath.concat([ending])

  #   longestPath = []

  #   # # _.each nodes, (beats, teamId) =>
  #   #   # _.each beats, (beaten) =>
  #   _.every nodes, (beats, teamId) =>
  #     beaten = beats[0]
  #     if !_.contains(_.pluck(currentPath, "teamId"), beaten.teamId)
  #       console.log "Gonna search", teamId, beaten

  #       newPath = @search(nodes, orderedTeamIds, currentPath.concat([beaten]))
  #       console.log "NEW PATH", newPath
  #       if newPath.length > longestPath.length
  #         console.log "!!!!!! LONGER"
  #         longestPath = newPath

  #       false

  #     else
  #       true

  #   return longestPath


  #   # _.each orderedTeamIds, (candidateTeamId) =>
  #   #   if !_.contains(_.pluck(currentPath, "teamId"), candidateTeamId)
  #   #     console.log ">> condidateTeamId"
  #       # newPath = @search(nodes, orderedTeamIds, currentPath.concat([{ teamId: candidateTeamId }]))

  #       # if newPath.length > longestPath.length
  #       #   longestPath = newPath

  #       # node = _.detect nodes[candidateTeamId], (node) -> node.teamId == candidateTeamId
  #       # if node
  #       #   path = @search(nodes, orderedTeamIds, newPath)
  #       #   paths.push(path: path, node: node)

  #   # return longestPath
  #   # returm longest path

  # # search: (nodes, endingTeamId, rootTeamId, neededTeamIds) ->
  # #   # if _.isEmpty(neededTeamIds)
  # #   #   n
  # #   paths = []

  # #   _.each neededTeamIds, (candidateTeamId) =>
  # #     node = _.detect nodes[rootTeamId], (node) -> node.teamId == candidateTeamId
  # #     if node
  # #       path = @search(nodes, endingTeamId, candidateTeamId, _.without(neededTeamIds, candidateTeamId))
  # #       paths.push(path: path, node: node)

  # #   return path[0]
  # #   # returm longest path
