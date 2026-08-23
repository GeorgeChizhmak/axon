#!/usr/bin/env bash
# =============================================================================
# tests/run_tests.sh — Automated test suite for axon
#
# Runs entirely in a temp directory. Does NOT require Docker.
# Run from the repository root: bash tests/run_tests.sh
# Or via: make test
# =============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BIN="$REPO_ROOT/src/axon"

# Colours
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

PASS=0
FAIL=0

pass() { echo -e "  ${GREEN}✓${NC} $*"; PASS=$(( PASS + 1 )); }
fail() { echo -e "  ${RED}✗${NC} $*"; FAIL=$(( FAIL + 1 )); }
assert_exists()    { [ -e "$1" ]          && pass "EXISTS: $1"          || fail "MISSING: $1"; }
assert_not_exists(){ [ ! -e "$1" ]        && pass "ABSENT: $1"          || fail "SHOULD NOT EXIST: $1"; }
assert_contains()  { grep -q "$2" "$1"   2>/dev/null && pass "CONTAINS '$2' in $1" || fail "MISSING '$2' in $1"; }
assert_output()    { echo "$1" | sed 's/\x1b\[[0-9;]*m//g' | grep -qiE "$2" && pass "OUTPUT matches '$2'" || fail "OUTPUT missing '$2'"; }

# ── Setup: create isolated test directory ─────────────────────────────────────
TESTDIR=$(mktemp -d)
trap "rm -rf '$TESTDIR'" EXIT
cd "$TESTDIR"

echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "${CYAN}   axon Test Suite                     ${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

# ─────────────────────────────────────────────────────────────────────────────
# TEST 1: axon help
# ─────────────────────────────────────────────────────────────────────────────
echo "[ Test 1: axon help ]"
output=$("$BIN" help 2>&1)
echo "$output" | grep -q "axon" && pass "help shows tool name" || fail "help missing tool name"
echo "$output" | grep -q "init"     && pass "help lists 'init'"    || fail "help missing 'init'"
echo "$output" | grep -q "new"      && pass "help lists 'new'"     || fail "help missing 'new'"
echo "$output" | grep -q "generate" && pass "help lists 'generate'"|| fail "help missing 'generate'"
echo "$output" | grep -q "list"     && pass "help lists 'list'"    || fail "help missing 'list'"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 2: axon init
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 2: axon init ]"
VISUAL=true "$BIN" init documentation -n "Test Project" -a "Tester <test@example.com>" >/dev/null 2>&1

assert_exists ".axon-dir"
assert_exists "README.adoc"
assert_exists "documentation/workspace.dsl"
assert_exists "documentation/arc42/_config.adoc"
assert_exists "documentation/arc42/01_introduction_and_goals.adoc"
assert_exists "documentation/arc42/09_architecture_decisions.adoc"
assert_exists "documentation/arc42/11_technical_risks.adoc"
assert_exists "documentation/adrs"
assert_exists "documentation/tdrs"
assert_exists "documentation/experiments"
assert_exists "documentation/epics"
assert_exists "documentation/tasks"
assert_exists "documentation/meetings"
assert_exists "documentation/data-cards"
assert_exists "documentation/model-cards"
assert_exists "documentation/runbooks"
assert_exists "documentation/guidelines"
assert_exists "documentation/diagrams"

# ADR #0001 should be created automatically
ADR_1=$(find documentation/adrs -name "0001-*.adoc" | head -1)
[ -n "$ADR_1" ] && pass "ADR #0001 created: $(basename "$ADR_1")" || fail "ADR #0001 not found"

# Placeholders should be substituted
assert_contains "README.adoc" "Test Project"
assert_contains "documentation/workspace.dsl" "Test Project"

# Re-init should be blocked (run from the TESTDIR where .axon-dir exists)
reinit_out=$("$BIN" init documentation -n "Second" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' || true)
echo "$reinit_out" | grep -qiE "already|initialised|initialized" \
    && pass "Re-init blocked with warning" \
    || fail "Re-init not blocked (got: $reinit_out)"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 3: axon new adr
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 3: axon new adr ]"
VISUAL=true "$BIN" new adr "Use PostgreSQL as the Operational Database" >/dev/null 2>&1

