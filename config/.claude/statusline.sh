#!/usr/bin/env bash
# Claude Code status line
# Mirrors the segments/colors of ~/dotfiles/config/.config/posh/coco.omp.json
# (oh-my-posh "coco" theme) as closely as practical.

input=$(cat)

# ---------------------------------------------------------------------------
# helpers
# ---------------------------------------------------------------------------
rgb() { printf '\033[38;2;%d;%d;%dm' "$1" "$2" "$3"; }   # 24-bit fg color
RESET=$'\033[0m'
SEP="   "                                                 # theme pads segments with 3 spaces

# Decode the exact nerd-font glyphs used in the omp theme via jq's unicode
# escape handling, so we don't depend on bash's (version-gated) \u support.
glyph() { jq -rn "\"\\u$1\""; }

ICON_FOLDER=$(glyph e5ff)   # path segment icon
ICON_NODE=$(glyph e781)     # node segment icon
ICON_JAVA=$(glyph e738)     # java segment icon
ICON_PYTHON=$(glyph e61e)   # python segment icon
ICON_RUST=$(glyph e61d)     # rust segment icon
ICON_MODEL=$(glyph e795)    # reused from theme's "shell" segment icon
ICON_WORKING=$(glyph f044)  # theme's Working.Changed icon
ICON_STASH=$(glyph eb4b)    # theme's stash icon

# theme colors (hex -> rgb)
C_PATH=$(rgb 97 175 239)        # #61AFEF
C_GIT=$(rgb 243 194 103)        # #F3C267
C_GIT_DIRTY=$(rgb 255 146 72)   # #FF9248
C_GIT_DIVERGED=$(rgb 255 69 0)  # #ff4500
C_GIT_SYNC=$(rgb 179 136 255)   # #B388FF
C_NODE=$(rgb 152 195 121)       # #98C379
C_JAVA=$(rgb 204 62 68)         # #cc3e44
C_PYTHON=$(rgb 103 150 230)     # #6796e6
C_RUST=$(rgb 81 154 186)        # #519aba
C_REPO=$(rgb 86 182 194)        # #56B6C2 (theme's "always-on" PhysMem segment color)
C_MODEL=$(rgb 224 108 117)      # #E06C75 (theme's shell segment color)
C_BLUE=$(rgb 129 156 252)       # #819CFC (theme's CPU baseline color)
C_WARN=$(rgb 243 194 103)       # #F3C267
C_ERR=$(rgb 224 108 117)        # #E06C75
C_OK=$(rgb 184 255 117)         # #b8ff75 (theme's status/executiontime ok color)

