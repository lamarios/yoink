# Yoink - Free Leech Manager

Yoink is a Go CLI application that automatically downloads freeleech torrents from private trackers using Prowlarr as an indexer and qBittorrent as the download client.

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Working Effectively

Bootstrap, build, and test the repository:
- Install Go 1.24+ if not available: `wget https://go.dev/dl/go1.24.6.linux-amd64.tar.gz && tar -C /usr/local -xzf go1.24.6.linux-amd64.tar.gz`
- Install Task (build automation): `wget https://github.com/go-task/task/releases/latest/download/task_linux_amd64.tar.gz && tar -xzf task_linux_amd64.tar.gz && chmod +x task`
- Install golangci-lint for linting: `curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b $(go env GOPATH)/bin v2.0.1`
- Build: `go build ./cmd/yoink` -- takes <1 second
- Run tests: `./task test` -- takes 22 seconds first run (includes dependency download), 5 seconds subsequent runs
- Lint code: `./task lint` -- takes 5 seconds

## Core Commands

Build and run the application:
- Build: `go build ./cmd/yoink` (creates `yoink` executable)
- Run with config: `./yoink --config ./config.sample.yaml --dry-run`
- Show help: `./yoink --help`
- Print parsed config: `./yoink print-config --config ./config.sample.yaml`
- List available indexers: `./yoink indexers --config ./config.sample.yaml` (requires prowlarr connection)

Task automation commands:
- `./task run` -- runs the application with CLI_ARGS
- `./task test` -- runs all tests with coverage
- `./task lint` -- runs golangci-lint with auto-fix
- `./task goreleaser` -- builds releases using GoReleaser

## Validation

Always manually validate any changes by:
- Running `./task test` to ensure all tests pass
- Running `./task lint` to check code quality  
- Building and testing CLI commands: `go build ./cmd/yoink && ./yoink --help`
- Testing config parsing: `./yoink print-config --config ./config.sample.yaml`
- Testing dry-run mode: `./yoink --config ./config.sample.yaml --dry-run`

Expected behavior for external service connections:
- The application expects prowlarr at `http://localhost:8081` and qBittorrent at `http://localhost:8080`
- When these services are unavailable, the application will show connection refused errors - this is EXPECTED behavior
- Use `--dry-run` flag for testing without actually downloading torrents
- The dry-run mode will still attempt to connect to services but won't download anything

## Repository Structure

Key directories and files:
- `cmd/yoink/` -- CLI application entry point and commands  
- `pkg/` -- Reusable packages for prowlarr and qbittorrent clients
- `internal/` -- Internal packages (torrent handling, disk utilities)
- `config.go` -- Configuration structure and validation
- `config.sample.yaml` -- Sample configuration file
- `Taskfile.yaml` -- Task automation definitions
- `.golangci.yml` -- Linter configuration
- `.github/workflows/` -- CI/CD pipelines for linting and releases

## Configuration

The application requires a YAML configuration file specifying:
- Prowlarr connection details (host, API key)
- qBittorrent connection details (host, username, password)  
- Download limits and indexer settings
- See `config.sample.yaml` for a complete example

Environment variables can override config file values:
- `PROWLARR_HOST`, `PROWLARR_API_KEY` -- Prowlarr connection
- `QBIT_HOST`, `QBIT_USER`, `QBIT_PASS` -- qBittorrent connection
- `TOTAL_FREELEECH_SIZE`, `CATEGORY`, `PAUSED` -- Download settings

## Common Tasks

Running the application:
```bash
# Build first
go build ./cmd/yoink

# Test configuration parsing
./yoink print-config --config ./config.sample.yaml

# Test in dry-run mode (safe, no downloads)  
./yoink --config ./config.sample.yaml --dry-run

# List available indexers (needs prowlarr)
./yoink indexers --config ./config.sample.yaml

# Run for real (needs both prowlarr and qBittorrent)
PROWLARR_API_KEY=your_key QBIT_PASS=your_pass ./yoink --config ./config.yaml
```

Development workflow:
```bash
# Make code changes
# Always run tests and linting
./task test && ./task lint

# Build and test functionality  
go build ./cmd/yoink
./yoink --help
./yoink print-config --config ./config.sample.yaml

# For releases, use GoReleaser
./task goreleaser
```

## Testing External Integrations

The application integrates with external services:
- **Prowlarr**: API calls to search for freeleech torrents
- **qBittorrent**: WebUI API to manage torrent downloads

When these services are not available:
- Connection errors are expected and normal
- Use `--dry-run` mode for testing application logic
- Mock servers are used in unit tests (`pkg/*/test.go`)
- Integration testing requires running instances of both services

## Troubleshooting

Common issues and solutions:
- "connection refused" errors: Expected when prowlarr/qBittorrent not running
- Config parsing errors: Validate YAML syntax and required fields
- Build failures: Ensure Go 1.24+ is installed
- Lint failures: Run `./task lint` to auto-fix issues
- Test failures: Check for missing test dependencies or environment setup

The application is designed to fail gracefully when external services are unavailable, making it safe to test in isolated environments.