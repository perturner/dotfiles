if status is-interactive
    # Commands to run in interactive sessions can go here
    if command -q uwsm; and uwsm check may-start
        exec uwsm start hyprland
    end
    alias g git
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

command -q pyenv; and pyenv init - | source
command -q starship; and starship init fish | source

