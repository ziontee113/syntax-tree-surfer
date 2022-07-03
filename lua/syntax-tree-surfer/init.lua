---@diagnostic disable: missing-parameter, empty-block

local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

local function find_range_from_2nodes(nodeA, nodeB) --{{{
	local start_row_A, start_col_A, end_row_A, end_col_A = nodeA:range()
	local start_row_B, start_col_B, end_row_B, end_col_B = nodeB:range()

	local true_range = {}

	if start_row_A == start_row_B then
		if start_col_A < start_col_B then
			table.insert(true_range, start_row_A)
			table.insert(true_range, start_col_A)
		else
			table.insert(true_range, start_row_B)
			table.insert(true_range, start_col_B)
		end
	end

	if start_row_A < start_row_B then
		table.insert(true_range, start_row_A)
		table.insert(true_range, start_col_A)
	elseif start_row_A > start_row_B then
		table.insert(true_range, start_row_B)
		table.insert(true_range, start_col_B)
	end

	if end_row_A == end_row_B then
		if end_col_A > end_col_B then
			table.insert(true_range, end_row_A)
			table.insert(true_range, end_col_A)
		else
			table.insert(true_range, end_row_B)
			table.insert(true_range, end_col_B)
		end
	end
	if end_row_A > end_row_B then
		table.insert(true_range, end_row_A)
		table.insert(true_range, end_col_A)
	elseif end_row_A < end_row_B then
		table.insert(true_range, end_row_B)
		table.insert(true_range, end_col_B)
	end

	return true_range
end --}}}

M.surf = function(direction, mode, move) --{{{
	local node = ts_utils.get_node_at_cursor() -- declare node and bufnr
	local bufnr = vim.api.nvim_get_current_buf()

	if node == nil then -- prevent errors
		return
	end

	if mode == "visual" then
		local nodeA = node
		vim.cmd("normal! o")
		local nodeB = ts_utils.get_node_at_cursor()
		vim.cmd("normal! o")
		local root = ts_utils.get_root_for_node(node)

		if nodeA:id() ~= nodeB:id() then --> get the true node
			local true_range = find_range_from_2nodes(nodeA, nodeB)
			local parent = nodeA:parent()
			local start_row_P, start_col_P, end_row_P, end_col_P = parent:range()

			while
				start_row_P ~= true_range[1]
				or start_col_P ~= true_range[2]
				or end_row_P ~= true_range[3]
				or end_col_P ~= true_range[4]
			do
				if parent:parent() == nil then
					break
				end
				parent = parent:parent()
				start_row_P, start_col_P, end_row_P, end_col_P = parent:range()
			end

			node = parent
		end

		if node == root then -- catch some edge cases
			node = nodeA
		end
	end

	local parent = node:parent() --> if parent only has 1 child, move up the tree
	while parent ~= nil and parent:named_child_count() == 1 do
		node = parent
		parent = node:parent()
	end

	local target --> setting the target, depending on the direction
	if direction == "parent" then
		target = node:parent()
	elseif direction == "child" and node ~= nil then
		while node ~= nil do
			if node:named_child_count() >= 2 then
				target = node:named_child(0)
				break
			end
			node = node:named_child(0)
		end
	else
		target = node:next_named_sibling() -- naively look for next or prev sibling based on direction
		if direction == "prev" then
			target = node:prev_named_sibling()
		end

		while target ~= nil and target:type() == "comment" do -- skip over the comments because how comments are treated in Treesitter
			if direction == "prev" then
				target = target:prev_named_sibling()
			else
				target = target:next_named_sibling()
			end
		end
	end

	if target ~= nil then
		if move == true then
			ts_utils.swap_nodes(node, target, bufnr, true)

			if mode == "visual" then
				target = ts_utils.get_node_at_cursor()
				ts_utils.update_selection(bufnr, target)
				ts_utils.update_selection(bufnr, target)
			end
		else
			ts_utils.update_selection(bufnr, target) --> make the selection
			if mode == "visual" then
				ts_utils.update_selection(bufnr, target)
			end
		end
	end
end --}}}

M.select_current_node = function() --{{{
	local node = ts_utils.get_node_at_cursor()
	local bufnr = vim.api.nvim_get_current_buf()

	if node ~= nil then
		ts_utils.update_selection(bufnr, node)
	end
end --}}}

---

M.jump_to_current_node = function(start_or_end)
	local node = ts_utils.get_node_at_cursor()
	ts_utils.goto_node(node, start_or_end, true)
end

---

