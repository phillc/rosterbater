//= require underscore

@onmessage = (event) ->
  {matchups, teams} = event.data

  nodes = {}
  _(matchups).each (matchup) ->
    winner = _.detect matchup.teams, (team) -> team.is_winner

    if winner
      loser = _.find matchup.teams, (team) -> team.id != winner.id
      nodes[winner.id] ||= []
      nodes[winner.id].push(teamId: loser.id, matchup: matchup)

  # Order is to ensure teams with fewer wins are searched first
  orderedTeamIds = _.chain(nodes)
    .keys()
    .sortBy (teamId) -> nodes[teamId].length
    .value()

  path = search(nodes, orderedTeamIds[1..], [{ teamId: orderedTeamIds[0] }])


  _.each path, (node) ->
    node.team = _(teams).findWhere(id: node.teamId)

  postMessage(path: path)

search = (nodes, neededTeamIds, currentPath) ->
  tail = _.last(currentPath)

  if _.isEmpty(neededTeamIds)
    ending = _.findWhere nodes[tail.teamId], teamId: currentPath[0].teamId

    if ending
      return currentPath.concat([ending])
    else
      return []

  longestPath = []

  _.each neededTeamIds, (neededTeamId) =>
    if beatenTeam = _.findWhere(nodes[tail.teamId], teamId: neededTeamId)
      newNeededTeamIds = _.reject neededTeamIds, (teamId) -> teamId == beatenTeam.teamId
      newCurrentPath = currentPath.concat([beatenTeam])

      path = search(nodes, newNeededTeamIds, newCurrentPath)
      if path.length > longestPath.length
        longestPath = path

  return longestPath
