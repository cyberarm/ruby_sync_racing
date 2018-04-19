class Track
  class Editor
    class Load < Game::Scene::Menu
      def prepare
        title "Track Editor"
        label("Load Track", size: 40)

        button "← Back" do
          push_game_state(Track::Editor::Menu)
        end

        @track_list = Dir.glob("data/tracks/custom/*.json")
        @tracks = []

        process_tracks
      end

      def process_tracks
        @track_list.each do |track|
          button track do
            push_game_state(Track::Editor::Edit.new(track_file: track))
          end
        end
      end

      def button_up(id)
        super

        case id
        when Gosu::KbEscape
          push_game_state(Track::Editor::Menu)
        end
      end
    end
  end
end
