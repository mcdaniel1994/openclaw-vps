# 4Geeks Progress Assistant Local Setup

This document explains how to configure the 4Geeks Progress Assistant without committing secrets.

## Runtime Environment

The helper reads these environment variables at runtime:

```text
BREATHECODE_STUDENT_TOKEN
BREATHECODE_API_BASE_URL
```

`BREATHECODE_STUDENT_TOKEN` is required. Store it only in the local runtime environment, such as the ignored `.env` used by Docker or another private OpenClaw environment source. Do not place a real token in tracked files.

`BREATHECODE_API_BASE_URL` is optional. If omitted, the helper provisionally uses:

```text
https://breathecode.herokuapp.com
```

That host must be confirmed during the first approved real API test.

## Token Rotation

The token shown during planning must be treated as exposed. Rotate it before running any real API test.

After rotation, configure only the new token in the private runtime environment. Do not paste it into chat, Git, docs, skill files, shell history, or test logs.

## Helper

The shared helper is:

```text
/data/.openclaw/workspace/scripts/breathecode-student-api.sh
```

It constructs the BreatheCode authorization header internally and returns minimized JSON. It must not print the token, authorization header, complete curl command, or environment values.

Supported commands:

```bash
/data/.openclaw/workspace/scripts/breathecode-student-api.sh auth-me
/data/.openclaw/workspace/scripts/breathecode-student-api.sh tasks
/data/.openclaw/workspace/scripts/breathecode-student-api.sh final-projects
/data/.openclaw/workspace/scripts/breathecode-student-api.sh cohorts
/data/.openclaw/workspace/scripts/breathecode-student-api.sh cohort-log
/data/.openclaw/workspace/scripts/breathecode-student-api.sh pending-work
/data/.openclaw/workspace/scripts/breathecode-student-api.sh progress-summary
```

## Skill Discovery

Skills are installed under:

```text
/data/.openclaw/skills/<skill-name>/SKILL.md
```

OpenClaw should discover skills from that directory. If a new skill does not appear in a live session, restart or reload OpenClaw before editing `openclaw.json`. Do not manually register skills in `openclaw.json` unless automatic discovery fails and the installed OpenClaw version requires it.

## First Real API Test

Only run the first real API test after explicit approval.

Required steps:

1. Rotate the exposed student token.
2. Add the rotated token to the private runtime environment as `BREATHECODE_STUDENT_TOKEN`.
3. Optionally set `BREATHECODE_API_BASE_URL` if the provisional host is wrong.
4. Restart/reload OpenClaw or its container if needed so the runtime env is visible.
5. Run the authentication helper command.
6. Confirm that the output is minimized and contains no token, header, email, full name, GitHub identity, biography, private URLs, or raw token metadata.
7. Record the redacted result in `SKILL_LOG.md` as `Real API tested`.

Do not commit `.env`, real API responses, runtime logs, private student data, or `data/.openclaw/openclaw.json`.
