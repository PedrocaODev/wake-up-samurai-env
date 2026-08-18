-- Wake Up Samurai
-- Shared palette for Herdr / Pi / Neovim

vim.cmd("highlight clear")

if vim.fn.exists("syntax_on") == 1 then
  vim.cmd("syntax reset")
end

vim.o.background = "dark"
vim.g.colors_name = "wake-up-samurai"

local p = {
  -- backgrounds
  bg = "#0b0f14",
  bg_dark = "#090c10",
  surface0 = "#131922",
  surface1 = "#1d2531",
  selection = "#25202a",

  -- reds
  text = "#f08080",
  text_secondary = "#d87474",
  muted = "#a85c5c",

  accent = "#e23d3d",
  red = "#ee4b4b",

  -- borders
  border = "#8a4f4f",
  border_dim = "#5f3030",

  -- semantic
  cyan = "#6ec6ff",
  cyan_dim = "#4e9dc7",
  green = "#3eea9a",
  yellow = "#f6da63",
  peach = "#eaa65a",

  -- subtle semantic backgrounds
  red_bg = "#241014",
  green_bg = "#0d211a",
  yellow_bg = "#26210f",
  cyan_bg = "#10202a",
}

local function hl(group, opts)
  vim.api.nvim_set_hl(0, group, opts)
end

-- ─────────────────────────────────────────────────────────────
-- Core editor
-- ─────────────────────────────────────────────────────────────

hl("Normal", {
  fg = p.text,
  bg = p.bg,
})

hl("NormalNC", {
  fg = p.text_secondary,
  bg = p.bg,
})

hl("NormalFloat", {
  fg = p.text,
  bg = p.surface0,
})

hl("FloatBorder", {
  fg = p.border,
  bg = p.surface0,
})

hl("FloatTitle", {
  fg = p.red,
  bg = p.surface0,
  bold = true,
})

hl("SignColumn", {
  bg = p.bg,
})

hl("FoldColumn", {
  fg = p.muted,
  bg = p.bg,
})

hl("Folded", {
  fg = p.text_secondary,
  bg = p.surface0,
})

hl("EndOfBuffer", {
  fg = p.bg,
})

-- ─────────────────────────────────────────────────────────────
-- Lines / cursor
-- ─────────────────────────────────────────────────────────────

hl("CursorLine", {
  bg = p.surface0,
})

hl("CursorColumn", {
  bg = p.surface0,
})

hl("ColorColumn", {
  bg = p.surface0,
})

hl("LineNr", {
  fg = p.muted,
})

hl("LineNrAbove", {
  fg = p.muted,
})

hl("LineNrBelow", {
  fg = p.muted,
})

hl("CursorLineNr", {
  fg = p.red,
  bold = true,
})

hl("CursorLineSign", {
  bg = p.surface0,
})

hl("CursorLineFold", {
  bg = p.surface0,
})

-- ─────────────────────────────────────────────────────────────
-- Selection / search
-- ─────────────────────────────────────────────────────────────

hl("Visual", {
  bg = "#3a1d25",
})

hl("VisualNOS", {
  bg = "#3a1d25",
})

hl("Search", {
  fg = p.bg,
  bg = p.yellow,
  bold = true,
})

hl("IncSearch", {
  fg = p.bg,
  bg = p.red,
  bold = true,
})

hl("CurSearch", {
  fg = p.bg,
  bg = p.red,
  bold = true,
})

hl("Substitute", {
  fg = p.bg,
  bg = p.cyan,
  bold = true,
})

hl("MatchParen", {
  fg = p.cyan,
  bg = p.surface1,
  bold = true,
})

-- ─────────────────────────────────────────────────────────────
-- Windows / separators
-- ─────────────────────────────────────────────────────────────

hl("WinSeparator", {
  fg = p.border_dim,
})

hl("VertSplit", {
  fg = p.border_dim,
})

hl("StatusLine", {
  fg = p.text,
  bg = p.surface0,
})

hl("StatusLineNC", {
  fg = p.muted,
  bg = p.bg_dark,
})

hl("WinBar", {
  fg = p.text_secondary,
  bg = p.bg,
})

hl("WinBarNC", {
  fg = p.muted,
  bg = p.bg,
})

-- ─────────────────────────────────────────────────────────────
-- Tabs
-- ─────────────────────────────────────────────────────────────

hl("TabLine", {
  fg = p.text_secondary,
  bg = p.surface0,
})

hl("TabLineSel", {
  fg = p.bg,
  bg = p.accent,
  bold = true,
})

hl("TabLineFill", {
  bg = p.bg_dark,
})

-- ─────────────────────────────────────────────────────────────
-- Popup menu / completion
-- ─────────────────────────────────────────────────────────────

hl("Pmenu", {
  fg = p.text,
  bg = p.surface0,
})

hl("PmenuSel", {
  fg = p.bg,
  bg = p.accent,
  bold = true,
})

hl("PmenuSbar", {
  bg = p.surface1,
})

hl("PmenuThumb", {
  bg = p.border,
})

