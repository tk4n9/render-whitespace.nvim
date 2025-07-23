local M = {}
local utils = require('render-whitespace.utils')

-- Default configuration
local default_config = {
  chars = {
    space = '·',
    tab = '↦',
    newline = '↲',
    trail = '•',
  },
  modes = {
    normal = false,
    visual = true,
    insert = false,
  },
  enabled = true,
  highlight_group = 'Whitespace',
  -- Color configuration
  colors = {
    fg = '#666666',        -- Foreground color for whitespace characters
    bg = nil,              -- Background color (nil for transparent)
    visual_fg = nil,       -- Foreground when in visual selection (nil to use Visual highlight)
    visual_bg = nil,       -- Background when in visual selection (nil to use Visual highlight)
  },
}

-- Current configuration
local config = {}

-- State tracking
local state = {
  enabled = false,
  current_mode = nil,
  autocmd_group = nil,
  namespace = nil,
}

-- Create highlight group if it doesn't exist
local function setup_highlight()
  -- Create the main whitespace highlight group
  local hl_opts = {
    fg = config.colors.fg,
    nocombine = true,
  }
  
  if config.colors.bg then
    hl_opts.bg = config.colors.bg
  end
  
  vim.api.nvim_set_hl(0, config.highlight_group, hl_opts)
  
  -- Create a special highlight group for visual selection if custom colors are specified
  if config.colors.visual_fg or config.colors.visual_bg then
    local visual_hl_opts = {
      nocombine = true,
    }
    
    if config.colors.visual_fg then
      visual_hl_opts.fg = config.colors.visual_fg
    else
      -- Get the Visual highlight group's foreground
      local visual_hl = vim.api.nvim_get_hl(0, { name = 'Visual' })
      visual_hl_opts.fg = visual_hl.fg or config.colors.fg
    end
    
    if config.colors.visual_bg then
      visual_hl_opts.bg = config.colors.visual_bg
    else
      -- Get the Visual highlight group's background
      local visual_hl = vim.api.nvim_get_hl(0, { name = 'Visual' })
      visual_hl_opts.bg = visual_hl.bg
    end
    
    vim.api.nvim_set_hl(0, config.highlight_group .. 'Visual', visual_hl_opts)
  end
end

-- Get the current mode
local function get_current_mode()
  local mode = vim.api.nvim_get_mode().mode
  if mode == 'n' or mode == 'no' then
    return 'normal'
  elseif mode:match('^[vV\22]') then -- visual, visual-line, visual-block
    return 'visual'
  elseif mode:match('^[iR]') then -- insert, replace
    return 'insert'
  end
  return 'normal'
end

-- Check if whitespace should be rendered in current mode
local function should_render()
  if not state.enabled or not config.enabled then
    return false
  end
  
  local mode = get_current_mode()
  return config.modes[mode] == true
end

-- Clear whitespace rendering
local function clear_whitespace()
  if state.namespace then
    vim.api.nvim_buf_clear_namespace(0, state.namespace, 0, -1)
  end
end

