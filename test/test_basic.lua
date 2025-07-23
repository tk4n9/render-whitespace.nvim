-- Tests for render-whitespace.nvim
local render_whitespace = require('render-whitespace')

-- Test default configuration
local function test_default_config()
  render_whitespace._reset() -- Reset state before test
  render_whitespace.setup()
  assert(render_whitespace.is_enabled(), "Plugin should be enabled by default")
  print("✓ Default configuration test passed")
end

-- Test custom configuration
local function test_custom_config()
  render_whitespace._reset() -- Reset state before test
  render_whitespace.setup({
    enabled = false,
    chars = {
      space = '•',
      tab = '⇥',
    },
  })
  assert(not render_whitespace.is_enabled(), "Plugin should be disabled")
  print("✓ Custom configuration test passed")
end

-- Test enable/disable functionality
local function test_enable_disable()
  render_whitespace._reset() -- Reset state before test
  render_whitespace.setup({ enabled = false })
  
  render_whitespace.enable()
  assert(render_whitespace.is_enabled(), "Plugin should be enabled")
  
  render_whitespace.disable()
  assert(not render_whitespace.is_enabled(), "Plugin should be disabled")
  
  print("✓ Enable/disable test passed")
end

-- Test toggle functionality
local function test_toggle()
  render_whitespace._reset() -- Reset state before test
  render_whitespace.setup({ enabled = false })
  
  local initial_state = render_whitespace.is_enabled()
  render_whitespace.toggle()
  local after_toggle = render_whitespace.is_enabled()
  
  assert(initial_state ~= after_toggle, "Toggle should change state")
  
  render_whitespace.toggle()
  local after_second_toggle = render_whitespace.is_enabled()
  
  assert(initial_state == after_second_toggle, "Two toggles should return to original state")
  
  print("✓ Toggle test passed")
end

-- Test mode-specific functionality
local function test_mode_specific()
  render_whitespace._reset() -- Reset state before test
  render_whitespace.setup({ enabled = true })
  
  -- Test toggle_mode
  local initial_normal = render_whitespace.is_mode_enabled('normal')
  render_whitespace.toggle_mode('normal')
  local after_toggle_normal = render_whitespace.is_mode_enabled('normal')
  assert(initial_normal ~= after_toggle_normal, "toggle_mode should change mode state")
  
  -- Test enable_mode and disable_mode
  render_whitespace.enable_mode('visual')
  assert(render_whitespace.is_mode_enabled('visual'), "enable_mode should enable the mode")
  
  render_whitespace.disable_mode('visual')
  assert(not render_whitespace.is_mode_enabled('visual'), "disable_mode should disable the mode")
  
  -- Test get_modes
  local modes = render_whitespace.get_modes()
  assert(type(modes) == 'table', "get_modes should return a table")
  assert(modes.normal ~= nil, "modes should contain normal")
  assert(modes.visual ~= nil, "modes should contain visual")
  assert(modes.insert ~= nil, "modes should contain insert")
  
  -- Test invalid mode handling
  local function test_invalid_mode()
    render_whitespace.toggle_mode('invalid')
  end
  local success = pcall(test_invalid_mode)
  assert(not success, "toggle_mode should error on invalid mode")
  
  print("✓ Mode-specific functionality test passed")
end

-- Run all tests
local function run_tests()
  print("Running render-whitespace.nvim tests...")
  
  test_default_config()
  test_custom_config()
  test_enable_disable()
  test_toggle()
  test_mode_specific()
  
  -- Clean up after all tests
  render_whitespace._reset()
  
  print("All tests passed! ✓")
end

-- Execute tests if this file is run directly
if debug.getinfo(2, "S") == nil then
  run_tests()
end

return {
  run_tests = run_tests,
}
