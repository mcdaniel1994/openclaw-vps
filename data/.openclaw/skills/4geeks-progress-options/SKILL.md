---
name: 4geeks-progress-options
description: Use when Cory asks what 4Geeks checking options are available, wants a short menu, or wants to choose what 4Geeks progress action to run next.
---

# 4Geeks Progress Options

## Purpose

Show a short Telegram-friendly menu of available 4Geeks checks, then run the option Cory chooses.

## Trigger Examples

- "What options do I have for checking 4Geeks?"
- "What can you check for 4Geeks?"
- "Show me my 4Geeks options."
- "4Geeks menu."

## First Response

When Cory asks for options, do not call the BreatheCode API yet. Reply with a short numbered menu:

```text
Here are your 4Geeks checks:

1. Progress summary
2. Pending work
3. Assigned projects
4. My cohorts
5. Cohort history
6. Connection check

Reply with a number or name.
```

Keep the menu short. Do not include implementation details, endpoints, environment variables, or helper commands in the Telegram response.

## Selection Handling

If Cory replies with a number or close phrase, route to the matching skill:

- `1`, `progress`, `summary`, `how far along` -> use `4geeks-progress-summary`
- `2`, `pending`, `todo`, `still need`, `work left` -> use `4geeks-get-pending-work`
- `3`, `projects`, `assigned projects` -> use `4geeks-get-projects`
- `4`, `cohorts`, `courses`, `my course` -> use `4geeks-get-my-cohorts`
- `5`, `history`, `cohort history`, `log` -> use `4geeks-get-cohort-history`
- `6`, `connection`, `auth`, `token`, `is it working` -> use `4geeks-authenticate`

If the selection is unclear, show the same menu again and ask for a number or name.

## Output Style

Telegram responses should be concise:

- Start with the answer, not a long explanation.
- Preserve raw API statuses when showing status.
- Avoid raw JSON unless Cory explicitly asks for technical output.
- Do not print tokens, authorization headers, environment values, or complete helper commands.

## Safety

The menu itself is safe and does not require an API call. Only run a BreatheCode check after Cory selects an option or directly asks for a specific check.
