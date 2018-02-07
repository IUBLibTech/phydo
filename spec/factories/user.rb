FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "email-#{n}@test.com" }
    password "password"
    guest false
    provider 'cas'
    uid do |user|
      user.email
    end
  end
end
