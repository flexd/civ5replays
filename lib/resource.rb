class Resource
  include DataMapper::Resource
  include Paperclip::Resource

  property :id,     Serial

  has_attached_file :file,
                    :url => "/:attachment/:id/:style/:basename.:extension",
                    :path => "#{APP_ROOT}/public/:attachment/:id/:style/:basename.:extension"
end
