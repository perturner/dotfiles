if command -q kiro-cli
    kiro-cli init fish pre | source
    kiro-cli init fish post | source
end