hl("PmenuMatch", {
  fg = p.cyan,
  bold = true,
})

hl("PmenuMatchSel", {
  fg = p.bg,
  bold = true,
})

-- ─────────────────────────────────────────────────────────────
-- Messages
-- ─────────────────────────────────────────────────────────────

hl("Title", {
  fg = p.text,
  bold = true,
})

hl("Directory", {
  fg = p.cyan,
})

hl("Question", {
  fg = p.green,
})

hl("MoreMsg", {
  fg = p.green,
})

hl("ModeMsg", {
  fg = p.text_secondary,
  bold = true,
})

hl("ErrorMsg", {
  fg = p.red,
  bold = true,
})

hl("WarningMsg", {
  fg = p.yellow,
})

-- ─────────────────────────────────────────────────────────────
-- Base syntax
-- ─────────────────────────────────────────────────────────────

hl("Comment", {
  fg = p.muted,
  italic = true,
})

hl("Constant", {
  fg = p.peach,
})

hl("String", {
  fg = p.green,
})

hl("Character", {
  fg = p.green,
})

hl("Number", {
  fg = p.peach,
})

hl("Boolean", {
  fg = p.yellow,
  bold = true,
})

hl("Float", {
  fg = p.peach,
})

hl("Identifier", {
  fg = p.text,
})

hl("Function", {
  fg = p.cyan,
})

hl("Statement", {
  fg = p.red,
  bold = true,
})

hl("Conditional", {
  fg = p.red,
})

hl("Repeat", {
  fg = p.red,
})

hl("Label", {
  fg = p.text_secondary,
})

hl("Operator", {
  fg = p.red,
})

hl("Keyword", {
  fg = p.red,
  bold = true,
})

hl("Exception", {
  fg = p.red,
})

hl("PreProc", {
  fg = p.text_secondary,
})

hl("Include", {
  fg = p.red,
})

hl("Define", {
  fg = p.red,
})

hl("Macro", {
  fg = p.red,
})

hl("PreCondit", {
  fg = p.text_secondary,
})

hl("Type", {
  fg = p.cyan,
})

hl("StorageClass", {
  fg = p.red,
})

hl("Structure", {
  fg = p.cyan,
})

hl("Typedef", {
  fg = p.cyan,
})

hl("Special", {
  fg = p.yellow,
})

hl("SpecialChar", {
  fg = p.yellow,
})

hl("Tag", {
  fg = p.cyan,
})

hl("Delimiter", {
  fg = p.text_secondary,
})

hl("SpecialComment", {
  fg = p.muted,
  italic = true,
})

hl("Debug", {
  fg = p.peach,
})

hl("Underlined", {
  fg = p.cyan,
  underline = true,
})

hl("Ignore", {
  fg = p.muted,
})

hl("Error", {
  fg = p.red,
})

hl("Todo", {
  fg = p.bg,
  bg = p.yellow,
  bold = true,
})

-- ─────────────────────────────────────────────────────────────
-- Treesitter
-- ─────────────────────────────────────────────────────────────

hl("@comment", { link = "Comment" })
hl("@comment.documentation", {
  fg = p.text_secondary,
  italic = true,
})

hl("@string", { link = "String" })
hl("@string.escape", {
  fg = p.yellow,
})
hl("@string.special", {
  fg = p.cyan,
})

hl("@character", { link = "Character" })
hl("@number", { link = "Number" })
hl("@number.float", { link = "Float" })
hl("@boolean", { link = "Boolean" })

hl("@constant", {
  fg = p.peach,
})
hl("@constant.builtin", {
  fg = p.yellow,
})
hl("@constant.macro", {
  fg = p.peach,
})

hl("@variable", {
  fg = p.text,
})
hl("@variable.builtin", {
  fg = p.text_secondary,
  italic = true,
})
hl("@variable.parameter", {
  fg = p.text_secondary,
})
hl("@variable.member", {
  fg = p.text,
})

hl("@function", {
  fg = p.cyan,
})
hl("@function.call", {
  fg = p.cyan,
})
hl("@function.builtin", {
  fg = p.cyan,
})
hl("@function.method", {
  fg = p.cyan,
})
hl("@function.method.call", {
  fg = p.cyan,
})

hl("@constructor", {
  fg = p.cyan,
})

hl("@keyword", {
  fg = p.red,
  bold = true,
})
hl("@keyword.function", {
  fg = p.red,
})
hl("@keyword.return", {
  fg = p.red,
})
hl("@keyword.operator", {
  fg = p.red,
})
hl("@keyword.conditional", {
  fg = p.red,
})
hl("@keyword.repeat", {
  fg = p.red,
})
hl("@keyword.import", {
  fg = p.red,
})

hl("@operator", {
  fg = p.red,
})

hl("@type", {
  fg = p.cyan,
})
hl("@type.builtin", {
  fg = p.cyan,
})
hl("@type.definition", {
  fg = p.cyan,
})

hl("@property", {
  fg = p.text,
})
hl("@attribute", {
  fg = p.yellow,
})

