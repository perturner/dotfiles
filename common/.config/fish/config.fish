if status is-interactive
    # Commands to run in interactive sessions can go here
    if command -q uwsm; and uwsm check may-start
        exec uwsm start hyprland.desktop
    end
    alias g git
    alias theme '~/.config/hypr/scripts/auto-theme.sh'
end

# Custom MOTD
function fish_greeting
    set -l color_info (set_color cyan)
    set -l color_reset (set_color normal)

    # Fish Mastery Tips
    set -l fish_tips \
        "Press 'Alt + S' to quickly prepend 'sudo' to your current command." \
        "Press 'Alt + .' to cycle through the last arguments of previous commands." \
        "Press 'Alt + L' to list the directory of the path under your cursor." \
        "Press 'Alt + W' to see a quick description of the command you typed." \
        "Type 'cd -' to quickly switch back to your previous directory." \
        "Type 'dirh' to see your recent directory history, and 'prevd'/'nextd' to move through it." \
        "Use 'abbr -a g git' to create an abbreviation that expands as you type." \
        "Press 'Ctrl + F' or 'Right Arrow' to accept the current autosuggestion." \
        "Press 'Alt + Enter' to insert a newline without executing the command." \
        "Type 'help <command>' to open the web documentation for any command." \
        "Use 'type <command>' to see if a command is a function, builtin, or binary." \
        "Type 'math 5 + 5' for quick calculations directly in the shell."
    
    set -l random_tip (random choice $fish_tips)
    echo "  $color_info Fish Mastery:$color_reset $random_tip"
end

# Add ssh key to keyring
set -gx SSH_KEYS_TO_AUTOLOAD ~/.ssh/id_ed25519

set -gx MOZ_ENABLE_WAYLAND 1
set -gx _JAVA_AWT_WM_NONREPARENTING 1
set -gx VISUAL nvim
set -gx EDITOR nvim
set -gx GITHUB_USERNAME perturner

fish_add_path -P ~/.cargo/bin
fish_add_path -P ~/.npm-global/bin
fish_add_path /home/per/.local/bin

command -q pyenv; and pyenv init - | source
command -q starship; and starship init fish | source
command -q direnv; and direnv hook fish | source
zoxide init fish | source

# Attach to the persistent tmux server managed by the user service
# (~/.config/systemd/user/tmux.service). The server lives in app.slice and
# survives GNOME/GDM session restarts, which requires
# `loginctl enable-linger $USER` (set once). The service auto-starts the
# server, so tx just attaches -- it never starts the service, which would
# spawn an extra session and is what broke attaching over SSH.
#   tx           -> attach to the running server (last-used session)
#   tx <name>    -> attach to <name>, creating it only if it does not exist
function tx
    if set -q argv[1]
        tmux new-session -A -s $argv[1]
    else if tmux has-session 2>/dev/null
        tmux attach
    else
        # No server/session at all: start one rather than failing.
        tmux new-session
    end
end


# Added by Antigravity CLI installer
set -gx PATH "/home/per/.local/bin" $PATH
