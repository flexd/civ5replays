require './environment'

class Job
  @queue = :replay_parser
  def self.perform(file_id)
    puts "Hello #{file_id}"
  #  @file = Resource.get(file_id)
   # if @file.file_content_type == "application/x-octet-stream" then
    #  # assume its a civ5replay
     # system("python civ5replay.py -H #{APP_ROOT}/public/generated/#{@file.replay_file} #{APP_ROOT}/public/files/#{@file.id}/original/#{@file.file_file_name}")
    #elsif @file.file_content_type == "application/x-zip-compressed" then
     # system("unzip #{APP_ROOT}/public/files/#{@file.id}/original/#{@file.file_file_name}")
      #system("python civ5replay.py -H #{APP_ROOT}/public/generated/#{@file.replay_file} #{APP_ROOT}/public/files/#{@file.id}/original/#{@file.file_file_name}")
    #end
  end
end