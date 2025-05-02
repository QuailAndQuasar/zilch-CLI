require 'tty-prompt'
require 'tty-table'
require 'tty-spinner'
require 'thor'
require_relative 'zilch_cli/config'
require_relative 'zilch_cli/api_client'

module ZilchCLI
  class CLI < Thor
    no_commands do
      def main_menu
        prompt = TTY::Prompt.new
        choices = {
          'Test Connection' => :test_connection,
          'Start New Game' => :start_game,
          'Join Game' => :join_game,
          'View Game Status' => :view_game_status,
          'Play Turn' => :play_turn,
          'Exit' => :exit
        }

        loop do
          choice = prompt.select('What would you like to do?', choices)
          case choice
          when :test_connection
            test_connection
          when :start_game
            start_game
          when :join_game
            join_game
          when :view_game_status
            view_game_status
          when :play_turn
            play_turn
          when :exit
            puts 'Goodbye!'
            break
          end
        end
      end

      def start_game
        # Screen 1: Start Game
        puts "\n" + TTY::Box.frame(
          "🎲 Starting New Game 🎲",
          padding: 1,
          align: :center,
          border: :thick
        )

        # Screen 2: Player Names
        puts "\n" + TTY::Box.frame(
          "👥 Player Setup 👥",
          padding: 1,
          align: :center,
          border: :thick
        )

        prompt = TTY::Prompt.new
        
        # Get player names with validation
        player1_name = prompt.ask('Enter Player 1 name:') do |q|
          q.required true
          q.validate /\A\w+\z/
          q.messages[:valid?] = 'Name must contain only letters, numbers, and underscores'
        end
        
        player2_name = prompt.ask('Enter Player 2 name:') do |q|
          q.required true
          q.validate /\A\w+\z/
          q.messages[:valid?] = 'Name must contain only letters, numbers, and underscores'
        end

        spinner = TTY::Spinner.new(
          "[:spinner] Creating game...",
          format: :dots,
          success_mark: "✅",
          error_mark: "❌"
        )
        spinner.auto_spin

        begin
          # Create the game with players
          response = ApiClient.start_game(player1_name, player2_name)
          spinner.success('Game created successfully!')
          game_id = response['game_id']

          # Screen 3: Game Landing
          puts "\n" + TTY::Box.frame(
            "🎮 Game Ready! 🎮",
            padding: 1,
            align: :center,
            border: :thick
          )

          # Game Info Box
          game_info = [
            "Game ID: #{game_id}",
            "",
            "Players:",
            "1. #{player1_name} (ID: #{response['player1_id']})",
            "2. #{player2_name} (ID: #{response['player2_id']})",
            "",
            "🎲 It's #{player1_name}'s turn to roll! 🎲"
          ].join("\n")

          puts TTY::Box.frame(
            game_info,
            padding: 1,
            border: :rounded
          )

          # Action Menu
          puts "\n" + TTY::Box.frame(
            "What would you like to do?",
            padding: 1,
            align: :center,
            border: :thick
          )

          choice = prompt.select(
            'Choose an action:',
            [
              { name: '🎲 Roll dice', value: 'Roll' },
              { name: '📊 View game status', value: 'View' },
              { name: '🏠 Return to main menu', value: 'Menu' }
            ],
            cycle: true,
            per_page: 3
          )

          case choice
          when 'Roll'
            play_turn(game_id, response['player1_id'])
          when 'View'
            view_game_status(game_id)
          when 'Menu'
            main_menu
          end

        rescue ApiError => e
          spinner.error("Failed to start game: #{e.message}")
        end
      end

      def join_game
        prompt = TTY::Prompt.new
        game_id = prompt.ask('Enter game ID:')
        player_name = prompt.ask('Enter your name:')

        spinner = TTY::Spinner.new('[:spinner] Joining game...', format: :dots)
        spinner.auto_spin

        begin
          response = ApiClient.join_game(game_id, player_name)
          spinner.success('Joined game successfully!')
          puts "Player ID: #{response['player_id']}"
        rescue NotFoundError
          spinner.error("Game not found with ID: #{game_id}")
        rescue ValidationError => e
          spinner.error("Invalid input: #{e.message}")
        rescue ApiError => e
          spinner.error("Failed to join game: #{e.message}")
        end
      end

      def view_game_status
        prompt = TTY::Prompt.new
        game_id = prompt.ask('Enter game ID:')

        spinner = TTY::Spinner.new('[:spinner] Fetching game status...', format: :dots)
        spinner.auto_spin

        begin
          response = ApiClient.get_game_status(game_id)
          spinner.success('Game status retrieved!')
          
          # Display game status in a table
          table = TTY::Table.new(
            header: ['Player', 'Score', 'Current Turn'],
            rows: response['players'].map do |player|
              [
                player['name'],
                player['score'],
                player['is_current_turn'] ? 'Yes' : 'No'
              ]
            end
          )
          puts table.render(:ascii)
        rescue NotFoundError
          spinner.error("Game not found with ID: #{game_id}")
        rescue ApiError => e
          spinner.error("Failed to get game status: #{e.message}")
        end
      end

      def play_turn
        prompt = TTY::Prompt.new
        game_id = prompt.ask('Enter game ID:')
        player_id = prompt.ask('Enter your player ID:')

        spinner = TTY::Spinner.new('[:spinner] Rolling dice...', format: :dots)
        spinner.auto_spin

        begin
          # Roll dice
          roll_response = ApiClient.roll_dice(game_id, player_id)
          spinner.success('Dice rolled!')
          puts "Dice: #{roll_response['dice'].join(', ')}"
          
          # Ask if player wants to end turn
          if prompt.yes?('Do you want to end your turn?')
            score = prompt.ask('Enter your score:', convert: :int)
            
            spinner = TTY::Spinner.new('[:spinner] Ending turn...', format: :dots)
            spinner.auto_spin
            
            end_response = ApiClient.end_turn(game_id, player_id, score)
            spinner.success('Turn ended!')
            puts "New score: #{end_response['score']}"
          end
        rescue NotFoundError
          spinner.error("Game or player not found")
        rescue ValidationError => e
          spinner.error("Invalid input: #{e.message}")
        rescue ApiError => e
          spinner.error("Failed to play turn: #{e.message}")
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
        response = ApiClient.test_connection
        spinner.success('Connected successfully!')
        
        puts "\nResponse Details:"
        puts "Status Code: #{response.code}"
        puts "Headers:"
        response.headers.each do |key, value|
          puts "  #{key}: #{value}"
        end
        puts "\nBody:"
        puts response.body
      rescue ApiError => e
        spinner.error("Failed to connect: #{e.message}")
      end
    end

    desc 'version', 'Show version'
    def version
      puts 'Zilch CLI v0.1.0'
    end
  end
end
