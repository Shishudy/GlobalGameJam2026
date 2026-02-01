level = nil
current_level = 1

function load_level()
	local map_w = 128
	local levels_per_row = map_w / 16

	-- convert level index (1-based) to block coords
	local idx = current_level - 1

	local lvl = {
		obstacles = {},
		enemies = {},
		player = nil
	}

	-- scan the 16x16 area
	for y = 0, 15 do
		for x = 0, 15 do
			local map_x = idx * 16 + x
			local map_y = y
			local t = mget(map_x, map_y)
			-- tile definitions
			if t >= 1 and t <= 9 then
				lvl.player = {
					x = map_x * 8 % 128,
					y = map_y * 8 % 128,
					spriteW = 1,
					spriteH = 1,
					frame = 0,
					mask = t,
					maskMax = 9,
					maskOffsetX = 0,
					maskOffsetY = 0,
					collisionSizeX = 3,
					collisionSizeY = 3,
					velocityX = 0,
					velocityY = 0,
					sprite = 0,
					acceleration = 0.25,
					directionX = 1,
					directionY = 0,
					aimTarget = 0,
					aimDirection = 0,
					aimSpeed = 0.6,
					aimLock = false,
					maxBullets = 0,
					currentBullet = 0,
					reloading = false,
					reloadingTime = 30
				}
			elseif t >= 112 and t <= 113 then
				add(lvl.obstacles, { x = x, y = y, sprite_number = t })
			elseif t == 48 then
				add(lvl.enemies, { x = x, y = y, sprite_number = t })
			end
		end
	end
	lvl.player.maxBullets = #lvl.enemies or 0
	lvl.player.currentBullet = #lvl.enemies or 0
	player = lvl.player
	level = lvl
end

function load_next_level()
	if (current_targets_destroyed == #level.enemies) then
		add(time_table, timer.elapsed)
		reset_timer()
		current_level += 1
		current_targets_destroyed = 0
		load_level()
		init_shadow_objects()
		change_pallete(player.mask)
	end
end