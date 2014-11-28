class MatchupView extends Backbone.View
  tagName: "td"

  template: _.template """
    <% _.each(get("teams"), function(team) { %>
      <div class="radio">
        <label>
          <input type="radio" name="matchup-<%= get("id") %>" value="<%= team.id %>" <%= get("result") == team.id ? "checked" : "" %>>
          <%= team.name %>
        </label>
      </div>
    <% }); %>
    <div class="radio">
      <label>
        <input type="radio" name="matchup-<%= get("id") %>" value="unknown"<%= get("result") == "unknown" ? "checked" : "" %>>
        Unknown
      </label>
    </div>
  """
  # <div class="radio">
  #   <label>
  #     <input type="radio" name="matchup-<%= get("id") %>" value="tie" <%= get("result") == "tie" ? "checked" : "" %>>
  #     Tie
  #   </label>
  # </div>

  events:
    "change input": "radioChanged"

  render: ->
    html = @template(@model)
    $(this.el).html(html)
    return this

  radioChanged: ->
    input = @$("input:checked")
    @model.set result: input.val()

class MatchupListView extends Backbone.View
  template: _.template """
    <table class="table table-bordered">
      <thead>
      </thead>
      <tbody>
      </tbody>
    </table>
  """

  initialize: ({@weeks, @matchups}) ->

  render: ->
    @$el.html @template()

    _.times @weeks, (i) =>
      week = i + 1
      tr = $("<tr><td>Week #{week}</td></tr>")
      @matchups.where(week: week).forEach (matchup) =>
        @appendMatchup(matchup, tr)

      @$el.find("tbody").append(tr)

  appendMatchup: (matchup, tr) ->
    matchupView = new MatchupView(model: matchup)
    $(tr).append(matchupView.render().el)

class TeamOutcomesView extends Backbone.View
  tagName: "tr"

  template: _.template """
    <td><%= name %></td>
    <td><%= points_for %></td>
    <td><%= wins %>-<%= losses %></td>
    <td><%= unknowns %></td>
    <% _.times(weeks + 1, function(i){ %>
      <% record = _.find(outcomes, function(outcome){ return outcome.wins === weeks - i });  %>
      <td>
        <% if(record) { %>
          <%= record.wins %>-<%= record.losses %>
        <% } %>
      </td>
    <% }); %>
  """

  initialize: ({@weeks}) ->

  render: ->
    @$el.html @template(
      name: @model.get("name")
      points_for: @model.get("points_for")
      wins: @model.get("wins")
      losses: @model.get("losses")
      ties: @model.get("ties")
      unknowns: @model.get("unknowns")
      outcomes: @model.outcomes()
      weeks: @weeks
    )
    return this

class TeamListView extends Backbone.View
  template: _.template """
    <table class="table table-hover table-bordered">
      <thead>
        <tr>
          <th rowspan="2">Team</th>
          <th rowspan="2">Points For</th>
          <th rowspan="2">Known record</th>
          <th rowspan="2">Unknown games</th>
          <th colspan="<%= weeks + 1 %>">Possible Wins</th>
        </tr>
        <tr>
          <% _.times(weeks + 1, function(i){ %>
            <th>
              <%= weeks - i %>
            </th>
          <% }); %>
        </tr>
      </thead>
      <tbody>
      </tbody>
    </table>
  """

  initialize: ({@teams, @weeks}) ->
    @teams.bind "recalculated", this.render, this

  render: ->
    @$el.html @template(weeks: @weeks)

    @teams.forEach (team) =>
      view = new TeamOutcomesView model: team, weeks: @weeks
      @$el.find("tbody").append(view.render().el)

window.LeaguePlayoffsPage = class LeaguePlayoffsPage
  constructor: ({@matchups, @teams, @weeks}) ->

  bind: ->
    matchups = new window.APP.collections.MatchupCollection(@matchups)
    teams = new window.APP.collections.TeamCollection(@teams)

    teams.calculateRecords(matchups)
    matchups.on "change", ->
      teams.calculateRecords(matchups)

    matchupListView = new MatchupListView(el: $("#playoffs-matchups"), matchups: matchups, weeks: @weeks)
    matchupListView.render()

    teamListView = new TeamListView(el: $("#playoffs-outcomes"), teams: teams, weeks: @weeks)
    teamListView.render()

