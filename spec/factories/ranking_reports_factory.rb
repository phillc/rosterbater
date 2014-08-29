FactoryGirl.define do
  factory :ranking_report do
    game
    period "draft"
    ranking_type "standard"

    trait :standard do
      ranking_type "standard"
    end

    trait :ppr do
      ranking_type "ppr"
    end
  end
end
