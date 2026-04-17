#!/bin/sh
input=$(cat)

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
window_size=$(echo "$input" | jq -r '.context_window.context_window_size // empty')

if [ -z "$used" ]; then
  printf "ctx: --"
  exit 0
fi

used_int=$(printf "%.0f" "$used")

# Build a 10-char bar: filled = used_int/10 blocks
filled=$(( used_int / 10 ))
empty=$(( 10 - filled ))

bar=""
i=0
while [ $i -lt $filled ]; do
  bar="${bar}█"
  i=$(( i + 1 ))
done
i=0
while [ $i -lt $empty ]; do
  bar="${bar}░"
  i=$(( i + 1 ))
done

# Format token counts as e.g. "200k" or "1M"
fmt_tokens() {
  val=$1
  if [ "$val" -ge 1000000 ]; then
    printf "%.1fM" "$(echo "$val" | awk '{printf "%.1f", $1/1000000}')"
  elif [ "$val" -ge 1000 ]; then
    printf "%dk" "$(( val / 1000 ))"
  else
    printf "%d" "$val"
  fi
}

used_tokens=$(echo "$used $window_size" | awk '{printf "%.0f", $1/100 * $2}')
used_fmt=$(fmt_tokens "$used_tokens")
max_fmt=$(fmt_tokens "$window_size")
label="${used_fmt}/${max_fmt} ${used_int}%"

prefix=""
[ -n "$model" ] && prefix="${model} | "

if [ "$used_int" -ge 80 ]; then
  printf "\033[31m%sctx [%s] %s\033[0m" "$prefix" "$bar" "$label"
elif [ "$used_int" -ge 50 ]; then
  printf "\033[33m%sctx [%s] %s\033[0m" "$prefix" "$bar" "$label"
else
  printf "%sctx [%s] %s" "$prefix" "$bar" "$label"
fi
