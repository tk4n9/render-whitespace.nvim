-- Example configuration for render-whitespace.nvim

-- Basic setup with default options
require('render-whitespace').setup()

-- Custom configuration example
require('render-whitespace').setup({
  -- Customize whitespace characters
  chars = {
    space = '·',           -- Dots for spaces
    tab = '▸',             -- Right-pointing triangle for tabs
    newline = '↵',         -- Return symbol for newlines
    trail = '◦',           -- White bullet for trailing spaces
  },
  
  -- Configure which modes to render whitespace
  modes = {
    normal = true,         -- Show in normal mode
    visual = true,         -- Show in visual mode
    insert = false,        -- Don't show in insert mode (less distracting)
  },
  
  -- Plugin is enabled by default
  enabled = true,
  
  -- Use custom highlight group
  highlight_group = 'MyWhitespace',
  
  -- Custom colors
  colors = {
    fg = '#888888',        -- Gray for normal whitespace
    bg = nil,              -- No background
    visual_fg = '#ffd700', -- Gold in visual selection
    visual_bg = '#2d3748', -- Dark blue background in visual selection
  },
})

-- Set up custom highlight group
vim.api.nvim_set_hl(0, 'MyWhitespace', {
  fg = '#444444',
  nocombine = true,
})

-- Example keymaps using function calls
vim.keymap.set('n', '<leader>tw', function()
  require('render-whitespace').toggle()
end, { desc = 'Toggle whitespace rendering' })

vim.keymap.set('n', '<leader>te', function()
  require('render-whitespace').enable()
end, { desc = 'Enable whitespace rendering' })

vim.keymap.set('n', '<leader>td', function()
  require('render-whitespace').disable()
end, { desc = 'Disable whitespace rendering' })

-- Mode-specific toggle keymaps using function calls
vim.keymap.set('n', '<leader>tn', function()
  require('render-whitespace').toggle_mode('normal')
  local enabled = require('render-whitespace').is_mode_enabled('normal')
  print('Whitespace rendering in normal mode: ' .. (enabled and 'enabled' or 'disabled'))
end, { desc = 'Toggle whitespace rendering in normal mode' })

vim.keymap.set('n', '<leader>tv', function()
  require('render-whitespace').toggle_mode('visual')
  local enabled = require('render-whitespace').is_mode_enabled('visual')
  print('Whitespace rendering in visual mode: ' .. (enabled and 'enabled' or 'disabled'))
end, { desc = 'Toggle whitespace rendering in visual mode' })

vim.keymap.set('n', '<leader>ti', function()
  require('render-whitespace').toggle_mode('insert')
  local enabled = require('render-whitespace').is_mode_enabled('insert')
  print('Whitespace rendering in insert mode: ' .. (enabled and 'enabled' or 'disabled'))
end, { desc = 'Toggle whitespace rendering in insert mode' })

-- Alternative: Command-style keymaps (more performant)
-- Uncomment these and comment the above if you prefer command style

-- vim.keymap.set('n', '<leader>tw', '<cmd>RenderWhitespaceToggle<cr>', { desc = 'Toggle whitespace rendering' })
-- vim.keymap.set('n', '<leader>te', '<cmd>RenderWhitespaceEnable<cr>', { desc = 'Enable whitespace rendering' })
-- vim.keymap.set('n', '<leader>td', '<cmd>RenderWhitespaceDisable<cr>', { desc = 'Disable whitespace rendering' })

-- vim.keymap.set('n', '<leader>tn', '<cmd>RenderWhitespaceToggleNormal<cr>', { desc = 'Toggle normal mode whitespace' })
-- vim.keymap.set('n', '<leader>tv', '<cmd>RenderWhitespaceToggleVisual<cr>', { desc = 'Toggle visual mode whitespace' })
-- vim.keymap.set('n', '<leader>ti', '<cmd>RenderWhitespaceToggleInsert<cr>', { desc = 'Toggle insert mode whitespace' })

-- vim.keymap.set('n', '<leader>wn', '<cmd>RenderWhitespaceEnableNormal<cr>', { desc = 'Enable normal mode whitespace' })
-- vim.keymap.set('n', '<leader>wv', '<cmd>RenderWhitespaceEnableVisual<cr>', { desc = 'Enable visual mode whitespace' })
-- vim.keymap.set('n', '<leader>wi', '<cmd>RenderWhitespaceEnableInsert<cr>', { desc = 'Enable insert mode whitespace' })

-- Color management keymaps
vim.keymap.set('n', '<leader>tc', function()
  -- Cycle through different color schemes
  local colors = {
    { fg = '#666666', visual_fg = nil },           -- Default gray
    { fg = '#888888', visual_fg = '#ffd700' },     -- Gray with gold selection
    { fg = '#ff6b6b', visual_fg = '#4ecdc4' },     -- Red with teal selection
    { fg = '#a8cc8c', visual_fg = '#e67e22' },     -- Green with orange selection
  }
  
  -- Simple cycle through colors (you'd want to track state in real usage)
  local current = math.random(#colors)
  require('render-whitespace').set_colors(colors[current])
  print('Changed whitespace colors')
end, { desc = 'Cycle whitespace colors' })
