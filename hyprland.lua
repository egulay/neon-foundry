-- Neon Foundry — Hyprland window chrome.
--
-- The gradient is also declared in colors.toml as hyprland_active_border, so it
-- survives `omarchy theme install`: Omarchy drops a cloned theme's .lua files
-- and regenerates this one from the palette. This copy exists for the linked
-- install and adds what the template cannot express — an acid-green glow under
-- the focused window, so focus reads at a glance on a near-black desktop.
--
-- Note the shape: hl.config() wants a gradient as a table, not as a Hyprland
-- gradient string. Passing the string form gets "invalid color" at reload and
-- silently leaves the previous theme's borders in place.

local active_border_color = {
  colors = { "rgba(c8ff00ee)", "rgba(31e5ffee)", "rgba(ff2e8bee)" },
  angle = 45,
}
local inactive_border_color = {
  colors = { "rgba(27292daa)", "rgba(0e0f12aa)" },
  angle = 45,
}
local active_shadow_color = "rgba(c8ff0033)"
local inactive_shadow_color = "rgba(06070977)"

hl.config({
  general = {
    col = {
      active_border = active_border_color,
      inactive_border = inactive_border_color,
    },
  },

  group = {
    col = {
      border_active = active_border_color,
      border_inactive = inactive_border_color,
    },
  },

  decoration = {
    shadow = {
      enabled = true,
      range = 8,
      render_power = 3,
      color = active_shadow_color,
      color_inactive = inactive_shadow_color,
    },
  },
})