local function get_master_node(block_check) --{{{
	local node = ts_utils.get_node_at_cursor()
	if node == nil then
		error("No Treesitter parser found")
	end

	local root = ts_utils.get_root_for_node(node)

	local start_row = node:start()
	local parent = node:parent()

	while parent ~= nil and parent ~= root and parent:start() == start_row do
		if block_check and parent:type() == "block" then
			break
		end

		node = parent
		parent = node:parent()
		-- print(node:type())
	end

	return node
end --}}}

M.select = function() --{{{
	local node = get_master_node()
	local bufnr = vim.api.nvim_get_current_buf()

	ts_utils.update_selection(bufnr, node)
end --}}}

M.move = function(mode, up) --{{{
	local node = get_master_node(true)
	local bufnr = vim.api.nvim_get_current_buf()

	local target
	if up == true then
		target = node:prev_named_sibling()
	else
		target = node:next_named_sibling()
	end

	if target == nil then
		return
	end

	while target:type() == "comment" do
		if up == true then
			target = target:prev_named_sibling()
		else
			target = target:next_named_sibling()
		end
	end

	if target ~= nil then
		ts_utils.swap_nodes(node, target, bufnr, true)

		if mode == "v" then
			target = ts_utils.get_node_at_cursor()
			ts_utils.update_selection(bufnr, target)
			ts_utils.update_selection(bufnr, target)
		end
	end
end --}}}

--! Create User Commands for 1.0 functionalities !{{{

-- Swap in Normal Mode
vim.api.nvim_create_user_command("STSSwapUpNormal", function()
	M.move("n", true)
end, {})
vim.api.nvim_create_user_command("STSSwapDownNormal", function()
	M.move("n", false)
end, {})
vim.api.nvim_create_user_command("STSSwapCurrentNodePrevNormal", function()
	M.surf("prev", "normal", true)
end, {})
vim.api.nvim_create_user_command("STSSwapCurrentNodeNextNormal", function()
	M.surf("next", "normal", true)
end, {})

-- Select Node from Normal Mode
vim.api.nvim_create_user_command("STSSelectCurrentNode", function()
	M.select_current_node()
end, {})
vim.api.nvim_create_user_command("STSSelectMasterNode", function()
	M.select()
end, {})

-- Jump to Node in Normal Mode
vim.api.nvim_create_user_command("STSJumpToStartOfCurrentNode", function()
	M.jump_to_current_node(false)
end, {})
vim.api.nvim_create_user_command("STSJumpToEndOfCurrentNode", function()
	M.jump_to_current_node(true)
end, {})

-- Select Node from Visual Mode
vim.api.nvim_create_user_command("STSSelectParentNode", function()
	M.surf("parent", "visual")
end, {})
vim.api.nvim_create_user_command("STSSelectChildNode", function()
	M.surf("child", "visual")
end, {})
vim.api.nvim_create_user_command("STSSelectPrevSiblingNode", function()
	M.surf("prev", "visual")
end, {})
vim.api.nvim_create_user_command("STSSelectNextSiblingNode", function()
	M.surf("next", "visual")
end, {})

-- Swap in Visual Mode
vim.api.nvim_create_user_command("STSSwapNextVisual", function()
	M.surf("next", "visual", true)
end, {})
vim.api.nvim_create_user_command("STSSwapPrevVisual", function()
	M.surf("prev", "visual", true)
end, {}) --}}}

-- Global Variables for Normal Swap Dot Repeat{{{
_G.STSSwapCurrentNodePrevNormal_Dot = function()
	vim.cmd("STSSwapCurrentNodePrevNormal")
end
_G.STSSwapCurrentNodeNextNormal_Dot = function()
	vim.cmd("STSSwapCurrentNodeNextNormal")
end
_G.STSSwapUpNormal_Dot = function()
	vim.cmd("STSSwapUpNormal")
end
_G.STSSwapDownNormal_Dot = function()
	vim.cmd("STSSwapDownNormal")
end --}}}

--- version 1.1

local function get_top_node() --{{{
	local node = ts_utils.get_node_at_cursor()
	if node == nil then
		error("No Treesitter parser found")
	end

	local root = ts_utils.get_root_for_node(node)

	local start_row = node:start()
	local parent = node:parent()

	while parent ~= nil and parent ~= root do
		node = parent
		parent = node:parent()
	end

	return node
end --}}}

local function go_to_top_node(go_to_end) --{{{
	local node = get_top_node()
	ts_utils.goto_node(node, go_to_end)
end --}}}

