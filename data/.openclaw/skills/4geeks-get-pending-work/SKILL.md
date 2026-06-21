---
name: 4geeks-get-pending-work
description: Use when Cory asks what 4Geeks tasks or projects remain incomplete or need attention.
---

# 4Geeks Get Pending Work

## Purpose

Return incomplete work only, combining tasks and projects without dumping every course detail.

## Trigger Examples

- "What work do I still have pending?"
- "What should I work on next for 4Geeks?"
- "Show incomplete tasks and projects."

## API Action

- Helper command: `/data/.openclaw/workspace/scripts/breathecode-student-api.sh pending-work`
- Endpoints:
  - `GET /v1/assignment/user/me/task`
  - `GET /v1/assignment/user/me/final_project`

## Expected Output

Group results into:

- pending tasks
- pending projects
- rejected work that likely needs attention
- unknown statuses requiring manual review

For each item include title/name, task type when present, cohort slug when present, and raw status fields.

## Status Rules

Use raw API statuses first. Treat task `DONE` as completion only for task-status counts; do not call it graded. Treat project approval/rejection as a revision-status concern when that field exists.

Unknown statuses must be included in the output.

## Error Behavior

If one endpoint fails and the other succeeds, report partial results and clearly name which endpoint failed.

## Verification

Mock tests should cover empty lists, mixed statuses, rejected revisions, missing titles/names, duplicates, and unknown statuses.
