class Track
  class Editor
    class Menu < Game::Scene::Menu
      def prepare
        # @title      = Game::Text.new("Track Editor", size: 50, y: 100)
        # @sub_title  = Game::Text.new("Ruby Sync Racing", size: 40, y: 150)
        # @new_track  = Game::Text.new("New Track", size: 23, y: 220, z: 2)
        # @load_track = Game::Text.new("Load Track", size: 23, y: 320, z: 2)
        # @quit       = Game::Text.new("Quit", size: 23, y: 420, z: 2)

        # @background_color = Gosu::Color.rgb(219, 96, 0)
        # @background_hover_color = Gosu::Color.rgb(255, 144, 0)

        title "Ruby Sync Racing"
        label "Track Editor", size: 48

        button "Create Track" do
          push_game_state(Edit)
        end

        button "Load Track" do
          push_game_state(Load)
        end

        button "Exit" do
          $window.close
          exit
        end
      end

      # def draw
      #   super
      #   @title.draw
      #   @sub_title.draw
      #   @new_track.draw
      #   @load_track.draw
      #   @quit.draw

      #   if mouse_over?(@new_track)
      #     $window.fill_rect(@new_track.x-20, @new_track.y-20, @new_track.width+40, @new_track.height+40, @background_hover_color, 1)
      #   else
      #     $window.fill_rect(@new_track.x-20, @new_track.y-20, @new_track.width+40, @new_track.height+40, @background_color, 1)
      #   end
      #   if mouse_over?(@load_track)
      #     $window.fill_rect(@load_track.x-20, @load_track.y-20, @load_track.width+40, @load_track.height+40, @background_hover_color, 1)
      #   else
      #     $window.fill_rect(@load_track.x-20, @load_track.y-20, @load_track.width+40, @load_track.height+40, @background_color, 1)
      #   end
      #   if mouse_over?(@quit)
      #     $window.fill_rect(@quit.x-20, @quit.y-20, @quit.width+40, @quit.height+40, @background_hover_color, 1)
      #   else
      #     $window.fill_rect(@quit.x-20, @quit.y-20, @quit.width+40, @quit.height+40, @background_color, 1)
      #   end
      # end

      # def update
      #   @title.x      = ($window.width/2)-(@title.width/2)
      #   @sub_title.x  = ($window.width/2)-(@sub_title.width/2)
      #   @new_track.x  = ($window.width/2)-(@new_track.width/2)
      #   @load_track.x = ($window.width/2)-(@load_track.width/2)
      #   @quit.x       = ($window.width/2)-(@quit.width/2)
      # end

      # def mouse_over?(text_object)
      #   if $window.mouse_x.between?(text_object.x-20, text_object.x+text_object.width+20)
      #     if $window.mouse_y.between?(text_object.y-20, text_object.y+text_object.height+20)
      #       true
      #     else
      #       false
      #     end
      #   else
      #     false
      #   end
      # end

      # def button_up(id)
      #   case id
      #   when Gosu::MsLeft
      #     # New track button
      #     if mouse_over?(@new_track)
      #       push_game_state(Edit)
      #     end

      #     # Load track button
      #     if mouse_over?(@load_track)
      #       push_game_state(Load)
      #     end

      #     # Quit button
      #     if mouse_over?(@quit)
      #       exit
      #     end
      #   end
      # end
    end
  end
end
