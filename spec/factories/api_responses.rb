FactoryBot.define do
  factory :api_response, class: Hash do
    skip_create
    initialize_with { attributes }

    trait :success do
      status { 'ok' }
      message { 'API is running' }
    end

    trait :error do
      status { 'error' }
      message { 'Something went wrong' }
    end

    trait :game_created do
      status { 'ok' }
      game_id { Faker::Alphanumeric.alphanumeric(number: 10) }
    end
  end
end 