ADR_2=$(find documentation/adrs -name "0002-*.adoc" | head -1)
[ -n "$ADR_2" ] && pass "ADR #0002 created: $(basename "$ADR_2")" || fail "ADR #0002 not found"
assert_contains "documentation/arc42/09_architecture_decisions.adoc" "0002-"
assert_contains "$ADR_2" "ACCEPTED"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 4: axon new tdr
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 4: axon new tdr ]"
VISUAL=true "$BIN" new tdr "Memory Leak Under High Load" >/dev/null 2>&1

TDR_1=$(find documentation/tdrs -name "0001-*.adoc" | head -1)
[ -n "$TDR_1" ] && pass "TDR #0001 created: $(basename "$TDR_1")" || fail "TDR #0001 not found"
assert_contains "documentation/arc42/11_technical_risks.adoc" "0001-"
assert_contains "$TDR_1" "OPEN"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 5: axon new data-card, model-card, runbook, guideline
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 5: axon new (other types) ]"
VISUAL=true "$BIN" new data-card  "Raw User Events Dataset" >/dev/null 2>&1
VISUAL=true "$BIN" new model-card "Fraud Detection Classifier" >/dev/null 2>&1
VISUAL=true "$BIN" new runbook    "Deploy to Production" >/dev/null 2>&1
VISUAL=true "$BIN" new guideline  "REST API Design Standards" >/dev/null 2>&1

assert_exists "$(find documentation/data-cards   -name "0001-*.adoc" | head -1)"
assert_exists "$(find documentation/model-cards  -name "0001-*.adoc" | head -1)"
assert_exists "$(find documentation/runbooks     -name "0001-*.adoc" | head -1)"
assert_exists "$(find documentation/guidelines   -name "0001-*.adoc" | head -1)"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 6: axon new adr -s (supersession)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 6: Supersession (-s flag) ]"
VISUAL=true "$BIN" new adr -s 2 "Switch to CockroachDB for Global Scale" >/dev/null 2>&1

ADR_3=$(find documentation/adrs -name "0003-*.adoc" | head -1)
[ -n "$ADR_3" ] && pass "ADR #0003 created: $(basename "$ADR_3")" || fail "ADR #0003 not found"
assert_contains "$ADR_2" "SUPERSEDED"
assert_contains "$ADR_3" "Supersedes"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 7: axon list
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 7: axon list ]"
list_output=$("$BIN" list adr 2>&1)
echo "$list_output" | grep -q "0001" && pass "list adr shows #0001" || fail "list adr missing #0001"
echo "$list_output" | grep -q "0002" && pass "list adr shows #0002" || fail "list adr missing #0002"
echo "$list_output" | grep -q "0003" && pass "list adr shows #0003" || fail "list adr missing #0003"

summary_output=$("$BIN" list 2>&1)
echo "$summary_output" | grep -q "adr" && pass "list shows adr type" || fail "list missing adr type"
echo "$summary_output" | grep -qi "Project Management" && pass "list shows Project Management section" || fail "list missing Project Management section"
echo "$summary_output" | grep -q "epic" && pass "list shows epic type" || fail "list missing epic type"
echo "$summary_output" | grep -q "task" && pass "list shows task type" || fail "list missing task type"
echo "$summary_output" | grep -q "meeting" && pass "list shows meeting type" || fail "list missing meeting type"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 8: axon new experiment
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 8: axon new experiment ]"
assert_exists "documentation/experiments"

VISUAL=true "$BIN" new experiment "Redis for Session Caching" >/dev/null 2>&1
EXP_1=$(find documentation/experiments -name "0001-*.adoc" | head -1)
[ -n "$EXP_1" ] && pass "Experiment #0001 created: $(basename "$EXP_1")" || fail "Experiment #0001 not found"
assert_contains "$EXP_1" "EXP-0001"
assert_contains "$EXP_1" "Hypothesis"
assert_contains "$EXP_1" "ACTIVE"

VISUAL=true "$BIN" new experiment "Postgres Full-Text Search vs Elasticsearch" >/dev/null 2>&1
EXP_2=$(find documentation/experiments -name "0002-*.adoc" | head -1)
[ -n "$EXP_2" ] && pass "Experiment #0002 created: $(basename "$EXP_2")" || fail "Experiment #0002 not found"

# List experiments
list_exp=$("$BIN" list experiment 2>&1)
echo "$list_exp" | grep -q "0001" && pass "list experiment shows #0001" || fail "list experiment missing #0001"
echo "$list_exp" | grep -q "0002" && pass "list experiment shows #0002" || fail "list experiment missing #0002"

# Summary should include experiment type
summary_out=$("$BIN" list 2>&1)
echo "$summary_out" | grep -q "experiment" && pass "list summary shows experiment type" || fail "list summary missing experiment"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 9: axon promote
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 9: axon promote ]"