M.go_to_top_node_and_execute_commands = function(go_to_end, list_of_commands) --{{{
	go_to_top_node(go_to_end)

	-- I want to create a function at the top level
	vim.schedule(function()
		for _, command in ipairs(list_of_commands) do
			vim.cmd(command)
		end
	end)
end --}}}

M.go_to_node_and_execute_commands = function(node, go_to_end, list_of_commands) --{{{
	ts_utils.goto_node(node, go_to_end)

	-- I want to create a function at the top level
	vim.schedule(function()
		for _, command in pairs(list_of_commands) do
			command()
		end
	end)
end --}}}

M.get_master_node = get_master_node

-- version 2.0 Beta --

-- Imports & Aliases{{{
M.opts = {
	disable_no_instance_found_report = false,
	highlight_group = "STS_highlight",
}

vim.cmd(":highlight STS_highlight guifg=#00F1F5")

local api = vim.api
local ns = api.nvim_create_namespace("tree_testing_ns")

local current_desired_types = {
	"function",
	"if_statement",
	"else_clause",
	"else_statement",
	"elseif_statement",
	"for_statement",
	"while_statement",
	"switch_statement",
} -- default desired types }}}

-- Dictionary{{{
M.opts.icon_dictionary = {
	["if_statement"] = "",
	["else_clause"] = "",
	["else_statement"] = "",
	["elseif_statement"] = "",
	["for_statement"] = "ﭜ",
	["while_statement"] = "ﯩ",
	["switch_statement"] = "ﳟ",
	["function"] = "",
	["variable_declaration"] = "",
	["comment"] = "",
}

-- Possible keymaps for jumping
M.opts.left_hand_side = "fdsawervcxqtzb"
M.opts.left_hand_side = vim.split(M.opts.left_hand_side, "")
M.opts.right_hand_side = "jkl;oiu.,mpy/n"
M.opts.right_hand_side = vim.split(M.opts.right_hand_side, "") --}}}

-- Utils (Getters)
local function recursive_child_iter(node, table_to_insert, desired_types) -- {{{
	if node:iter_children() then
		for child in node:iter_children() do
			if desired_types then
				if vim.tbl_contains(desired_types, child:type()) then
					table.insert(table_to_insert, child)
				end
			else
				table.insert(table_to_insert, child)
			end

			recursive_child_iter(child, table_to_insert, desired_types)
		end
	end
end --}}}
local function filter_children_recursively(node, desired_types) --{{{
	local children = {}

	recursive_child_iter(node, children, desired_types)

	return children
end --}}}

local function get_nodes_in_array() --{{{
	local ts = vim.treesitter
	local parser = ts.get_parser(0)
	local trees = parser:parse()
	local root = trees[1]:root()

	local current_buffer = vim.api.nvim_get_current_buf()
	local nodes = {}

	recursive_child_iter(root, nodes)

	return nodes
end --}}}
local function get_desired_nodes(nodes, desired_types) --{{{
	-- get current cursor position
	local return_nodes = {}

	-- loop through nodes
	for i = 1, #nodes do
		local node = nodes[i]
		local node_type = node:type()
		local start_row, start_col, end_row, end_col = node:range()

		-- if node_type is in desired_types, add to return_nodes
		if vim.tbl_contains(desired_types, node_type) then
			table.insert(return_nodes, node)
		end
	end

	return return_nodes
end --}}}

local function filter_sibling_nodes(node, desired_types) --{{{
	local current_node_id = node:id()
	local parent = node:parent()
	local return_nodes = {}

	for child in parent:iter_children() do
		if child:id() ~= current_node_id then
			local node_type = child:type()

			if vim.tbl_contains(desired_types, node_type) then
				table.insert(return_nodes, child)
			end
		end
	end

	return return_nodes
end --}}}
local function filter_nearest_parent(node, desired_types) --{{{
	if node:parent() then
		local parent = node:parent()
		local parent_type = parent:type()

		if vim.tbl_contains(desired_types, parent_type) then
			return parent
		else
			return filter_nearest_parent(parent, desired_types)
		end
	else
		return nil
	end
end --}}}

local function get_parent_nodes(node, desired_types) --{{{
	local parents = {}

	while node:parent() do
		node = node:parent()
		local node_type = node:type()

		if vim.tbl_contains(desired_types, node_type) then
			table.insert(parents, node)
		end
	end

	return parents
end --}}}
local function set_extmark_then_delete_it(start_row, start_col, contents, color_group, timeout) --{{{
	-- if start_col <= 0 then
	-- 	start_col = 1
	-- end

	if not contents then
		contents = ""
	end

	local extmark_id = api.nvim_buf_set_extmark(0, ns, start_row, start_col - 0, {
		virt_text = { { contents, color_group } },
		virt_text_pos = "overlay",
	})

	local timer = vim.loop.new_timer()
	timer:start(
		timeout,
		timeout,
		vim.schedule_wrap(function()
			api.nvim_buf_del_extmark(0, ns, extmark_id)
		end)
	)

	return extmark_id
end --}}}

