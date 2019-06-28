FactoryBot.define do
  factory :ranking_profile do
    game
    name { Faker::Name.name }
  end
end
