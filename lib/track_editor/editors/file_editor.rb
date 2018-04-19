class Track
  class Editor
    class FileEditor < EditorMode
      def setup
        # sidebar_label "Options"

        sidebar_button("Save Track") do
          @editor.save_track
        end

        sidebar_button("Test Track")

        sidebar_button("Exit Editor") do
          if @editor.track_save_tainted?
            @editor.close_dialog do
              @editor.push_game_state(Track::Editor::Menu)
            end
          else
            @editor.push_game_state(Track::Editor::Menu)
          end
        end
      end
    end
  end
end