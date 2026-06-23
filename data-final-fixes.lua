local min = math.min
local max = math.max

--helpers.write_file("grounded-tree-selection-box.txt", {"", "----------------------------------------\n"})

local size_basis = settings.startup["grounded-tree-selection-box-size-basis"].value
local position = settings.startup["grounded-tree-selection-box-position"].value
local shape = settings.startup["grounded-tree-selection-box-shape"].value
local horizontal_padding = settings.startup["grounded-tree-selection-box-horizontal-padding"].value
local vertical_padding = settings.startup["grounded-tree-selection-box-vertical-padding"].value
local static_minimum_width = settings.startup["grounded-tree-selection-box-static-minimum-width"].value
local static_minimum_height = settings.startup["grounded-tree-selection-box-static-minimum-height"].value
local static_maximum_width = settings.startup["grounded-tree-selection-box-static-maximum-width"].value
local static_maximum_height = settings.startup["grounded-tree-selection-box-static-maximum-height"].value
local growable_minimum_width = settings.startup["grounded-tree-selection-box-growable-minimum-width"].value
local growable_minimum_height = settings.startup["grounded-tree-selection-box-growable-minimum-height"].value
local growable_maximum_width = settings.startup["grounded-tree-selection-box-growable-maximum-width"].value
local growable_maximum_height = settings.startup["grounded-tree-selection-box-growable-maximum-height"].value

local function is_empty_box(box)
	return box[1][1] == box[2][1] or box[1][2] == box[2][2]
end

local function lerp(a, b, t)
	return (a * (1.0 - t)) + (b * t)
end

local function calculate_new_size(basis_box, is_growable)
	local basis_width = basis_box[2][1] - basis_box[1][1]
	local basis_height = basis_box[2][2] - basis_box[1][2]
	local new_width = basis_width + horizontal_padding * 2
	local new_height = basis_height + vertical_padding * 2

	if shape == "small-square" then
		new_width = min(new_width, new_height)
		new_height = new_width
	elseif shape == "large-square" then
		new_width = max(new_width, new_height)
		new_height = new_width
	end

	local min_w = is_growable and growable_minimum_width or static_minimum_width
	local min_h = is_growable and growable_minimum_height or static_minimum_height
	local max_w = is_growable and growable_maximum_width or static_maximum_width
	local max_h = is_growable and growable_maximum_height or static_maximum_height

	new_width = max(min_w, new_width)
	new_height = max(min_h, new_height)

	if max_w > 0 then
		new_width = min(new_width, max_w)
	end
	if max_h > 0 then
		new_height = min(new_height, max_h)
	end

	return new_width, new_height
end

local function update_box(target_box, new_width, new_height, basis_box, lerp_x, lerp_y)
	local anchor_x = lerp(basis_box[1][1], basis_box[2][1], lerp_x)
	local anchor_y = lerp(basis_box[1][2], basis_box[2][2], lerp_y)

	target_box[1][1] = anchor_x - new_width * lerp_x
	target_box[1][2] = anchor_y - new_height * lerp_y
	target_box[2][1] = anchor_x + new_width * (1.0 - lerp_x)
	target_box[2][2] = anchor_y + new_height * (1.0 - lerp_y)
end

local function process_entity_prototype(prototype)
	local c_box = prototype.collision_box
	local s_box = prototype.selection_box
	if c_box == nil or s_box == nil or is_empty_box(c_box) or is_empty_box(s_box) then
		return
	end

	--local d_box = {{ c_box[1][1] - s_box[1][1], c_box[1][2] - s_box[1][2] }, { c_box[2][1] - s_box[2][1], c_box[2][2] - s_box[2][2] }}
	--helpers.write_file("grounded-tree-selection-box.txt", {"", tree_name, ":\n"}, true)
	--helpers.write_file("grounded-tree-selection-box.txt", {"", "\tcollision_box: {{ ", c_box[1][1], ", ", c_box[1][2], " }, { ", c_box[2][1], ", ", c_box[2][2], " }}\n"}, true)
	--helpers.write_file("grounded-tree-selection-box.txt", {"", "\tselection_box: {{ ", s_box[1][1], ", ", s_box[1][2], " }, { ", s_box[2][1], ", ", s_box[2][2], " }}\n"}, true)
	--helpers.write_file("grounded-tree-selection-box.txt", {"", "\tdifference:    {{ ", d_box[1][1], ", ", d_box[1][2], " }, { ", d_box[2][1], ", ", d_box[2][2], " }}\n"}, true)

	local basis_box = (size_basis == "collision-box" and c_box or s_box)
	local is_growable = (prototype.type == "plant" and prototype.growth_ticks ~= nil)
	local new_width, new_height = calculate_new_size(basis_box, is_growable)
	if position == "centered-on-entity" then
		update_box(s_box, new_width, new_height, {{0,0}, {0,0}}, 0, 0)
	elseif position == "centered-on-collision-box" then
		update_box(s_box, new_width, new_height, c_box, 0.5, 0.5)
	elseif position == "grounded-on-collision-box" then
		update_box(s_box, new_width, new_height, c_box, 0.5, 1.0)
	elseif position == "grounded-on-original-selection-box" then
		update_box(s_box, new_width, new_height, s_box, 0.5, 1.0)
	end
end

if data.raw.tree ~= nil then
	for tree_name, tree_prototype in pairs(data.raw.tree) do
		process_entity_prototype(tree_prototype)
	end
end

if data.raw.plant ~= nil then
	for plant_name, plant_prototype in pairs(data.raw.plant) do
		process_entity_prototype(plant_prototype)
	end
end