local function has_value(tab, val) --{{{
	for index, value in ipairs(tab) do
		if value == val then
			return true
		end
	end

	return false
end --}}}

-- Functions to Execute --
local function print_types(desired_types) -- {{{
	current_desired_types = desired_types

	local nodes = get_nodes_in_array()

	local current_window = api.nvim_get_current_win()
	local current_line = vim.api.nvim_win_get_cursor(current_window)[1]

	local nodes_before_cursor = {}
	local nodes_after_cursor = {}

	local hash_table = {}

	for _, node in ipairs(nodes) do
		local start_row, start_col, end_row, end_col = node:range()

		if start_row + 1 < current_line then
			table.insert(nodes_before_cursor, node)
		elseif start_row + 1 > current_line then
			table.insert(nodes_after_cursor, node)
		end
	end

	local color_group = M.opts.highlight_group

	-- loop backwards through nodes_before_cursor
	local count = 1
	for i = #nodes_before_cursor, 1, -1 do
		local node = nodes_before_cursor[i]
		local node_type = node:type()
		local start_row, start_col = node:range()

		if not M.opts.left_hand_side[count] then
			break
		end

		if has_value(desired_types, node_type) then
			if start_col - 1 < 0 then
				start_col = 0
			else
				-- start_col = start_col - 1
				start_col = start_col
			end
			api.nvim_buf_set_extmark(0, ns, start_row, start_col, {
				virt_text = { { M.opts.left_hand_side[count], color_group } },
				virt_text_pos = "overlay",
			})

			api.nvim_buf_set_extmark(0, ns, start_row, -1, {
				virt_text = { { " " .. M.opts.left_hand_side[count] .. " <-- " .. node_type, color_group } },
				virt_text_pos = "eol",
			})

			hash_table[M.opts.left_hand_side[count]] = {}
			hash_table[M.opts.left_hand_side[count]].start_row = start_row
			hash_table[M.opts.left_hand_side[count]].start_col = start_col

			count = count + 1
		end
	end

	count = 1
	for i = 1, #nodes_after_cursor do
		local node = nodes_after_cursor[i]
		local node_type = node:type()
		local start_row, start_col = node:range()

		if not M.opts.right_hand_side[count] then
			break
		end

		if has_value(desired_types, node_type) then
			if start_col - 1 < 0 then
				start_col = 0
			else
				-- start_col = start_col - 1
				start_col = start_col
			end
			api.nvim_buf_set_extmark(0, ns, start_row, start_col, {
				virt_text = { { M.opts.right_hand_side[count], color_group } },
				virt_text_pos = "overlay",
			})

			api.nvim_buf_set_extmark(0, ns, start_row, -1, {
				virt_text = { { " " .. M.opts.right_hand_side[count] .. " <-- " .. node_type, color_group } },
				virt_text_pos = "eol",
			})

			hash_table[M.opts.right_hand_side[count]] = {}
			hash_table[M.opts.right_hand_side[count]].start_row = start_row
			hash_table[M.opts.right_hand_side[count]].start_col = start_col

			count = count + 1
		end
	end

	vim.cmd([[redraw]])

	local ok, keynum = pcall(vim.fn.getchar)
	if ok then
		local key = string.char(keynum)
		if hash_table[key] then
			local start_row = hash_table[key].start_row + 1
			local start_col = hash_table[key].start_col

			vim.api.nvim_win_set_cursor(current_window, { start_row, start_col })
		end
	end

	api.nvim_buf_clear_namespace(0, ns, 0, -1)
end --}}}
local function go_to_next_instance(desired_types, forward, opts) --{{{
	if desired_types == "default" then
		desired_types = current_desired_types
	end

	-- get nodes to operate on
	local nodes = get_nodes_in_array()

	-- get cursor position
	local current_window = api.nvim_get_current_win()
	local current_line = vim.api.nvim_win_get_cursor(current_window)[1]

	-- set up variables
	local previous_closest_node = nil
	local next_closest_node = nil
	local previous_closest_node_line = nil
	local next_closest_node_line = nil

	local previous_closest_node_index = nil
	local next_closest_node_index = nil

	if nodes then
		-- filter the nodes based on the opts
		if opts then
			local current_node = ts_utils.get_node_at_cursor(current_window)

			if opts.destination == "parent" then
				nodes = get_parent_nodes(current_node, desired_types)
				previous_closest_node = nodes[1]
				previous_closest_node_index = 1
			end

			if opts.destination == "children" then
				nodes = filter_children_recursively(current_node, desired_types)
			end

			if opts.destination == "siblings" then
				nodes = filter_sibling_nodes(current_node, desired_types)

				if #nodes == 0 then
					nodes = {}
					-- if the current node type is in desired_types, then don't filter
					if not vim.tbl_contains(desired_types, current_node:type()) then
						previous_closest_node = filter_nearest_parent(current_node, desired_types)
						previous_closest_node_index = 1
					end
				end
			end
		else
			nodes = get_desired_nodes(nodes, desired_types)
		end

		-- find closest nodes before & after cursor
		for index, node in ipairs(nodes) do
			local start_row, start_col, end_row, end_col = node:range()

			-- TODO:: change the logic here
			if start_row + 1 < current_line then
				if previous_closest_node == nil then
					previous_closest_node = node
					previous_closest_node_line = start_row
					previous_closest_node_index = index
				elseif previous_closest_node_line and start_row > previous_closest_node_line then
					previous_closest_node = node
					previous_closest_node_index = index
				end
			elseif start_row + 1 > current_line then
				if next_closest_node == nil then
					next_closest_node = node
					next_closest_node_line = start_row
					next_closest_node_index = index
				elseif next_closest_node_line and start_row < next_closest_node_line then
					next_closest_node = node
					next_closest_node_index = index
				end
			end
		end
	end

	-- depends on forward or not, set cursor to closest node
	local cursor_moved = false
	if forward then
		if next_closest_node then
			local start_row, start_col, end_row, end_col = next_closest_node:range()
			vim.api.nvim_win_set_cursor(current_window, { start_row + 1, start_col })
			cursor_moved = true
		end
	else
		if previous_closest_node then
			local start_row, start_col, end_row, end_col = previous_closest_node:range()
			vim.api.nvim_win_set_cursor(current_window, { start_row + 1, start_col })
			cursor_moved = true
		end
	end

	-- if there is no next instance, print message
	if not cursor_moved then
		if not M.opts.disable_no_instance_found_report then
			if forward then
				print("No next instance found")
			else
				print("No previous instance found")
			end
		end
	else -- if cursor moved
		if not opts then
			if forward then
				while next_closest_node_index + 1 <= #nodes do
					local start_row, start_col = nodes[next_closest_node_index + 1]:range()
					set_extmark_then_delete_it(
						start_row,
						start_col,
						M.opts.icon_dictionary[nodes[next_closest_node_index + 1]:type()],
						M.opts.highlight_group,
						800
					)
					next_closest_node_index = next_closest_node_index + 1
				end
			else
				while previous_closest_node_index - 1 >= 1 do
					local start_row, start_col = nodes[previous_closest_node_index - 1]:range()
					set_extmark_then_delete_it(
						start_row,
						start_col,
						M.opts.icon_dictionary[nodes[previous_closest_node_index - 1]:type()],
						M.opts.highlight_group,
						800
					)
					previous_closest_node_index = previous_closest_node_index - 1
				end
			end
		end
	end
end --}}}

