require 'tty-prompt'
require 'tty-table'
require 'tty-spinner'
require 'httparty'
require 'thor'

module ZilchCLI
  class CLI < Thor
    desc "login", "Login to the API"
    def login
      prompt = TTY::Prompt.new
      email = prompt.ask("Enter your email:")
      password = prompt.mask("Enter your password:")

      spinner = TTY::Spinner.new("[:spinner] Logging in...", format: :dots)
      spinner.auto_spin

      begin
        response = HTTParty.post(
          "#{ENV['API_BASE_URL']}/auth/login",
          body: {
            email: email,
            password: password
          }.to_json,
          headers: {
            'Content-Type' => 'application/json'
          }
        )

        spinner.success("Logged in successfully!")
        puts "Welcome back!"
      rescue StandardError => e
        spinner.error("Failed to login: #{e.message}")
      end
    end

    desc "version", "Show version"
    def version
      puts "Zilch CLI v0.1.0"
    end
  end
end 