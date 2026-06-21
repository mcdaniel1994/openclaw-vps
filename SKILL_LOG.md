# 4Geeks Progress Assistant Skill Log

This log tracks planned and tested OpenClaw skills for the 4Geeks Progress Assistant. It is public-safe and must not contain tokens, authorization headers, real private API responses, emails, full names, GitHub identities, private URLs, or runtime configuration values.

Allowed test statuses:

- Planned
- Mock tested
- Real API tested
- Failed
- Unresolved

## Security Baseline

- Auth header is constructed only inside `data/.openclaw/workspace/scripts/breathecode-student-api.sh`.
- Runtime token variable: `BREATHECODE_STUDENT_TOKEN`.
- Runtime base URL variable: `BREATHECODE_API_BASE_URL`.
- Provisional default host: `https://breathecode.herokuapp.com`.
- The planning token is treated as exposed and must be rotated before real API testing.
- Real API testing has not been performed yet.

## Shared Helper

- File: `data/.openclaw/workspace/scripts/breathecode-student-api.sh`
- Description: safe transport and response minimization layer for BreatheCode student API calls.
- Status: Mock tested
- Real API result: Unresolved
- Limitations: base host and live response details remain subject to the first approved real API test.

## Skill: 4geeks-authenticate

- Starting prompt: "I want to give you the ability to connect to my 4Geeks account using my student token, without me having to write any code. What do we need to do?"
- Description: validate that the configured student token works.
- Endpoint: `GET /v1/auth/user/me`
- Required input: configured `BREATHECODE_STUDENT_TOKEN`.
- Expected output: safe authentication status and minimal account context.
- Security considerations: do not print token, auth header, email, full name, GitHub identity, biography, private URLs, token metadata, or raw response.
- Test status: Real API tested
- Real API result: Passed on 2026-06-21. The helper returned `ok: true`, `authenticated: true`, user and username presence booleans, language setting, two student academy entries with slugs, and permission count. No token, authorization header, email, full name, GitHub identity, biography, private URL, or token metadata was shown.
- Limitations: downstream task, project, cohort, and history endpoints still need approved real testing.

## Skill: 4geeks-get-projects

- Starting prompt: "What projects have been assigned to me?"
- Description: retrieve assigned final projects and preserve real status fields.
- Endpoint: `GET /v1/assignment/user/me/final_project`
- Required input: configured token; optional query filters may be added later.
- Expected output: project names, raw project statuses, raw revision statuses, visibility statuses, and safe URL-presence flags.
- Security considerations: do not return full raw project response or private URL values by default.
- Test status: Mock tested
- Real API result: Unresolved
- Limitations: `/final_project` is source-confirmed but still needs approved live verification.

## Skill: 4geeks-get-pending-work

- Starting prompt: "What work do I still have pending?"
- Description: combine incomplete tasks and incomplete projects.
- Endpoints: `GET /v1/assignment/user/me/task`, `GET /v1/assignment/user/me/final_project`
- Required input: configured token.
- Expected output: pending/rejected/unknown tasks and projects with raw statuses.
- Security considerations: minimize fields and avoid raw responses.
- Test status: Mock tested
- Real API result: Unresolved
- Limitations: pending rules may need refinement after real statuses are observed.

## Skill: 4geeks-progress-summary

- Starting prompt: "How far along am I in the course?"
- Description: provide factual progress counts from tasks and projects.
- Endpoints: `GET /v1/assignment/user/me/task`, `GET /v1/assignment/user/me/final_project`
- Required input: configured token.
- Expected output: totals and status-count buckets.
- Security considerations: do not invent percentages or expose raw data.
- Test status: Mock tested
- Real API result: Unresolved
- Limitations: no percentage is shown until a trustworthy backend field or complete documented calculation is confirmed.

## Skill: 4geeks-get-my-cohorts

- Starting prompt: "What 4Geeks cohorts am I in?"
- Description: retrieve student cohort memberships and course context.
- Endpoint: `GET /v1/admissions/user/me`
- Required input: configured token.
- Expected output: student-role cohort rows, educational status, stage, self-paced context, and completion object when present.
- Security considerations: do not expose private profile fields.
- Test status: Mock tested
- Real API result: Unresolved
- Limitations: macro/micro cohort behavior needs approved live verification.

## Skill: 4geeks-get-cohort-history

- Starting prompt: "Show my cohort history log."
- Description: retrieve cohort history snapshots as secondary progress evidence.
- Endpoints: `GET /v1/admissions/me/cohort/user/log`, `GET /v1/admissions/me/cohort/<cohort-id>/user/log`
- Required input: configured token; optional cohort id.
- Expected output: history existence, delivered count, pending count, safe top-level keys.
- Security considerations: treat history as private and minimize output.
- Test status: Mock tested
- Real API result: Unresolved
- Limitations: history may lag live tasks; live task rows remain authoritative when they disagree.

## Skill: 4geeks-progress-options

- Starting prompt: "What options do I have for checking 4Geeks?"
- Description: show a short Telegram-friendly menu, then route the selected number or phrase to the matching focused 4Geeks skill.
- Endpoint: none for the menu response; selected actions delegate to the relevant skill endpoint.
- Required input: a menu request, then a number or option name.
- Expected output: a short numbered list: progress summary, pending work, assigned projects, my cohorts, cohort history, connection check.
- Security considerations: menu display does not call the API; selected checks still follow the shared helper's token and response-minimization rules.
- Test status: Planned
- Real API result: Unresolved
- Limitations: requires OpenClaw skill reload/restart before Telegram can use the new skill.

## Mock Test Summary

- Static helper syntax: Mock tested; `bash -n` passed.
- Missing credential behavior: Mock tested; helper returns `MISSING_CREDENTIALS` without token/header output.
- Accepted auth fixture: Mock tested; helper returns minimized auth context and omits email, full name, GitHub identity, biography, private URLs, and token metadata.
- HTTP error fixtures: Mock tested; 401, 403, 404, 429, and 500-class responses return safe error envelopes.
- Network behavior: Mock tested; timeout and connection failure return safe error envelopes.
- Malformed JSON: Mock tested; invalid JSON returns `MALFORMED_JSON`.
- Data normalization fixtures: Mock tested; tasks, projects, cohorts, cohort history, pending work, and progress summary preserve raw statuses and minimize URL fields.
- Security audit: Passed current-run public-file scan; no planning token, fake test token, mock private literals, or secret values were found in the new tracked files. Expected documentation warnings about `.env` and `openclaw.json` remain.

Update this section after each test run with redacted results only.
