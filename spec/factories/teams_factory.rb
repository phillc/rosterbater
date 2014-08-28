FactoryGirl.define do
  factory :team do
    name { Faker::Company.name }
    sequence(:yahoo_team_key) {|n| "tplayer.#{n}" }
    sequence(:yahoo_team_id) {|n| "tidplayer.#{n}" }

    league
  end
end
