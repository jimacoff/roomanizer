FactoryBot.define do
  factory :room do
    title '10.T.35'

    trait :with_floor do
      floor
    end
  end
end
