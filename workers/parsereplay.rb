def unzip(filename, destination)
   command = "unzip #{filename} -d #{destination}"
   success = system(command)
   
   success && $?.exitstatus == 0
 end
class ParseReplay
  @queue = :replay_parser
  def self.perform(id)
    @replay = Replay.get(id)
    tempfile = @replay.original.current_path.scan(/[\/]#{@replay.name}\/(.+)[.]/).first.first
    temppath = "#{APP_ROOT}/public/uploads/tmp/" + tempfile + ".html"
  #  puts "temppath: #{temppath.inspect}"
   # tempfile = temppath + tempfile.first
    if @replay.original.current_path =~ /[.]civ5replay/ then
      # It's a .civ5replay file
      system("python civ5replay.py -H #{temppath} #{APP_ROOT}/public/#{@replay.original}")
      # python script has generated a html in tf, lets save it
      @replay.replay_file = File.read(temppath)
      #tempfile.close
      raise "Horrible errror!" unless @replay.save
      p @replay.errors.full_messages
      #puts "@replay.replay is: #{@replay.replay_file.inspect} - tf is: #{temppath.inspect}" 
    end
  end
end