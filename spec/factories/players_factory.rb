FactoryGirl.define do
  factory :player do
    sequence(:yahoo_player_key) {|n| "player.#{n}" }
    sequence(:yahoo_player_id) {|n| "ddplayer.#{n}" }
    game
  end
end
