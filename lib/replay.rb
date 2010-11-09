class Replay
  include Mongoid::Document
  field :description
  mount_uploader :original, OriginalUploader
  mount_uploader :replay, ReplayUploader
  
  validates_presence_of :description
  validates_presence_of :original
  def async_parse
    Resque.enqueue(ParseReplay, self.id) 
  end
end


  