FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email-#{srand}@test.com" }
    sequence(:password) { |n| "password#{n}" }
    provider 'cas'
    uid do |user|
      user.email
    end
  end
end
