class OriginalUploader < CarrierWave::Uploader::Base
  storage :file
  def store_dir
    "#{APP_ROOT}/public/uploads/#{model.name}"
  end
  
  def extension_white_list
    %w(civ5replay zip)
  end
end