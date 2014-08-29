FactoryGirl.define do
  factory :ranking do
    ranking_report
    ranking_profile

    rank 8

    trait :standard do
      association :ranking_report, ranking_type: "standard"
    end

    trait :ppr do
      association :ranking_report, ranking_type: "standard"
    end
  end
end
