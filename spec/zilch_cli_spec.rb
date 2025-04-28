require 'spec_helper'

RSpec.describe ZilchCLI::CLI do
  let(:cli) { described_class.new }

  describe '#test_connection' do
    context 'when API is available' do
      it 'shows success message and response' do
        response = build(:api_response, :success)
        
        stub_request(:get, "#{ZilchCLI::Config.api_base_url}/test")
          .to_return(status: 200, body: response.to_json)

        expect { cli.test_connection }.to output(/Connected successfully!/).to_stdout
      end
    end

    context 'when API is not available' do
      it 'shows error message' do
        stub_request(:get, "#{ZilchCLI::Config.api_base_url}/test")
          .to_return(status: 500)

        expect { cli.test_connection }.to output(/Failed to connect/).to_stdout
      end
    end
  end

  describe '#start_game' do
    context 'when game is created successfully' do
      it 'shows success message and game ID' do
        response = build(:api_response, :game_created)
        
        stub_request(:post, "#{ZilchCLI::Config.api_base_url}/games")
          .to_return(status: 200, body: response.to_json)

        expect { cli.start_game }.to output(/Game started successfully!/).to_stdout
      end
    end

    context 'when game creation fails' do
      it 'shows error message' do
        stub_request(:post, "#{ZilchCLI::Config.api_base_url}/games")
          .to_return(status: 500)

        expect { cli.start_game }.to output(/Failed to start game/).to_stdout
      end
    end
  end
end 