-- Render whitespace in current buffer
local function render_whitespace()
  if not should_render() then
    clear_whitespace()
    return
  end
  
  local bufnr = vim.api.nvim_get_current_buf()
  
  -- Skip invalid buffers
  if not utils.is_valid_buffer(bufnr) then
    return
  end
  
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  
  clear_whitespace()
  
  -- Get visual selection if in visual mode
  local visual_selection = nil
  local current_mode = get_current_mode()
  if current_mode == 'visual' then
    visual_selection = utils.get_visual_selection()
  end
  
  for line_idx, line in ipairs(lines) do
    local col = 0
    local line_len = #line
    
    while col < line_len do
      local char = line:sub(col + 1, col + 1)
      local render_char = nil
      local hl_group = config.highlight_group
      
      -- Check if this position is within visual selection
      if visual_selection and current_mode == 'visual' then
        local line_num = line_idx - 1 -- Convert to 0-indexed
        if line_num >= visual_selection.start_line and line_num <= visual_selection.end_line then
          local in_selection = false
          
          if visual_selection.mode == 'V' then
            -- Line-wise selection: entire line is selected
            in_selection = true
          elseif visual_selection.mode == '\22' then
            -- Block-wise selection
            in_selection = col >= visual_selection.start_col and col < visual_selection.end_col
          else
            -- Character-wise selection
            if line_num == visual_selection.start_line and line_num == visual_selection.end_line then
              -- Single line selection
              in_selection = col >= visual_selection.start_col and col < visual_selection.end_col
            elseif line_num == visual_selection.start_line then
              -- First line of multi-line selection
              in_selection = col >= visual_selection.start_col
            elseif line_num == visual_selection.end_line then
              -- Last line of multi-line selection
              in_selection = col < visual_selection.end_col
            else
              -- Middle lines of multi-line selection
              in_selection = true
            end
          end
          
          if in_selection then
            -- Use custom visual highlight if available, otherwise use Visual
            if config.colors.visual_fg or config.colors.visual_bg then
              hl_group = config.highlight_group .. 'Visual'
            else
              hl_group = 'Visual'
            end
          end
        end
      end
      
      if char == ' ' then
        render_char = config.chars.space
      elseif char == '\t' then
        render_char = config.chars.tab
      end
      
      if render_char then
        vim.api.nvim_buf_set_extmark(bufnr, state.namespace, line_idx - 1, col, {
          virt_text = {{render_char, hl_group}},
          virt_text_pos = 'overlay',
          priority = 100,
        })
      end
      
      col = col + 1
    end
    
    -- Check for trailing spaces
    local trailing_start = line:find('%s+$')
    if trailing_start then
      for i = trailing_start, line_len do
        if line:sub(i, i) == ' ' then
          local hl_group = config.highlight_group
          
          -- Check if trailing space is in visual selection
          if visual_selection and current_mode == 'visual' then
            local line_num = line_idx - 1
            if line_num >= visual_selection.start_line and line_num <= visual_selection.end_line then
              local col = i - 1
              local in_selection = false
              
              if visual_selection.mode == 'V' then
                -- Line-wise selection: entire line is selected
                in_selection = true
              elseif visual_selection.mode == '\22' then
                -- Block-wise selection
                in_selection = col >= visual_selection.start_col and col < visual_selection.end_col
              else
                -- Character-wise selection
                if line_num == visual_selection.start_line and line_num == visual_selection.end_line then
                  in_selection = col >= visual_selection.start_col and col < visual_selection.end_col
                elseif line_num == visual_selection.start_line then
                  in_selection = col >= visual_selection.start_col
                elseif line_num == visual_selection.end_line then
                  in_selection = col < visual_selection.end_col
                else
                  in_selection = true
                end
              end
              
              if in_selection then
                -- Use custom visual highlight if available, otherwise use Visual
                if config.colors.visual_fg or config.colors.visual_bg then
                  hl_group = config.highlight_group .. 'Visual'
                else
                  hl_group = 'Visual'
                end
              end
            end
          end
          
          vim.api.nvim_buf_set_extmark(bufnr, state.namespace, line_idx - 1, i - 1, {
            virt_text = {{config.chars.trail, hl_group}},
            virt_text_pos = 'overlay',
            priority = 101,
          })
        end
      end
    end
    
    -- Render newline character at the end of line (except last line)
    if line_idx < #lines or line ~= '' then
      local hl_group = config.highlight_group
      
      -- Check if newline is in visual selection
      if visual_selection and current_mode == 'visual' then
        local line_num = line_idx - 1
        if line_num >= visual_selection.start_line and line_num <= visual_selection.end_line then
          local col = line_len
          local in_selection = false
          
          if visual_selection.mode == 'V' then
            -- Line-wise selection: entire line including newline is selected
            in_selection = true
          elseif visual_selection.mode == '\22' then
            -- Block-wise selection: check if newline position is in selection
            in_selection = col >= visual_selection.start_col and col <= visual_selection.end_col
          else
            -- Character-wise selection
            if line_num == visual_selection.start_line and line_num == visual_selection.end_line then
              in_selection = col >= visual_selection.start_col and col <= visual_selection.end_col
            elseif line_num == visual_selection.start_line then
              in_selection = col >= visual_selection.start_col
            elseif line_num == visual_selection.end_line then
              in_selection = col <= visual_selection.end_col
            else
              in_selection = true
            end
          end
          
          if in_selection then
            -- Use custom visual highlight if available, otherwise use Visual
            if config.colors.visual_fg or config.colors.visual_bg then
              hl_group = config.highlight_group .. 'Visual'
            else
              hl_group = 'Visual'
            end
          end
        end
      end
      
      vim.api.nvim_buf_set_extmark(bufnr, state.namespace, line_idx - 1, line_len, {
        virt_text = {{config.chars.newline, hl_group}},
        virt_text_pos = 'eol',
        priority = 100,
      })
    end
  end
