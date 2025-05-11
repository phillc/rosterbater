FactoryBot.define do
  factory :user do
    sequence(:yahoo_uid) {|n| "123#{n}" }
  end
end

