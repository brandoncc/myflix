Fabricator(:user) do
  email { Faker::Internet.email }  
  name { Faker::Name.name }
  password {'12345'}
  admin false
end

Fabricator(:admin, from: :user) do
  admin true
end