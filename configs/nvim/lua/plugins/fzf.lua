return {
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("fzf-lua").setup({})
      vim.keymap.set("n", "<leader>ff", function()
        require("fzf-lua").files()
      end, { desc = "FZF: Find Files" })
    end,
  },
}
