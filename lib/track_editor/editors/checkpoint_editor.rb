class Track
  class Editor
    class CheckPointEditor < EditorMode
      def setup
        @grid = {}
      end

      def add_checkpoint(type, image_path, angle)
        x = @editor.normalize_map_position($window.mouse_x-@editor.screen_vector.x)+@mouse.width/2
        y = @editor.normalize_map_position($window.mouse_y-@editor.screen_vector.y)+@mouse.height/2
        z = 0
        if @grid["#{x}"] && @grid["#{x}"]["#{y}"] && @grid["#{x}"]["#{y}"].is_a?(Track::CheckPoint)
          @editor.add_message("A checkpoint is already placed there.") unless @painting
          @editor.error_sound.play unless @painting
        else
          checkpoint = Track::CheckPoint.new(type, image_path, x, y, z, angle)
          @grid["#{x}"] = {} unless @grid["#{x}"].is_a?(Hash)
          @grid["#{x}"]["#{y}"] = tile
          @editor.checkpoints << checkpoint
        end
      end
    end
  end
end