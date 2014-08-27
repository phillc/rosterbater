FactoryGirl.define do
  factory :league do
    name { Faker::Company.name }
    sequence(:yahoo_league_key) {|n| "999#{n}.l.888#{n}" }
    sequence(:yahoo_league_id) {|n| 300 + n }
  end
end
