FactoryBot.define do
  factory :menu_item do
    name { 'Menu Item' }
    price { 15 }

    association :menu, strategy: :build
  end
end