---
name: 4geeks-authenticate
description: Use when Cory asks whether the 4Geeks/BreatheCode student API connection is configured, valid, or ready to use.
---

# 4Geeks Authenticate

## Purpose

Validate the configured BreatheCode student token without exposing the token or raw account data.

## Trigger Examples

- "Is my 4Geeks connection working?"
- "Check whether my student token is valid."
- "Can you connect to my 4Geeks account?"

## API Action

- Helper command: `/data/.openclaw/workspace/scripts/breathecode-student-api.sh auth-me`
- Endpoint: `GET /v1/auth/user/me`
- Auth: the helper constructs `Authorization: Token ${BREATHECODE_STUDENT_TOKEN}` internally.

## Required Input

No user input is required after `BREATHECODE_STUDENT_TOKEN` and optional `BREATHECODE_API_BASE_URL` are configured in the runtime environment.

## Expected Output

Return only safe authentication information:

- whether authentication succeeded
- whether a user id or username was present, without printing values
- student academy slug if returned by the API
- settings such as language or currency when present
- permissions count

Do not print email, full name, GitHub identity, biography, private URLs, token metadata, authorization headers, or raw response bodies.

## Error Behavior

- Missing token: say credentials are not configured.
- 401: say the token was rejected.
- 403: say the token is valid but lacks permission for the endpoint.
- 404: say the validation endpoint was not found and base URL may need confirmation.
- 429: ask to retry later.
- 5xx, timeout, malformed JSON: report the failure without guessing.

## Verification

Mock/static tests may verify helper behavior. Real API validation must only be reported after an approved real API test with a rotated token.