end

-- Setup autocmds
local function setup_autocmds()
  if state.autocmd_group then
    vim.api.nvim_del_augroup_by_id(state.autocmd_group)
  end
  
  state.autocmd_group = vim.api.nvim_create_augroup('RenderWhitespace', { clear = true })
  
  -- Create debounced render function to improve performance
  local debounced_render = utils.debounce(render_whitespace, 50)
  
  -- Render on various events
  vim.api.nvim_create_autocmd({
    'BufEnter',
    'BufWinEnter',
    'TextChanged',
    'TextChangedI',
    'ModeChanged',
  }, {
    group = state.autocmd_group,
    callback = function()
      vim.schedule(debounced_render)
    end,
  })
  
  -- Immediate render for cursor movement and visual selection changes
  vim.api.nvim_create_autocmd({
    'CursorMoved',
    'CursorMovedI',
  }, {
    group = state.autocmd_group,
    callback = function()
      vim.schedule(render_whitespace)
    end,
  })
  
  -- Special handling for visual mode to update selection highlighting
  vim.api.nvim_create_autocmd('ModeChanged', {
    group = state.autocmd_group,
    pattern = '*:[vV\22]*', -- Entering visual mode
    callback = function()
      vim.schedule(render_whitespace)
    end,
  })
  
  vim.api.nvim_create_autocmd('ModeChanged', {
    group = state.autocmd_group,
    pattern = '[vV\22]*:*', -- Leaving visual mode
    callback = function()
      vim.schedule(render_whitespace)
    end,
  })
  
  -- Clear on buffer leave
  vim.api.nvim_create_autocmd('BufLeave', {
    group = state.autocmd_group,
    callback = clear_whitespace,
  })
end

-- Enable whitespace rendering
function M.enable()
  state.enabled = true
  setup_autocmds()
  render_whitespace()
end

-- Disable whitespace rendering
function M.disable()
  state.enabled = false
  clear_whitespace()
  if state.autocmd_group then
    vim.api.nvim_del_augroup_by_id(state.autocmd_group)
    state.autocmd_group = nil
  end
end

-- Toggle whitespace rendering
function M.toggle()
  if state.enabled then
    M.disable()
  else
    M.enable()
  end
end

-- Check if enabled
function M.is_enabled()
  return state.enabled
end

-- Toggle rendering for a specific mode
function M.toggle_mode(mode)
  local valid_modes = { 'normal', 'visual', 'insert' }
  local is_valid = false
  for _, valid_mode in ipairs(valid_modes) do
    if mode == valid_mode then
      is_valid = true
      break
    end
  end
  
  if not is_valid then
    error("Invalid mode: " .. mode .. ". Valid modes are: normal, visual, insert")
    return
  end
  
  config.modes[mode] = not config.modes[mode]
  
  -- Re-render if plugin is enabled
  if state.enabled then
    render_whitespace()
  end
  
  return config.modes[mode]
end

-- Enable rendering for a specific mode
function M.enable_mode(mode)
  local valid_modes = { 'normal', 'visual', 'insert' }
  local is_valid = false
  for _, valid_mode in ipairs(valid_modes) do
    if mode == valid_mode then
      is_valid = true
      break
    end
  end
  
  if not is_valid then
    error("Invalid mode: " .. mode .. ". Valid modes are: normal, visual, insert")
    return
  end
  
  config.modes[mode] = true
  
  -- Re-render if plugin is enabled
  if state.enabled then
    render_whitespace()
  end
end

-- Disable rendering for a specific mode
function M.disable_mode(mode)
  local valid_modes = { 'normal', 'visual', 'insert' }
  local is_valid = false
  for _, valid_mode in ipairs(valid_modes) do
    if mode == valid_mode then
      is_valid = true
      break
    end
  end
  
  if not is_valid then
    error("Invalid mode: " .. mode .. ". Valid modes are: normal, visual, insert")
    return
  end
  
  config.modes[mode] = false
  
  -- Re-render if plugin is enabled
  if state.enabled then
    render_whitespace()
  end
