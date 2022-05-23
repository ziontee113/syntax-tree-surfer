# 🌳 syntax-tree-surfer 🌳🌊
### Syntax Tree Surfer is a plugin for Neovim that helps you surf through your document and move elements around using the nvim-treesitter API.

![tree surfing cover](https://user-images.githubusercontent.com/102876811/163170119-89369c35-a061-4058-aaeb-1706ea6fa4cf.jpg)

# What does it do?

### **Navigate** around your document based on Treesitter's abstract Syntax Tree. Step into, step out, step over, step back.

https://user-images.githubusercontent.com/102876811/163170843-a7c9f1a1-4ffb-4a39-9636-fc81521bd9b5.mp4

---
### Version 1.1 update

This feature will help you save some keystrokes & brain power when you want to create some code at the top level node of your current cursor position.

```lua
lua require("syntax-tree-surfer").go_to_top_node_and_execute_commands(false, { "normal! O", "normal! O", "startinsert" })<cr>
```

The .go_to_top_node_and_execute_commands() method takes 2 arguments:

1. boolean: if false then it will jump to the beginning of the node, if true it jumps to the end.

1. lua table: a table that contains strings, each tring is a vim command example: { "normal! O", "normal! O", "startinsert" }

---

### **Move / Swap** elements around based on your visual selection

https://user-images.githubusercontent.com/102876811/163171460-4620be6b-360f-4d39-b025-55c412f54a96.mp4

https://user-images.githubusercontent.com/102876811/163171686-4ad49b7a-9fd3-41d5-a2c2-deae1bb41c3d.mp4

### **Swap in Normal Mode** (limited support)

https://user-images.githubusercontent.com/102876811/163173466-b4bfd70f-c239-4e9c-a7ae-c540c093e0f4.mp4


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
