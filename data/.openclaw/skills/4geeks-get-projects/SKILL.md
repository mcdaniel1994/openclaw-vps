---
name: 4geeks-get-projects
description: Use when Cory asks for assigned 4Geeks projects, project submission state, approval state, or project status counts.
---

# 4Geeks Get Projects

## Purpose

Retrieve assigned final projects and report their real BreatheCode statuses.

## Trigger Examples

- "What projects are assigned to me?"
- "Which projects are pending, submitted, approved, or rejected?"
- "Show my 4Geeks project statuses."

## API Action

- Helper command: `/data/.openclaw/workspace/scripts/breathecode-student-api.sh final-projects`
- Endpoint: `GET /v1/assignment/user/me/final_project`
- Auth: handled internally by the shared helper.

## Expected Output

Report:

- project count
- project name, using "Untitled project" if missing
- raw `project_status`
- raw `revision_status`
- raw `visibility_status`
- cohort slug/name when available
- whether repo/public/screenshot URLs are present, not the private URL values by default

## Status Rules

Preserve raw API values. Friendly wording may be added only as a secondary interpretation.

Do not equate `DONE` with graded. Treat grading/approval as known only when `revision_status` or another explicit field supports it.

Unknown statuses must be shown as unknown, not discarded.

## Error Behavior

Use the shared helper error envelope. If `/final_project` is not found during a later approved real test, report that `/projects` may need separate confirmation before changing endpoints.

## Verification

Mock tests should cover empty projects, mixed statuses, unknown statuses, missing names, and safe URL minimization.
