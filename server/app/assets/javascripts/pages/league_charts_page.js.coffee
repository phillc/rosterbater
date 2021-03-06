class ChartsView extends Backbone.View
  template: _.template """
    <div class="page-header"><h4>Standings</h4></div>
    <div id="standings-chart"></div>
    <div class="page-header"><h4>Points per week</h4></div>
    <div id="points-per-week-chart"></div>
    <div class="page-header"><h4>Points (cumulative)</h4></div>
    <div id="points-chart"></div>
    <div class="page-header"><h4>Projection per week</h4></div>
    <div id="projection-per-week-chart"></div>
    <div class="page-header"><h4>Projection (cumulative)</h4></div>
    <div id="total-projection-chart"></div>
    <div class="page-header"><h4>Performance (actual - projected)</h4></div>
    <div id="points-performance-chart"></div>
    <div class="page-header"><h4>Performance (cumulative)</h4></div>
    <div id="points-total-performance-chart"></div>
    <div class="page-header"><h4>Points differential vs opponent</h4></div>
    <div id="points-differential-chart"></div>
  """

  initialize: ({@teams, @weekStandings, @weeks}) ->

  render: ->
    @$el.html @template()

    @renderStandingsChart
      selector: "#standings-chart"
    @renderPointsChart
      selector: "#points-per-week-chart"
      yLabel: "Points"
      dataPoint: "week_points_for"
    @renderPointsChart
      selector: "#points-chart"
      yLabel: "Points (cumulative)"
      dataPoint: "points_for"
    @renderPointsChart
      selector: "#projection-per-week-chart"
      yLabel: "Points"
      dataPoint: "week_projection"
    @renderPointsChart
      selector: "#total-projection-chart"
      yLabel: "Projection (cumulative)"
      dataPoint: "total_projection"
    @renderPointsChart
      selector: "#points-performance-chart"
      yLabel: "actual - projected"
      dataPoint: "week_performance"
    @renderPointsChart
      selector: "#points-total-performance-chart"
      yLabel: "actual - projected"
      dataPoint: "total_performance"
    @renderPointsChart
      selector: "#points-differential-chart"
      yLabel: "Points for - points against"
      dataPoint: "week_differential"

  renderPointsChart: ({yLabel, dataPoint, selector}) ->
    margin = { top: 30, right: 400, bottom: 70, left: 75 }
    width = 1000 - margin.left - margin.right
    height = 600 - margin.top - margin.bottom

    x = d3.scaleLinear()
      .domain([1, @weeks])
      .range([0, width])

    pointsExtents = []
    _(@weeks).times (i) =>
      week = i + 1
      pointsExtents = pointsExtents.concat(d3.extent @weekStandings[week], (d) -> d[dataPoint])

    y = d3.scaleLinear()
      .domain(d3.extent(pointsExtents))
      .range([height, 0])

    xAxis = d3.axisBottom().scale(x)
        .ticks(@weeks)

    yAxis = d3.axisLeft().scale(y)
        .ticks(@teams.size())

    pointsLine = d3.line()
      .x (d) -> x(d.week)
      .y (d) -> y(d[dataPoint])

    options =
      selector: selector
      height: height
      width: width
      margin: margin
      line: pointsLine
      xAxis: xAxis
      yAxis: yAxis
      yLabel: yLabel
    svg = @createSvg(options)
    @addData(svg, options)
    @addAxis(svg, options)

  renderStandingsChart: ({selector}) ->
    margin = { top: 30, right: 400, bottom: 70, left: 75 }
    width = 1000 - margin.left - margin.right
    height = Math.max(200, @teams.size() * 30) - margin.top - margin.bottom

    x = d3.scaleLinear()
      .domain([1, @weeks])
      .range([0, width])
    y = d3.scaleLinear()
      .domain([@teams.size(), 1])
      .range([height, 0])

    xAxis = d3.axisBottom().scale(x)
        .ticks(@weeks)

    yAxis = d3.axisLeft().scale(y)
        .ticks(@teams.size())

    standingLine = d3.line()
      .x (d) -> x(d.week)
      .y (d) -> y(d.standing)

    options =
      selector: selector
      height: height
      width: width
      margin: margin
      line: standingLine
      xAxis: xAxis
      yAxis: yAxis
      yLabel: "Standing"
    svg = @createSvg(options)
    @addData(svg, options)
    @addAxis(svg, options)

  createSvg: ({selector, width, height, margin}) ->
    d3.select(selector)
      .append("svg")
      .attr("width", width + margin.left + margin.right)
      .attr("height", height + margin.top + margin.bottom)
      .append("g")
      .attr("transform", "translate(" + margin.left + "," + margin.top + ")")


  addData: (svg, {height, width, margin, line, selector}) ->
    legendX = width + margin.right / 15
    legendX2 = width + (margin.right / 2) + 25
    color = d3.scaleOrdinal(d3.schemeTableau10)

    hideTeam = (team) ->
      d3.select("#{selector} #line-#{team.id}")
        .transition()
        .duration(700)
        .style("opacity", 0)
      d3.select("#{selector} #legend-#{team.id}")
        .transition()
        .duration(700)
        .style("opacity", 0)
    showTeam = (team) ->
      d3.select("#{selector} #line-#{team.id}")
        .transition()
        .duration(700)
        .style("opacity", 1)
      d3.select("#{selector} #legend-#{team.id}")
        .transition()
        .duration(700)
        .style("opacity", 1)

    svg.append("text")
      .attr("x", legendX2)
      .attr("y", height)
      .attr("class", "legend")
      .text("(show all)")
      .on "click", =>
        @teams.each (team) ->
          showTeam(team)

    @teams.map (team, teamIndex) =>
      teamY = teamIndex * height / (@teams.size() + 1)
      values = _.times @weeks, (i) =>
        week = i + 1
        _(@weekStandings[week]).findWhere(id: team.get("id"))

      svg.append("path")
        .style "stroke", -> color(team.id)
        .attr "id", "line-#{team.id}"
        .attr "class", "line-path"
        .attr "d", line(values)
        .attr "fill", "none"
        .attr "stroke-width", "3"

      svg.append("text")
        .attr("x", legendX)
        .attr("y", teamY)
        .attr("class", "legend")
        .attr("id", "legend-#{team.id}")
        .style "fill", -> color(team.id)
        .text(team.get("name"))

      svg.append("text")
        .attr("x", legendX2)
        .attr("y", teamY)
        .attr("class", "legend")
        .style "fill", -> color(team.id)
        .text("(hide)")
        .on "click", ->
          hideTeam(team)
      svg.append("text")
        .attr("x", legendX2 + 40)
        .attr("y", teamY)
        .attr("class", "legend")
        .style "fill", -> color(team.id)
        .text("(show)")
        .on "click", ->
          showTeam(team)
      svg.append("text")
        .attr("x", legendX2 + 90)
        .attr("y", teamY)
        .attr("class", "legend")
        .style "fill", -> color(team.id)
        .text("(show only)")
        .on "click", =>
          @teams.each (t) ->
            if t.id == team.id
              showTeam(t)
            else
              hideTeam(t)

  addAxis: (svg, {height, width, xAxis, yAxis, yLabel, margin}) ->
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
      .text(yLabel)

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
        week_points_for: team.get("last_points_for")
        week_projection: team.get("last_projection")
        total_projection: team.get("projection")
        week_performance: team.lastPerformance()
        total_performance: team.performance()
        week_differential: team.lastDifferential()
        wins: team.get("wins")
        losses: team.get("losses")
        ties: team.get("ties")
        week: week

    view = new ChartsView(el: $("#charts"), teams: teams, weekStandings: weekStandings, weeks: @weeks)
    view.render()
