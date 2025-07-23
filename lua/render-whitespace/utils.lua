-- Utility functions for render-whitespace.nvim

local M = {}

-- Check if we're in a valid buffer for whitespace rendering
function M.is_valid_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  
  -- Skip special buffer types
  local buftype = vim.api.nvim_buf_get_option(bufnr, 'buftype')
  if buftype ~= '' then
    return false
  end
  
  -- Skip certain filetypes
  local filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local skip_filetypes = {
    'help',
    'terminal',
    'quickfix',
    'qf',
    'netrw',
    'NvimTree',
    'neo-tree',
    'TelescopePrompt',
    'alpha',
    'dashboard',
    'startify',
  }
  
  for _, ft in ipairs(skip_filetypes) do
    if filetype == ft then
      return false
    end
  end
  
  return true
end

-- Get visual selection range
function M.get_visual_selection()
  -- Get the current mode to ensure we're in visual mode
  local mode = vim.api.nvim_get_mode()
  if not mode.mode:match('^[vV\22]') then
    return nil -- Not in visual mode
  end
  
  -- For visual mode, we need to use the marks to get accurate selection
  local start_pos, end_pos
  
  if mode.mode == 'V' then
    -- Line-wise visual mode - use getpos() for marks but handle specially
    start_pos = vim.fn.getpos('v')
    end_pos = vim.fn.getpos('.')
    
    -- For line-wise selection, we want the entire lines
    local start_line = math.min(start_pos[2], end_pos[2]) - 1 -- Convert to 0-indexed
    local end_line = math.max(start_pos[2], end_pos[2]) - 1
    
    return {
      start_line = start_line,
      start_col = 0,  -- Start of line
      end_line = end_line,
      end_col = vim.fn.col('$'), -- End of line (column after last character)
      mode = 'V'
    }
  elseif mode.mode == '\22' then
    -- Block-wise visual mode
    start_pos = vim.fn.getpos('v')
    end_pos = vim.fn.getpos('.')
    
    local start_line, start_col = start_pos[2] - 1, start_pos[3] - 1
    local end_line, end_col = end_pos[2] - 1, end_pos[3] - 1
    
    -- Ensure proper ordering
    if start_line > end_line then
      start_line, end_line = end_line, start_line
    end
    if start_col > end_col then
      start_col, end_col = end_col, start_col
    end
    
    return {
      start_line = start_line,
      start_col = start_col,
      end_line = end_line,
      end_col = end_col + 1, -- Include the end character
      mode = '\22'
    }
  else
    -- Character-wise visual mode ('v')
    start_pos = vim.fn.getpos('v')
    end_pos = vim.fn.getpos('.')
    
    local start_line, start_col = start_pos[2] - 1, start_pos[3] - 1
    local end_line, end_col = end_pos[2] - 1, end_pos[3] - 1
    
    -- Ensure start comes before end
    if start_line > end_line or (start_line == end_line and start_col > end_col) then
      start_line, end_line = end_line, start_line
      start_col, end_col = end_col, start_col
    end
    
    return {
      start_line = start_line,
      start_col = start_col,
      end_line = end_line,
      end_col = end_col + 1, -- Include the end character
      mode = 'v'
    }
  end
end

-- Calculate display width of a tab character
function M.get_tab_width()
  return vim.api.nvim_buf_get_option(0, 'tabstop')
end

-- Check if character is whitespace
function M.is_whitespace(char)
  return char:match('%s') ~= nil
end

-- Get the appropriate character width for display
function M.get_char_width(char)
  if char == '\t' then
    return M.get_tab_width()
  else
    return 1
  end
end

-- Debounce function to limit frequent updates
function M.debounce(func, delay)
  local timer = nil
  return function(...)
    local args = {...}
    if timer then
      timer:stop()
    end
    timer = vim.loop.new_timer()
    timer:start(delay, 0, vim.schedule_wrap(function()
      func(unpack(args))
      timer:close()
      timer = nil
    end))
  end
end

return M
