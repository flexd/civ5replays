require './environment'
class Resource
  include DataMapper::Resource
  include Paperclip::Resource

  property :id,     Serial
  property :replay_file, String

  has_attached_file :file,
                    :url => "/:attachment/:id/:style/:basename.:extension",
                    :path => "#{APP_ROOT}/public/:attachment/:id/:style/:basename.:extension"
  before :create, :generate_replay_file
  #before :save, :validate_filetype
#  def validate_filetype
  #  unless self.file_content_type == "application/x-octet-stream" then halt 409, "This is not a Civ 5 replay" end
  #end
  def async_generate_replay
    Resque.enqueue(Job, self.id) 
  end
  def generate_replay_file
    self.replay_file = rand(32**8).to_s(32) + ".html"
  end
end
