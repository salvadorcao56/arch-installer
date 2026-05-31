return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  opts = {
    adapters = {
      opencode = function()
        return require("codecompanion.adapters").extend("acp", {
          env = {
            script_path = "opencode",
          },
        })
      end,
      ollama = function()
        return require("codecompanion.adapters").extend("ollama", {
          env = {
            url = "http://localhost:11434",
          },
        })
      end,
    },
    display = {
      chat = {
        window = {
          layout = "horizontal",
          position = "bottom",
          height = 0.3,
        },
      },
    },
    strategies = {
      chat = {
        adapter = "opencode",
      },
    },
  },
  keys = {
    {
      "<leader>A",
      function()
        vim.ui.select({ "opencode", "ollama" }, {
          prompt = "AI Chat - Select provider:",
        }, function(choice)
          if choice then
            vim.cmd("CodeCompanionChat " .. choice)
          end
        end)
      end,
      mode = "n",
      desc = "CodeCompanion AI Chat (select provider)",
    },
  },
}
