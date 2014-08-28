FactoryGirl.define do
  factory :game do
    sequence(:yahoo_game_key) {|n| 200 + n }
    yahoo_game_id { yahoo_game_key }
    name { Faker::Company.name }
    code { "asd" }
    sequence(:season) {|n| 2010 + n }
  end
end
