#!/usr/bin/env bash
# =============================================================================
# google-docs.sh — Google Docs helpers via Composio MCP
# =============================================================================
# Usage: ./google-docs.sh create "<title>" "[markdown content]"
#        ./google-docs.sh get <doc-id-or-url>
#        ./google-docs.sh list
# =============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
MCP="$SCRIPT_DIR/composio-mcp.sh"

case "${1:-help}" in
  create)
    TITLE="${2:-Untitled Document}"
    MARKDOWN="${3:-}"
    if [ -z "$MARKDOWN" ]; then
      ARGS=$(cat <<JSON
{
  "tools": [{
    "tool_slug": "GOOGLEDOCS_CREATE_DOCUMENT_MARKDOWN",
    "arguments": {"title": "$TITLE"}
  }],
  "sync_response_to_workbench": false
}
JSON
)
    else
      # Escape for JSON (basic)
      ESCAPED=$(echo "$MARKDOWN" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
      ARGS=$(cat <<JSON
{
  "tools": [{
    "tool_slug": "GOOGLEDOCS_CREATE_DOCUMENT_MARKDOWN",
    "arguments": {"title": "$TITLE", "markdown_text": $ESCAPED}
  }],
  "sync_response_to_workbench": false
}
JSON
)
    fi
    bash "$MCP" COMPOSIO_MULTI_EXECUTE_TOOL "$ARGS"
    ;;
  get)
    ID="${2:?Usage: $0 get <doc-id-or-url>}"
    ARGS=$(cat <<JSON
{
  "tools": [{
    "tool_slug": "GOOGLEDOCS_GET_DOCUMENT_BY_ID",
    "arguments": {"id": "$ID"}
  }],
  "sync_response_to_workbench": false
}
JSON
)
    bash "$MCP" COMPOSIO_MULTI_EXECUTE_TOOL "$ARGS"
    ;;
  list)
    bash "$MCP" COMPOSIO_SEARCH_TOOLS \
      '{"queries":[{"use_case":"List my Google Docs documents"}],"session":{"generate_id":true}}'
    ;;
  *)
    echo "Usage: $0 create <title> [markdown]"
    echo "       $0 get <doc-id-or-url>"
    echo "       $0 list"
    exit 1
    ;;
esac
