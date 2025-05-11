module InterestingStatsService
  def self.by_matchup(matchups)
    return [] unless matchups.count > 0
    MatchupStats
      .all
      .map{ |stat_name| MatchupStats.public_send(stat_name, matchups) }
      .flatten
  end

  def self.by_team(matchup_teams)
    return [] unless matchup_teams.count > 0
    TeamStats
      .all
      .map{ |stat_name| TeamStats.public_send(stat_name, matchup_teams) }
      .flatten
  end

  module MatchupStats
    def self.all
      %w(
        point_difference
        point_total
        projected_difference
        projected_total
      )
    end

    class Stat < Struct.new(:matchup, :importance, :value, :label)
      def matchup_id
        matchup.id
      end
    end

    def self.point_difference(matchups)
      pairs = matchups.map do |matchup|
        difference = matchup.matchup_teams.map(&:points).inject(:-).abs
        [difference, matchup]
      end

      sorted = pairs.sort_by(&:first)

      high = sorted.last
      low = sorted.first

      [
        Stat.new(high.last, :high, high.first, "Point difference"),
        Stat.new(low.last, :low, low.first, "Point difference")
      ]
    end

    def self.point_total(matchups)
      pairs = matchups.map do |matchup|
        sum = matchup.matchup_teams.map(&:points).inject(:+)
        [sum, matchup]
      end

      sorted = pairs.sort_by(&:first)

      high = sorted.last
      low = sorted.first

      [
        Stat.new(high.last, :high, high.first, "Point total"),
        Stat.new(low.last, :low, low.first, "Point total")
      ]
    end

    def self.projected_difference(matchups)
      pairs = matchups.map do |matchup|
        difference = matchup.matchup_teams.map(&:projected_points).inject(:-).abs
        [difference, matchup]
      end

      sorted = pairs.sort_by(&:first)

      high = sorted.last
      low = sorted.first

      [
        Stat.new(high.last, :high, high.first, "Projected point difference"),
        Stat.new(low.last, :low, low.first, "Projected point difference")
      ]
    end

    def self.projected_total(matchups)
      pairs = matchups.map do |matchup|
        sum = matchup.matchup_teams.map(&:projected_points).inject(:+)
        [sum, matchup]
      end

      sorted = pairs.sort_by(&:first)

      high = sorted.last
      low = sorted.first

      [
        Stat.new(high.last, :high, high.first, "Projected point total"),
        Stat.new(low.last, :low, low.first, "Projected point total")
      ]
    end
  end

  module TeamStats
    def self.all
      %w(
        points
        projected_points
        projection_difference
      )
    end

    class Stat < Struct.new(:matchup_team, :importance, :value, :label)
      def team_id
        matchup_team.team.id
      end
    end

    def self.points(matchup_teams)
      pairs = matchup_teams.map do |matchup_team|
        [matchup_team.points, matchup_team]
      end

      sorted = pairs.sort_by(&:first)

      high = sorted.last
      low = sorted.first

      [
        Stat.new(high.last, :high, high.first, "Points"),
        Stat.new(low.last, :low, low.first, "Points")
      ]
    end

    def self.projected_points(matchup_teams)
      pairs = matchup_teams.map do |matchup_team|
        [matchup_team.projected_points, matchup_team]
      end

      sorted = pairs.sort_by(&:first)

      high = sorted.last
      low = sorted.first

      [
        Stat.new(high.last, :high, high.first, "Projected"),
        Stat.new(low.last, :low, low.first, "Projected")
      ]
    end

    def self.projection_difference(matchup_teams)
      pairs = matchup_teams.map do |matchup_team|
        [matchup_team.points - matchup_team.projected_points, matchup_team]
      end

      sorted = pairs.sort_by(&:first)

      high = sorted.last
      low = sorted.first

      [
        Stat.new(high.last, :high, high.first, "Projection difference"),
        Stat.new(low.last, :low, low.first, "Projection difference")
      ]
    end
  end
end
