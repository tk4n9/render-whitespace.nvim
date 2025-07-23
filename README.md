# render-whitespace.nvim

A Neovim plugin that renders whitespace characters with configurable options, primarily designed for visual mode highlighting.

## Features

- Render different types of whitespace characters (spaces, tabs, newlines, etc.)
- Configure which modes to render whitespace (normal, visual, insert)
- Customizable characters for each whitespace type
- Mode-specific toggle functionality
- Lightweight and performant
- Default visual-mode-only rendering for distraction-free editing

## Installation

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'GTPV/render-whitespace.nvim'
```

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'GTPV/render-whitespace.nvim',
  config = function()
    require('render-whitespace').setup()
  end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'GTPV/render-whitespace.nvim'
```

## Configuration

```lua
require('render-whitespace').setup({
  -- Characters to use for rendering different whitespace types
  chars = {
    space = '·',           -- Character for spaces
    tab = '↦',             -- Character for tabs
    newline = '↲',         -- Character for newlines
    trail = '•',           -- Character for trailing spaces
  },
  
  -- Modes in which to render whitespace
  modes = {
    normal = false,        -- Render in normal mode
    visual = true,         -- Render in visual mode
    insert = false,        -- Render in insert mode
  },
  
  -- Enable/disable the plugin
  enabled = true,
  
  -- Highlight group for whitespace characters
  highlight_group = 'Whitespace',
  
  -- Color configuration
  colors = {
    fg = '#666666',        -- Foreground color for whitespace characters
    bg = nil,              -- Background color (nil for transparent)
    visual_fg = nil,       -- Foreground when in visual selection (nil to inherit)
    visual_bg = nil,       -- Background when in visual selection (nil to inherit)
  },
})
```

## Usage

### Commands

#### General Commands

- `:RenderWhitespaceToggle` - Toggle whitespace rendering
- `:RenderWhitespaceEnable` - Enable whitespace rendering
- `:RenderWhitespaceDisable` - Disable whitespace rendering

#### Mode-Specific Toggle Commands

- `:RenderWhitespaceToggleNormal` - Toggle whitespace rendering in normal mode only
- `:RenderWhitespaceToggleVisual` - Toggle whitespace rendering in visual mode only
- `:RenderWhitespaceToggleInsert` - Toggle whitespace rendering in insert mode only

#### Mode-Specific Enable Commands

- `:RenderWhitespaceEnableNormal` - Enable whitespace rendering in normal mode
- `:RenderWhitespaceEnableVisual` - Enable whitespace rendering in visual mode
- `:RenderWhitespaceEnableInsert` - Enable whitespace rendering in insert mode

#### Mode-Specific Disable Commands

- `:RenderWhitespaceDisableNormal` - Disable whitespace rendering in normal mode
- `:RenderWhitespaceDisableVisual` - Disable whitespace rendering in visual mode
- `:RenderWhitespaceDisableInsert` - Disable whitespace rendering in insert mode

#### Color Management Commands

- `:RenderWhitespaceSetColors fg=#ff0000 visual_fg=#00ff00` - Set colors with key=value pairs

### API

```lua
local rw = require('render-whitespace')

-- Toggle whitespace rendering
rw.toggle()

-- Enable/disable whitespace rendering
rw.enable()
rw.disable()

-- Check if enabled
if rw.is_enabled() then
  -- Do something
end

-- Mode-specific controls
rw.toggle_mode('normal')    -- Toggle for normal mode
rw.enable_mode('visual')    -- Enable for visual mode
rw.disable_mode('insert')   -- Disable for insert mode

-- Check mode status
if rw.is_mode_enabled('normal') then
  -- Normal mode rendering is enabled
end

-- Get all mode configurations
local modes = rw.get_modes()
print(vim.inspect(modes))

-- Color management
rw.set_colors({
  fg = '#888888',        -- Change foreground color
  visual_fg = '#ffff00', -- Yellow in visual selection
})

-- Get current colors
local colors = rw.get_colors()
print(vim.inspect(colors))
```

### Keybindings Examples

#### Using Function Calls

```lua
-- Global toggle
vim.keymap.set('n', '<leader>tw', require('render-whitespace').toggle)

-- Mode-specific toggles
vim.keymap.set('n', '<leader>tn', function()
  require('render-whitespace').toggle_mode('normal')
end, { desc = 'Toggle whitespace in normal mode' })

vim.keymap.set('n', '<leader>tv', function()
  require('render-whitespace').toggle_mode('visual')
end, { desc = 'Toggle whitespace in visual mode' })

vim.keymap.set('n', '<leader>ti', function()
  require('render-whitespace').toggle_mode('insert')
end, { desc = 'Toggle whitespace in insert mode' })
```

#### Using Command Style (Recommended for Performance)

```lua
-- Global controls
vim.keymap.set('n', '<leader>tw', '<cmd>RenderWhitespaceToggle<cr>')
vim.keymap.set('n', '<leader>we', '<cmd>RenderWhitespaceEnable<cr>')
vim.keymap.set('n', '<leader>wd', '<cmd>RenderWhitespaceDisable<cr>')

-- Mode-specific toggles
vim.keymap.set('n', '<leader>tn', '<cmd>RenderWhitespaceToggleNormal<cr>')
vim.keymap.set('n', '<leader>tv', '<cmd>RenderWhitespaceToggleVisual<cr>')
vim.keymap.set('n', '<leader>ti', '<cmd>RenderWhitespaceToggleInsert<cr>')

-- Mode-specific enable/disable
vim.keymap.set('n', '<leader>wn', '<cmd>RenderWhitespaceEnableNormal<cr>')
vim.keymap.set('n', '<leader>wv', '<cmd>RenderWhitespaceEnableVisual<cr>')
vim.keymap.set('n', '<leader>wi', '<cmd>RenderWhitespaceEnableInsert<cr>')

-- Color management
vim.keymap.set('n', '<leader>wc', '<cmd>RenderWhitespaceSetColors fg=#ff6b6b visual_fg=#4ecdc4<cr>')
```

## Customization

### Custom Colors

You can customize colors in several ways:

#### 1. During Setup

```lua
require('render-whitespace').setup({
  colors = {
    fg = '#888888',        -- Gray whitespace characters
    bg = '#2d3748',        -- Dark background
    visual_fg = '#ffd700', -- Gold color in visual selection
    visual_bg = '#4a5568', -- Different background in visual selection
  }
})
```

#### 2. Dynamically Change Colors

```lua
-- Change colors at runtime
require('render-whitespace').set_colors({
  fg = '#ff6b6b',        -- Red whitespace
  visual_fg = '#4ecdc4', -- Teal in visual selection
})
```

#### 3. Using Highlight Groups

```vim
highlight Whitespace guifg=#555555 gui=nocombine
highlight WhitespaceVisual guifg=#ffff00 guibg=#333333 gui=nocombine
```

Or in Lua:

```lua
vim.api.nvim_set_hl(0, 'Whitespace', { fg = '#555555', nocombine = true })
vim.api.nvim_set_hl(0, 'WhitespaceVisual', { fg = '#ffff00', bg = '#333333', nocombine = true })
```

### Custom Highlight Group

You can customize the appearance by defining your own highlight group:

```vim
highlight Whitespace guifg=#555555 gui=nocombine
```

Or in Lua:

```lua
vim.api.nvim_set_hl(0, 'Whitespace', { fg = '#555555', nocombine = true })
```

## License

MIT License
