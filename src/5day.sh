#!/usr/bin/env bash
set -euo pipefail

# 5day - Five Day Docs CLI

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -d "$SCRIPT_DIR/docs/5day/scripts" ]; then
    PROJECT_ROOT="$SCRIPT_DIR"
else
    PROJECT_ROOT="$(dirname "$(dirname "$(dirname "$SCRIPT_DIR")")")"
fi

# Count files matching $2 (default *.md) directly under directory $1.
# Robust to empty/missing dirs (returns 0 via nullglob), spaces in the
# directory path (quoted) and in filenames (glob results are not
# word-split), and the caller's CWD (pass an absolute $1). nullglob is
# restored so callers see no global side effect.
count_files() {
    local dir="$1" pat="${2:-*.md}" restore
    local -a files
    restore="$(shopt -p nullglob)"
    shopt -s nullglob
    files=( "$dir"/$pat )
    eval "$restore"
    echo "${#files[@]}"
}

# Utility: run helper script
run_script() {
    local script="$PROJECT_ROOT/docs/5day/scripts/$1"
    shift
    if [ ! -f "$script" ]; then
        echo -e "${RED}ERROR: Script not found: $script${NC}"
        exit 1
    elif [ -x "$script" ]; then
        "$script" "$@"
    else
        # Fallback for filesystems that don't preserve the exec bit
        # (Windows volumes under WSL, Docker mounts, FAT32, some NFS/SMB,
        # git on Windows with core.fileMode=false, etc.). On those hosts
        # setup.sh's chmod +x silently no-ops, so we run via bash directly
        # rather than failing every command.
        bash "$script" "$@"
    fi
}

show_help() {
    echo -e "${CYAN}5day - Five Day Docs CLI${NC}"
    echo ""
    echo "Usage: ./5day.sh <command> [options]"
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo "  newidea <name>            Create a new idea to refine"
    echo "  newfeature [name]         Create a new feature (no name = AI Q&A)"
    echo "  newtask <description>     Create a new task"
    echo "  newbug <description>      Report a new bug"
    echo "  newtest <name>            Create a test loop to validate a deployed thing"
    echo "  status                    Show project status"
    echo "  checkfeatures             Analyze feature alignment"
    echo "  ai-context                Generate AI context summary"
    echo ""
    echo -e "${BLUE}Workflow:${NC}"
    echo "  profile                       Create or update project profile"
    echo "  search <keyword>              Search tasks by keyword"
    echo "  find <task-id>                Find task, analyze state, show prompt"
    echo "  find <task-id> --think        Stress-test task quality (interactive)"
    echo "  find <task-id> --work         Analyze → move → work (full lifecycle)"
    echo "  plan <task-id>            Interactive Q&A to define an incomplete task"
    echo "  sprint [count] [focus]    Plan a sprint from backlog tasks"
    echo "  define [limit]            Review and refine tasks in next/"
    echo "  tasks [limit] [--parallel] [--fast] Execute tasks from next/"
    echo "  loop [--hours N] [--refill] [--retry] Continuous task runner"
    echo "  split <path>              Split a large task into subtasks"
    echo "  review-sprint             Review sprint via dual-persona analysis"
    echo "  triage [limit]                Interactive walk-through of task pipeline"
    echo "  audit [folder|file] [limit] [offset]  Audit tasks in next/ (or specified folder)"
    echo "  review-code <file> [passes]   Run code audit on a task's changes"
    echo ""
    echo -e "${BLUE}Sync:${NC}"
    echo "  sync [--all]                  Push task changes to GitHub"
    echo ""
    echo -e "${BLUE}Maintenance:${NC}"
    echo "  validate [--fix] [--dry-run]  Validate task files against template"
    echo "  cleanup [--delete|--all]      Clean stale scratch files"
    echo ""
    echo "  help                      Show this message"
    echo "  help <command>            Show details for a command (e.g. help tasks)"
    echo ""
}

