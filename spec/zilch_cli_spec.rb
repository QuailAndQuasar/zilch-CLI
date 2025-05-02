require 'spec_helper'

RSpec.describe ZilchCLI::CLI do
  let(:cli) { described_class.new }

  describe '#test_connection' do
    context 'when API is available' do
      it 'shows success message and response' do
        response = build(:api_response, :success)
        
        allow(ZilchCLI::ApiClient).to receive(:test_connection)
          .and_return(instance_double(HTTParty::Response, 
            code: 200,
            headers: { 'content-type' => 'application/json' },
            body: response.to_json,
            success?: true
          ))

        expect { cli.test_connection }.to output(/Connected successfully!/).to_stdout
      end
    end

    context 'when API is not available' do
      it 'shows error message' do
        allow(ZilchCLI::ApiClient).to receive(:test_connection)
          .and_raise(StandardError.new('Connection failed'))

        expect { cli.test_connection }.to output(/Failed to connect/).to_stdout
      end
    end
  end

  describe '#start_game' do
    context 'when game is created successfully' do
      it 'shows success message and game ID' do
        response = build(:api_response, :game_created)
        
        allow(ZilchCLI::ApiClient).to receive(:start_game)
          .and_return(response)

        expect { cli.start_game }.to output(/Game started successfully!/).to_stdout
      end
    end

    context 'when game creation fails' do
      it 'shows error message' do
        allow(ZilchCLI::ApiClient).to receive(:start_game)
          .and_raise(StandardError.new('Game creation failed'))

        expect { cli.start_game }.to output(/Failed to start game/).to_stdout
      end
    end
  end
end 