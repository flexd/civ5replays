class MapUploader < CarrierWave::Uploader::Base
  storage :file
  def store_dir
    "#{APP_ROOT}/public/uploads/#{model.id}"
  end
  
  def extension_white_list
    %w(civ5map)
  end
end