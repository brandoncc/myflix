require 'spec_helper'

describe Video do
  it { should belong_to(:category) }
  it { should have_many(:reviews) }
  it { should validate_presence_of(:title) }
  it { should validate_presence_of(:description) }
  it { should validate_presence_of(:video_url) }
  it { should have_many(:queue_items) }

  describe '::search_by_title' do
    it 'allows case-insensitive searches' do
      sons_of_anarchy = Fabricate(:video, title: 'Sons of Anarchy - Pilot')
      expect(Video.search_by_title('anarchy')).to eq([sons_of_anarchy])
    end

    it 'returns an empty array if no videos match' do
      Fabricate(:video, title: 'Sons of Anarchy - Pilot')
      expect(Video.search_by_title('Sesame Street')).to eq([])
    end

    it 'returns an array with one item if one video matches exactly' do
      sons_of_anarchy = Fabricate(:video, title: 'Sons of Anarchy - Pilot')
      expect(Video.search_by_title('Sons of Anarchy - Pilot')).to eq([sons_of_anarchy])
    end

    it 'returns an array with one item if one video partially matches' do
      sons_of_anarchy = Fabricate(:video, title: 'Sons of Anarchy - Pilot')
      expect(Video.search_by_title('Anarchy')).to eq([sons_of_anarchy])
    end

    it 'returns an array of all matching videos ordered by created_at' do
      sons_of_anarchy_1 = Fabricate(:video, title: 'Sons of Anarchy - Pilot')
      sons_of_anarchy_2 = Fabricate(:video, title: 'Sons of Anarchy - Ep 2')
      sons_of_anarchy_3 = Fabricate(:video, title: 'Sons of Anarchy - Ep 3')
      Fabricate(:video, title: 'House, M.D. - Pilot')
      expect(Video.search_by_title('Anarchy')).to eq([sons_of_anarchy_3, sons_of_anarchy_2, sons_of_anarchy_1])
    end

    it 'returns an empty array if search string is empty' do
      Fabricate(:video, title: 'House, M.D. - Pilot')
      expect(Video.search_by_title('')).to eq([])
    end
  end

  describe '#average_rating' do
    let(:video) { Fabricate(:video) }
    before do
      [3, 1, 4].each { |rating| Fabricate(:review, rating: rating, video: video) }
    end

    it 'returns a float' do
      expect(video.average_rating).to be_instance_of(Float)
    end

    it 'has a maximum of 1 number after the decimal' do
      expect(video.average_rating).to eq(2.7)
    end
  end

  describe 'reviews relation' do
    it 'returns reviews in reverse chronological order' do
      video = Fabricate(:video)
      first_review = Fabricate(:review, video: video, created_at: 3.days.ago)
      second_review = Fabricate(:review, video: video, created_at: 2.days.ago)
      third_review = Fabricate(:review, video: video, created_at: 1.days.ago)
      expect(video.reviews).to eq([third_review, second_review, first_review])
    end
  end

  describe '.search', elasticsearch: true do
    let(:refresh_index) do
      Video.import
      Video.__elasticsearch__.refresh_index!
    end

    context 'with title' do
      it 'returns no results when no match' do
        Fabricate(:video, title: 'Green apples', description: 'Green apples')
        refresh_index

        expect(Video.search('Red').records.to_a).to eq([])
      end

      it 'returns an array of 1 video for title case insensitive match' do
        apples = Fabricate(:video, title: 'Green apples', description: 'Green apples')
        Fabricate(:video, title: 'Red apples', description: 'Red apples')
        refresh_index

        expect(Video.search('green').records.to_a).to eq([apples])
      end

      it 'returns an array of many videos for title match' do
        apples = Fabricate(:video, title: 'Green apples', description: 'Green apples')
        balls = Fabricate(:video, title: 'Green balls', description: 'Green balls')
        cars = Fabricate(:video, title: 'Green cars', description: 'Green cars')
        trucks = Fabricate(:video, title: 'Green trucks', description: 'Green trucks')
        airplanes = Fabricate(:video, title: 'Green airplanes', description: 'Green airplanes')
        Fabricate(:video, title: 'Red apples', description: 'Red apples')
        refresh_index

        expect(Video.search('green').records.to_a).to match_array([apples, balls, cars, trucks, airplanes])
      end
    end

    context 'with title and description' do
      it 'returns an array of many videos based on title and description match' do
        match_title = Fabricate(:video, title: 'Cool stuff', description: 'hot cars')
        match_description = Fabricate(:video, title: 'other stuff', description: 'cool cars')
        Fabricate(:video, title: 'no', description: 'match')
        refresh_index

        expect(Video.search('cool').records.to_a).to match_array([match_title, match_description])
      end
    end

    context 'multiple words must match' do
      it 'returns an array of videos where 2 words match term' do
        Fabricate(:video, title: 'red cats and horses', description: 'the cat stuff')
        Fabricate(:video, title: 'dogs and horses', description: 'the dog stuff')
        should_match_1 = Fabricate(:video, title: 'red cats and dogs')
        should_match_2 = Fabricate(:video, description: 'red cats and dogs')
        refresh_index

        expect(Video.search('red dog').records.to_a).to match_array([should_match_1, should_match_2])
      end
    end
  end
end
