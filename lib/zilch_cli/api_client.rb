require 'httparty'
require 'logger'

module ZilchCLI
  class ApiClient
    include HTTParty
    base_uri ZilchCLI::Config.api_base_url

    class << self
      def logger
        @logger ||= Logger.new($stdout).tap do |log|
          log.level = Logger::INFO
          log.formatter = proc do |severity, datetime, _progname, msg|
            "[#{datetime.strftime('%Y-%m-%d %H:%M:%S')}] #{severity}: #{msg}\n"
          end
        end
      end

      def test_connection
        log_request('GET', '/test')
        response = get('/test')
        log_response(response)
        handle_response(response)
      end

      def start_game(player1_name, player2_name)
        log_request('POST', '/games')
        response = post(
          '/games',
          body: {
            player1_name: player1_name,
            player2_name: player2_name
          }.to_json,
          headers: default_headers
        )
        log_response(response)
        handle_response(response)
      end

      def join_game(game_id, player_name)
        log_request('POST', "/games/#{game_id}/join")
        response = post(
          "/games/#{game_id}/join",
          body: { player_name: player_name }.to_json,
          headers: default_headers
        )
        log_response(response)
        handle_response(response)
      end

      def get_game_status(game_id)
        log_request('GET', "/games/#{game_id}")
        response = get("/games/#{game_id}")
        log_response(response)
        handle_response(response)
      end

      def roll_dice(game_id, player_id)
        log_request('POST', "/games/#{game_id}/players/#{player_id}/roll")
        response = post(
          "/games/#{game_id}/players/#{player_id}/roll",
          headers: default_headers
        )
        log_response(response)
        handle_response(response)
      end

      def end_turn(game_id, player_id, score)
        log_request('POST', "/games/#{game_id}/players/#{player_id}/end_turn")
        response = post(
          "/games/#{game_id}/players/#{player_id}/end_turn",
          body: { score: score }.to_json,
          headers: default_headers
        )
        log_response(response)
        handle_response(response)
      end

      private

      def default_headers
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json'
        }
      end

      def log_request(method, path)
        logger.info("API Request: #{method} #{base_uri}#{path}")
      end

      def log_response(response)
        if response.success?
          logger.info("API Response: #{response.code} - #{response.body}")
        else
          logger.error("API Error: #{response.code} - #{response.body}")
        end
      end

      def handle_response(response)
        case response.code
        when 200..299
          response.parsed_response
        when 400
          raise BadRequestError, parse_error_message(response)
        when 401
          raise UnauthorizedError, parse_error_message(response)
        when 403
          raise ForbiddenError, parse_error_message(response)
        when 404
          raise NotFoundError, parse_error_message(response)
        when 422
          raise ValidationError, parse_error_message(response)
        when 500..599
          raise ServerError, parse_error_message(response)
        else
          raise StandardError, "Unexpected response: #{response.code} - #{response.body}"
        end
      end

      def parse_error_message(response)
        parsed = response.parsed_response
        if parsed.is_a?(Hash) && parsed['error']
          parsed['error']
        else
          response.body
        end
      end
    end
  end

  # Custom error classes for better error handling
  class ApiError < StandardError; end
  class BadRequestError < ApiError; end
  class UnauthorizedError < ApiError; end
  class ForbiddenError < ApiError; end
  class NotFoundError < ApiError; end
  class ValidationError < ApiError; end
  class ServerError < ApiError; end
end 