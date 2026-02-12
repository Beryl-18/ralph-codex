while true; do
    clear
    printf "Time: %s\n\n" "$(date '+%Y-%m-%d %H:%M:%S')"

    jq -r '
      .userStories as $s
      | ($s|length) as $total
      | ($s|map(select(.passes))|length) as $done
      | ($s|map(select(.passes|not))|sort_by(.priority)|.[0]) as $next
      | "Progress: \($done)/\($total) done",
        "Next: \($next.id // "NONE") P\($next.priority // "-") - \($next.title // "All complete")",
        "",
        "Stories:",
        ($s|sort_by(.priority)|map("  \(.id)  P\(.priority)  \((if .passes then "DONE" else "TODO" end))  \(.title)")|.[])
    ' prd.json

    echo
    echo "Recent commits:"
    git log --oneline -n 5

    sleep 3
  done
