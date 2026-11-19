#!/usr/bin/env bash
# ticket.sh - helper for the file-based ticket board in ./tickets
#
# The folder a ticket sits in IS its status. This script is the only thing
# that should create or move ticket files, so IDs stay unique and no ticket
# skips a stage by accident.
#
# CUSTOMIZE: change the ID prefixes or the tickets folder with the env vars
#            below (or edit the defaults). If you rename or add a status,
#            update STATUSES and the transition table in allowed().
# JIRA:      if you switch to Jira, this script and ./tickets are not used.
#            See ../SKILL.jira.md.
#
# Works with the bash 3.2 that ships on macOS and with Git Bash on Windows.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
TICKETS_DIR="${TICKETS_DIR:-$ROOT/tickets}"
TICKET_PREFIX="${TICKET_PREFIX:-T}"
EPIC_PREFIX="${EPIC_PREFIX:-E}"
STATUSES="pending in-progress review qa done"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATES="${TICKET_TEMPLATES:-$SCRIPT_DIR/../templates}"

die() { echo "ticket.sh: $*" >&2; exit 1; }

usage() {
  cat <<'EOF'
Usage: ticket.sh <command> [args]

  init                              Create the tickets/ folders if missing
  list [status|epics]               Show the board (or one column)
  show <ID>                         Print status, path, and full ticket text
  path <ID>                         Print the ticket's file path
  status <ID>                       Print the ticket's status (folder name)
  next                              Print the ID of the next ready pending ticket
  next-id [ticket|epic]             Print the next unused ID
  new <type> "<title>" [options]    Create a ticket in pending/ (or an epic in epics/)
        type: feature | bug | chore | spike | epic
        --epic E-001   --priority P1|P2|P3   --depends T-001,T-002   --estimate S|M|L
  move <ID> <status> [--by <agent>] [--force]
                                    Move a ticket to another status folder
  log <ID> <agent> <message...>     Append a dated line to the ticket's Activity section
  check                             Report duplicate IDs and misplaced files

Statuses: pending -> in-progress -> review -> qa -> done
Allowed moves: pending>in-progress, in-progress>review, review>qa, qa>done,
               review>in-progress, qa>in-progress, in-progress>pending
EOF
}

is_status() {
  local s
  for s in $STATUSES; do [ "$s" = "$1" ] && return 0; done
  return 1
}

allowed() {
  case "$1>$2" in
    "pending>in-progress"|"in-progress>review"|"review>qa"|"qa>done") return 0 ;;
    "review>in-progress"|"qa>in-progress"|"in-progress>pending") return 0 ;;
    *) return 1 ;;
  esac
}

upper() { printf '%s' "$1" | tr '[:lower:]' '[:upper:]'; }

# Print every file whose name starts with the given ID.
find_matches() {
  [ -d "$TICKETS_DIR" ] || return 0
  find "$TICKETS_DIR" -type f \( -name "$1-*.md" -o -name "$1.md" \) 2>/dev/null | sort
}

find_file() {
  local id matches count
  id="$(upper "$1")"
  matches="$(find_matches "$id")"
  [ -n "$matches" ] || die "no ticket found with ID $id (looked in $TICKETS_DIR)"
  count="$(printf '%s\n' "$matches" | wc -l | tr -d ' ')"
  if [ "$count" -gt 1 ]; then
    echo "ticket.sh: duplicate ID $id, fix by hand before continuing:" >&2
    printf '%s\n' "$matches" >&2
    exit 1
  fi
  printf '%s\n' "$matches"
}

status_of() { basename "$(dirname "$1")"; }

# Read a single-line frontmatter field, stripping surrounding quotes.
field() {
  local v
  v="$(sed -n "s/^$2:[[:space:]]*//p" "$1" | head -n 1)"
  v="${v%\"}"; v="${v#\"}"
  printf '%s' "$v"
}

num_of() { printf '%s' "$1" | sed -E 's/^[A-Za-z]+-0*([0-9]+).*/\1/'; }

cmd_init() {
  local s
  for s in $STATUSES epics; do
    mkdir -p "$TICKETS_DIR/$s"
    [ -e "$TICKETS_DIR/$s/.gitkeep" ] || : > "$TICKETS_DIR/$s/.gitkeep"
  done
  echo "tickets board ready at $TICKETS_DIR"
}

next_id() {
  local prefix max f n
  prefix="$1"; max=0
  if [ -d "$TICKETS_DIR" ]; then
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      n="$(num_of "$(basename "$f")")"
      case "$n" in ''|*[!0-9]*) continue ;; esac
      [ "$n" -gt "$max" ] && max="$n"
    done <<EOF
$(find "$TICKETS_DIR" -type f -name "$prefix-[0-9]*.md" 2>/dev/null)
EOF
  fi
  printf '%s-%03d\n' "$prefix" $((max + 1))
}

