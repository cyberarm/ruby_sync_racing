class Track
  class Editor
    class Edit < EditorContainer
      def prepare

        selector("File", FileEditor.new, Gosu::Color.rgb(50, 50, 50))
        selector("Tiles", TileEditor.new, Gosu::Color.rgb(50, 50, 150))
        selector("Decorations", DecorationEditor.new, Gosu::Color.rgb(50, 150, 50))
        selector("Checkpoints", nil, Gosu::Color.rgb(150, 50, 50))
        # selector("Starting Positions", :Decorations, Gosu::Color.rgb(50, 50, 50))

        load_savefile
      end

      def load_savefile
        if @options[:track_file]
          @track_file = @options[:track_file]
          @save_file = File.basename(@track_file)
          p self.save_file
          @track_data = AbstractJSON.load(File.open(@track_file).read)

          @mode_selectors.each {|s| s.instance.load_track(@track_data)}
        end
      end
    end
  end
end