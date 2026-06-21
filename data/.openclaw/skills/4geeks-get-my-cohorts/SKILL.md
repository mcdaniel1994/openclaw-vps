---
name: 4geeks-get-my-cohorts
description: Use when Cory asks which 4Geeks cohorts or courses he belongs to, including student membership and self-paced context.
---

# 4Geeks Get My Cohorts

## Purpose

Retrieve current student cohort memberships and course context.

## Trigger Examples

- "What 4Geeks cohorts am I in?"
- "Which course is my progress tied to?"
- "Am I in a self-paced cohort?"

## API Action

- Helper command: `/data/.openclaw/workspace/scripts/breathecode-student-api.sh cohorts`
- Endpoint: `GET /v1/admissions/user/me`

## Expected Output

Report student-role cohort rows only:

- cohort slug/name
- role
- educational status
- financial status if present
- stage
- `never_ends`
- current day/module as context only
- backend completion object only if present

## Cohort Rules

Filter to student memberships. Do not use teacher, assistant, or staff rows for learner progress.

For self-paced cohorts where `never_ends` is true, do not treat current day/module as primary progress.

## Error Behavior

Report missing permissions, missing credentials, not-found base URL issues, or malformed responses without guessing cohort state.

## Verification

Mock tests should cover no cohorts, student plus non-student roles, self-paced cohorts, completion present, and completion absent.