show_command_help() {
    local cmd="$1"
    local helpfile="$PROJECT_ROOT/docs/5day/help/$cmd.md"
    if [ ! -f "$helpfile" ]; then
        echo -e "${RED}Unknown command: $cmd${NC}"
        echo "Run ./5day.sh help for a list of commands."
        exit 1
    fi
    echo -e "${CYAN}./5day.sh $cmd${NC}"
    echo ""
    cat "$helpfile"
}

cmd_newidea() {
    [ -z "${1:-}" ] && { echo -e "${RED}ERROR: Idea name required${NC}"; exit 1; }
    run_script "create-idea.sh" "$1"
}

cmd_newtask() {
    [ -z "${1:-}" ] && { echo -e "${RED}ERROR: Task description required${NC}"; exit 1; }
    run_script "create-task.sh" "$1"
}

cmd_newfeature() {
    run_script "create-feature.sh" "$@"
}

cmd_status() {
    local root="$PROJECT_ROOT"
    local tasks="$root/docs/tasks"

    echo -e "${CYAN}=== Project Status ===${NC}"
    echo ""

    echo -e "${BLUE}Tasks:${NC}"
    echo "  Backlog:  $(count_files "$tasks/backlog")"
    echo "  Next:     $(count_files "$tasks/next")"
    echo "  Doing:    $(count_files "$tasks/doing")"
    echo "  Blocked:  $(count_files "$tasks/blocked")"
    echo "  Review:   $(count_files "$tasks/review")"
    echo "  Done:     $(count_files "$tasks/done")"

    local blocked_count doing_count
    blocked_count=$(count_files "$tasks/blocked")
    if [ "$blocked_count" -gt 0 ]; then
        echo ""
        echo -e "${RED}Blocked (needs attention to unblock sprint):${NC}"
        for task in "$tasks"/blocked/*.md; do
            [ -f "$task" ] && echo "  $(basename "$task" .md)"
        done
    fi

    doing_count=$(count_files "$tasks/doing")
    if [ "$doing_count" -gt 0 ]; then
        echo ""
        echo -e "${YELLOW}In progress:${NC}"
        for task in "$tasks"/doing/*.md; do
            [ -f "$task" ] && echo "  $(basename "$task" .md)"
        done
    fi

    local ideas_count bugs_count features_count
    ideas_count=$(count_files "$root/docs/ideas")
    if [ "$ideas_count" -gt 0 ]; then
        echo ""
        echo -e "${BLUE}Ideas:${NC}  $ideas_count"
    fi

    bugs_count=$(count_files "$root/docs/bugs" "[0-9]*.md")
    if [ "$bugs_count" -gt 0 ]; then
        echo ""
        echo -e "${BLUE}Bugs:${NC}   $bugs_count open"
    fi

    features_count=$(count_files "$root/docs/features")
    if [ "$features_count" -gt 0 ]; then
        echo ""
        echo -e "${BLUE}Features:${NC}"
        echo "  Backlog:  $(grep -l "Status:.*BACKLOG" "$root"/docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')"
        echo "  Doing:    $(grep -l "Status:.*DOING" "$root"/docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')"
        echo "  Done:     $(grep -l "Status:.*DONE" "$root"/docs/features/*.md 2>/dev/null | wc -l | tr -d ' ')"
    fi
}

cmd_newbug() {
    [ -z "${1:-}" ] && { echo -e "${RED}ERROR: Bug description required${NC}"; exit 1; }
    run_script "create-bug.sh" "$1"
}

cmd_newtest() {
    [ -z "${1:-}" ] && { echo -e "${RED}ERROR: Test name required${NC}"; exit 1; }
    run_script "create-test.sh" "$1"
}

cmd_search() {
    [ -z "${1:-}" ] && { echo -e "${RED}ERROR: Search term required${NC}"; echo "Usage: ./5day.sh search <keyword>"; exit 1; }
    run_script "search.sh" "$@"
}

cmd_find() {
    [ -z "${1:-}" ] && { echo -e "${RED}ERROR: Task ID required${NC}"; echo "Usage: ./5day.sh find <task-id>"; exit 1; }
    run_script "find.sh" "$@"
}

cmd_profile() {
    run_script "profile.sh" "$@"
}

cmd_plan() {
    [ -z "${1:-}" ] && { echo -e "${RED}ERROR: Task ID required${NC}"; echo "Usage: ./5day.sh plan <task-id>"; exit 1; }
    run_script "plan.sh" "$@"
}

cmd_sprint() {
    run_script "sprint.sh" "$@"
}

cmd_define() {
    run_script "define.sh" "$@"
}

cmd_tasks() {
    run_script "tasks.sh" "$@"
}

cmd_loop() {
    run_script "loop.sh" "$@"
}

cmd_split() {
    [ -z "${1:-}" ] && { echo -e "${RED}ERROR: Task file path required${NC}"; echo "Usage: ./5day.sh split <path/to/task.md>"; exit 1; }
    run_script "split.sh" "$@"
}

cmd_review_sprint() {
    run_script "review-sprint.sh" "$@"
}

cmd_triage() {
    run_script "triage.sh" "$@"
}

cmd_audit() {
    run_script "audit-tasks.sh" "$@"
}

cmd_review_code() {
    [ -z "${1:-}" ] && { echo -e "${RED}ERROR: File path(s) required${NC}"; echo "Usage: ./5day.sh review-code <task.md> [max-passes]"; echo "       ./5day.sh review-code <file1> <file2> ... [-- max-passes]"; exit 1; }
    run_script "audit-code.sh" "$@"
}

cmd_validate() {
    run_script "validate-tasks.sh" "$@"
}

cmd_cleanup() {
    run_script "cleanup-tmp.sh" "$@"
}

cmd_sync() {
    run_script "sync.sh" "$@"
}

cmd_checkfeatures() {
    run_script "check-alignment.sh"
}

cmd_ai_context() {
    run_script "ai-context.sh"
}

# Intercept --help/-h on any command: ./5day.sh tasks --help → help tasks
CMD="${1:-}"
if [ -n "$CMD" ] && [ "$CMD" != "help" ] && [ "$CMD" != "--help" ] && [ "$CMD" != "-h" ]; then
    for arg in "$@"; do
        if [ "$arg" = "--help" ] || [ "$arg" = "-h" ]; then
            show_command_help "$CMD"
            exit 0
        fi
    done
fi

# Main
case "$CMD" in
    newidea)       shift; cmd_newidea "$@" ;;
    newtask)       shift; cmd_newtask "$@" ;;
    newfeature)    shift; cmd_newfeature "$@" ;;
    newbug)        shift; cmd_newbug "$@" ;;
    newtest)       shift; cmd_newtest "$@" ;;
    status)        cmd_status ;;
    profile)       shift; cmd_profile "$@" ;;
    search)        shift; cmd_search "$@" ;;
    find)          shift; cmd_find "$@" ;;
    plan)          shift; cmd_plan "$@" ;;
    sprint)        shift; cmd_sprint "$@" ;;
    define)        shift; cmd_define "$@" ;;
    tasks)         shift; cmd_tasks "$@" ;;
    loop)          shift; cmd_loop "$@" ;;
    split)         shift; cmd_split "$@" ;;
    review-sprint) shift; cmd_review_sprint "$@" ;;
    triage)        shift; cmd_triage "$@" ;;
    audit)         shift; cmd_audit "$@" ;;
    review-code)   shift; cmd_review_code "$@" ;;
    sync)          shift; cmd_sync "$@" ;;
    validate)      shift; cmd_validate "$@" ;;
    cleanup)       shift; cmd_cleanup "$@" ;;
    checkfeatures) cmd_checkfeatures ;;
    ai-context)    cmd_ai_context ;;
    help|--help|-h) shift; if [ -n "${1:-}" ]; then show_command_help "$1"; else show_help; fi ;;
    "") show_help ;;
    *)
        echo -e "${RED}Unknown command: $CMD${NC}"
        show_help
        exit 1
        ;;
esac
