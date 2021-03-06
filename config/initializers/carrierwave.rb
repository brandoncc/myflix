if Rails.env.test? or Rails.env.cucumber?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
  end
elsif Rails.env.development?
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',                        # required
      :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],     # required
      :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'], # required
    }
    config.fog_directory  = 'brandons-myflix-dev'                     # required
    config.fog_public     = false                                   # optional, defaults to true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}

    config.storage :fog
  end
else
  CarrierWave.configure do |config|
    config.fog_credentials = {
      :provider               => 'AWS',                        # required
      :aws_access_key_id      => ENV['AWS_ACCESS_KEY_ID'],     # required
      :aws_secret_access_key  => ENV['AWS_SECRET_ACCESS_KEY'], # required
    }
    config.fog_directory  = 'brandons-myflix'                     # required
    config.fog_public     = false                                   # optional, defaults to true
    config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}

    config.storage :fog
  end
end
