" render-whitespace.nvim - Whitespace rendering plugin for Neovim

if exists('g:loaded_render_whitespace')
  finish
endif
let g:loaded_render_whitespace = 1

" Default configuration
if !exists('g:render_whitespace_config')
  let g:render_whitespace_config = {}
endif

" Initialize the plugin with Lua
lua require('render-whitespace').setup(vim.g.render_whitespace_config or {})
