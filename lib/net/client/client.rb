module Game
  module Net
    class Client < GameOverseer::Client
      def self.id
        @id
      end
      def self.id=string
        @id=string
      end

      def self.username
        @username
      end
      def self.username=string
        @username=string
      end

      def self.token
        @token
      end
      def self.token=token
        @token=token
      end

      def self.instance
        @instance
      end
      def self.instance=instance
        @instance = instance
      end
    end
  end
end
