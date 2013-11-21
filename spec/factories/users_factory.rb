FactoryGirl.define do
  factory :user do
    sequence(:uid) {|n| "123#{n}" }
  end
end

