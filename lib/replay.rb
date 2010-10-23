#require 'carrierwave/orm/datamapper' 

class Replay
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :description, Text, :required => true, :length => 0..150
  property :original_file, String, :auto_validation => false
  property :replay_file, String, :auto_validation => false
  mount_uploader :original, OriginalUploader, :mount_on => :original_file
 # mount_uploader :replay, ReplayUploader, :mount_on => :replay_file
  
  before :create, :generate_name
  
  def async_parse
    Resque.enqueue(ParseReplay, self.id) 
  end
  def generate_name
    self.name = rand(32**8).to_s(32)
  end
end