end

-- Check if rendering is enabled for a specific mode
function M.is_mode_enabled(mode)
  return config.modes[mode] == true
end

-- Get current mode configuration
function M.get_modes()
  return vim.deepcopy(config.modes)
end

-- Update colors dynamically
function M.set_colors(new_colors)
  config.colors = vim.tbl_deep_extend('force', config.colors, new_colors or {})
  setup_highlight()
  
  -- Re-render if plugin is enabled
  if state.enabled then
    render_whitespace()
  end
end

-- Get current color configuration
function M.get_colors()
  return vim.deepcopy(config.colors)
end

-- Reset plugin state (useful for testing)
function M._reset()
  -- Disable and clean up
  if state.enabled then
    M.disable()
  end
  
  -- Reset state
  state.enabled = false
  state.current_mode = nil
  state.autocmd_group = nil
  state.namespace = nil
  
  -- Reset config
  config = {}
end

-- Setup function
function M.setup(user_config)
  -- Merge user config with defaults
  config = vim.tbl_deep_extend('force', default_config, user_config or {})
  
  -- Create namespace for extmarks
  state.namespace = vim.api.nvim_create_namespace('render_whitespace')
  
  -- Setup highlight group
  setup_highlight()
  
  -- Enable or disable based on configuration
  if config.enabled then
    M.enable()
  else
    M.disable()
  end
  
  -- Create user commands
  vim.api.nvim_create_user_command('RenderWhitespaceToggle', M.toggle, {
    desc = 'Toggle whitespace rendering'
  })
  
  vim.api.nvim_create_user_command('RenderWhitespaceEnable', M.enable, {
    desc = 'Enable whitespace rendering'
  })
  
  vim.api.nvim_create_user_command('RenderWhitespaceDisable', M.disable, {
    desc = 'Disable whitespace rendering'
  })
  
  -- Mode-specific commands
  vim.api.nvim_create_user_command('RenderWhitespaceToggleNormal', function()
    M.toggle_mode('normal')
  end, {
    desc = 'Toggle whitespace rendering in normal mode'
  })
  
  vim.api.nvim_create_user_command('RenderWhitespaceToggleVisual', function()
    M.toggle_mode('visual')
  end, {
    desc = 'Toggle whitespace rendering in visual mode'
  })
  
  vim.api.nvim_create_user_command('RenderWhitespaceToggleInsert', function()
    M.toggle_mode('insert')
  end, {
    desc = 'Toggle whitespace rendering in insert mode'
  })
  
  -- Enable/disable mode-specific commands
  vim.api.nvim_create_user_command('RenderWhitespaceEnableNormal', function()
    M.enable_mode('normal')
  end, {
    desc = 'Enable whitespace rendering in normal mode'
  })
  
  vim.api.nvim_create_user_command('RenderWhitespaceEnableVisual', function()
    M.enable_mode('visual')
  end, {
    desc = 'Enable whitespace rendering in visual mode'
  })
  
  vim.api.nvim_create_user_command('RenderWhitespaceEnableInsert', function()
    M.enable_mode('insert')
  end, {
    desc = 'Enable whitespace rendering in insert mode'
  })
  
  vim.api.nvim_create_user_command('RenderWhitespaceDisableNormal', function()
    M.disable_mode('normal')
  end, {
    desc = 'Disable whitespace rendering in normal mode'
  })
  
  vim.api.nvim_create_user_command('RenderWhitespaceDisableVisual', function()
    M.disable_mode('visual')
  end, {
    desc = 'Disable whitespace rendering in visual mode'
  })
  
  vim.api.nvim_create_user_command('RenderWhitespaceDisableInsert', function()
    M.disable_mode('insert')
  end, {
    desc = 'Disable whitespace rendering in insert mode'
  })
  
  -- Color management commands
  vim.api.nvim_create_user_command('RenderWhitespaceSetColors', function(opts)
    local colors = {}
    for arg in opts.args:gmatch('%S+') do
      local key, value = arg:match('([^=]+)=([^=]+)')
      if key and value then
        colors[key] = value
      end
    end
    M.set_colors(colors)
  end, {
    desc = 'Set whitespace colors (e.g., :RenderWhitespaceSetColors fg=#ff0000 visual_fg=#00ff00)',
    nargs = '*',
  })
end

return M
