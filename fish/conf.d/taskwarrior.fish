# --- Taskwarrior -----------------------------------------------------------
# Loaded automatically by fish. Edit or delete freely.

# Expand these as you type (press space/enter after the abbreviation).
abbr --add t       task
abbr --add tl      'task list'
abbr --add tn      'task next'
abbr --add ta      'task add'
abbr --add td      'task done'
abbr --add tm      'task modify'
abbr --add tan     'task annotate'
abbr --add tp      'task projects'

# `tt` without arguments opens the daily view (today report).
# `tt -r list` / `tt -r next` still works; bare `taskwarrior-tui` stays default.
function tt --description 'Open taskwarrior-tui, default report: today'
    if test (count $argv) -eq 0
        taskwarrior-tui -r today
    else
        taskwarrior-tui $argv
    end
end

# Add multiple tasks in one command:
#   tadd "Buy milk" "Call mom" "Fix the bug"
function tadd --description 'Add multiple Taskwarrior tasks in one command'
    for desc in $argv
        task add -- $desc
    end
end

# Add several tasks that share attributes:
#   taddto project:work +urgent "Write report" "Reply to email"
function taddto --description 'Add multiple tasks with shared attributes'
    set -l attrs
    while test (count $argv) -gt 0; and string match -qr '^(project:|\\+|due:|priority:|scheduled:|wait:)' -- $argv[1]
        set -a attrs $argv[1]
        set -e argv[1]
    end
    for desc in $argv
        task add $attrs -- $desc
    end
end

# Full details for one or more task ids:
#   tinfo 12
function tinfo --description 'Show full info for a task id'
    task $argv info
end

# Add a task and pick its project interactively with fzf:
#   taddp Buy paint
function taddp --description 'Add a task and pick a project with fzf'
    if test (count $argv) -eq 0
        echo "usage: taddp <task description>"
        return 1
    end
    set -l proj (task _projects 2>/dev/null | fzf --prompt='Project> ')
    if test -z "$proj"
        task add -- $argv
    else
        task add project:$proj -- $argv
    end
end

# Print a task count, or 0 when nothing matches.
function __tw_count --description 'Count tasks matching a filter'
    set -l n (task $argv count 2>/dev/null)
    if string match -qr '^[0-9]+$' -- "$n"
        echo $n
    else
        echo 0
    end
end

# Today's progress as completed/total:
#   tcount   ->  4/10 completed (6 pending)
function tcount --description 'Show completed/total counts for today'
    set -l pending (__tw_count status:pending)
    set -l done (__tw_count status:completed end:today)
    set -l total (math "$pending + $done")
    echo "$done/$total completed ($pending pending)"
end

# Daily review with counts and a separator: pending first, then completed today.
#   tday
function tday --description 'Show pending tasks and completed today, separated'
    set -l sep (string repeat -n 60 '─')
    set -l pending (__tw_count status:pending)
    set -l done (__tw_count status:completed end:today)
    set -l total (math "$pending + $done")
    set_color --bold
    echo "TODAY  $done/$total completed  ($pending pending)"
    set_color normal
    echo
    set_color --bold cyan
    echo "PENDING ($pending)"
    set_color normal
    task status:pending list
    echo
    echo $sep
    echo
    set_color --bold green
    echo "COMPLETED TODAY ($done)"
    set_color normal
    task completed end:today
end
