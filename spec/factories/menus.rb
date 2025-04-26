FactoryBot.define do
  factory :menu do
    name { 'Test' }

    association :restaurant, strategy: :build
  end
end