-- Methods to return {{{
M.filtered_jump = go_to_next_instance
M.targeted_jump = print_types --}}}
-- Setup Function{{{
M.setup = function(opts)
	if opts then
		for key, value in pairs(opts) do
			if key == "default_desired_types" then
				current_desired_types = value
			else
				M.opts[key] = value

				if key == "left_hand_side" then
					M.opts.left_hand_side = vim.split(value, "")
				elseif key == "right_hand_side" then
					M.opts.right_hand_side = vim.split(value, "")
				end
			end
		end
	end
end --}}}

-- version 2.1

local function get_raw_parent_nodes(node) --{{{
	local parents = {}

	while node:parent() do
		node = node:parent()

		table.insert(parents, node)
	end

	return parents
end --}}}

local function print_nodes_at_cursor() --{{{
	local current_node = ts_utils.get_node_at_cursor()

	local parents = get_raw_parent_nodes(current_node)

	local types = { current_node:type() }
	for _, node in ipairs(parents) do
		table.insert(types, node:type())
	end

	print(vim.inspect(types))
end --}}}

vim.api.nvim_create_user_command("STSPrintNodesAtCursor", function()
	print_nodes_at_cursor()
end, {})

return M

-- vim: foldmethod=marker foldmarker={{{,}}} foldlevel=0
