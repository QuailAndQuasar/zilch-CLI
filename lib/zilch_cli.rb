require 'tty-prompt'
require 'tty-table'
require 'tty-spinner'
require 'httparty'
require 'thor'
require_relative 'zilch_cli/config'

module ZilchCLI
  class CLI < Thor
    no_commands do
      def main_menu
        prompt = TTY::Prompt.new
        choices = {
          'Test Connection' => :test_connection,
          'Start New Game' => :start_game,
          'Exit' => :exit
        }

        loop do
          choice = prompt.select('What would you like to do?', choices)
          case choice
          when :test_connection
            test_connection
          when :start_game
            start_game
          when :exit
            puts 'Goodbye!'
            break
          end
        end
      end

      def start_game
        spinner = TTY::Spinner.new('[:spinner] Starting new game...', format: :dots)
        spinner.auto_spin

        begin
          response = HTTParty.post(
            "#{Config.api_base_url}/games",
            headers: {
              'Content-Type' => 'application/json'
            }
          )

          spinner.success('Game started successfully!')
          puts 'Game ID: ' + response.parsed_response['game_id']
        rescue StandardError => e
          spinner.error("Failed to start game: #{e.message}")
        end
      end
    end

    desc 'start', 'Start the Zilch CLI'
    def start
      main_menu
    end

    desc 'test_connection', 'Test connection to the API'
    def test_connection
      test_url = "#{Config.api_base_url}/test"
      puts "\nTesting connection to: #{test_url}\n"

      spinner = TTY::Spinner.new('[:spinner] Sending request...', format: :dots)
      spinner.auto_spin

      begin
        response = HTTParty.get(test_url)
        spinner.success('Connected successfully!')

        puts "\nResponse Details:"
        puts "Status Code: #{response.code}"
        puts 'Headers:'
        response.headers.each do |key, value|
          puts "  #{key}: #{value}"
        end
        puts "\nBody:"
        puts response.body
      rescue StandardError => e
        spinner.error("Failed to connect: #{e.message}")
      end
    end

    desc 'version', 'Show version'
    def version
      puts 'Zilch CLI v0.1.0'
    end
  end
end
