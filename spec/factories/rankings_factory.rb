FactoryBot.define do
  factory :ranking do
    ranking_report
    ranking_profile

    rank { 8 }
    team { "PHI" }
    bye_week { 15 }
    position { "WR1" }

    trait :standard do
      association :ranking_report, ranking_type: "standard"
    end

    trait :ppr do
      association :ranking_report, ranking_type: "standard"
    end
  end
end
