FactoryGirl.define do
  factory :league do
    name { Faker::Company.name }
    sequence(:yahoo_league_key) {|n| "999#{n}.l.888#{n}" }
    sequence(:yahoo_league_id) {|n| 300 + n }

    playoff_start_week 14

    game

    trait :synced do
      sync_started_at 3.hours.ago
      sync_finished_at 3.hours.ago
    end
  end
end