# ---------------------------------------------------------------------------
# pull fields out of the stdin JSON payload
# ---------------------------------------------------------------------------
cwd=$(printf '%s' "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model=$(printf '%s' "$input" | jq -r '.model.display_name // empty')
used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(printf '%s' "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
seven_day=$(printf '%s' "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
repo_owner=$(printf '%s' "$input" | jq -r '.workspace.repo.owner // empty')
repo_name=$(printf '%s' "$input" | jq -r '.workspace.repo.name // empty')
pr_number=$(printf '%s' "$input" | jq -r '.pr.number // empty')
pr_state=$(printf '%s' "$input" | jq -r '.pr.review_state // empty')
vim_mode=$(printf '%s' "$input" | jq -r '.vim.mode // empty')

# ---------------------------------------------------------------------------
# path segment — blue, folder icon (theme: type "path", style "full")
# ---------------------------------------------------------------------------
display_path="$cwd"
[ -n "$HOME" ] && display_path="${display_path/#$HOME/~}"
path_seg="${C_PATH}${ICON_FOLDER} ${display_path}${RESET}"

# ---------------------------------------------------------------------------
# git segment — yellow, orange when dirty, purple when ahead/behind,
# orange-red when diverged (theme: type "git")
# ---------------------------------------------------------------------------
git_seg=""
if [ -n "$cwd" ] && git -C "$cwd" --no-optional-locks rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
  [ -z "$branch" ] && branch=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)

  ahead=$(git -C "$cwd" --no-optional-locks rev-list --count '@{u}..HEAD' 2>/dev/null)
  behind=$(git -C "$cwd" --no-optional-locks rev-list --count 'HEAD..@{u}' 2>/dev/null)
  ahead=${ahead:-0}
  behind=${behind:-0}

  dirty_count=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  stash_count=$(git -C "$cwd" --no-optional-locks stash list 2>/dev/null | wc -l | tr -d ' ')

  git_color="$C_GIT"
  if [ "$dirty_count" != "0" ]; then
    git_color="$C_GIT_DIRTY"
  fi
  if [ "$ahead" != "0" ] && [ "$behind" != "0" ]; then
    git_color="$C_GIT_DIVERGED"
  elif [ "$ahead" != "0" ] || [ "$behind" != "0" ]; then
    git_color="$C_GIT_SYNC"
  fi

  status_bits=""
  [ "$ahead" != "0" ] && status_bits="${status_bits}↑${ahead} "
  [ "$behind" != "0" ] && status_bits="${status_bits}↓${behind} "
  [ "$dirty_count" != "0" ] && status_bits="${status_bits}${ICON_WORKING} ${dirty_count} "
  [ "$stash_count" != "0" ] && status_bits="${status_bits}${ICON_STASH} ${stash_count} "

  git_seg="${git_color}${branch}${status_bits:+ ${status_bits% }}${RESET}"
fi

# ---------------------------------------------------------------------------
# node segment — green, node icon, only when a JS/TS project (theme: type "node")
# ---------------------------------------------------------------------------
node_seg=""
if [ -n "$cwd" ] && [ -f "$cwd/package.json" ] && command -v node >/dev/null 2>&1; then
  node_version=$(node --version 2>/dev/null | sed 's/^v//')
  pkg_mgr=""
  if [ -f "$cwd/pnpm-lock.yaml" ]; then
    pkg_mgr="pnpm "
  elif [ -f "$cwd/yarn.lock" ]; then
    pkg_mgr="yarn "
  elif [ -f "$cwd/package-lock.json" ]; then
    pkg_mgr="npm "
  fi
  node_seg="${C_NODE}${ICON_NODE} ${pkg_mgr}${node_version}${RESET}"
fi

# ---------------------------------------------------------------------------
# java / python / rust segments — only when the project matches (theme: type
# "java" / "python" / "rust")
# ---------------------------------------------------------------------------
java_seg=""
if [ -n "$cwd" ] && { [ -f "$cwd/pom.xml" ] || [ -f "$cwd/build.gradle" ] || [ -f "$cwd/build.gradle.kts" ]; } && command -v java >/dev/null 2>&1; then
  java_version=$(java -version 2>&1 | head -n1 | sed -E 's/.*"([^"]+)".*/\1/')
  java_seg="${C_JAVA}${ICON_JAVA} ${java_version}${RESET}"
fi

python_seg=""
if [ -n "$cwd" ] && { [ -f "$cwd/pyproject.toml" ] || [ -f "$cwd/requirements.txt" ] || [ -f "$cwd/Pipfile" ]; } && command -v python3 >/dev/null 2>&1; then
  python_version=$(python3 --version 2>&1 | awk '{print $2}')
  python_seg="${C_PYTHON}${ICON_PYTHON} ${python_version}${RESET}"
fi

rust_seg=""
if [ -n "$cwd" ] && [ -f "$cwd/Cargo.toml" ] && command -v rustc >/dev/null 2>&1; then
  rust_version=$(rustc --version 2>/dev/null | awk '{print $2}')
  rust_seg="${C_RUST}${ICON_RUST} ${rust_version}${RESET}"
fi

# ---------------------------------------------------------------------------
# repo segment — cyan, always-on ambient info (theme: PhysMem segment analog)
# ---------------------------------------------------------------------------
repo_seg=""
if [ -n "$repo_owner" ] && [ -n "$repo_name" ]; then
  repo_seg="${C_REPO}${repo_owner}/${repo_name}${RESET}"
  if [ -n "$pr_number" ]; then
    pr_color="$C_WARN"
    case "$pr_state" in
      approved) pr_color="$C_OK" ;;
      changes_requested) pr_color="$C_ERR" ;;
    esac
    repo_seg="${repo_seg} ${pr_color}#${pr_number}${RESET}"
  fi
