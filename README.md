# Zilch CLI

A command-line interface for interacting with the Zilch API.

## Installation

1. Clone this repository
2. Install dependencies:
   ```bash
   bundle install
   ```

## Configuration

The CLI is configured to use a local Sinatra server by default (http://localhost:4567). You can change this using the configure command:

```bash
./bin/zilch configure
```

## Usage

Run the CLI using:

```bash
./bin/zilch [command]
```

### Available Commands

- `login` - Login to the API
- `configure` - Configure API settings
- `version` - Show version information

## Local Development

To run the CLI against a local Sinatra server:

1. Start your Sinatra server (typically on port 4567)
2. The CLI will automatically connect to http://localhost:4567
3. If your Sinatra server runs on a different port, use the configure command to update the URL

## Development

To add new commands, edit the `lib/zilch_cli.rb` file and add new methods to the `CLI` class.

## License

MIT
