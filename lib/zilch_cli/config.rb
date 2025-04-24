module ZilchCLI
  class Config
    class << self
      attr_accessor :api_base_url, :api_key

      def configure
        yield self
      end

      def reset
        @api_base_url = nil
        @api_key = nil
      end
    end
  end
end 