cmd_next_id() {
  case "${1:-ticket}" in
    epic) next_id "$EPIC_PREFIX" ;;
    *) next_id "$TICKET_PREFIX" ;;
  esac
}

slugify() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//' | cut -c1-50 | sed -E 's/-+$//'
}

cmd_new() {
  [ $# -ge 2 ] || die "usage: new <type> \"<title>\" [--epic E-001] [--priority P2] [--depends T-001,T-002] [--estimate M]"
  local type title epic priority depends estimate id dir tpl slug file content today
  type="$1"; title="$2"; shift 2
  epic=""; priority="P2"; depends=""; estimate=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --epic) epic="$(upper "${2:-}")"; shift 2 ;;
      --priority) priority="$(upper "${2:-}")"; shift 2 ;;
      --depends) depends="$(upper "${2:-}")"; shift 2 ;;
      --estimate) estimate="$(upper "${2:-}")"; shift 2 ;;
      *) die "unknown option: $1" ;;
    esac
  done
  case "$priority" in P1|P2|P3) ;; *) die "priority must be P1, P2, or P3" ;; esac
  case "$type" in
    epic) id="$(next_id "$EPIC_PREFIX")"; dir="$TICKETS_DIR/epics"; tpl="$TEMPLATES/epic.md" ;;
    bug) id="$(next_id "$TICKET_PREFIX")"; dir="$TICKETS_DIR/pending"; tpl="$TEMPLATES/bug.md" ;;
    feature|chore|spike) id="$(next_id "$TICKET_PREFIX")"; dir="$TICKETS_DIR/pending"; tpl="$TEMPLATES/ticket.md" ;;
    *) die "type must be one of: feature, bug, chore, spike, epic" ;;
  esac
  [ -f "$tpl" ] || die "template not found: $tpl"
  if [ -n "$epic" ]; then find_file "$epic" >/dev/null; fi
  mkdir -p "$dir"
  title="$(printf '%s' "$title" | tr '"' "'")"
  slug="$(slugify "$title")"
  [ -n "$slug" ] || slug="untitled"
  file="$dir/$id-$slug.md"
  today="$(date +%Y-%m-%d)"
  depends="$(printf '%s' "$depends" | sed -E 's/[[:space:]]*,[[:space:]]*/, /g')"
  content="$(cat "$tpl")"
  content=${content//\{\{ID\}\}/"$id"}
  content=${content//\{\{TITLE\}\}/"$title"}
  content=${content//\{\{TYPE\}\}/"$type"}
  content=${content//\{\{PRIORITY\}\}/"$priority"}
  content=${content//\{\{EPIC\}\}/"$epic"}
  content=${content//\{\{DEPENDS\}\}/"$depends"}
  content=${content//\{\{ESTIMATE\}\}/"$estimate"}
  content=${content//\{\{DATE\}\}/"$today"}
  printf '%s\n' "$content" > "$file"
  echo "$file"
}

cmd_log() {
  [ $# -ge 3 ] || die "usage: log <ID> <agent> <message...>"
  local file agent
  file="$(find_file "$1")"; agent="$2"; shift 2
  grep -q '^## Activity' "$file" || printf '\n## Activity\n\n' >> "$file"
  printf -- '- %s [%s] %s\n' "$(date '+%Y-%m-%d %H:%M')" "$agent" "$*" >> "$file"
}

cmd_move() {
  [ $# -ge 2 ] || die "usage: move <ID> <status> [--by <agent>] [--force]"
  local id to by force file from dest
  id="$(upper "$1")"; to="$2"; shift 2
  by="unknown"; force=0
  while [ $# -gt 0 ]; do
    case "$1" in
      --by) by="${2:-unknown}"; shift 2 ;;
      --force) force=1; shift ;;
      *) die "unknown option: $1" ;;
    esac
  done
  is_status "$to" || die "unknown status '$to' (valid: $STATUSES)"
  file="$(find_file "$id")"
  from="$(status_of "$file")"
  [ "$from" != "epics" ] || die "$id is an epic; epics stay in tickets/epics and do not move"
  [ "$from" != "$to" ] || die "$id is already in $to"
  if [ "$force" -ne 1 ] && ! allowed "$from" "$to"; then
    die "move $from -> $to is not allowed for $id (use --force only if a human told you to)"
  fi
  mkdir -p "$TICKETS_DIR/$to"
  dest="$TICKETS_DIR/$to/$(basename "$file")"
  if git -C "$ROOT" ls-files --error-unmatch "$file" >/dev/null 2>&1; then
    git -C "$ROOT" mv "$file" "$dest"
  else
    mv "$file" "$dest"
  fi
  cmd_log "$id" "$by" "moved $from -> $to"
  echo "$dest"
}

print_column() {
  local dir f count
  dir="$TICKETS_DIR/$1"; count=0
  echo "== $1 =="
  if [ -d "$dir" ]; then
    for f in "$dir"/*.md; do
      [ -e "$f" ] || continue
      count=$((count + 1))
      printf '  %-7s %-8s %-3s %s\n' "$(field "$f" id)" "$(field "$f" type)" "$(field "$f" priority)" "$(field "$f" title)"
    done
  fi
  [ "$count" -gt 0 ] || echo "  (empty)"
}

cmd_list() {
  local s
  if [ $# -ge 1 ]; then
    if [ "$1" != "epics" ] && ! is_status "$1"; then die "unknown column '$1' (valid: epics $STATUSES)"; fi
    print_column "$1"
    return 0
  fi
  print_column epics
  for s in $STATUSES; do print_column "$s"; done
}

cmd_show() {
  [ $# -ge 1 ] || die "usage: show <ID>"
  local file
  file="$(find_file "$1")"
  echo "status: $(status_of "$file")"
  echo "path: ${file#"$ROOT"/}"
  echo "----"
  cat "$file"
}

# Next ready ticket: lowest priority number first, then lowest ID, skipping
# any ticket whose depends_on entries are not all in done/.
cmd_next() {
  local dir f pri line id deps d ok blocked
  dir="$TICKETS_DIR/pending"; blocked=""
  [ -d "$dir" ] || die "no pending folder; run: ticket.sh init"
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    f="${line#* * }"
    id="$(field "$f" id)"
    deps="$(sed -n 's/^depends_on:[[:space:]]*//p' "$f" | head -n 1 | grep -oE '[A-Za-z]+-[0-9]+' || true)"
    ok=1
    for d in $deps; do
      if ! find "$TICKETS_DIR/done" -type f \( -name "$d-*.md" -o -name "$d.md" \) 2>/dev/null | grep -q .; then
        ok=0; blocked="$blocked $id(waiting on $d)"
        break
      fi
    done
    if [ "$ok" -eq 1 ]; then echo "$id"; return 0; fi
  done <<EOF
$(for f in "$dir"/*.md; do
    [ -e "$f" ] || continue
    pri="$(field "$f" priority)"; [ -n "$pri" ] || pri="P2"
    printf '%s %06d %s\n' "$pri" "$(num_of "$(basename "$f")")" "$f"
  done | sort)
EOF
  if [ -n "$blocked" ]; then echo "ticket.sh: no ready ticket; blocked:$blocked" >&2; else echo "ticket.sh: pending is empty" >&2; fi
  return 1
}

cmd_check() {
  local problems f id dups s base
  problems=0
  [ -d "$TICKETS_DIR" ] || die "no tickets folder; run: ticket.sh init"
  dups="$(find "$TICKETS_DIR" -type f -name '*.md' ! -name 'README.md' -exec basename {} \; | grep -oE '^[A-Za-z]+-[0-9]+' | sort | uniq -d || true)"
  for id in $dups; do
    problems=$((problems + 1))
    echo "DUPLICATE ID $id:"; find_matches "$id" | sed 's/^/  /'
  done
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    base="$(basename "$f")"
    [ "$base" = "README.md" ] && continue
    s="$(status_of "$f")"
    if [ "$s" != "epics" ] && ! is_status "$s"; then
      problems=$((problems + 1)); echo "MISPLACED (not in a status folder): $f"
    fi
    if ! printf '%s' "$base" | grep -qE '^[A-Za-z]+-[0-9]+(-.*)?\.md$'; then
      problems=$((problems + 1)); echo "BAD FILENAME (expected ID-slug.md): $f"
    elif [ "$(field "$f" id)" != "$(printf '%s' "$base" | grep -oE '^[A-Za-z]+-[0-9]+')" ]; then
      problems=$((problems + 1)); echo "ID MISMATCH (frontmatter id differs from filename): $f"
    fi
  done <<EOF
$(find "$TICKETS_DIR" -type f -name '*.md')
EOF
  if [ "$problems" -eq 0 ]; then echo "board OK"; else echo "$problems problem(s) found"; return 1; fi
}

main() {
  local cmd
  cmd="${1:-help}"
  [ $# -gt 0 ] && shift
  case "$cmd" in
    init) cmd_init ;;
    list|board) cmd_list "$@" ;;
    show) cmd_show "$@" ;;
    path) [ $# -ge 1 ] || die "usage: path <ID>"; find_file "$1" ;;
    status) [ $# -ge 1 ] || die "usage: status <ID>"; status_of "$(find_file "$1")" ;;
    next) cmd_next ;;
    next-id) cmd_next_id "$@" ;;
    new) cmd_new "$@" ;;
    move) cmd_move "$@" ;;
    log) cmd_log "$@" ;;
    check) cmd_check ;;
    help|-h|--help) usage ;;
    *) usage >&2; exit 1 ;;
  esac
}

main "$@"
