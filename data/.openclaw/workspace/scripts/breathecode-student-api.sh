#!/usr/bin/env bash
# =============================================================================
# breathecode-student-api.sh - Safe BreatheCode student API helper
# =============================================================================
# Public-safe helper for OpenClaw skills. It reads credentials from environment,
# constructs Authorization internally, and emits minimized JSON summaries.
#
# Required at runtime:
#   BREATHECODE_STUDENT_TOKEN
#
# Optional:
#   BREATHECODE_API_BASE_URL  defaults to https://breathecode.herokuapp.com
#
# Test-only mock mode:
#   BREATHECODE_MOCK_BODY_FILE=/tmp/fixture.json
#   BREATHECODE_MOCK_TASKS_FILE=/tmp/tasks.json
#   BREATHECODE_MOCK_PROJECTS_FILE=/tmp/projects.json
#   BREATHECODE_MOCK_AUTH_FILE=/tmp/auth.json
#   BREATHECODE_MOCK_COHORTS_FILE=/tmp/cohorts.json
#   BREATHECODE_MOCK_COHORT_LOG_FILE=/tmp/cohort-log.json
#   BREATHECODE_MOCK_STATUS=200
#   BREATHECODE_MOCK_NETWORK_ERROR=timeout|connection
# =============================================================================

set -euo pipefail
set +x

DEFAULT_BASE_URL="https://breathecode.herokuapp.com"
BASE_URL="${BREATHECODE_API_BASE_URL:-$DEFAULT_BASE_URL}"
TOKEN="${BREATHECODE_STUDENT_TOKEN:-}"
TMPDIR="${TMPDIR:-/tmp}"

usage() {
  cat <<'USAGE'
Usage:
  breathecode-student-api.sh auth-me
  breathecode-student-api.sh tasks [query-string]
  breathecode-student-api.sh final-projects [query-string]
  breathecode-student-api.sh cohorts
  breathecode-student-api.sh cohort-log [cohort-id]
  breathecode-student-api.sh pending-work
  breathecode-student-api.sh progress-summary

All output is minimized JSON. Raw API responses and authorization headers are not printed.
USAGE
}

json_error() {
  local code="$1"
  local message="$2"
  local http_status="${3:-null}"
  jq -n \
    --arg code "$code" \
    --arg message "$message" \
    --argjson http_status "$http_status" \
    '{ok:false,error:{code:$code,message:$message,http_status:$http_status}}'
}

require_token() {
  if [ -z "$TOKEN" ]; then
    json_error "MISSING_CREDENTIALS" "BREATHECODE_STUDENT_TOKEN is not configured."
    exit 2
  fi
}

clean_base_url() {
  printf "%s" "${BASE_URL%/}"
}

safe_query() {
  local query="${1:-}"
  if [ -n "$query" ] && [ "${query#\?}" = "$query" ]; then
    printf "?%s" "$query"
  else
    printf "%s" "$query"
  fi
}

