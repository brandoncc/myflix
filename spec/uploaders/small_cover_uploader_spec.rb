require 'carrierwave/test/matchers'
require 'spec_helper'

describe SmallCoverUploader do
  include CarrierWave::Test::Matchers

  before do
    SmallCoverUploader.enable_processing = true
    @uploader = SmallCoverUploader.new(@video, :small_cover)
    @uploader.store!(File.open('public/covers/30_rock_small.jpg'))
  end

  after do
    SmallCoverUploader.enable_processing = false
    @uploader.remove!
  end

  it "should fit within 166x236" do
    @uploader.should be_no_larger_than(166, 236)
  end
end
