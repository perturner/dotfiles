return {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
        require("nvim-treesitter").setup({
            ensure_installed = {
                "cpp", "python", "lua", "cmake", "markdown", "vimdoc",
                "proto", "bash", "json", "toml", "c_sharp", "bitbake"
            },
            highlight = { enable = true },
            indent = { enable = true }
        })
    end
}
