class Replay
  include Mongoid::Document
  field :description
  mount_uploader :original, OriginalUploader
  mount_uploader :replay, ReplayUploader
  
  def async_parse
    Resque.enqueue(ParseReplay, self.id) 
  end
end


  