#!/usr/bin/env bash
# =============================================================================
# composio-mcp.sh — Call Composio MCP tools via HTTP JSON-RPC
# =============================================================================
# Usage: ./composio-mcp.sh <tool_name> '<json-arguments>'
#
# Examples:
#   Search for tools:  ./composio-mcp.sh COMPOSIO_SEARCH_TOOLS \
#     '{"queries":[{"use_case":"Send email"}],"session":{"generate_id":true}}'
#
#   Execute a tool:    ./composio-mcp.sh COMPOSIO_MULTI_EXECUTE_TOOL \
#     '{"tools":[{"tool_slug":"GOOGLEDOCS_CREATE_DOCUMENT_MARKDOWN","arguments":{"title":"My Doc"}}],"sync_response_to_workbench":false}'
#
#   Get schemas:       ./composio-mcp.sh COMPOSIO_GET_TOOL_SCHEMAS \
#     '{"tool_slugs":["GOOGLEDOCS_CREATE_DOCUMENT_MARKDOWN"]}'
# =============================================================================

set -euo pipefail

API_KEY="${COMPOSIO_API_KEY:?COMPOSIO_API_KEY not set}"
HOST="connect.composio.dev"
URL_PATH="/mcp"

if [ $# -lt 1 ]; then
  echo "Usage: $0 <tool_name> [json-arguments]"
  echo ""
  echo "Available meta tools:"
  echo "  COMPOSIO_SEARCH_TOOLS       Search for app tools by use case"
  echo "  COMPOSIO_GET_TOOL_SCHEMAS   Get full schemas for tool slugs"
  echo "  COMPOSIO_MULTI_EXECUTE_TOOL Execute app tools (up to 50 in parallel)"
  echo "  COMPOSIO_MANAGE_CONNECTIONS Manage auth connections"
  echo "  COMPOSIO_WAIT_FOR_CONNECTIONS Wait for auth to complete"
  echo "  COMPOSIO_REMOTE_BASH_TOOL   Run bash in remote sandbox"
  exit 1
fi

TOOL_NAME="$1"
if [ -z "${2:-}" ]; then
  ARGS="{}"
else
  ARGS="$2"
fi

TMPDIR="${TMPDIR:-/tmp}"
BODY_FILE=$(mktemp "${TMPDIR}/composio_body_XXXXXX.json")
RESP_FILE=$(mktemp "${TMPDIR}/composio_resp_XXXXXX.json")

cleanup() {
  rm -f "$BODY_FILE" "$RESP_FILE"
}
trap cleanup EXIT

# --- Initialize MCP session ---
echo "[*] Initializing MCP session..." >&2
SESSION_ID=$(curl -s -D - -X POST \
  -H "x-consumer-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": { "name": "openclaw-mcp", "version": "1.0.0" }
    }
  }' \
  "https://${HOST}${URL_PATH}" 2>&1 | grep -i "mcp-session-id" | head -1 | awk -F': ' '{print $2}' | tr -d '\r')

echo "[*] Session: $SESSION_ID" >&2

# --- Build JSON-RPC body using jq ---
jq -n \
  --arg name "$TOOL_NAME" \
  --argjson args "$ARGS" \
  '{
    jsonrpc: "2.0",
    id: 2,
    method: "tools/call",
    params: {
      name: $name,
      arguments: $args
    }
  }' > "$BODY_FILE"

# --- Call the tool ---
echo "[*] Calling $TOOL_NAME..." >&2
curl -s -X POST \
  -H "x-consumer-api-key: $API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -H "Mcp-Session-Id: $SESSION_ID" \
  -d @"$BODY_FILE" \
  "https://${HOST}${URL_PATH}" > "$RESP_FILE"

# --- Extract and print text content from SSE response ---
python3 -c "
import sys, json

with open('$RESP_FILE') as f:
    data = f.read()

for line in data.split(chr(10)):
    line = line.rstrip(chr(13))
    if line.startswith('data: '):
        try:
            msg = json.loads(line[6:])
        except:
            continue
        if 'result' in msg and 'content' in msg['result']:
            for item in msg['result']['content']:
                if item.get('type') == 'text':
                    try:
                        parsed = json.loads(item['text'])
                        print(json.dumps(parsed, indent=2))
                    except:
                        print(item['text'])
        elif 'error' in msg:
            print(json.dumps(msg['error'], indent=2))
"
