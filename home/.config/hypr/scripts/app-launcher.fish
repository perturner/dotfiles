#!/bin/fish
# Native Fish TUI Launcher - High Density Version

set -l CACHE_FILE "$HOME/.cache/fzf_launcher_cache"
set -l HISTORY_FILE "$HOME/.cache/fzf_launcher_history"
touch "$HISTORY_FILE"

# 1. Build/Refresh Cache
if not test -f "$CACHE_FILE"; or test (find "$CACHE_FILE" -mmin +60)
    set -l TEMP_CACHE (mktemp)
    for dir in /usr/share/applications $HOME/.local/share/applications
        if test -d "$dir"
            for file in "$dir"/*.desktop
                if test -f "$file"; and not grep -q "^NoDisplay=true" "$file"
                    set -l name (grep -m 1 "^Name=" "$file" | cut -d= -f2-)
                    set -l cmd (grep -m 1 "^Exec=" "$file" | cut -d= -f2- | sed -E 's/ %([a-zA-Z])//g' | sed 's/^"//; s/"$//')
                    set -l desc (grep -m 1 "^Comment=" "$file" | cut -d= -f2- | sed 's/^"//; s/"$//')
                    
                    if test -z "$desc"
                        set desc "No description available."
                    end

                    if test -n "$name"; and test -n "$cmd"
                        printf "%s\t%s\t%s\n" "$name" "$cmd" "$desc" >> "$TEMP_CACHE"
                    end
                end
            end
        end
    end
    sort -u "$TEMP_CACHE" > "$CACHE_FILE"
    rm "$TEMP_CACHE"
end

function get_ranked_list --inherit-variable HISTORY_FILE --inherit-variable CACHE_FILE
    set -l hist (cat "$HISTORY_FILE")
    while read -l line
        set -l fields (string split \t -- "$line")
        set -l name "$fields[1]"
        set -l count (printf "%s\n" $hist | grep -Fxc "$name")
        printf "%05d\t%s\n" "$count" "$line"
    end < "$CACHE_FILE"
end

# 3. Launch FZF
# - Reduced margins to 0
# - Adjusted width to 50/50 split for the narrow window
set -l TAB (printf "\t")
set -l SELECTED (get_ranked_list | sort -k1,1rn -k2,2 | cut -f2- | fzf \
    --prompt="Launch > " \
    --layout=reverse --border=rounded \
    --delimiter="$TAB" \
    --with-nth=1 \
    --no-sort \
    --header="History-ranked Apps" \
    --preview "echo 'Cmd:  {2}'; echo ''; echo 'Desc: {3}'" \
    --preview-window="right:50%:wrap:border-left")

if test -n "$SELECTED"
    set -l fields (string split \t -- "$SELECTED")
    set -l NAME "$fields[1]"
    set -l CMD "$fields[2]"
    
    echo "$NAME" >> "$HISTORY_FILE"
    hyprctl dispatch exec "uwsm app -- $CMD"
end
