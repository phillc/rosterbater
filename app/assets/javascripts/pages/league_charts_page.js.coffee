class ChartsView extends Backbone.View
  template: _.template """
    <div id="standings-chart"></div>
  """

  initialize: ({@teams, @weekStandings, @weeks}) ->

  render: ->
    @$el.html @template()

    margin = { top: 30, right: 250, bottom: 70, left: 50 }
    width = 800 - margin.left - margin.right
    height = 300 - margin.top - margin.bottom

    x = d3.scale.linear()
      .domain([1, @weeks])
      .range([0, width])
    y = d3.scale.linear()
      .domain([@teams.size(),1])
      .range([height, 0])

    xAxis = d3.svg.axis().scale(x)
        .orient("bottom").ticks(@weeks)

    yAxis = d3.svg.axis().scale(y)
        .orient("left").ticks(@teams.size())

    standingLine = d3.svg.line()
      .x (d) -> x(d.week)
      .y (d) -> y(d.standing)

    svg = d3.select("#standings-chart")
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")

    color = d3.scale.category20()

    legendX = width + margin.right / 15
    @teams.map (team, teamIndex) =>
      values = _.times @weeks, (i) =>
        week = i + 1
        _(@weekStandings[week]).findWhere(id: team.get("id"))

      svg.append("path")
        .style "stroke", -> color(team.id)
        .attr "id", "line-#{team.id}"
        .attr "d", standingLine(values)
        .attr "fill", "none"
        .attr "stroke-width", "3"

      svg.append("text")
        .attr("x", legendX)
        .attr("y", teamIndex * height / 12)
        .attr("class", "legend")
        .attr("id", "legend-#{team.id}")
        .style "fill", -> color(team.id)
        .text(team.get("name"))
        .on "click", ->
          currentlyHidden = team.get("hidden")
          newLineOpacity = if currentlyHidden then 1 else 0
          newLegendOpacity = if currentlyHidden then 1 else 0.4
          newLegendDecoration = if currentlyHidden then "none" else "line-through"
          team.set("hidden", !currentlyHidden)

          d3.select("#line-#{team.id}")
            .transition().duration(700)
            .style("opacity", newLineOpacity)
          d3.select("#legend-#{team.id}")
            .transition().duration(700)
            .style("opacity", newLegendOpacity)
            .style("text-decoration", newLegendDecoration)

    svg.append("text")
      .attr("x", legendX + 20)
      .attr("y", (@teams.size() + 1)  * height / 12)
      .attr("class", "legend")
      .text("(click name to hide)")


    svg.append("g")
        .attr("class", "x axis")
        .attr("transform", "translate(0," + height + ")")
        .call(xAxis)

    svg.append("g")
        .attr("class", "y axis")
        .call(yAxis)

    svg.append("text")
      .attr("class", "ylabel")
      .attr("y", 0 - margin.left) # x and y switched due to rotation!!
      .attr("x", 0 - (height / 2))
      .attr("dy", "1em")
      .attr("transform", "rotate(-90)")
      .style("text-anchor", "middle")
      .text("Standing")

    svg.append("text")
      .attr("class", "xlabel")
      .attr("text-anchor", "middle")
      .attr("x", width / 2)
      .attr("y", height + (margin.bottom / 2))
      .text("Week")

window.LeagueChartsPage = class LeagueChartsPage
  constructor: ({@matchups, @teams, @weeks}) ->

  bind: ->
    matchups = new window.APP.collections.MatchupCollection(@matchups)
    teams = new window.APP.collections.TeamCollection(@teams)

    weekStandings = {}

    _.times @weeks, (i) =>
      week = i + 1
      weekMatchups = _(matchups.where(week: week))
      teams.calculateRecords(weekMatchups)

      weekStandings[week] = teams.map (team, i) ->
        standing: i + 1
        id: team.get("id")
        name: team.get("name")
        points_for: team.get("points_for")
        points_for_str: team.pointsFor()
        wins: team.get("wins")
        losses: team.get("losses")
        ties: team.get("ties")
        week: week

    view = new ChartsView(el: $("#charts"), teams: teams, weekStandings: weekStandings, weeks: @weeks)
    view.render()
