local M = {}


local function expand_path(path)
  if path:sub(1, 1) == "~" then
    return os.getenv("HOME") .. path:sub(2)
  end
  return path
end

local function center_window(outer, inner)
  return math.floor((outer - inner) / 2) -- Decimals cause float panel errors
end

local function window_config()
  local width = math.min(math.floor(vim.o.columns * 0.8), 64)
  local height = math.floor(vim.o.lines * 0.8)

  return {
    relative = "editor",
    width = width,
    height = height,
    col = center_window(vim.o.columns, width),
    row = center_window(vim.o.lines, height),
    border = "single",
  }
end

local function open_floating_file(filename)
  local expanded_path = expand_path(filename)

  -- bufadd seamlessly fetches or constructs the target file buffer safely
  local buf = vim.fn.bufadd(expanded_path)
  vim.fn.bufload(buf)

  vim.bo[buf].swapfile = false
  local win = vim.api.nvim_open_win(buf, true, window_config())

  vim.api.nvim_buf_set_keymap(buf, "n", "q", "", {
    noremap = true,
    silent = true,
    callback = function()
      if vim.api.nvim_get_option_value("modified", { buf = buf }) then
        vim.notify("save your changes.", vim.log.levels.WARN)
      else
        if vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
        end
      end
    end,
  })
end

local function setup_user_commands(opts)
  opts = opts or {}
  local target_file = opts.target_file or "~/todo.md"
  vim.api.nvim_create_user_command("TodoFloat", function()
    open_floating_file(target_file) -- Adjust target filename here if needed
  end, {})
end

M.setup = function(opts)
  -- Automatically registers the command on launch
  setup_user_commands(opts)
end

return M
