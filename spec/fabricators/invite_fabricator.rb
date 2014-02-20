Fabricator(:invite) do
  name { Faker::Name.name }
  email { Faker::Internet.email }
  message { Faker::Lorem.paragraphs(2).join(' ') }
end
