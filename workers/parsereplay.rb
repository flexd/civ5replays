def parse(filename, destination, map)
  if not map.blank? then
    success = system("python lib/parser/civ5replay.py -H #{destination} #{APP_ROOT}/public/#{filename} -m #{APP_ROOT}/public/#{map}")
  else
    success = system("python lib/parser/civ5replay.py -H #{destination} #{APP_ROOT}/public/#{filename}")
  end
  success && $?.exitstatus == 0
end
class ParseReplay
  @queue = :replay_parser
  def self.perform(id)
    @replay = Replay.find(id)
    tempfile = @replay.original.current_path.scan(/[\/]#{@replay.id}\/(.+)[.]/).first.first
    temppath = "#{APP_ROOT}/public/uploads/tmp/" + tempfile + ".html"
    if @replay.original.current_path =~ /[.]civ5replay/ then
      # It's a .civ5replay file
      if parse(@replay.original, temppath, @replay.map) then
        # python script has generated a html in tf, lets save it
        begin
          @replay.replay = File.open(temppath)
          @replay.generated = true
          puts "Error saving generated replay!" unless @replay.save!
        rescue CarrierWave::IntegrityError
          puts "Wrong file?"
          p @replay.errors.full_messages
        end
      else
        @replay.generated = false
        @replay.save!
        raise "Catastrophic failure parsing :-D"     
      end
    end
  end
end
