class Track
  class Editor
    class Save < CyberarmEngine::GameState
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
        @background_color   = @options[:background_color]
        @time_of_day        = @options[:time_of_day]
        $window.text_input = NameInput.new

        @title = CyberarmEngine::Text.new("Enter Track Name:", y: $window.height/4, size: 50)
        @name = CyberarmEngine::Text.new("#{@tiles.count}", y: $window.height/4+100, size: 30)
        @save = CyberarmEngine::Text.new("Save", y: $window.height/4+200, size: 23)
      end

      def draw
        super
        @previous_game_state.draw
        $window.flush
        Gosu.draw_rect(0, 0, $window.width, $window.height, Gosu::Color.rgba(0,0,0,180))

        Gosu.draw_rect(@save.x-20, @save.y-20, @save.width+40, @save.height+40, Gosu::Color::GRAY, 1)

        pos = @name.textobject.text_width("track_#{$window.text_input.text[0...$window.text_input.caret_pos]}")
        Gosu.draw_rect(@name.x+pos, @name.y, 3, 25, Gosu::Color::WHITE, 2) if @caret

        @title.draw
        @name.draw
        @save.draw

      end

      def update
        super

        # Auto save and return to Edit if Edit.save_file is set.
        if @previous_game_state && defined?(@previous_game_state.save_file) && @previous_game_state.save_file
          save_track(@previous_game_state.save_file, @background_color)
          $window.text_input = nil
          pop_state
          return
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
          $window.text_input = nil
          pop_state

        when Gosu::MsLeft
          save if $window.mouse_x.between?(@save.x - 20, @save.x + @save.width + 40) &&
                  $window.mouse_x.between?(@save.y - 20, @save.y + @save.height + 40)
        when Gosu::KbEnter, Gosu::KbReturn
          save
        end
      end

      def save
        save_track(@name.text, @background_color)
        @previous_game_state.save_file = @name.text
        $window.text_input = nil
        pop_state
      end

      def save_track(name, color)
        hash = {"name" => "#{name.sub('.json','')}",
                "background" => {
                  "red"   => color.red,
                  "green" => color.green,
                  "blue"  => color.blue,
                  "alpha" => color.alpha
                },
                "time_of_day" => @time_of_day,
                "tiles" => [], "decorations" => [], "checkpoints" => [], "starting_positions" => []
              }
        p hash["name"]

        @tiles.each do |tile|
          if tile.is_a?(Track::Tile)
            hash["tiles"] << {
                              "type" => tile.type,
                              "image" => AssetManager.id_from_image(tile.image),
                              "x" => tile.x,
                              "y" => tile.y,
                              "z" => tile.z,
                              "angle" => tile.angle
                            }
          end
        end

        @decorations.each do |decoration|
          hash["decorations"] << {
            "collidable" => decoration.collidable,
            "image"=> AssetManager.id_from_image(decoration.image),
            "x"    => decoration.x,
            "y"    => decoration.y,
            "z"    => decoration.z,
            "angle"=> decoration.angle,
            "scale"=> decoration.scale
          }
        end

        @checkpoints.each do |checkpoint|
          hash["checkpoints"] << {
            "x"     => checkpoint.x,
            "y"     => checkpoint.y,
            "width" => checkpoint.width,
            "height"=> checkpoint.height
          }
        end

        @starting_positions.each do |starting_position|
          hash["starting_positions"] << {
            "x"    => starting_position.x,
            "y"    => starting_position.y,
            "angle"=> starting_position.angle
          }
        end

        data = AbstractJSON.dump(hash)
        unless File.exist?("data/tracks/custom/#{name.downcase}")
          File.open("data/tracks/custom/#{name.downcase}", "w").write(data)
        else
          puts "OVERWRITING TRACK!"
          File.open("data/tracks/custom/#{name.downcase}", "w").write(data)
        end

        @previous_game_state.add_message "Saved track: #{name.downcase}"
        $window.text_input = nil
      end
    end
  end
end
