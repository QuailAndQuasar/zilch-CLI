module ZilchCLI
  class Config
    class << self
      attr_accessor :api_base_url, :api_key

      def configure
        yield self
      end

      def reset
        @api_base_url = 'http://localhost:4567'  # Default Sinatra port
        @api_key = nil
      end

      def api_base_url
        @api_base_url || 'http://localhost:4567'
      end
    end
  end
end
