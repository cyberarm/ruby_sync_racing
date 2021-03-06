module Game
  class Scene
    class LevelSelection < Menu
      def prepare
        title("Ruby Sync Racing")
        label("Choose Track", size: 50)
        button("← Main Menu") {push_state(MainMenu)}
        label("", size: 25)

        process_tracks
      end

      def process_tracks
        @track_list = Dir.glob("data/tracks/*.json")
        @custom_track_list = Dir.glob("data/tracks/custom/*.json")

        (@track_list+@custom_track_list).each do |track|
          _track = AbstractJSON.load(open(track).read)["name"]
          _track = "#{_track} (Custom)" if track.include?("/custom/")

          button(_track) do
            push_state(CarSelection.new(trackfile: track))
          end
        end
      end
    end
  end
end
