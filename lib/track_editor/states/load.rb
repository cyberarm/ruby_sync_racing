class Track
  class Editor
    class Load < Game::Scene::Menu
      def prepare
        title "Track Editor"
        label("Load Track", size: 40, y: 80)

        button "Back" do
          push_game_state(Track::Editor::Menu)
        end

        @track_list = Dir.glob("data/tracks/custom/*.json")
        @tracks = []

        process_tracks
      end

      def process_tracks
        y = 150
        @track_list.each do |track|
          text = Game::Text.new(track, y: y, size: 26, x: $window.width/3, z: 8)
          @tracks << text
          y+=40
        end
      end

      def draw
        super
        if @current
          @current.color = Gosu::Color::BLACK
          $window.fill_rect(@current.x-4,@current.y-4, @current.width+8, @current.height+4, Gosu::Color::WHITE, 2)
        end

        @tracks.each do |track|
          $window.fill_rect(track.x-4,track.y-4, track.width+8, track.height+4, Gosu::Color::GRAY, 1)
          track.draw
        end

        @current.color = Gosu::Color::WHITE if @current
      end

      def update
        super

        boolean = @tracks.detect do |track|
          if $window.mouse_x.between?(track.x-4, track.x+track.width+8)
            if $window.mouse_y.between?(track.y-4, track.y+track.height+4)
              @current = track
              true
            end
          end
        end

        @current = nil if boolean == nil
      end

      def button_up(id)
        super

        case id
        when Gosu::KbEscape
          push_game_state(Track::Editor::Menu)

        when Gosu::MsLeft
          @tracks.detect do |track|
            if $window.mouse_x.between?(track.x-4, track.x+track.width+8)
              if $window.mouse_y.between?(track.y-4, track.y+track.height+4)
                push_game_state(Track::Editor::Edit.new(track_file: track.text))
              end
            end
          end
        end
      end
    end
  end
end
