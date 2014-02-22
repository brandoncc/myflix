Fabricator(:video) do
  title { Faker::Lorem.words(5).join(' ') }
  description { Faker::Lorem.paragraph(2) }
  category { Fabricate(:category) }
  video_url { Faker::Internet.domain_name }
end
