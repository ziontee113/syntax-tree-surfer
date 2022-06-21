# 🌳 syntax-tree-surfer 🌳🌊

### Syntax Tree Surfer is a plugin for Neovim that helps you surf through your document and move elements around using the nvim-treesitter API.

![tree surfing cover](https://user-images.githubusercontent.com/102876811/163170119-89369c35-a061-4058-aaeb-1706ea6fa4cf.jpg)

## Table of Contents

1. [Version 1.0 Functionalities](#version-10-functionalities)
1. [How do I install?](#how-do-i-install)
1. [Version 1.1 Update](#version-11-update)
1. [Version 2.0 Beta Update](#version-20-beta-update-)

# Version 1.0 Functionalities

### **Navigate** around your document based on Treesitter's abstract Syntax Tree. Step into, step out, step over, step back.

https://user-images.githubusercontent.com/102876811/163170843-a7c9f1a1-4ffb-4a39-9636-fc81521bd9b5.mp4

---

### **Move / Swap** elements around based on your visual selection

https://user-images.githubusercontent.com/102876811/163171460-4620be6b-360f-4d39-b025-55c412f54a96.mp4

https://user-images.githubusercontent.com/102876811/163171686-4ad49b7a-9fd3-41d5-a2c2-deae1bb41c3d.mp4

### **Swap in Normal Mode** - Now supports Dot (.) Repeat

https://user-images.githubusercontent.com/102876811/174811583-52b7beb0-853f-4ac9-9498-eb718ce626d9.mp4

<!-- https://user-images.githubusercontent.com/102876811/163173466-b4bfd70f-c239-4e9c-a7ae-c540c093e0f4.mp4 -->

# How do I install?

#### Use your favorite Plugin Manager with the link [ziontee113/syntax-tree-surfer](ziontee113/syntax-tree-surfer)

For Packer:

```lua
use "ziontee113/syntax-tree-surfer"
```

# How do I set things up?

### Here's my suggestion:

```lua
-- Syntax Tree Surfer
local opts = {noremap = true, silent = true}

-- Normal Mode Swapping:
-- Swap The Master Node relative to the cursor with it's siblings, Dot Repeatable
vim.keymap.set("n", "vU", function()
	vim.opt.opfunc = "v:lua.STSSwapUpNormal_Dot"
	return "g@l"
end, { silent = true, expr = true })
vim.keymap.set("n", "vD", function()
	vim.opt.opfunc = "v:lua.STSSwapDownNormal_Dot"
	return "g@l"
end, { silent = true, expr = true })

-- Swap Current Node at the Cursor with it's siblings, Dot Repeatable
vim.keymap.set("n", "vd", function()
	vim.opt.opfunc = "v:lua.STSSwapCurrentNodeNextNormal_Dot"
	return "g@l"
end, { silent = true, expr = true })
vim.keymap.set("n", "vu", function()
	vim.opt.opfunc = "v:lua.STSSwapCurrentNodePrevNormal_Dot"
	return "g@l"
end, { silent = true, expr = true })

--> If the mappings above don't work, use these instead (no dot repeatable)
-- vim.keymap.set("n", "vd", '<cmd>STSSwapCurrentNodeNextNormal<cr>', opts)
-- vim.keymap.set("n", "vu", '<cmd>STSSwapCurrentNodePrevNormal<cr>', opts)
-- vim.keymap.set("n", "vD", '<cmd>STSSwapDownNormal<cr>', opts)
-- vim.keymap.set("n", "vU", '<cmd>STSSwapUpNormal<cr>', opts)

-- Visual Selection from Normal Mode
vim.keymap.set("n", "vx", '<cmd>STSSelectMasterNode<cr>', opts)
vim.keymap.set("n", "vn", '<cmd>STSSelectCurrentNode<cr>', opts)

-- Select Nodes in Visual Mode
vim.keymap.set("x", "J", '<cmd>STSSelectNextSiblingNode<cr>', opts)
vim.keymap.set("x", "K", '<cmd>STSSelectPrevSiblingNode<cr>', opts)
vim.keymap.set("x", "H", '<cmd>STSSelectParentNode<cr>', opts)
vim.keymap.set("x", "L", '<cmd>STSSelectFirstChildNode<cr>', opts)

-- Swapping Nodes in Visual Mode
vim.keymap.set("x", "<A-j>", '<cmd>STSSwapNextVisual<cr>', opts)
vim.keymap.set("x", "<A-k>", '<cmd>STSSwapPrevVisual<cr>', opts)
```

# Now let's start Tree Surfing! 🌲💦

### Version 1.1 update

This feature will help you save some keystrokes & brain power when you want to create some code at the top level node of your current cursor position.

```lua
lua require("syntax-tree-surfer").go_to_top_node_and_execute_commands(false, { "normal! O", "normal! O", "startinsert" })<cr>
```

The .go_to_top_node_and_execute_commands() method takes 2 arguments:

1. boolean: if false then it will jump to the beginning of the node, if true it jumps to the end.

1. lua table: a table that contains strings, each tring is a vim command example: { "normal! O", "normal! O", "startinsert" }

---

# Version 2.0 Beta Update ⚡

### Targeted Jump with Virtual Text 🆕

https://user-images.githubusercontent.com/102876811/169820839-5ec66bd9-bf14-49f6-8e5a-3078b8ec43c4.mp4

### Filtered Jump through user-defined node types 🆕

https://user-images.githubusercontent.com/102876811/169820922-b1eefa5e-6ed9-4ebd-95d1-f3f35e0388da.mp4

### These are experimental features and I wish to expand them even further. If you have any suggestions, please feel free to let me know 😊

Example mappings for Version 2.0 Beta functionalities:

```lua
-- Syntax Tree Surfer V2 Mappings
-- Targeted Jump with virtual_text
local sts = require("syntax-tree-surfer")
vim.keymap.set("n", "gv", function() -- only jump to variable_declarations
	sts.targeted_jump({ "variable_declaration" })
end, opts)
vim.keymap.set("n", "gfu", function() -- only jump to functions
	sts.targeted_jump({ "function", "function_definition" })
  --> In this example, the Lua language schema uses "function",
  --  when the Python language uses "function_definition"
  --  we include both, so this keymap will work on both languages
end, opts)
vim.keymap.set("n", "gif", function() -- only jump to if_statements
	sts.targeted_jump({ "if_statement" })
end, opts)
vim.keymap.set("n", "gfo", function() -- only jump to for_statements
	sts.targeted_jump({ "for_statement" })
end, opts)
vim.keymap.set("n", "gj", function() -- jump to all that you specify
	sts.targeted_jump({
		"function",
	  "if_statement",
		"else_clause",
		"else_statement",
		"elseif_statement",
		"for_statement",
		"while_statement",
		"switch_statement",
	})
end, opts)

-------------------------------
-- filtered_jump --
-- "default" means that you jump to the default_desired_types or your lastest jump types
vim.keymap.set("n", "<A-n>", function()
	sts.filtered_jump("default", true) --> true means jump forward
end, opts)
vim.keymap.set("n", "<A-p>", function()
	sts.filtered_jump("default", false) --> false means jump backwards
end, opts)

-- non-default jump --> custom desired_types
vim.keymap.set("n", "your_keymap", function()
	sts.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, true) --> true means jump forward
end, opts)
vim.keymap.set("n", "your_keymap", function()
	sts.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, false) --> false means jump backwards
end, opts)

-------------------------------
-- jump with limited targets --
-- jump to sibling nodes only
vim.keymap.set("n", "-", function()
	sts.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, false, { destination = "siblings" })
end, opts)
vim.keymap.set("n", "=", function()
	sts.filtered_jump({ "if_statement", "else_clause", "else_statement" }, true, { destination = "siblings" })
end, opts)

-- jump to parent or child nodes only
vim.keymap.set("n", "_", function()
	sts.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, false, { destination = "parent" })
end, opts)
vim.keymap.set("n", "+", function()
	sts.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, true, { destination = "children" })
end, opts)

-- Setup Function example:
-- These are the default options:
require("syntax-tree-surfer").setup({
	highlight_group = "STS_highlight",
	disable_no_instance_found_report = false,
	default_desired_types = {
		"function",
		"function_definition",
		"if_statement",
		"else_clause",
		"else_statement",
		"elseif_statement",
		"for_statement",
		"while_statement",
		"switch_statement",
	},
	left_hand_side = "fdsawervcxqtzb",
	right_hand_side = "jkl;oiu.,mpy/n",
	icon_dictionary = {
		["if_statement"] = "",
		["else_clause"] = "",
		["else_statement"] = "",
		["elseif_statement"] = "",
		["for_statement"] = "ﭜ",
		["while_statement"] = "ﯩ",
		["switch_statement"] = "ﳟ",
		["function"] = "",
		["function_definition"] = "",
		["variable_declaration"] = "",
	},
})
```

### Because every languages have different schemas and node-types, you can check the node-types that you're interested in with https://github.com/nvim-treesitter/playground

#### You can also do a quick check using the command :STSPrintNodesAtCursor

### I'll try to incorporate a simple function to tell what kind of node is the cursor is on natively so you don't have to install a separate plugin soon :)
