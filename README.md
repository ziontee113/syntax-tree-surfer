# 🌳 syntax-tree-surfer 🌳🌊
### Syntax Tree Surfer is a plugin for Neovim that helps you surf through your document and move elements around using the nvim-treesitter API.

![tree surfing cover](https://user-images.githubusercontent.com/102876811/163170119-89369c35-a061-4058-aaeb-1706ea6fa4cf.jpg)

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
local stf = require("syntax-tree-surfer")
vim.keymap.set("n", "gv", function() -- only jump to variable_declarations
	stf.targeted_jump({ "variable_declaration" })
end, opts)
vim.keymap.set("n", "gfu", function() -- only jump to functions
	stf.targeted_jump({ "function" })
end, opts)
vim.keymap.set("n", "gif", function() -- only jump to if_statements
	stf.targeted_jump({ "if_statement" })
end, opts)
vim.keymap.set("n", "gfo", function() -- only jump to for_statements
	stf.targeted_jump({ "for_statement" })
end, opts)
vim.keymap.set("n", "gj", function() -- jump to all that you specify
	stf.targeted_jump({
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
	stf.filtered_jump("default", true) --> true means jump forward
end, opts)
vim.keymap.set("n", "<A-p>", function()
	stf.filtered_jump("default", false) --> false means jump backwards
end, opts)

-- non-default jump --> custom desired_types
vim.keymap.set("n", "your_keymap", function()
	stf.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, true) --> true means jump forward
end, opts)
vim.keymap.set("n", "your_keymap", function()
	stf.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, false) --> false means jump backwards
end, opts)

-------------------------------
-- jump with limited targets --
-- jump to sibling nodes only
vim.keymap.set("n", "-", function()
	stf.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, false, { destination = "siblings" })
end, opts)
vim.keymap.set("n", "=", function()
	stf.filtered_jump({ "if_statement", "else_clause", "else_statement" }, true, { destination = "siblings" })
end, opts)

-- jump to parent or child nodes only
vim.keymap.set("n", "_", function()
	stf.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, false, { destination = "parent" })
end, opts)
vim.keymap.set("n", "+", function()
	stf.filtered_jump({
		"if_statement",
		"else_clause",
		"else_statement",
	}, true, { destination = "children" })
end, opts)

-- Setup Function example:
-- These are the default options:
require("syntax-tree-surfer").setup({
	disable_no_instance_found_report = false,
	default_desired_types = {
		"function",
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
		["variable_declaration"] = "",
	},
})
```

---

# Basic Functionalities

### **Navigate** around your document based on Treesitter's abstract Syntax Tree. Step into, step out, step over, step back.

https://user-images.githubusercontent.com/102876811/163170843-a7c9f1a1-4ffb-4a39-9636-fc81521bd9b5.mp4

---

### **Move / Swap** elements around based on your visual selection

https://user-images.githubusercontent.com/102876811/163171460-4620be6b-360f-4d39-b025-55c412f54a96.mp4

https://user-images.githubusercontent.com/102876811/163171686-4ad49b7a-9fd3-41d5-a2c2-deae1bb41c3d.mp4

### **Swap in Normal Mode** (limited support)

https://user-images.githubusercontent.com/102876811/163173466-b4bfd70f-c239-4e9c-a7ae-c540c093e0f4.mp4

### Version 1.1 update

This feature will help you save some keystrokes & brain power when you want to create some code at the top level node of your current cursor position.

```lua
lua require("syntax-tree-surfer").go_to_top_node_and_execute_commands(false, { "normal! O", "normal! O", "startinsert" })<cr>
```

The .go_to_top_node_and_execute_commands() method takes 2 arguments:

1. boolean: if false then it will jump to the beginning of the node, if true it jumps to the end.

1. lua table: a table that contains strings, each tring is a vim command example: { "normal! O", "normal! O", "startinsert" }

---

# How do I install?
### I don't know! This is my first plugin! Use the github link with your favorite Package Manager and hope for the best! 🥳


# How do I set things up?
### Here's my suggestion:

``` lua
-- Syntax Tree Surfer

-- Normal Mode Swapping
vim.api.nvim_set_keymap("n", "vd", '<cmd>lua require("syntax-tree-surfer").move("n", false)<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("n", "vu", '<cmd>lua require("syntax-tree-surfer").move("n", true)<cr>', {noremap = true, silent = true})
-- .select() will show you what you will be swapping with .move(), you'll get used to .select() and .move() behavior quite soon!
vim.api.nvim_set_keymap("n", "vx", '<cmd>lua require("syntax-tree-surfer").select()<cr>', {noremap = true, silent = true})
-- .select_current_node() will select the current node at your cursor
vim.api.nvim_set_keymap("n", "vn", '<cmd>lua require("syntax-tree-surfer").select_current_node()<cr>', {noremap = true, silent = true})

-- NAVIGATION: Only change the keymap to your liking. I would not recommend changing anything about the .surf() parameters!
vim.api.nvim_set_keymap("x", "J", '<cmd>lua require("syntax-tree-surfer").surf("next", "visual")<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("x", "K", '<cmd>lua require("syntax-tree-surfer").surf("prev", "visual")<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("x", "H", '<cmd>lua require("syntax-tree-surfer").surf("parent", "visual")<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("x", "L", '<cmd>lua require("syntax-tree-surfer").surf("child", "visual")<cr>', {noremap = true, silent = true})

-- SWAPPING WITH VISUAL SELECTION: Only change the keymap to your liking. Don't change the .surf() parameters!
vim.api.nvim_set_keymap("x", "<A-j>", '<cmd>lua require("syntax-tree-surfer").surf("next", "visual", true)<cr>', {noremap = true, silent = true})
vim.api.nvim_set_keymap("x", "<A-k>", '<cmd>lua require("syntax-tree-surfer").surf("prev", "visual", true)<cr>', {noremap = true, silent = true})
```

# Now start Tree Surfing! 🌲💦
