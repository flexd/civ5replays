
def unzip(filename, destination)
   command = "unzip #{filename} -d #{destination}"
   success = system(command)
   
   success && $?.exitstatus == 0
 end
GEN_PATH = "#{APP_ROOT}/public/generated/"
class ParseReplay
  @queue = :replay_parser
  def self.perform(file_id)
    @file = Resource.get(file_id)
    @path = "#{APP_ROOT}/public/files/#{@file.id}/original/"
    @file_path = "#{@path}#{@file.file_file_name}"
    @ext_path = "#{APP_ROOT}/public/files/#{@file.id}/original/extracted/"
    if @file.file_content_type == "application/x-octet-stream" then
      # assume its a civ5replay
      system("python civ5replay.py -H #{APP_ROOT}/public/generated/#{@file.replay_file} #{APP_ROOT}/public/files/#{@file.id}/original/#{@file.file_file_name}")
    elsif @file.file_content_type == "application/x-zip-compressed" then
      if unzip(@file_path,@ext_path) then
        puts "yay file extracted! #{Dir.new(@ext_path).entries.last}"
        # Bad bad hack to get the damn file.
        @ext_file = "#{@ext_path}#{Dir.new(@ext_path).entries.last}"
        @gen_file = "#{GEN_PATH}#{@file.replay_file}"
        system("python", "civ5replay.py", "-H#{@gen_file}", @ext_file)
      else
        raise "Problems unzipping file"
      end
    end
  end
end