require 'spec_helper'

describe VideoSearchDecorator do
  describe '#decorate' do
    it 'references object that was passed in' do
      video = Fabricate.build(:video)
      expect(VideoSearchDecorator.decorate(video).object).to eq(video)
    end

    it 'returns a decorator object' do
      video = Fabricate.build(:video)
      expect(VideoSearchDecorator.decorate(video)).to be_instance_of(VideoSearchDecorator)
    end
  end

  describe '#decorate_collection' do
    it 'decorates each element of the array' do
      videos = [
        Fabricate.build(:video),
        Fabricate.build(:video)
      ]

      expect(VideoSearchDecorator.decorate_collection(videos)[0]).to be_instance_of(VideoSearchDecorator)
      expect(VideoSearchDecorator.decorate_collection(videos)[1]).to be_instance_of(VideoSearchDecorator)
    end

    it 'returns an instance of VideoSearchDecoratorCollection' do
      videos = [
        Fabricate.build(:video),
        Fabricate.build(:video)
      ]

      expect(VideoSearchDecorator.decorate_collection(videos)).to be_instance_of(VideoSearchDecoratorCollection)
    end
  end

  describe '#title' do
    context 'there was a match' do
      it 'returns the highlighted title' do
        video = OpenStruct.new(
          "title" => "the title",
          "highlight" => { "title" => ["the <em>title</em>"] }
        )

        expect(VideoSearchDecorator.decorate(video).title).to eq('the <em>title</em>')
      end
    end

    context 'there was no match' do
      it 'returns the objects title' do
        video = OpenStruct.new(
          "title" => "the title",
          "highlight" => {}
        )

        expect(VideoSearchDecorator.decorate(video).title).to eq('the title')
      end
    end
  end

  describe '#description' do
    context 'there was a match' do
      it 'returns the highlighted description' do
        video = OpenStruct.new(
          "description" => "the description",
          "highlight" => { "description" => ["the <em>description</em>"] }
        )

        expect(VideoSearchDecorator.decorate(video).description).to eq('the <em>description</em>')
      end
    end

    context 'there was no match' do
      it 'returns the objects description' do
        video = OpenStruct.new(
          "description" => "the description",
          "highlight" => {}
        )

        expect(VideoSearchDecorator.decorate(video).description).to eq('the description')
      end
    end
  end

  describe '#first_review' do
    context 'there are reviews' do
      context 'there was a match' do
        it 'returns the highlighted review body' do
          video = OpenStruct.new(
            "reviews" => [
              { "body" => "the body" }
            ],
            "highlight" => { "reviews.body" => ["the <em>body</em>"] }
          )

          expect(VideoSearchDecorator.decorate(video).first_review).to eq('the <em>body</em>')
        end
      end

      context 'there was no match' do
        it 'returns the review description' do
          video = OpenStruct.new(
            "reviews" => [
              OpenStruct.new(body: 'the body')
            ],
            "highlight" => {}
          )

          expect(VideoSearchDecorator.decorate(video).first_review).to eq('the body')
        end
      end
    end

    context 'there are no reviews' do
      it 'returns no reviews message' do
          video = OpenStruct.new(
            "reviews" => [],
            "highlight" => {}
          )

          expect(VideoSearchDecorator.decorate(video).first_review).to eq('There are currently no reviews.')
      end
    end
  end
end