hl("@punctuation.delimiter", {
  fg = p.text_secondary,
})
hl("@punctuation.bracket", {
  fg = p.text_secondary,
})
hl("@punctuation.special", {
  fg = p.red,
})

hl("@tag", {
  fg = p.red,
})
hl("@tag.attribute", {
  fg = p.cyan,
})
hl("@tag.delimiter", {
  fg = p.text_secondary,
})

-- ─────────────────────────────────────────────────────────────
-- Markdown
-- ─────────────────────────────────────────────────────────────

hl("@markup.heading", {
  fg = p.text,
  bold = true,
})

hl("@markup.heading.1", {
  fg = p.red,
  bold = true,
})

hl("@markup.heading.2", {
  fg = p.text,
  bold = true,
})

hl("@markup.heading.3", {
  fg = p.text_secondary,
  bold = true,
})

hl("@markup.link", {
  fg = p.cyan,
})

hl("@markup.link.url", {
  fg = p.cyan_dim,
  underline = true,
})

hl("@markup.raw", {
  fg = p.green,
})

hl("@markup.raw.block", {
  fg = p.green,
})

hl("@markup.list", {
  fg = p.red,
})

hl("@markup.quote", {
  fg = p.text_secondary,
  italic = true,
})

hl("@markup.strong", {
  fg = p.text,
  bold = true,
})

hl("@markup.italic", {
  fg = p.text_secondary,
  italic = true,
})

-- ─────────────────────────────────────────────────────────────
-- Diagnostics
-- ─────────────────────────────────────────────────────────────

hl("DiagnosticError", {
  fg = p.red,
})

hl("DiagnosticWarn", {
  fg = p.yellow,
})

hl("DiagnosticInfo", {
  fg = p.cyan,
})

hl("DiagnosticHint", {
  fg = p.green,
})

hl("DiagnosticOk", {
  fg = p.green,
})

hl("DiagnosticVirtualTextError", {
  fg = p.red,
  bg = p.red_bg,
})

hl("DiagnosticVirtualTextWarn", {
  fg = p.yellow,
  bg = p.yellow_bg,
})

hl("DiagnosticVirtualTextInfo", {
  fg = p.cyan,
  bg = p.cyan_bg,
})

hl("DiagnosticVirtualTextHint", {
  fg = p.green,
  bg = p.green_bg,
})

hl("DiagnosticUnderlineError", {
  undercurl = true,
  sp = p.red,
})

hl("DiagnosticUnderlineWarn", {
  undercurl = true,
  sp = p.yellow,
})

hl("DiagnosticUnderlineInfo", {
  undercurl = true,
  sp = p.cyan,
})

hl("DiagnosticUnderlineHint", {
  undercurl = true,
  sp = p.green,
})

-- ─────────────────────────────────────────────────────────────
-- Git / diff
-- ─────────────────────────────────────────────────────────────

hl("DiffAdd", {
  fg = p.green,
  bg = p.green_bg,
})

hl("DiffChange", {
  fg = p.yellow,
  bg = p.yellow_bg,
})

hl("DiffDelete", {
  fg = p.red,
  bg = p.red_bg,
})

hl("DiffText", {
  fg = p.bg,
  bg = p.yellow,
  bold = true,
})

hl("Added", {
  fg = p.green,
})

hl("Changed", {
  fg = p.yellow,
})

hl("Removed", {
  fg = p.red,
})

hl("GitSignsAdd", {
  fg = p.green,
})

hl("GitSignsChange", {
  fg = p.yellow,
})

hl("GitSignsDelete", {
  fg = p.red,
})

-- ─────────────────────────────────────────────────────────────
-- Spell
-- ─────────────────────────────────────────────────────────────

hl("SpellBad", {
  undercurl = true,
  sp = p.red,
})

hl("SpellCap", {
  undercurl = true,
  sp = p.yellow,
})

hl("SpellRare", {
  undercurl = true,
  sp = p.cyan,
})

hl("SpellLocal", {
  undercurl = true,
  sp = p.green,
})

-- ─────────────────────────────────────────────────────────────
-- Terminal ANSI palette
-- ─────────────────────────────────────────────────────────────

vim.g.terminal_color_0 = p.bg
vim.g.terminal_color_1 = p.red
vim.g.terminal_color_2 = p.green
vim.g.terminal_color_3 = p.yellow
vim.g.terminal_color_4 = p.cyan_dim
vim.g.terminal_color_5 = p.text_secondary
vim.g.terminal_color_6 = p.cyan
vim.g.terminal_color_7 = p.text

vim.g.terminal_color_8 = p.muted
vim.g.terminal_color_9 = "#ff5a5a"
vim.g.terminal_color_10 = "#55f5aa"
vim.g.terminal_color_11 = "#ffe47a"
vim.g.terminal_color_12 = "#83d0ff"
vim.g.terminal_color_13 = "#ef9292"
vim.g.terminal_color_14 = "#8bd8ff"
vim.g.terminal_color_15 = "#f5a0a0"
