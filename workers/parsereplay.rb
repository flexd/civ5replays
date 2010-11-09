def unzip(filename, destination)
   command = "unzip #{filename} -d #{destination}"
   success = system(command)
   
   success && $?.exitstatus == 0
end
def parse(filename, destination, map)
  if not map.blank? then
    success = system("python civ5replay.py -H #{destination} #{APP_ROOT}/public/#{filename} -m #{APP_ROOT}/public/#{map}")
  else
    success = system("python civ5replay.py -H #{destination} #{APP_ROOT}/public/#{filename}")
  end
  success && $?.exitstatus == 0
end
class ParseReplay
  @queue = :replay_parser
  def self.perform(id)
   # puts "We got this far?"
    @replay = Replay.find(id)
   # puts "but not this far?"
    tempfile = @replay.original.current_path.scan(/[\/]#{@replay.id}\/(.+)[.]/).first.first
    temppath = "#{APP_ROOT}/public/uploads/tmp/" + tempfile + ".html"
   # puts "and this far!"
  #  puts "temppath: #{temppath.inspect}"
   # tempfile = temppath + tempfile.first
    if @replay.original.current_path =~ /[.]civ5replay/ then
      # It's a .civ5replay file
      if parse(@replay.original, temppath, @replay.map) then
        # python script has generated a html in tf, lets save it
        begin
          @replay.replay = File.open(temppath)
          puts "Error saving generated replay!" unless @replay.save!
        rescue CarrierWave::IntegrityError
          puts "wrong file silly"
          p @replay.errors.full_messages
        end
        puts "@replay.replay is: #{@replay.replay.inspect} - tf is: #{temppath.inspect}"
      else 
        raise "Catastrophic failure parsing :-D"
      end
    end
  end
end