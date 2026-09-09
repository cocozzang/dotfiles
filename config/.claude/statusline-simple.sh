#!/usr/bin/env bash
# Claude Code status line — plain/minimal style.
# No nerd fonts. One recessive base color for the body, with the rate-limit
# reset countdown tiered by how soon the window resets.

input=$(cat)

rgb() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }
RESET=$'\033[0m'

BASE=$(rgb 150 156 166)    # 본문 기본색 (기존 dim보다 한 톤 밝게)
C_SOON=$(rgb 152 195 121)  # < 1h  — 곧 리셋
C_MID=$(rgb 229 192 123)   # 1~12h — 대기중
C_FAR=$(rgb 108 114 124)   # > 12h — 한참 남음

model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
# five_hour = "current session" window, seven_day = "current week" window
session_pct=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week_pct=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
session_reset=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_reset=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
effort=$(printf '%s' "$input" | jq -r '.effort.level // empty')

now=$(date +%s)

# epoch -> compact "time until reset", e.g. 2d5h / 3h12m / 12m. Empty if past/absent.
until_reset() {
  [ -z "$1" ] && return
  local left=$(( $1 - now ))
  [ "$left" -le 0 ] && return
  local d=$(( left / 86400 ))
  local h=$(( (left % 86400) / 3600 ))
  local m=$(( (left % 3600) / 60 ))
  if [ "$d" -gt 0 ]; then
    [ "$h" -gt 0 ] && printf '%dd%dh' "$d" "$h" || printf '%dd' "$d"
  elif [ "$h" -gt 0 ]; then
    [ "$m" -gt 0 ] && printf '%dh%dm' "$h" "$m" || printf '%dh' "$h"
  else
    printf '%dm' "$m"
  fi
}

# epoch -> color for that countdown, by how soon the window resets
reset_color() {
  local left=$(( $1 - now ))
  if [ "$left" -lt 3600 ]; then
    printf '%s' "$C_SOON"
  elif [ "$left" -lt 43200 ]; then
    printf '%s' "$C_MID"
  else
    printf '%s' "$C_FAR"
  fi
}

# "12%" + colored "(3h12m)" when a reset time is available
limit_part() {
  local label=$1 pct=$2 reset=$3 t c
  t=$(until_reset "$reset")
  if [ -n "$t" ]; then
    c=$(reset_color "$reset")
    printf '%s %.0f%% %s(%s)%s' "$label" "$pct" "$c" "$t" "$BASE"
  else
    printf '%s %.0f%%' "$label" "$pct"
  fi
}

# 현재 effort 레벨 — 높을수록 눈에 띄는 색
effort_part() {
  local c
  case "$1" in
    low)    c=$C_FAR ;;
    medium) c=$BASE ;;
    high)   c=$C_MID ;;
    *)      c=$C_SOON ;;
  esac
  printf 'eff %s%s%s' "$c" "$1" "$BASE"
}

dir_name="${cwd##*/}"

branch=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  if [ -n "$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)" ]; then
    branch="${branch}*"
  fi
fi

parts=()
[ -n "$model" ] && parts+=("[$model]")
[ -n "$dir_name" ] && parts+=("$dir_name")
[ -n "$branch" ] && parts+=("$branch")
[ -n "$used_pct" ] && parts+=("ctx $(printf '%.0f' "$used_pct")%")
[ -n "$session_pct" ] && parts+=("$(limit_part ses "$session_pct" "$session_reset")")
[ -n "$week_pct" ] && parts+=("$(limit_part wk "$week_pct" "$week_reset")")
[ -n "$effort" ] && parts+=("$(effort_part "$effort")")

line=""
for p in "${parts[@]}"; do
  if [ -z "$line" ]; then
    line="$p"
  else
    line="${line} | ${p}"
  fi
done

printf '%b\n' "${BASE}${line}${RESET}"
