FactoryBot.define do
  factory :menu_item do
    name { "MenuItem #{SecureRandom.hex(4)}" } # Menu Item must be unique
    price { 15 }

    association :restaurant, strategy: :build
  end
end
