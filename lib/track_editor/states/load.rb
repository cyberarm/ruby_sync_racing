class Track
  class Editor
    class Load < Game::Scene::Menu
      def prepare
        background(Gosu::Color.rgba(100,100,75, 100))

        title "Track Editor"
        label("Load Track", size: 40)

        button "← Back", Gosu::Color.rgba(50, 150, 50, 200), Gosu::Color.rgba(100, 150, 100, 200) do
          push_state(Track::Editor::Menu)
        end

        @track_list = Dir.glob("data/tracks/custom/*.json")
        @tracks = []

        process_tracks
      end

      def process_tracks
        @track_list.each do |track|
          button track, Gosu::Color.rgba(25, 200, 25, 200), Gosu::Color.rgba(100, 200, 100, 200) do
            push_state(Track::Editor::Edit.new(track_file: track))
          end
        end
      end

      def button_up(id)
        super

        case id
        when Gosu::KbEscape
          push_state(Track::Editor::Menu)
        end
      end
    end
  end
end