fi

# ---------------------------------------------------------------------------
# model segment — red, reused from theme's "shell" segment (current tool/session)
# ---------------------------------------------------------------------------
model_seg=""
[ -n "$model" ] && model_seg="${C_MODEL}${ICON_MODEL} ${model}${RESET}"
if [ -n "$vim_mode" ]; then
  model_seg="${model_seg} ${C_MODEL}[${vim_mode}]${RESET}"
fi

# ---------------------------------------------------------------------------
# context-window segment — 3-tier color, mirrors theme's CPU segment
# (blue <=50%, yellow 50-80%, red >80%)
# ---------------------------------------------------------------------------
ctx_seg=""
if [ -n "$used_pct" ]; then
  ctx_color="$C_BLUE"
  over50=$(awk -v v="$used_pct" 'BEGIN{print (v>50)}')
  over80=$(awk -v v="$used_pct" 'BEGIN{print (v>80)}')
  [ "$over50" = "1" ] && ctx_color="$C_WARN"
  [ "$over80" = "1" ] && ctx_color="$C_ERR"
  ctx_seg="${ctx_color}ctx $(printf '%.0f' "$used_pct")%${RESET}"
fi

# ---------------------------------------------------------------------------
# rate-limit segment — 2-tier color, mirrors theme's status/executiontime
# (ok green, >=80% red)
# ---------------------------------------------------------------------------
rl_seg=""
if [ -n "$five_hour" ] || [ -n "$seven_day" ]; then
  rl_text=""
  rl_color="$C_OK"
  if [ -n "$five_hour" ]; then
    rl_text="5h:$(printf '%.0f' "$five_hour")%"
    over=$(awk -v v="$five_hour" 'BEGIN{print (v>=80)}')
    [ "$over" = "1" ] && rl_color="$C_ERR"
  fi
  if [ -n "$seven_day" ]; then
    rl_text="${rl_text:+$rl_text }7d:$(printf '%.0f' "$seven_day")%"
    over=$(awk -v v="$seven_day" 'BEGIN{print (v>=80)}')
    [ "$over" = "1" ] && rl_color="$C_ERR"
  fi
  rl_seg="${rl_color}${rl_text}${RESET}"
fi

# ---------------------------------------------------------------------------
# assemble — same left-to-right, 3-space-padded layout style as the theme
# ---------------------------------------------------------------------------
segments=()
[ -n "$path_seg" ] && segments+=("$path_seg")
[ -n "$git_seg" ] && segments+=("$git_seg")
[ -n "$node_seg" ] && segments+=("$node_seg")
[ -n "$java_seg" ] && segments+=("$java_seg")
[ -n "$python_seg" ] && segments+=("$python_seg")
[ -n "$rust_seg" ] && segments+=("$rust_seg")
[ -n "$repo_seg" ] && segments+=("$repo_seg")
[ -n "$model_seg" ] && segments+=("$model_seg")
[ -n "$ctx_seg" ] && segments+=("$ctx_seg")
[ -n "$rl_seg" ] && segments+=("$rl_seg")

line=""
for seg in "${segments[@]}"; do
  if [ -z "$line" ]; then
    line="$seg"
  else
    line="${line}${SEP}${seg}"
  fi
done

printf '%b\n' "$line"
