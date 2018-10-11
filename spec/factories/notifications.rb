FactoryGirl.define do
  factory :notification do
    # summary 'My summary'
    # description 'My description'
    sequence(:summary) { |n| "Summary #{n}" }
    sequence(:description) { |n| "Description #{n}" }
  end
end
