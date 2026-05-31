local M = {}

local curl = vim.fn.system

local API_URL = "http://localhost:8000"

-- =========================================================
-- UTIL: GET SELECTED TEXT
-- =========================================================

local function get_visual_selection()
  local _, ls, cs = unpack(vim.fn.getpos("'<"))
  local _, le, ce = unpack(vim.fn.getpos("'>"))

  local lines = vim.fn.getline(ls, le)

  if #lines == 0 then
    return ""
  end

  lines[1] = string.sub(lines[1], cs)
  lines[#lines] = string.sub(lines[#lines], 1, ce)

  return table.concat(lines, "\n")
end

-- =========================================================
-- CALL AGENT OS
-- =========================================================

local function call_agent(message, context)
  local payload = vim.fn.json_encode({
    message = message,
    context = context,
  })

  local cmd = string.format("curl -s -X POST %s -H 'Content-Type: application/json' -d '%s'", API_URL, payload)

  local response = vim.fn.system(cmd)

  return vim.fn.json_decode(response)
end

-- =========================================================
-- APPLY RESPONSE TO BUFFER
-- =========================================================

local function apply_response(result)
  if not result or not result.result then
    print("Agent error")
    return
  end

  local r = result.result

  if type(r) == "table" then
    r = vim.fn.json_encode(r)
  end

  local lines = vim.split(r, "\n")

  local start = vim.fn.line("'>")
  vim.fn.append(start, lines)

  print("🧠 Agent response applied")
end

-- =========================================================
-- MAIN COMMAND: FIX CODE
-- =========================================================

function M.fix()
  local selection = get_visual_selection()

  if selection == "" then
    print("No selection")
    return
  end

  local context = {
    file = vim.fn.expand("%"),
    cwd = vim.fn.getcwd(),
  }

  local result = call_agent("fix this code:\n" .. selection, context)

  apply_response(result)
end

-- =========================================================
-- MAIN COMMAND: ASK AGENT
-- =========================================================

function M.ask()
  vim.ui.input({ prompt = "Agent> " }, function(input)
    if not input then
      return
    end

    local context = {
      file = vim.fn.expand("%"),
      cwd = vim.fn.getcwd(),
    }

    local result = call_agent(input, context)

    apply_response(result)
  end)
end

-- =========================================================
-- KEYMAPS
-- =========================================================

function M.setup()
  vim.api.nvim_create_user_command("AgentFix", function()
    M.fix()
  end, {})

  vim.api.nvim_create_user_command("AgentAsk", function()
    M.ask()
  end, {})

  vim.keymap.set("v", "<leader>af", ":AgentFix<CR>")
  vim.keymap.set("n", "<leader>aa", ":AgentAsk<CR>")

  print("🧠 Agent Neovim bridge loaded")
end

return M
