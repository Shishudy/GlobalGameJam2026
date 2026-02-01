levels = {}
current_level = 1

-- scan the map for up to 5 levels of 16x16 tiles
function parse_levels()
	local level_count = 0

	-- assume map is horizontally laid out (adjust if vertical)
	local map_w, map_h = 128, 64

	-- loop through map in 16x16 blocks
	for ly = 0, flr(map_h / 16) - 1 do
		for lx = 0, flr(map_w / 16) - 1 do
			if level_count >= 5 then
				return
			end

			local level = { obstacles = {}, enemies = {}, player = nil }

			for y = 0, 16 - 1 do
				for x = 0, 16 - 1 do
					local map_x = lx * 16 + x
					local map_y = ly * 16 + y
					local t = mget(map_x, map_y)

					-- define tile types (adjust numbers to your map)
					if t == 1 then
						level.player = { x = x, y = y, sprite_number = t }
					elseif t >= 2 and t <= 7 then
						add(level.obstacles, { x = x, y = y, sprite_number = t })
					elseif t >= 8 and t <= 15 then
						add(level.enemies, { x = x, y = y, sprite_number = t })
					end
				end
			end

			add(levels, level)
			level_count += 1
		end
	end
end

function load_next_level()
	local button_pressed = btn(4)
	if is_button_pressed and not button_pressed then
		current_level += 1
	end
	is_button_pressed = button_pressed
end
