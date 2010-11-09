class ReplayUploader < CarrierWave::Uploader::Base
  storage :file
  def store_dir
    "#{APP_ROOT}/public/replays/#{model.id}"
  end
end