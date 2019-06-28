FactoryBot.define do
  factory :draft_pick do
    round { 999 }
    pick { 99 }
    sequence(:yahoo_player_key) {|n| "dplayer.#{n}" }

    league
    team
  end
end
