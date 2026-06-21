---
name: 4geeks-progress-summary
description: Use when Cory asks how far along he is in 4Geeks or wants an overview of task and project progress.
---

# 4Geeks Progress Summary

## Purpose

Provide a factual progress overview from task and project counts.

## Trigger Examples

- "How far along am I in the course?"
- "Summarize my 4Geeks progress."
- "Give me counts of completed and pending work."

## API Action

- Helper command: `/data/.openclaw/workspace/scripts/breathecode-student-api.sh progress-summary`
- Endpoints:
  - `GET /v1/assignment/user/me/task`
  - `GET /v1/assignment/user/me/final_project`

## Expected Output

Report:

- task total
- task status counts
- task revision status counts
- task type counts
- project total
- project status counts
- project revision status counts
- project visibility counts

## Progress Rules

Do not invent a percentage. Show percentage only if a trustworthy backend field is returned or a complete documented calculation is approved later.

Preserve raw status values and state uncertainty clearly.

## Error Behavior

Report API, credential, malformed JSON, rate-limit, and partial-data failures plainly. Do not fabricate missing progress data.

## Verification

Mock tests should cover mixed statuses, no percentage, empty datasets, unknown statuses, and malformed JSON.
