FactoryBot.define do
  factory :task do
    description { "Test Description" }
    title { "Test Title" }
    due_date { 1.day.from_now.to_date }
    status { "pending" }

    user
  end
end
