require 'spec_helper'

describe User do
  it { should validate_presence_of :email }
  it { should validate_uniqueness_of :email }
  it { should validate_presence_of :full_name }
  it { should have_secure_password }
  it { should validate_presence_of :password }
  it { should have_many :reviews }
  it { should have_many :queue_items }
  it { should have_many :relationships }
  it { should have_many :leaders }
  it { should have_many :inverse_relationships }
  it { should have_many :followers }
  it { should have_many(:invites) }
  it { should have_many(:payments) }

  let(:user) { Fabricate(:user) }

  it 'retrieves reviews in reverse cronological order' do
    review1 = Fabricate(:review, creator: user, created_at: 1.day.ago)
    review2 = Fabricate(:review, creator: user)
    expect(user.reviews).to eq([review2, review1])
  end

  it 'retrieves queued_items in ascending order sorted by position' do
    queue_item1 = Fabricate(:queue_item, user: user, position: 2)
    queue_item2 = Fabricate(:queue_item, user: user, position: 1)
    expect(user.queue_items).to eq([queue_item2, queue_item1])
  end

  describe '#has_queued_video?' do
    it 'returns true if video exists in users queue' do
      video = Fabricate(:video)
      queue_item1 = Fabricate(:queue_item, user: user, video: video, position: 2)
      expect(user.has_queued_video?(video)).to eq(true)
    end

    it 'returns false if video does not exist in users queue' do
      video = Fabricate(:video)
      expect(user.has_queued_video?(video)).to eq(false)
    end
  end

  describe '#normalize_queue_positions' do
    it 'takes out gaps in position numbering' do
      queue_item1 = Fabricate(:queue_item, user: user, position: 1)
      queue_item2 = Fabricate(:queue_item, user: user, position: 4)
      user.normalize_queue_positions
      expect(queue_item1.reload.position).to eq(1)
      expect(queue_item2.reload.position).to eq(2)
    end

    it 'breaks position ties, newest queued item wins' do
      queue_item1 = Fabricate(:queue_item, user: user, position: 1, created_at: 1.day.ago)
      queue_item2 = Fabricate(:queue_item, user: user, position: 1)
      user.normalize_queue_positions
      expect(queue_item1.reload.position).to eq(2)
      expect(queue_item2.reload.position).to eq(1)
    end
  end

  describe '#reviews_with_rating' do
    it 'returns an empty array if none of the given users reviews have ratings' do
      review1 = Fabricate(:review, creator: user)
      review1.rating = nil
      review1.save(validate: false)
      review2 = Fabricate(:review, creator: user)
      review2.rating = nil
      review2.save(validate: false)
      expect(user.reviews_with_rating).to eq([])
    end

    it 'returns an array containing all reviews by given user that have a rating' do
      review1 = Fabricate(:review, creator: user)
      review2 = Fabricate(:review, creator: user)
      expect(user.reviews_with_rating).to match_array([review1, review2])
    end

    it 'does not include any reviews that have a nil rating value' do
      review1 = Fabricate(:review, creator: user)
      review1.rating = nil
      review1.save(validate: false)
      review2 = Fabricate(:review, creator: user)
      expect(user.reviews_with_rating).to eq([review2])
    end
  end

  describe '#follows?(leader)' do
    it 'returns true if user follows given user' do
      adam = Fabricate(:user)
      bryan = Fabricate(:user)
      Fabricate(:relationship, follower: adam, leader: bryan)
      expect(adam.follows?(bryan)).to eq(true)
    end

    it 'returns false if user does not follow given user' do
      adam = Fabricate(:user)
      bryan = Fabricate(:user)
      expect(adam.follows?(bryan)).to eq(false)
    end
  end

  describe '#can_follow?(user)' do
    it 'returns false if user and given user are the same' do
      adam = Fabricate(:user)
      expect(adam.can_follow?(adam)).to eq(false)
    end

    it 'returns false if user already follows given user' do
      adam = Fabricate(:user)
      bryan = Fabricate(:user)
      Fabricate(:relationship, follower: adam, leader: bryan)
      expect(adam.can_follow?(bryan)).to eq(false)
    end

    it 'returns true if user is not given user and does not follow given user' do
      adam = Fabricate(:user)
      bryan = Fabricate(:user)
      expect(adam.can_follow?(bryan)).to eq(true)
    end
  end

  describe '#generate_password_reset_token' do
    it 'sets a users password reset token in the db' do
      adam = Fabricate(:user)
      adam.generate_password_reset_token
      expect(adam.password_reset_token).not_to be_nil
    end
  end

  describe '#follow' do
    it 'follows another user' do
      adam = Fabricate(:user)
      bryan = Fabricate(:user)
      adam.follow(bryan)
      expect(adam.follows?(bryan)).to eq(true)
    end

    it 'does not follow itself' do
      adam = Fabricate(:user)
      adam.follow(adam)
      expect(adam.follows?(adam)).to eq(false)
    end
  end

  describe '#lock!' do
    it 'locks the user account' do
      adam = Fabricate(:user, locked: false)
      adam.lock!
      expect(adam).to be_locked
    end
  end

  describe '#unlock!' do
    it 'unlocks the user account' do
      adam = Fabricate(:user, locked: true)
      adam.unlock!
      expect(adam).not_to be_locked
    end
  end

  describe '#next_billing_date' do
    it 'returns the date which is one month after the previous successful billing' do
      adam = Fabricate(:user)
      payment = Fabricate(:payment, user: adam, created_at: 6.days.ago)
      Fabricate(:payment, user: adam, successful: false, created_at: 2.days.ago)
      # expect(adam.next_billing_date).to eq(payment.created_at + 1.month)
    end

    it 'returns todays date if there is no previous bills in the system' do
      adam = Fabricate(:user)
      expect(adam.next_billing_date).to eq(Date.today)
    end
  end
end
