# Agent Sandbox

Minimal, network-isolated container images for running AI coding assistants (Claude, Gemini, Codex).

## What This Is

These containers provide a sandboxed environment where AI agents can only communicate with their respective API endpoints. All other network access is blocked via iptables rules.

**Key features:**
- Network isolation: Only AI API endpoints are allowed (configurable allowlist)
- Session persistence: tmux keeps sessions alive across disconnects
- Minimal footprint: Alpine-based images
- Extensible: Create custom agent images by extending the base

## Available Images

| Image | Description |
|-------|-------------|
| `ghcr.io/kinoto-ai/agent-base` | Base image with sandbox tools (tmux, iptables) |
| `ghcr.io/kinoto-ai/agent-claude` | Claude Code CLI |
| `ghcr.io/kinoto-ai/agent-gemini` | Gemini CLI |
| `ghcr.io/kinoto-ai/agent-codex` | OpenAI Codex CLI |

## Usage

### Running an Agent

```bash
# Run Claude Code with network isolation
docker run -it --cap-add=NET_ADMIN \
  -v /path/to/workspace:/workspace \
  -e ANTHROPIC_API_KEY=sk-... \
  ghcr.io/kinoto-ai/agent-claude

# Run Gemini CLI
docker run -it --cap-add=NET_ADMIN \
  -v /path/to/workspace:/workspace \
  -e GEMINI_API_KEY=... \
  ghcr.io/kinoto-ai/agent-gemini

# Run Codex
docker run -it --cap-add=NET_ADMIN \
  -v /path/to/workspace:/workspace \
  -e OPENAI_API_KEY=sk-... \
  ghcr.io/kinoto-ai/agent-codex
```

**Note:** `--cap-add=NET_ADMIN` is required for iptables rules. Without it, the container runs without network isolation.

### Adding Custom Allowlists

Mount additional allowlist files to extend network access:

```bash
docker run -it --cap-add=NET_ADMIN \
  -v ./my-allowlist.txt:/etc/kinoto/allowlist.d/custom.txt:ro \
  ghcr.io/kinoto-ai/agent-claude
```

Allowlist format (one domain per line):
```
# Comments start with #
api.example.com
another-api.example.com
```

## Creating a Custom Agent

Extend `agent-base` to create your own agent image:

```dockerfile
ARG BASE_IMAGE=ghcr.io/kinoto-ai/agent-base:latest
FROM ${BASE_IMAGE}

# Required: Set agent name for discovery
LABEL com.kinoto.agent.name="my-agent"

# Install your agent CLI
RUN apk add --no-cache nodejs npm
RUN npm install -g your-agent-cli

# Add your API allowlist
COPY allowlist.txt /etc/kinoto/allowlist.txt

# Set the command to run
ENV ASSISTANT_CMD="your-agent-cli"
```

Create an `allowlist.txt` with your agent's API endpoints:
```
# API endpoints for your agent
api.your-agent.com
```

Build and run:
```bash
docker build -t my-agent .
docker run -it --cap-add=NET_ADMIN my-agent
```

### Discovering Agents

List all available agent images:
```bash
docker images --filter "label=com.kinoto.agent.name" \
  --format "{{.Repository}}:{{.Tag}} → {{index .Labels \"com.kinoto.agent.name\"}}"
```

Get agent name from an image:
```bash
docker inspect IMAGE --format '{{index .Config.Labels "com.kinoto.agent.name"}}'
```

## How It Works

### Network Isolation

The entrypoint script configures iptables rules:

1. Default policy: DROP all outbound traffic
2. Allow loopback (localhost)
3. Allow established connections
4. Allow DNS (port 53)
5. Resolve each domain in allowlists and allow HTTPS/HTTP to those IPs

### Session Management

When running with a TTY (`-it`), the container starts a tmux session. This allows:
- Detaching/reattaching to sessions
- Session persistence if the terminal disconnects
- Multiple windows within a session

Environment variables:
- `TMUX_SESSION`: Session name (default: `kinoto`)
- `ASSISTANT_CMD`: Command to run in the session

## Development

### Building Locally

```bash
# Build all images
make build

# Build only base
make build-base
```

### Running Tests

```bash
# Full tests (requires CAP_NET_ADMIN)
make test

# CI tests (no CAP_NET_ADMIN)
make test-ci
```

### Cleaning Up

```bash
make clean
```

## License

MIT
