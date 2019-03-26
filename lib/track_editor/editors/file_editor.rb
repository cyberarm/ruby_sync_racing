class Track
  class Editor
    class FileEditor < EditorMode
      def setup

        sidebar_label "Track"
        sidebar_button("Save Track", "Press \"CTRL+S\"") do
          @editor.save_track
        end
        sidebar_button("Test Track", "Save and play track [NOT IMPLEMENTED]")
        sidebar_label ""

        sidebar_label "Background"
        sidebar_button("Forest Green (Default)") { @editor.background = Gosu::Color.rgba(100, 254, 78, 144); @editor.track_changed! }
        sidebar_button("Pale Pink")  { @editor.background = Gosu::Color.rgba(255, 170, 170, 144); @editor.track_changed! }
        sidebar_button("Desert Sands")  { @editor.background = Gosu::Color.rgba(250, 254, 78, 144); @editor.track_changed! }
        sidebar_label ""

        sidebar_label "Time"
        sidebar_button("Morning", "Adds bright orangish hue to everything, headlights optional with no effect") { @editor.time_of_day = "morning"; @editor.track_changed! }
        sidebar_button("Noon (Default)", "No lighting effects") { @editor.time_of_day = "noon"; @editor.track_changed! }
        sidebar_button("Evening", "Pale light, headlights should be on") { @editor.time_of_day = "evening"; @editor.track_changed! }
        sidebar_button("Night", "Can only see with headlights") { @editor.time_of_day = "night"; @editor.track_changed! }
        sidebar_label ""

        sidebar_button("Exit Editor", "Save and exit to main menu") do
          if @editor.track_save_tainted?
            if @editor.save_file
              @editor.save_track
              @editor.push_game_state(Track::Editor::Menu)
            else
              @editor.close_dialog do
                @editor.push_game_state(Track::Editor::Menu)
              end
            end
          else
            @editor.push_game_state(Track::Editor::Menu)
          end
        end
      end
    end
  end
end