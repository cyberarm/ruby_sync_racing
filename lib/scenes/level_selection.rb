module Game
  class Scene
    class LevelSelection < Chingu::GameState
      def setup
        @title = Game::Text.new("Ruby Sync Racing", x: $window.width/2, y: 20, color: Gosu::Color::WHITE, size: 80)
        @sub_title = Game::Text.new("Choose Track", x: $window.width/2, y: 120, color: Gosu::Color::WHITE, size: 50)

        @track_list = Dir.glob("data/tracks/*.json")
        @custom_track_list = Dir.glob("data/tracks/custom/*.json")

        @tracks = []

        @title.x = $window.width/2-@title.width/2
        @sub_title.x = $window.width/2-@sub_title.width/2

        process_tracks
      end

      def process_tracks
        y = 200
        (@track_list+@custom_track_list).each do |track|
          _track = MultiJson.load(open(track).read)["name"]
          _track = "#{_track} (Custom)" if track.include?("/custom/")

          text = Game::Text.new(_track, y: y, size: 26, x: $window.width/3, z: 8, track_path: track)
          @tracks << text
          y+=40
        end
      end

      def draw
        super
        fill(Gosu::Color.rgba(255,255,255,100), -5)

        @title.draw
        @sub_title.draw
        @tracks.each do |track|
          $window.fill_rect([track.x-4,track.y-4, track.width+8, track.height+4], Gosu::Color::GRAY, 1)

          if $window.mouse_x.between?(track.x-4, track.x+track.width+8)
            if $window.mouse_y.between?(track.y-4, track.y+track.height+4)
              $window.fill_rect([track.x-4,track.y-4, track.width+8, track.height+4], Gosu::Color.rgba(0,0,0,200), 1)
            end
          end
          track.draw
        end
      end

      def button_up(id)
        case id
        when Gosu::KbEscape
          push_game_state(previous_game_state, setup: false)

        when Gosu::MsLeft
          (@tracks).detect do |track|
            if $window.mouse_x.between?(track.x-4, track.x+track.width+8)
              if $window.mouse_y.between?(track.y-4, track.y+track.height+4)
                push_game_state(CarSelection.new(trackfile: track.options[:track_path]))
              end
            end
          end
        end
      end
    end
  end
end
