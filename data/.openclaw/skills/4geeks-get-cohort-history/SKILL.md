---
name: 4geeks-get-cohort-history
description: Use when Cory asks for 4Geeks cohort history snapshots, delivered assignment snapshots, or pending assignment history.
---

# 4Geeks Get Cohort History

## Purpose

Retrieve cohort history snapshots as secondary evidence for progress.

## Trigger Examples

- "Show my cohort history log."
- "What does 4Geeks history say I delivered?"
- "Check pending assignments from the cohort log."

## API Action

- Helper command for all cohorts: `/data/.openclaw/workspace/scripts/breathecode-student-api.sh cohort-log`
- Helper command for one cohort: `/data/.openclaw/workspace/scripts/breathecode-student-api.sh cohort-log <cohort-id>`
- Endpoints:
  - `GET /v1/admissions/me/cohort/user/log`
  - `GET /v1/admissions/me/cohort/<cohort-id>/user/log`

## Expected Output

Report:

- whether a history log exists
- delivered assignment count
- pending assignment count
- safe top-level history keys
- cohort slug when present

## Status Rules

Treat this endpoint as a snapshot that can lag behind live task rows. If history and live task data disagree, prefer `GET /v1/assignment/user/me/task` and explicitly say the history snapshot may be stale.

## Error Behavior

Report missing cohort id, missing permissions, not found, malformed JSON, and unavailable history without inventing log contents.

## Verification

Mock tests should cover empty history, delivered/pending counts, unknown history keys, and stale-history language.
