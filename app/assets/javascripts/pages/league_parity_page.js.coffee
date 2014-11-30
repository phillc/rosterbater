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
          <%= node.team.get("name") %>
        </li>
      <% }); %>
    </ul>
  """

  initialize: ({@path}) ->

  render: ->
    if @path.length == 0
      @$el.html "Parity has not yet been achieved"
      return

    @$el.html @template(path: @path)

    width = 900
    height = 700

    links = []

    for x, i in @path
      if i != @path.length - 1
        links.push source: @path[i].teamId, target: @path[i+1].teamId, matchup: @path[i+1].matchup

    centerX = width/2
    centerY = height/2
    radius = height/3
    dotSize = 30
    pathStartOffset = 1 / ((@path.length - 1) * 5)
    pathEndOffset = pathStartOffset * 2

    nodes = []
    for edge, i in @path[0..@path.length - 2]
      inc = i / ( @path.length - 1)
      nodes.push
        teamId: edge.teamId
        team: edge.team
        cx: centerX + (radius * Math.cos(2 * Math.PI * inc))
        cy: centerY + (radius * Math.sin(2 * Math.PI * inc))
        textX: centerX + ((radius + dotSize * 2) * Math.cos(2 * Math.PI * inc))
        textY: centerY + ((radius + dotSize * 2) * Math.sin(2 * Math.PI * inc))
        pathStartX: centerX + ((radius - dotSize) * Math.cos(2 * Math.PI * (inc + pathStartOffset)))
        pathStartY: centerY + ((radius - dotSize) * Math.sin(2 * Math.PI * (inc + pathStartOffset)))
        pathEndX: centerX + ((radius - dotSize) * Math.cos(2 * Math.PI * (inc - pathEndOffset)))
        pathEndY: centerY + ((radius - dotSize) * Math.sin(2 * Math.PI * (inc - pathEndOffset)))

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

    defs = svg.append("defs")
    defs.append("marker")
      .attr("id", "arrow")
      .attr("viewBox", "0 -5 10 10")
      .attr("refX", 0)
      .attr("refY", 0)
      .attr("markerWidth", 2)
      .attr("markerHeight", 2)
      # .attr("markerUnits", "userSpaceOnUse")
      # .attr("markerUnits", "strokeWidth")
      .attr("orient", "auto")
      .append("path")
      .attr("d", "M0,-5L10,0L0,5")
      .attr("stroke", "#ccc")
      .attr("fill", "#ccc")

    defs.selectAll("pattern")
      .data(force.nodes())
      .enter().append("pattern")
      .attr "id", (d) -> d.teamId
      .attr("x", 0)
      .attr("y", 0)
      .attr("height", dotSize)
      .attr("width", dotSize)
      .append("image")
      .attr("x", 0)
      .attr("y", 0)
      .attr("height", dotSize * 2)
      .attr("width", dotSize * 2)
      .attr "xlink:href", (d) -> d.team.get("logo_url")

    svg.append("g").selectAll("circle")
      .data(force.nodes())
      .enter().append("circle")
      .attr("r", dotSize)
      .attr "cx", (d) -> d.cx
      .attr "cy", (d) -> d.cy
      .attr "stroke", "black"
      .attr "stroke-width", "3"
      # .style "fill", (d) -> "url(##{d.teamId})"

    path = svg.append("g").selectAll("path")
      .data(force.links())
      .enter().append("path")
      .attr("stroke", "#ccc")
      .attr("stroke-width", 10)
      .attr("fill", "none")
      .attr "marker-end", (d) -> return "url(#arrow)"
      .attr "d", (d) ->
        source = _.findWhere(nodes, teamId: d.source)
        target = _.findWhere(nodes, teamId: d.target)
        dx = target.cx - source.cx
        dy = target.cy - source.cy
        dr = Math.sqrt(dx * dx + dy * dy) / 3
        attr = "M#{source.pathStartX},#{source.pathStartY} A#{dr},#{dr} 0 0,0 #{target.pathEndX},#{target.pathEndY}"
        attr

    svg.append("g").selectAll("text")
      .data(force.nodes())
      .enter().append("text")
      .attr "x", (d) -> d.textX
      .attr "y", (d) -> d.textY
      .text (d) -> return d.team.get("name")

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
    console.log("PATH", path)
    _.each path, (node) ->
      node.team = teams.findWhere(id: node.teamId)

    parityView = new ParityView(el: $("#parity"), path: path)
    parityView.render()

  search: (nodes, neededTeamIds, currentPath) ->
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

        path = @search(nodes, newNeededTeamIds, newCurrentPath)
        if path.length > longestPath.length
          longestPath = path

    return longestPath

