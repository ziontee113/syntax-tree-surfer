local ts_utils = require("nvim-treesitter.ts_utils")

local M = {}

local function find_range_from_2nodes(nodeA, nodeB)
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
end

M.surf = function(direction, mode, move)
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
end

M.select_current_node = function()
	local node = ts_utils.get_node_at_cursor()
	local bufnr = vim.api.nvim_get_current_buf()

	if node ~= nil then
		ts_utils.update_selection(bufnr, node)
	end
end

---

local function get_master_node(block_check)
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
end

M.select = function()
	local node = get_master_node()
	local bufnr = vim.api.nvim_get_current_buf()

	ts_utils.update_selection(bufnr, node)
end

M.move = function(mode, up)
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
end

return M