# Count ADRs before promote
adr_count_before=$(ls documentation/adrs/*.adoc 2>/dev/null | wc -l)

VISUAL=true "$BIN" promote 1 -t "Adopt Redis for Session Caching" >/dev/null 2>&1

# A new ADR should have been created
adr_count_after=$(ls documentation/adrs/*.adoc 2>/dev/null | wc -l)
[ "$adr_count_after" -gt "$adr_count_before" ] && pass "New ADR created by promote" || fail "Promote did not create ADR"

# The promoted ADR should reference the experiment
# Find the ADR that contains "Promoted from" (more reliable than -newer)
promoted_adr=$(grep -rl "Promoted from" documentation/adrs/ 2>/dev/null | head -1)
[ -n "$promoted_adr" ] && pass "Promoted ADR found: $(basename "$promoted_adr")" || fail "Promoted ADR not found"
assert_contains "$promoted_adr" "Promoted from"
assert_contains "$promoted_adr" "Experiment #1"

# The experiment should be marked PROMOTED-TO-ADR
assert_contains "$EXP_1" "PROMOTED-TO-ADR"

# The experiment should have a cross-reference back to the ADR
assert_contains "$EXP_1" "Promoted to ADR"

# The new ADR should be in the Arc42 section 09 aggregator
assert_contains "documentation/arc42/09_architecture_decisions.adoc" "adopt-redis"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 10: axon generate (--skip-dsl, no Docker needed)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 10: axon generate --skip-dsl ]"
"$BIN" generate --skip-dsl >/dev/null 2>&1 \
    && pass "generate --skip-dsl exited cleanly" \
    || fail "generate --skip-dsl failed"

assert_exists "$(find documentation -maxdepth 1 -name "*_architecture.html" | head -1)"
assert_exists "$(find documentation -maxdepth 1 -name "*_architecture.pdf"  | head -1)"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 11: unknown command / type error handling
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 11: Error handling ]"
# Unknown command: should exit non-zero and print something useful
unknown_cmd_out=$("$BIN" bogus-command 2>&1 | sed 's/\x1b\[[0-9;]*m//g' || true)
unknown_cmd_exit=${PIPESTATUS[0]:-1}
([ "$unknown_cmd_exit" -ne 0 ] || echo "$unknown_cmd_out" | grep -qiE "commands|usage|axon") \
    && pass "Unknown command handled gracefully (exit $unknown_cmd_exit)" \
    || fail "Unknown command not handled"

# Unknown type: should print 'Unknown' and exit non-zero
unknown_type_out=$("$BIN" new unknown-type "Title" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' || true)
echo "$unknown_type_out" | grep -qiE "unknown|invalid|valid" \
    && pass "Unknown type handled gracefully" \
    || fail "Unknown type not handled (got: $unknown_type_out)"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 12: axon new epic
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 12: axon new epic ]"
assert_exists "documentation/epics"

VISUAL=true "$BIN" new epic "Migrate to Event-Driven Architecture" >/dev/null 2>&1
EPIC_1=$(find documentation/epics -name "0001-*.adoc" | head -1)
[ -n "$EPIC_1" ] && pass "Epic #0001 created: $(basename "$EPIC_1")" || fail "Epic #0001 not found"
assert_contains "$EPIC_1" "EPIC-0001"
assert_contains "$EPIC_1" "PLANNING"
assert_contains "$EPIC_1" "Gantt"

list_epics=$("$BIN" list epic 2>&1)
echo "$list_epics" | grep -q "0001" && pass "list epic shows #0001" || fail "list epic missing #0001"
echo "$list_epics" | grep -qi "PRIORITY" && pass "list epic shows PRIORITY column" || fail "list epic missing PRIORITY column"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 13: axon new task with class
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 13: axon new task (with class) ]"
assert_exists "documentation/tasks"

VISUAL=true "$BIN" new task -c FEAT "Add OAuth2 Login Flow" >/dev/null 2>&1
TASK_1=$(find documentation/tasks -name "0001-*.adoc" | head -1)
[ -n "$TASK_1" ] && pass "Task #0001 created: $(basename "$TASK_1")" || fail "Task #0001 not found"
assert_contains "$TASK_1" "FEAT"
assert_contains "$TASK_1" "TODO"

VISUAL=true "$BIN" new task -c HYPO "Validate Caching Latency Improvement" >/dev/null 2>&1
TASK_2=$(find documentation/tasks -name "0002-*.adoc" | head -1)
[ -n "$TASK_2" ] && pass "Task #0002 (HYPO class) created: $(basename "$TASK_2")" || fail "Task #0002 not found"
assert_contains "$TASK_2" "HYPO"

VISUAL=true "$BIN" new task -c BUG "Memory Leak in Worker Process" >/dev/null 2>&1
TASK_3=$(find documentation/tasks -name "0003-*.adoc" | head -1)
[ -n "$TASK_3" ] && pass "Task #0003 (BUG class) created: $(basename "$TASK_3")" || fail "Task #0003 not found"
assert_contains "$TASK_3" "BUG"

# Default class should be TASK
VISUAL=true "$BIN" new task "Refactor Payment Service" >/dev/null 2>&1
TASK_4=$(find documentation/tasks -name "0004-*.adoc" | head -1)
[ -n "$TASK_4" ] && pass "Task #0004 (default TASK class) created: $(basename "$TASK_4")" || fail "Task #0004 not found"
assert_contains "$TASK_4" "TASK"

# Invalid class should be rejected
invalid_class_out=$("$BIN" new task -c INVALID "Some Task" 2>&1 | sed 's/\x1b\[[0-9;]*m//g' || true)
echo "$invalid_class_out" | grep -qiE "unknown|invalid|valid" \
    && pass "Invalid task class rejected gracefully" \
    || fail "Invalid task class not rejected"

list_tasks=$("$BIN" list task 2>&1)
echo "$list_tasks" | grep -q "0001" && pass "list task shows #0001" || fail "list task missing #0001"
echo "$list_tasks" | grep -qi "CLASS" && pass "list task shows CLASS column" || fail "list task missing CLASS column"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 14: axon list task --board (Kanban view)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 14: axon list task --board (Kanban view) ]"
board_out=$("$BIN" list task --board 2>&1 | sed 's/\x1b\[[0-9;]*m//g')
echo "$board_out" | grep -qiE "TODO|DONE|IN-PROGRESS|BLOCKED" \
    && pass "Kanban board shows status columns" \
    || fail "Kanban board missing status columns"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 15: axon new meeting
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 15: axon new meeting ]"
assert_exists "documentation/meetings"

VISUAL=true "$BIN" new meeting "Sprint 12 Planning" >/dev/null 2>&1
MEETING_1=$(find documentation/meetings -name "0001-*.adoc" | head -1)
[ -n "$MEETING_1" ] && pass "Meeting #0001 created: $(basename "$MEETING_1")" || fail "Meeting #0001 not found"
assert_contains "$MEETING_1" "SCHEDULED"
assert_contains "$MEETING_1" "Agenda"
assert_contains "$MEETING_1" "Action Items"

list_meetings=$("$BIN" list meeting 2>&1)
echo "$list_meetings" | grep -q "0001" && pass "list meeting shows #0001" || fail "list meeting missing #0001"
echo "$list_meetings" | grep -qi "DATE" && pass "list meeting shows DATE column" || fail "list meeting missing DATE column"

# ─────────────────────────────────────────────────────────────────────────────
# TEST 16: axon new experiment --notebook (optional Jupyter notebook)
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo "[ Test 16: axon new experiment --notebook ]"
VISUAL=true "$BIN" new experiment --notebook "Transformer Fine-Tuning Benchmark" >/dev/null 2>&1
EXP_NB=$(find documentation/experiments -name "0003-*.adoc" | head -1)
NB_FILE=$(find documentation/experiments -name "0003-*.ipynb" | head -1)
[ -n "$EXP_NB" ] && pass "Experiment #0003 adoc created: $(basename "$EXP_NB")" || fail "Experiment #0003 adoc not found"
[ -n "$NB_FILE" ] && pass "Experiment #0003 notebook created: $(basename "$NB_FILE")" || fail "Experiment #0003 notebook not found"
assert_contains "$NB_FILE" "EXP-0003"
assert_contains "$NB_FILE" "Transformer Fine-Tuning Benchmark"
assert_contains "$EXP_NB" "Companion notebook"

# ─────────────────────────────────────────────────────────────────────────────
# Summary
# ─────────────────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo -e "  Results: ${GREEN}${PASS} passed${NC}, ${RED}${FAIL} failed${NC}"
echo -e "${CYAN}═══════════════════════════════════════${NC}"
echo ""

[ $FAIL -eq 0 ] && exit 0 || exit 1
