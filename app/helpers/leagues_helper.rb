module LeaguesHelper
  def ranking_class(pick)
    html_class = case rank = pick.vs_yahoo_ranking
    when 13..24
      "good-4"
    when 7..12
      "good-3"
    when 4..6
      "good-2"
    when 1..3
      "good-1"
    when 0
      "even"
    when -3..-1
      "bad-1"
    when -6..-4
      "bad-2"
    when -12..-7
      "bad-3"
    when -24..-13
      "bad-4"
    else
      if !rank
        ""
      elsif rank >= 25
        "good-5"
      elsif rank <= -25
        "bad-5"
      end
    end
  end
end
