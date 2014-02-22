require 'carrierwave/test/matchers'
require 'spec_helper'

describe LargeCoverUploader do
  include CarrierWave::Test::Matchers

  before do
    LargeCoverUploader.enable_processing = true
    @uploader = LargeCoverUploader.new(@video, :large_cover)
    @uploader.store!(File.open('public/covers/30_rock_large.jpg'))
  end

  after do
    LargeCoverUploader.enable_processing = false
    @uploader.remove!
  end

  it "should fit within 665x375" do
    @uploader.should be_no_larger_than(665, 375)
  end
end
