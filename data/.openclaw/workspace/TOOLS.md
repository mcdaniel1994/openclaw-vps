# TOOLS.md - Confirmed Local Tool Notes

This file documents public-safe tool context for Forge. Do not store credentials, tokens, private IDs, customer data, or runtime secrets here.

## Confirmed Tools

### Telegram

Telegram is enabled as an OpenClaw interaction channel.

Use Telegram carefully:

- Draft before sending when message content matters.
- Do not expose private runtime data or credentials.
- Ask for clarification before sending if destination, content, recipient, tool, or consequence is unclear.

### Composio MCP

Composio MCP is configured in the local OpenClaw runtime.

Use it only through already-configured local access. Do not set up new APIs, OAuth flows, or credentials for this assignment.

### Google Docs Helper

A Google Docs helper exists at:

`/data/.openclaw/workspace/scripts/google-docs.sh`

Expected use:

- Create a Google Doc when the user explicitly requests document output.
- Verify creation by checking the tool response and, when appropriate, retrieving the document by ID or URL.
- Do not claim a document was created unless the helper confirms success.

### Email via `hhmail`

A custom `hhmail` skill exists for Himalaya/Hostinger email workflows.

Use email tools conservatively:

- Draft email content first when the user asks for a draft.
- Send only when Cory clearly requests sending and the recipient, subject, body, and sending tool are clear.
- Ask for clarification when any sending detail is ambiguous.
- Never print stored email credentials.
- Summarize email content instead of dumping private messages unless the user explicitly asks.

### Git and Filesystem

Git and local filesystem access are available in the VPS environment.

Use Git carefully:

- Check status before committing.
- Do not commit ignored runtime files.
- Do not commit secrets, logs, private memory, uploads, sessions, or local configuration.
- Keep public GitHub content limited to safe source, documentation, and skill instructions.

## Tools That Must Be Verified At Runtime

The following may be available through Composio or bundled OpenClaw tools, but should not be treated as confirmed until checked at runtime:

- Google Calendar
- Gmail through Composio
- Google Drive
- Google Tasks
- GitHub API integration

If a task depends on one of these, verify availability first and report the result.

## Drafting vs Sending

Forge may draft:

- Emails
- Telegram messages
- Client briefs
- Weekly plans
- Google Doc content
- Calendar event proposals

Forge may execute when Cory clearly requests the exact action. Ask for clarification before:

- Sending email with unclear recipient, subject, body, or sending tool
- Sending Telegram messages to an unclear destination
- Creating or modifying calendar events with unclear time, title, attendees, or calendar
- Sharing documents with unclear destination or permissions
- Publishing content with unclear audience or final text
- Deleting or overwriting data
- Changing runtime configuration

## Assignment Constraint

Do not configure new integrations for the assignment. Use only tools already connected in this OpenClaw environment.

Never print credentials or private runtime configuration.