request_json() {
  local method="$1"
  local path="$2"
  local query="${3:-}"
  local response_file status_file http_status url mock_file

  require_token

  response_file="$(mktemp "${TMPDIR}/breathecode_resp_XXXXXX.json")"
  status_file="$(mktemp "${TMPDIR}/breathecode_status_XXXXXX.txt")"
  trap 'rm -f "$response_file" "$status_file"' RETURN

  mock_file="${BREATHECODE_MOCK_BODY_FILE:-}"
  case "$path" in
    "/v1/auth/user/me")
      mock_file="${BREATHECODE_MOCK_AUTH_FILE:-$mock_file}"
      ;;
    "/v1/assignment/user/me/task")
      mock_file="${BREATHECODE_MOCK_TASKS_FILE:-$mock_file}"
      ;;
    "/v1/assignment/user/me/final_project")
      mock_file="${BREATHECODE_MOCK_PROJECTS_FILE:-$mock_file}"
      ;;
    "/v1/admissions/user/me")
      mock_file="${BREATHECODE_MOCK_COHORTS_FILE:-$mock_file}"
      ;;
    /v1/admissions/me/cohort/*/user/log|"/v1/admissions/me/cohort/user/log")
      mock_file="${BREATHECODE_MOCK_COHORT_LOG_FILE:-$mock_file}"
      ;;
  esac

  if [ -n "$mock_file" ]; then
    if [ -n "${BREATHECODE_MOCK_NETWORK_ERROR:-}" ]; then
      case "$BREATHECODE_MOCK_NETWORK_ERROR" in
        timeout)
          json_error "TIMEOUT" "The BreatheCode API request timed out."
          return 4
          ;;
        *)
          json_error "NETWORK_ERROR" "Could not reach BreatheCode API."
          return 4
          ;;
      esac
    fi

    if [ ! -f "$mock_file" ]; then
      json_error "MOCK_FILE_MISSING" "Configured mock response file was not found."
      return 3
    fi
    cp "$mock_file" "$response_file"
    http_status="${BREATHECODE_MOCK_STATUS:-200}"
  else
    url="$(clean_base_url)${path}$(safe_query "$query")"
    http_status="$(
      curl --silent --show-error --location \
        --connect-timeout 5 \
        --max-time 20 \
        --request "$method" \
        --header "Authorization: Token ${TOKEN}" \
        --header "Accept: application/json" \
        --output "$response_file" \
        --write-out "%{http_code}" \
        "$url" 2>"$status_file" || true
    )"

    if [ -s "$status_file" ] && [ "$http_status" = "000" ]; then
      json_error "NETWORK_ERROR" "Could not reach BreatheCode API."
      return 4
    fi
  fi

  if ! [[ "$http_status" =~ ^[0-9][0-9][0-9]$ ]]; then
    json_error "HTTP_STATUS_UNKNOWN" "The API returned an unreadable HTTP status."
    return 5
  fi

  case "$http_status" in
    200|201|202)
      if ! jq empty "$response_file" >/dev/null 2>&1; then
        json_error "MALFORMED_JSON" "The API response was not valid JSON." "$http_status"
        return 6
      fi
      cat "$response_file"
      ;;
    204)
      jq -n '{ok:true,result:null}'
      ;;
    401)
      json_error "AUTH_REJECTED" "The configured BreatheCode token was rejected." "$http_status"
      return 7
      ;;
    403)
      json_error "FORBIDDEN" "The token is valid but does not have permission for this request." "$http_status"
      return 8
      ;;
    404)
      json_error "NOT_FOUND" "The requested BreatheCode endpoint or resource was not found." "$http_status"
      return 9
      ;;
    429)
      json_error "RATE_LIMITED" "The BreatheCode API rate limit was reached. Retry later." "$http_status"
      return 10
      ;;
    5??)
      json_error "SERVER_ERROR" "The BreatheCode API returned a server error." "$http_status"
      return 11
      ;;
    *)
      json_error "HTTP_ERROR" "The BreatheCode API returned an unexpected HTTP status." "$http_status"
      return 12
      ;;
  esac
}

as_array() {
  jq 'if type == "array" then . elif type == "object" and (.results|type) == "array" then .results else [] end'
}

normalize_auth() {
  jq 'if type == "object" and .ok == false then . else {
    ok: true,
    result: {
      authenticated: true,
      user_id_present: (.id != null),
      username_present: ((.username // "") != ""),
      settings: {
        lang: (.settings.lang? // null),
        main_currency: (.settings.main_currency? // null)
      },
      student_roles: [
        (.roles // [])[]
        | select((.role.slug? // .role? // "" | ascii_downcase) == "student")
        | {
            academy_slug: (.academy.slug? // null),
            academy_name_present: ((.academy.name? // "") != "")
          }
      ],
      permissions_count: ((.permissions // []) | length)
    }
  } end'
}

normalize_tasks() {
  jq 'if type == "object" and .ok == false then . else (if type == "array" then . elif type == "object" and (.results|type) == "array" then .results else [] end) | {
    ok: true,
    result: {
      count: length,
      items: [
        .[]
        | {
            id_present: (.id != null),
            title: ((.title // .associated_slug // "Untitled task") | tostring),
            task_type: (.task_type // "UNKNOWN"),
            task_status: (.task_status // "UNKNOWN"),
            revision_status: (.revision_status // "UNKNOWN"),
            associated_slug: (.associated_slug // null),
            cohort: {
              id_present: (.cohort.id? != null),
              slug: (.cohort.slug? // null),
              name: (.cohort.name? // null)
            },
            delivered_at_present: (.delivered_at != null),
            reviewed_at_present: (.reviewed_at != null),
            github_url_present: ((.github_url // "") != ""),
            live_url_present: ((.live_url // "") != "")
          }
      ],
      status_counts: {
        task_status: (group_by(.task_status // "UNKNOWN") | map({key:(.[0].task_status // "UNKNOWN"), value:length}) | from_entries),
        revision_status: (group_by(.revision_status // "UNKNOWN") | map({key:(.[0].revision_status // "UNKNOWN"), value:length}) | from_entries),
        task_type: (group_by(.task_type // "UNKNOWN") | map({key:(.[0].task_type // "UNKNOWN"), value:length}) | from_entries)
      }
    }
  } end'
}

normalize_projects() {
  jq 'if type == "object" and .ok == false then . else (if type == "array" then . elif type == "object" and (.results|type) == "array" then .results else [] end) | {
    ok: true,
    result: {
      count: length,
      items: [
        .[]
        | {
            id_present: (.id != null),
            name: ((.name // "Untitled project") | tostring),
            project_status: (.project_status // "UNKNOWN"),
            revision_status: (.revision_status // "UNKNOWN"),
            visibility_status: (.visibility_status // "UNKNOWN"),
            cohort: {
              id_present: (.cohort.id? != null),
              slug: (.cohort.slug? // null),
              name: (.cohort.name? // null)
            },
            repo_url_present: ((.repo_url // "") != ""),
            public_url_present: ((.public_url // "") != ""),
            screenshot_present: ((.screenshot // "") != "")
          }
      ],
      status_counts: {
        project_status: (group_by(.project_status // "UNKNOWN") | map({key:(.[0].project_status // "UNKNOWN"), value:length}) | from_entries),
        revision_status: (group_by(.revision_status // "UNKNOWN") | map({key:(.[0].revision_status // "UNKNOWN"), value:length}) | from_entries),
        visibility_status: (group_by(.visibility_status // "UNKNOWN") | map({key:(.[0].visibility_status // "UNKNOWN"), value:length}) | from_entries)
      }
    }
  } end'
}

normalize_cohorts() {
  jq 'if type == "object" and .ok == false then . else {
    ok: true,
    result: {
      student_cohort_count: ((.cohorts // []) | map(select((.role // "" | ascii_upcase) == "STUDENT")) | length),
      cohorts: [
        (.cohorts // [])[]
        | select((.role // "" | ascii_upcase) == "STUDENT")
        | {
            membership_id_present: (.id != null),
            role: (.role // "UNKNOWN"),
            educational_status: (.educational_status // "UNKNOWN"),
            financial_status: (.finantial_status // "UNKNOWN"),
            completion: (.completion? // null),
            cohort: {
              id_present: (.cohort.id? != null),
              slug: (.cohort.slug? // null),
              name: (.cohort.name? // null),
              stage: (.cohort.stage? // "UNKNOWN"),
              never_ends: (.cohort.never_ends? // null),
              current_day: (.cohort.current_day? // null),
              current_module: (.cohort.current_module? // null),
              academy_slug: (.cohort.academy.slug? // null),
              academy_name: (.cohort.academy.name? // null),
              micro_cohort_count: ((.cohort.micro_cohorts? // []) | length)
            }
          }
      ]
    }
  } end'
}

normalize_cohort_log() {
  jq 'if type == "object" and .ok == false then . else {
    ok: true,
    result: {
      cohort: {
        id_present: (.cohort.id? != null),
        slug: (.cohort.slug? // null)
      },
      history_log_present: (.history_log != null),
      delivered_assignments_count: ((.history_log.delivered_assignments? // []) | length),
      pending_assignments_count: ((.history_log.pending_assignments? // []) | length),
      raw_keys: ((.history_log // {}) | keys)
    }
  } end'
}

normalize_pending_work() {
  jq '
    def arr: if type == "array" then . elif type == "object" and (.results|type) == "array" then .results else [] end;
    {
      ok: true,
      result: {
        pending_tasks: [
          (.[0] | arr)[]
          | select((.task_status // "UNKNOWN") != "DONE" or (.revision_status // "UNKNOWN") == "REJECTED")
          | {
              title: ((.title // .associated_slug // "Untitled task") | tostring),
              task_type: (.task_type // "UNKNOWN"),
              task_status: (.task_status // "UNKNOWN"),
              revision_status: (.revision_status // "UNKNOWN"),
              cohort_slug: (.cohort.slug? // null)
            }
        ],
        pending_projects: [
          (.[1] | arr)[]
          | select((.project_status // "UNKNOWN") != "DONE" or ((.revision_status // "UNKNOWN") | IN("APPROVED","IGNORED") | not))
          | {
              name: ((.name // "Untitled project") | tostring),
              project_status: (.project_status // "UNKNOWN"),
              revision_status: (.revision_status // "UNKNOWN"),
              visibility_status: (.visibility_status // "UNKNOWN"),
              cohort_slug: (.cohort.slug? // null)
            }
        ]
      }
    }
    | .result.pending_task_count = (.result.pending_tasks | length)
    | .result.pending_project_count = (.result.pending_projects | length)
  '
}

normalize_progress_summary() {
  jq '
    def arr: if type == "array" then . elif type == "object" and (.results|type) == "array" then .results else [] end;
    def counts($field): group_by(.[$field] // "UNKNOWN") | map({key:(.[0][$field] // "UNKNOWN"), value:length}) | from_entries;
    {
      ok: true,
      result: {
        tasks: {
          total: ((.[0] | arr) | length),
          task_status_counts: ((.[0] | arr) | counts("task_status")),
          revision_status_counts: ((.[0] | arr) | counts("revision_status")),
          task_type_counts: ((.[0] | arr) | counts("task_type"))
        },
        projects: {
          total: ((.[1] | arr) | length),
          project_status_counts: ((.[1] | arr) | counts("project_status")),
          revision_status_counts: ((.[1] | arr) | counts("revision_status")),
          visibility_status_counts: ((.[1] | arr) | counts("visibility_status"))
        },
        percentage: null,
        percentage_note: "No percentage is reported unless a trustworthy backend field or complete documented calculation is available."
      }
    }
  '
}

command="${1:-help}"
case "$command" in
  auth-me)
    request_json GET "/v1/auth/user/me" | normalize_auth
    ;;
  tasks)
    request_json GET "/v1/assignment/user/me/task" "${2:-}" | normalize_tasks
    ;;
  final-projects)
    request_json GET "/v1/assignment/user/me/final_project" "${2:-}" | normalize_projects
    ;;
  cohorts)
    request_json GET "/v1/admissions/user/me" | normalize_cohorts
    ;;
  cohort-log)
    if [ -n "${2:-}" ]; then
      request_json GET "/v1/admissions/me/cohort/${2}/user/log" | normalize_cohort_log
    else
      request_json GET "/v1/admissions/me/cohort/user/log" | normalize_cohort_log
    fi
    ;;
  pending-work)
    tasks_file="$(mktemp "${TMPDIR}/breathecode_tasks_XXXXXX.json")"
    projects_file="$(mktemp "${TMPDIR}/breathecode_projects_XXXXXX.json")"
    trap 'rm -f "$tasks_file" "$projects_file"' EXIT
    request_json GET "/v1/assignment/user/me/task" > "$tasks_file"
    request_json GET "/v1/assignment/user/me/final_project" > "$projects_file"
    jq -s '.' "$tasks_file" "$projects_file" | normalize_pending_work
    ;;
  progress-summary)
    tasks_file="$(mktemp "${TMPDIR}/breathecode_tasks_XXXXXX.json")"
    projects_file="$(mktemp "${TMPDIR}/breathecode_projects_XXXXXX.json")"
    trap 'rm -f "$tasks_file" "$projects_file"' EXIT
    request_json GET "/v1/assignment/user/me/task" > "$tasks_file"
    request_json GET "/v1/assignment/user/me/final_project" > "$projects_file"
    jq -s '.' "$tasks_file" "$projects_file" | normalize_progress_summary
    ;;
  help|-h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
