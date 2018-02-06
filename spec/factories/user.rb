FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email-#{n}@test.com" }
    password "password"
    guest false
    provider 'cas'
    uid do |user|
      user.email
    end

    factory :admin do
      roles [Role.find_or_create_by!(name: 'admin')]
    end
  end
end
