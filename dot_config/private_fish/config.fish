if status is-interactive
   # Commands to run in interactive sessions can go here
    if uwsm check may-start
        exec uwsm start hyprland
    end
end

# Add ssh key to keyring
set -gx SSH_KEYS_TO_AUTOLOAD ~/.ssh/id_ed25519

set -gx MOZ_ENABLE_WAYLAND 1
set -gx _JAVA_AWT_WM_NONREPARENTING 1
set -gx HSA_OVERRIDE_GFX_VERSION 10.3.0
set -gx VISUAL code --wait
set -gx EDITOR nano
set -gx GITHUB_USERNAME devloloper

string match -q "$TERM_PROGRAM" "vscode"
and . (code --locate-shell-integration-path fish)
fish_add_path -aP /opt/rocm/bin
fish_add_path -P ~/.npm-global/bin

pyenv init - | source

set -gx SDL_GAMECONTROLLERCONFIG "03000000321500003f0a000000000000,Razer Wolverine V3 Pro,a:b0,b:b1,x:b2,y:b3,back:b6,guide:b8,start:b7,leftstick:b9,rightstick:b10,leftshoulder:b4,rightshoulder:b5,dpup:h0.1,dpdown:h0.4,dpleft:h0.8,dpright:h0.2,leftx:a0,lefty:a1,rightx:a3,righty:a4,lefttrigger:a2,righttrigger:a5,"
starship init fish | source

