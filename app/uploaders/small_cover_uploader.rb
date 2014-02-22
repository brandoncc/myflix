# encoding: utf-8

class SmallCoverUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick

  process :resize_to_fit => [166, 236]

  def store_dir
    if Rails.env.test? or Rails.env.cucumber?
      "uploads/testing"
    else
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    end
  end
end
