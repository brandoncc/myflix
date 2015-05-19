# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Video.create(title: 'SouthPark', description: 'some thing funny', small_cover_url: '/tmp/south_park.jpg', large_cover_url: '/tmp/south_park.jpg')
# Video.create(title: 'Family guy', description: 'some thing funny', small_cover_url: '/tmp/family_guy.jpg', large_cover_url: '/tmp/family_guy.jpg')
# Video.create(title: 'Monk', description: 'some thing funny', small_cover_url: '/tmp/monk_large.jpg', large_cover_url: '/tmp/monk.jpg')
# Video.create(title: 'Futurama', description: 'some thing funny', small_cover_url: '/tmp/futurama.jpg', large_cover_url: '/tmp/futurama.jpg')

# Review.create(user_id: 6, video_id: 1, rating: 4, body: 'testing123')
# Review.create(user_id: 7, video_id: 1, rating: 4, body: 'testing123')
# Review.create(user_id: 12, video_id: 1, rating: 4,body: 'testing123')

User.create(name: 'yufei', email: 'test@test.com', password: '12345')
User.create(name: 'peter', email: 'test2@test.com', password: '12345')

# Category.create(name: 'TV Show')

# VideoCategory.create(video_id: 1, category_id: 1)
# VideoCategory.create(video_id: 2, category_id: 1)
# VideoCategory.create(video_id: 3, category_id: 1)
# VideoCategory.create(video_id: 4, category_id: 1)