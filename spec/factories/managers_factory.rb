FactoryGirl.define do
  factory :manager do
    sequence(:guid) {|n| "456#{n}" }
    sequence(:yahoo_manager_id) {|n| n }
    team
  end
end
