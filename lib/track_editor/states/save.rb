class Track
  class Editor
    class Save < GameState
      class NameInput < Gosu::TextInput
        def filter(text_in)
          text_in.downcase.gsub(/[^A-z0-9]/, '')
        end
      end

      def setup
        @tick = 0
        @caret= true

        @previous_game_state = @options[:edit_state]
        @tiles = @options[:tiles]
        @decorations = @options[:decorations]
        @checkpoints = @options[:checkpoints]
        @starting_positions = @options[:starting_positions]
        $window.text_input = NameInput.new

        @title = Game::Text.new("Enter Track Name:", y: $window.height/4, size: 50)
        @name = Game::Text.new("#{@tiles.count}", y: $window.height/4+100, size: 30)
        @save = Game::Text.new("Save", y: $window.height/4+200, size: 23)
      end

      def draw
        super
        @previous_game_state.draw
        $window.flush
        $window.fill_rect(0, 0, $window.width, $window.height, Gosu::Color.rgba(0,0,0,180))

        $window.fill_rect(@save.x-20, @save.y-20, @save.width+40, @save.height+40, Gosu::Color::GRAY, 1)

        pos = @name.textobject.text_width("track_#{$window.text_input.text[0...$window.text_input.caret_pos]}")
        $window.fill_rect(@name.x+pos, @name.y, 3, 25, Gosu::Color::WHITE, 2) if @caret

        @title.draw
        @name.draw
        @save.draw

      end

      def update
        super

        # Auto save and return to Edit if Edit.save_file is set.
        if @previous_game_state && defined?(@previous_game_state.save_file) && @previous_game_state.save_file
          save_track(@previous_game_state.save_file)
          push_game_state(@previous_game_state)
        end

        @tick+=1

        @title.x = ($window.width/2)-(@title.width/2)
        @name.x = ($window.width/2)-(@name.width/2)
        @save.x = ($window.width/2)-(@save.width/2)
        @name.text = "track_#{$window.text_input.text}.json" unless $window.text_input.text.length >= 75
        @name.update

        if @tick >= 16
          if @caret
            @caret = false
          else
            @caret = true
          end
          @tick = 0
        end
      end

      def button_up(id)
        case id
        when Gosu::KbEscape
          push_game_state(@previous_game_state)

        when Gosu::KbEnter
          save_track(@name.text)
          @previous_game_state.save_file = @name.text
          push_game_state(@previous_game_state)

        when Gosu::KbReturn
          save_track(@name.text)
          @previous_game_state.save_file = @name.text
          push_game_state(@previous_game_state)
        end
      end

      def save_track(name)
        hash = {"name" => "#{name.sub('.json','')}",
                "background" => {
                  "red"=> 100,
                  "green" => 254,
                  "blue"  =>  78,
                  "alpha" => 144
                },
                "tiles" => [], "decorations" => [], "checkpoints" => [], "starting_positions" => []
              }
        p hash["name"]
        p hash["tiles"]

        @tiles.each do |tile|
          if tile.is_a?(Track::Tile)
            hash["tiles"] << {
                              "type" => tile.type,
                              "image" => tile.image,
                              "x" => tile.x,
                              "y" => tile.y,
                              "z" => tile.z,
                              "angle" => tile.angle
                            }
          end
        end

        data = AbstractJSON.dump(hash)
        unless File.exist?("data/tracks/custom/#{name.downcase}")
          File.open("data/tracks/custom/#{name.downcase}", "w").write(data)
        else
          puts "OVERWRITING TRACK!"
          File.open("data/tracks/custom/#{name.downcase}", "w").write(data)
        end

        @previous_game_state.add_message "Saved track: #{name.downcase}"
      end
    end
  end
end
