vim.g.mapleader = ","

vim.keymap.set("n", ";", ":", { desc = "CMD enter command mode" })
vim.keymap.set("i", "jk", "<ESC>")
vim.keymap.set("i", "ii", "<ESC>")

local opts = { noremap = true, silent = true }

-- ======================= AI Chat (opencode / ollama) ======================
local Terminal = require("toggleterm.terminal").Terminal

function _G.AIChat()
  vim.ui.select({ "opencode", "ollama" }, {
    prompt = "AI Chat provider:",
  }, function(choice)
    if choice == "opencode" then
      local term = Terminal:new({ cmd = "opencode", direction = "horizontal", size = 12 })
      term:toggle()
    elseif choice == "ollama" then
      vim.ui.input({ prompt = "Ollama model: ", default = "qwen2.5-coder:3b" }, function(model)
        if model and model ~= "" then
          local term = Terminal:new({ cmd = "ollama run " .. model, direction = "horizontal", size = 12 })
          term:toggle()
        end
      end)
    end
  end)
end

vim.keymap.set("n", "<leader>a", "<cmd>lua AIChat()<CR>", { desc = "AI Chat (select provider)" })

-- ======================= AI Chat directo ======================
vim.keymap.set("n", "<leader>o", "<cmd>ToggleTerm direction=horizontal size=12 cmd=opencode<CR>", opts)
vim.keymap.set("n", "<leader>ot", '<cmd>ToggleTerm direction=horizontal size=12 cmd=\'opencode run "explícame el archivo %"\'<CR>', opts)

local ollama3b = Terminal:new({ cmd = "ollama run qwen2.5-coder:3b", hidden = true, direction = "horizontal", size = 12 })
function _G.OLLAMA3B_TOGGLE()
  ollama3b:toggle()
end
vim.keymap.set("n", "<leader>ol", "<cmd>lua OLLAMA3B_TOGGLE()<CR>", { desc = "Ollama Chat 3b" })

local ollama7b = Terminal:new({ cmd = "ollama run qwen2.5-coder:7b", hidden = true, direction = "horizontal", size = 12 })
function _G.OLLAMA7B_TOGGLE()
  ollama7b:toggle()
end
vim.keymap.set("n", "<leader>oo", "<cmd>lua OLLAMA7B_TOGGLE()<CR>", { desc = "Ollama Chat 7b" })

-- ======================= Other ======================
vim.keymap.set("n", "<leader>r", ":!/home/salva/scripts/ejecutar.sh %<CR>", opts)
vim.keymap.set("n", "<leader>fr", ":TermExec cmd='/home/salva/scripts/ejecutar.sh %'<CR>", opts)
vim.keymap.set("n", "<leader>t", ":ToggleTerm size=10 direction=horizontal<CR>", opts)

vim.keymap.set("n", "<leader>h", function()
  require("which-key").show({ global = false })
end, { desc = "Keymap Help (which-key)" })

vim.keymap.set("n", "<F12>", ":map<CR>", { desc = "Show keymaps" })

require("agent_nvim").setup()
