class ParityView extends Backbone.View
  template: _.template """
    <div id="parity-viz"></div>
    <ul>
      <% _.each(path, function(node) { %>
        <li>
          <% if(node.matchup) { %>
            in week
            <%= node.matchup.get("week") %>
            beat
          <% } %>
          <%= node.teamName %>
        </li>
      <% }); %>
    </ul>
  """

  initialize: ({@path}) ->

  render: ->
    @$el.html @template(path: @path)

    width = 750
    height = 750

    links = []

    for x, i in @path
      if i != @path.length - 1
        links.push source: @path[i].teamId, target: @path[i+1].teamId, matchup: @path[i+1].matchup

    centerX = width/2
    centerY = height/2
    radius = width/3

    nodes = []
    for edge, i in @path[0..@path.length - 2]
      inc = i / ( @path.length - 1)
      nodes.push
        teamId: edge.teamId
        teamName: edge.teamName
        cx: centerX + (radius * Math.cos(2 * Math.PI * inc))
        cy: centerX + (radius * Math.sin(2 * Math.PI * inc))

    console.log "nodes", nodes

    force = d3.layout.force()
      .nodes(nodes)
      .links(links)
      .size([width, height])
      .start()

    svg = d3.select("#parity-viz")
      .append("svg")
      .attr("width", width)
      .attr("height", height)
      .style("border", "1px solid black")

    svg.append("defs").append("marker")
      .attr("id", "arrow")
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 10)
      .attr("refY", 0)
      .attr("markerWidth", 6)
      .attr("markerHeight", 6)
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,-5L10,0L0,5")
      .attr("stroke", "red")

    circle = svg.append("g").selectAll("circle")
      .data(force.nodes())
      .enter().append("circle")
      .attr("r", 12)
      .attr "cx", (d) -> d.cx
      .attr "cy", (d) -> d.cy

    path = svg.append("g").selectAll("path")
      .data(force.links())
      .enter().append("path")
      .attr("stroke", "blue")
      .attr("stroke-width", 2)
      .attr("fill", "none")
      .attr "marker-end", (d) -> return "url(#arrow)"
      .attr "d", (d) ->
        source = _.findWhere(nodes, teamId: d.source)
        target = _.findWhere(nodes, teamId: d.target)
        dx = target.cx - source.cx
        dy = target.cy - source.cy
        dr = Math.sqrt(dx * dx + dy * dy)
        attr = "M#{source.cx},#{source.cy} A#{dr},#{dr} 0 0,0 #{target.cx},#{target.cy}"
        attr

    svg.append("g").selectAll("text")
      .data(force.nodes())
      .enter().append("text")
      .attr "x", (d) -> d.cx
      .attr "y", (d) -> d.cy
      .text (d) -> return d.teamName

    svg.append("g").selectAll("text")
      .data(force.links())
      .enter().append("text")
      .attr "x", (d) ->
        source = _.findWhere(nodes, teamId: d.source)
        target = _.findWhere(nodes, teamId: d.target)
        target.cx + 30
      .attr "y", (d) ->
        source = _.findWhere(nodes, teamId: d.source)
        target = _.findWhere(nodes, teamId: d.target)
        target.cy + 30
      .text (d) ->
        # target = _.findWhere(nodes, teamId: d.target)
        "week #{d.matchup.get("week")}"


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

    # orderedTeamIds = orderedTeamIds[0..5]

    path = @search(nodes, orderedTeamIds[1..], [{ teamId: orderedTeamIds[0] }])
    _.each path, (node) ->
      node.teamName = teams.findWhere(id: node.teamId).get("name")

    parityView = new ParityView(el: $("#parity"), path: path)
    parityView.render()

  search: (nodes, neededTeamIds, currentPath) ->
    tail = _.last(currentPath)

    if _.isEmpty(neededTeamIds)
      ending = _.findWhere nodes[tail.teamId], teamId: currentPath[0].teamId

      return currentPath.concat([ending])

    longestPath = []

    _.each neededTeamIds, (neededTeamId) =>
      if beatenTeam = _.findWhere(nodes[tail.teamId], teamId: neededTeamId)
        newNeededTeamIds = _.reject neededTeamIds, (teamId) -> teamId == beatenTeam.teamId
        newCurrentPath = currentPath.concat([beatenTeam])

        path = @search(nodes, newNeededTeamIds, newCurrentPath)
        if path.length > longestPath.length
          longestPath = path

    return longestPath

