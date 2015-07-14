require 'spec_helper'

describe VideoSearchDecoratorCollection do
  describe '.new' do
    it 'assigns the object to @objects' do
      videos = [
        Fabricate.build(:video),
        Fabricate.build(:video)
      ]

      expect(VideoSearchDecoratorCollection.new(videos).objects).to eq(videos)
    end

    it 'creates a decorated array' do
      jungle_book = double(:jungle_book)
      fantasia = double(:fantasia)
      videos = [jungle_book, fantasia]

      collection = VideoSearchDecoratorCollection.new(videos)

      expect(collection[0]).to be_instance_of(VideoSearchDecorator)
      expect(collection[1]).to be_instance_of(VideoSearchDecorator)
    end
  end
end
