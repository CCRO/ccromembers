CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',       # required
    :aws_access_key_id      => 'AKIAJT3YY3EZHKYHCXDQ',       # required
    :aws_secret_access_key  => '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',       # required
  }
  config.fog_directory  = 'ccromembers_assets'                     # required
  config.fog_attributes = {'Cache-Control'=>'max-age=315576000'}  # optional, defaults to {}
end