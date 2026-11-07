#!/bin/bash
# Claude Code status line. Reads session JSON on stdin, prints two rows:
#   valorune · feature/integrate-agents ●⇡ · #123 ✓
#   Opus 5.5 high · ━━━─────── 31% · 5h 58% 2h10m · wk 82% 3d04h
# Gray is the resting state; colour marks what needs attention.
# Branch symbols: ✓ committed and pushed, ● uncommitted, ⇡ unpushed, ⇣ behind,
# ⇕ diverged, ○ not published or detached.
# Schema: https://code.claude.com/docs/en/statusline

RESET=$'\033[0m' DIM=$'\033[2m' BOLD=$'\033[1m' LIGHT=$'\033[37m'
BLUE=$'\033[34m' CYAN=$'\033[36m' GREEN=$'\033[32m' YELLOW=$'\033[33m' RED=$'\033[31m'
SEP=" ${DIM}·${RESET} "

# Fields are joined on the unit separator so empty values keep their position.
IFS=$'\x1f' read -r cwd model effort ctx_pct limit_pct limit_reset \
  week_pct week_reset pr_number pr_state worktree <<<"$(jq -r '
  def pct: if . == null then "" else round end;
  def left: if . == null then "" else (100 - .) | if . < 0 then 0 elif . > 100 then 100 else . end | round end;
  [
    (.workspace.current_dir // .cwd // ""),
    (.model.display_name // ""),
    (.effort.level // ""),
    (.context_window.current_usage
      | if . == null then null
        else ((.input_tokens // 0) + (.cache_creation_input_tokens // 0) + (.cache_read_input_tokens // 0))
             * 100 / 400000
        end | pct),
    (.rate_limits.five_hour.used_percentage | left),
    (.rate_limits.five_hour.resets_at // ""),
    (.rate_limits.seven_day.used_percentage | left),
    (.rate_limits.seven_day.resets_at // ""),
    (.pr.number // ""),
    (.pr.review_state // ""),
    (.workspace.git_worktree // .worktree.name // "")
  ] | map(tostring) | join("\u001f")')"

# Seconds to a compact duration: <1m, 12m, 2h10m.
fmt_duration() {
  local s=$1
  if [ "$s" -lt 60 ]; then printf '<1m'
  elif [ "$s" -lt 3600 ]; then printf '%dm' $((s / 60))
  elif [ "$s" -ge 86400 ]; then printf '%dd%02dh' $((s / 86400)) $((s % 86400 / 3600))
  else printf '%dh%02dm' $((s / 3600)) $((s % 3600 / 60))
  fi
}

# Ten-cell line gauge in half-cell steps; the bar stops at full, the number does not.
context_gauge() {
  local halves=$(($1 / 5)) lit="" track="" i
  [ "$halves" -gt 20 ] && halves=20
  for ((i = 0; i < halves / 2; i++)); do lit+="━"; done
  [ $((halves % 2)) -eq 1 ] && lit+="╸"
  for ((i = (halves + 1) / 2; i < 10; i++)); do track+="─"; done
  printf '%s' "$2$lit$RESET$DIM$track$RESET"
}

# Context gauge: light gray at rest, yellow from 70%, red from 90%.
context_segment() {
  local pct=$1 lit_color=$LIGHT pct_color=$DIM
  if [ "$pct" -ge 90 ]; then lit_color=$RED pct_color=$RED
  elif [ "$pct" -ge 70 ]; then lit_color=$YELLOW pct_color=$YELLOW
  fi
  printf '%s %s' "$(context_gauge "$pct" "$lit_color")" "$pct_color$pct%$RESET"
}

# Branch and whether its work is committed and pushed. One git call covers both.
git_segment() {
  local status line oid="" head="" ab="" dirty="" state="" ahead behind
  status=$(git -C "$1" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null) || return

  # Headers come first, so the first other line proves the tree is dirty.
  while IFS= read -r line; do
    case "$line" in
      '# branch.oid '*) oid=${line#'# branch.oid '} ;;
      '# branch.head '*) head=${line#'# branch.head '} ;;
      '# branch.ab '*) ab=${line#'# branch.ab '} ;;
      '#'*) ;;
      *) dirty=1; break ;;
    esac
  done <<<"$status"

  if [ "$head" = "(detached)" ]; then
    head=${oid:0:7}
    state="${DIM}○${RESET}"
  elif [ -z "$ab" ]; then
    # No upstream, or the upstream branch was deleted.
    state="${DIM}○${RESET}"
  else
    ahead=${ab%% *}; ahead=${ahead#+}
    behind=${ab##*-}
    if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
      state="${RED}⇕${RESET}"
    elif [ "$ahead" -gt 0 ]; then
      state="${YELLOW}⇡${RESET}"
    elif [ "$behind" -gt 0 ]; then
      state="${YELLOW}⇣${RESET}"
    elif [ -z "$dirty" ]; then
      state="${DIM}✓${RESET}"
    fi
  fi

  [ -n "$dirty" ] && state="${YELLOW}●${RESET}${state}"
  printf '%s %s' "${DIM}${head}${RESET}" "$state"
}

pr_segment() {
  [ -n "$pr_number" ] || return
  local mark=""
  case "$pr_state" in
    approved) mark=" ${GREEN}✓${RESET}" ;;
    changes_requested) mark=" ${RED}✗${RESET}" ;;
    pending) mark=" ${DIM}…${RESET}" ;;
    draft) mark=" ${DIM}draft${RESET}" ;;
  esac
  printf '%s' "${DIM}#${pr_number}${RESET}${mark}"
}

# A row group with its leading separator; nothing if the group is empty.
group() {
  [ -z "$1" ] || printf '%s%s' "$SEP" "$1"
}

# Row 1: where you are and the state of your work.
row1="${BOLD}${BLUE}${cwd##*/}${RESET}"
[ -n "$worktree" ] && row1+=" ${CYAN}[${worktree}]${RESET}"
row1+=$(group "$(git_segment "$cwd")")
row1+=$(group "$(pr_segment)")
if [ -n "$VIRTUAL_ENV" ]; then
  row1+=$(group "${DIM}${VIRTUAL_ENV##*/}${RESET}")
elif [ -f "$cwd/venv/bin/activate" ]; then
  row1+=$(group "${DIM}venv${RESET}")
fi

# Row 2: model and how much room is left.
row2="${DIM}${model}${RESET}"
[ -n "$effort" ] && row2+=" ${DIM}${effort}${RESET}"
[ -n "$ctx_pct" ] && row2+=$(group "$(context_segment "$ctx_pct")")
now=$(date +%s)
if [ -n "$limit_pct" ]; then
  limit="${DIM}5h ${limit_pct}%${RESET}"
  if [ -n "$limit_reset" ]; then
    remaining=$((limit_reset - now))
    [ "$remaining" -gt 0 ] && limit+=" ${DIM}$(fmt_duration "$remaining")${RESET}"
  fi
  row2+=$(group "$limit")
fi
if [ -n "$week_pct" ]; then
  week="${DIM}wk ${week_pct}%${RESET}"
  if [ -n "$week_reset" ]; then
    remaining=$((week_reset - now))
    [ "$remaining" -gt 0 ] && week+=" ${DIM}$(fmt_duration "$remaining")${RESET}"
  fi
  row2+=$(group "$week")
fi

printf '%s\n%s\n' "$row1" "$row2"
