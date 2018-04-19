class Track
  class Editor
    class Edit < EditorContainer
      def prepare
        load_savefile

        selector("File", FileEditor, Gosu::Color.rgb(50, 50, 50))
        selector("Tiles", TileEditor, Gosu::Color.rgb(50, 50, 150))
        selector("Decorations", DecorationEditor, Gosu::Color.rgb(50, 150, 50))
        # selector("Checkpoints", :Decorations, Gosu::Color.rgb(150, 50, 50))
        # selector("Starting Positions", :Decorations, Gosu::Color.rgb(50, 50, 50))
      end

      def load_savefile
        if @options[:track_file]
          @track_file = @options[:track_file]
          @save_file = File.basename(@track_file)
          p self.save_file
          @track_data = AbstractJSON.load(File.open(@track_file).read)

          @track_data["tiles"].each do |tile|
            _x = tile["x"]
            _y = tile["y"]
            _z = tile["z"]
            _angle = tile["angle"]
            # Correct for old maps that don't have z and angle stored.
            _z     ||= 0
            _angle ||= 0

            _tile = Track::Tile.new(tile["type"],
                                    tile["image"],
                                    _x,
                                    _y,
                                    _z,
                                    _angle)
            @tiles << _tile
          end
        end
      end
    end
  end
end