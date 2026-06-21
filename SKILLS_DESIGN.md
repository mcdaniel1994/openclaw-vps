# SKILLS_DESIGN.md - OpenClaw Skill Design

This document defines the planned custom OpenClaw skills for the assignment "My Agent, My Way: Teaching Your Personal Assistant New Skills."

The planned skills are:

1. `weekly-ai-learning-plan`
2. `client-discovery-notes`
3. `email-writing-style`

The design is public-safe. It does not include credentials, private contacts, customer data, runtime secrets, or private schedules.

## Local Configuration Note

The VPS must load skills from:

`/data/.openclaw/skills`

The real local file:

`data/.openclaw/openclaw.json`

is intentionally ignored because it contains local runtime configuration and may contain secrets.

Manual skill entries should only be added locally if automatic discovery fails. No credentials or real runtime configuration should be committed to GitHub.

New skill files should follow this layout:

`data/.openclaw/skills/<skill-name>/SKILL.md`

Each skill should include frontmatter with at least:

```yaml
---
name: skill-name
description: One sentence describing when Forge should use this skill.
---
```

## Skill 1: `weekly-ai-learning-plan`

### What does this skill do?

Turns Cory's weekly AI engineering priorities and constraints into a realistic, structured learning and execution plan.

### What input does the agent need?

User-supplied information:

- Week or date range
- Current learning priorities
- Project or assignment deadlines
- Available work blocks or constraints
- Optional output preference: chat response or Google Doc

Information available from workspace files:

- Cory prefers calm, direct, practical plans.
- Cory values maintainability, secure defaults, and clear explanations.
- Forge should avoid overloading the plan.
- Forge should distinguish must-do, should-do, and optional work.
- Forge should confirm ambiguous external actions before executing them.

### What does good output look like?

Structure:

- Week title
- Primary goal
- Must-do items
- Should-do items
- Optional items
- Suggested daily focus
- Risks or overload warnings
- Open questions
- Next action checklist

Destination:

- Default: chat response for review
- Optional: Google Doc created with the existing Google Docs helper

Success criteria:

- The plan is realistic, not overloaded.
- Priorities are clearly ranked.
- Assumptions are labeled.
- The user can start work without further clarification.
- If a Google Doc is requested, Forge verifies that the document was created.

Verification method:

- For chat output: user review.
- For Google Docs output: confirm helper response and retrieve or report the created document reference when available.

### Why this skill is useful

It helps Cory convert scattered learning, project, and business priorities into a focused plan that supports steady progress without overcommitting.

### Connected tools used

Confirmed:

- Local filesystem
- Git context when relevant
- Google Docs helper when document output is requested

Optional, only if verified:

- Google Calendar for proposed calendar events

### Safe failure behavior

If Google Docs creation fails, Forge should return the finished plan in chat and report that document creation was not verified.

If calendar access is unavailable or unconfirmed, Forge should not create events. It may suggest calendar blocks as text only.

### Actions requiring confirmation or clarification

- Creating a Google Doc when the requested title or content is unclear
- Creating or modifying calendar events
- Sending the plan through Telegram or email when destination or message content is unclear

### Test scenario

Sample input:

```text
Plan my week for AI engineering study. I need to finish an OpenClaw assignment, review FastAPI auth patterns, make progress on a portfolio project, and avoid overloading the week. Output a Google Doc only after I approve the draft.
```

Expected result:

- Forge drafts a weekly plan in chat first.
- Forge asks for confirmation before creating a Google Doc because the sample request requires draft approval first.
- If approved, Forge creates the Google Doc and verifies the result.

## Skill 2: `client-discovery-notes`

### What does this skill do?

Transforms rough client discovery notes into a structured client brief without inventing facts or exposing unnecessary sensitive data.

### What input does the agent need?

User-supplied information:

- Raw discovery notes, transcript excerpts, or meeting bullets
- Optional client/project label
- Intended use: internal planning, proposal prep, follow-up draft, or documentation
- Optional output preference: chat response or Google Doc

Information available from workspace files:

- Cory builds practical AI-driven applications and business systems.
- Cory prefers clear, non-hyped communication.
- Forge should distinguish facts, assumptions, risks, and recommendations.
- Forge must avoid exposing sensitive information in public files.
- Forge should clarify ambiguous external actions before executing them.

### What does good output look like?

Structure:

- Brief title
- Source note summary
- Current problems
- Current workflow
- Requirements stated by the client
- Opportunities for automation or AI support
- Open questions
- Risks and constraints
- Recommended next steps
- Sensitive information flags
- Draft follow-up notes, if requested

Destination:

- Default: chat response for review
- Optional: Google Doc created with the existing Google Docs helper

Success criteria:

