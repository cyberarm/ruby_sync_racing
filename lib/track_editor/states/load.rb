class Track
  class Editor
    class Load < Chingu::GameState
      def setup
        @tracks = Dir.glob("data/tracks/custom/*.json")
        p @tracks
      end
    end
  end
end
