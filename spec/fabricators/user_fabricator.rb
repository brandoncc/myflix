Fabricator(:user) do
  email { Faker::Internet.email }
  password { 'A5s5&^5(HGiii655' }
  full_name { Faker::Name.name }
  admin false
  locked false
end

Fabricator(:admin, from: :user) do
  admin true
end