- The brief is structured and easy to review.
- No client facts are invented.
- Unclear items are marked as assumptions or open questions.
- Sensitive information is flagged and unnecessary sensitive detail is redacted or summarized.
- If a Google Doc is requested, creation is verified.

Verification method:

- For chat output: user review.
- For Google Docs output: confirm helper response and retrieve or report the created document reference when available.

### Why this skill is useful

It helps Cory turn messy discovery conversations into useful business and engineering artifacts while protecting accuracy and confidentiality.

### Connected tools used

Confirmed:

- Local filesystem
- Google Docs helper when document output is requested
- Telegram only as an interaction channel when the user explicitly asks for a message draft or approved send

Optional, only if verified:

- Gmail through Composio
- Google Drive
- Google Calendar
- Google Tasks

### Sensitive data handling

Before any external output, Forge should redact or summarize:

- Raw secrets
- Credentials
- API keys or tokens
- Regulated data
- Unnecessary personal information
- Private contact details
- Sensitive client or customer details

Forge should not place raw sensitive notes into Google Docs, Telegram, email, or other external tools unless Cory explicitly approves that exact content and destination.

For external documents, prefer sanitized summaries over raw transcripts or raw notes.

### Safe failure behavior

If the notes contain sensitive information, Forge should flag it and avoid placing unnecessary sensitive details into public or shared output.

If Google Docs creation fails, Forge should return the brief in chat and report that document creation was not verified.

If Gmail, Drive, Calendar, or Tasks are needed but not confirmed, Forge should state that availability must be verified first.

### Actions requiring confirmation or clarification

- Creating a Google Doc when title, content, or sanitization level is unclear
- Sending an email
- Sending a Telegram message
- Creating tasks or calendar items
- Sharing the brief externally
- Including raw sensitive content in any external destination

### Test scenario

Sample input:

```text
Here are rough discovery notes from a small operations team: they track jobs in spreadsheets, miss follow-ups, manually copy customer info between tools, and want fewer dropped handoffs. Create an internal brief. Do not send it anywhere yet.
```

Expected result:

- Forge creates a structured internal brief.
- Forge separates facts from assumptions.
- Forge lists open questions and risks.
- Forge does not send or share the brief.
- Forge flags categories of sensitive data to remove before external output.
- If requested and approved, Forge creates a sanitized Google Doc and verifies it.

## Skill 3: `email-writing-style`

### What does this skill do?

Drafts clear, calm, practical emails in Cory's professional style without sending them automatically unless Cory clearly requests a specific send action.

### What input does the agent need?

User-supplied information:

- Email purpose
- Recipient context, using public-safe or user-provided details
- Key points to include
- Desired tone
- Any constraints, deadlines, or call to action
- Whether the output should be a draft only or prepared for sending

Information available from workspace files:

- Cory prefers direct, non-hyped communication.
- Cory values practical explanations and clear next steps.
- Forge should preserve Cory's control over external communication.
- Forge must clarify ambiguous email-send details before sending.
- Forge must not invent relationship details or private facts.

### What does good output look like?

Structure:

- Subject line options
- Recommended email draft
- Optional shorter version
- Notes on assumptions or missing details
- Clear call to action when appropriate

Destination:

- Default: chat response for review
- Optional: email draft prepared or sent using an available email tool when the user clearly requests it

Success criteria:

- The email sounds direct, calm, and practical.
- It avoids hype, pressure, and unnecessary polish.
- It includes the user's requested points.
- It does not invent facts.
- It is not sent when recipient, subject, body, or sending tool is ambiguous.

Verification method:

- For draft output: user review.
- For sent email: tool confirmation from the configured email system, reported without exposing credentials or private headers beyond what is necessary.

### Why this skill is useful

It helps Cory communicate professionally while keeping control over tone, content, and sending decisions.

### Connected tools used

Confirmed:

- Existing `hhmail` skill for Himalaya/Hostinger email workflows, if available in the active OpenClaw session
- Chat response for draft review

Optional, only if verified:

- Gmail through Composio

### Safe failure behavior

If no email sending tool is available, Forge should still produce a complete draft and state that sending was not performed.

If the recipient, facts, or context are unclear, Forge should mark assumptions and ask only for details needed to avoid a bad email.

### Actions requiring confirmation or clarification

- Sending email when recipient, subject, body, or sending tool is unclear
- Replying to email
- Forwarding email
- Attaching files
- Using Gmail or another external email service

### Test scenario

Sample input:

```text
Draft a follow-up email after a discovery call. Tone should be direct and helpful. Mention that I will send a short recap and possible next steps. Do not send it yet.
```

Expected result:

- Forge provides subject line options and a complete email draft.
- Forge does not send anything.
- Forge notes any assumptions.
- If the user later approves sending, Forge confirms any missing recipient, subject, body, or sending-tool details first.
```
