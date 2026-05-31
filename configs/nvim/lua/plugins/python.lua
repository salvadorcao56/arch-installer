return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        pyright = {},
        pylyzer = { enabled = false },
        pylsp = { enabled = false },
        jedi_language_server = { enabled = false },
        basedpyright = { enabled = false },
        pyre = { enabled = false },
        pyrefly = { enabled = false },
      },
    },
  },
}
