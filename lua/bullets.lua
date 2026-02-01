bullets = {}

function spawnBullet(x, y, dx, dy)
	add(
		bullets, {
			x = x,
			y = y,
			dx = dx,
			dy = dy
		}
	)
end

function updateBullets()
	for b in all(bullets) do
		if check_space_collision(b.x + b.dx, b.y + b.dy, 1, 1)
				or b.x > MAP_W_MAX * 8 or b.x < MAP_W_MIN * 8 or b.y > MAP_H_MAX * 8 or b.y < MAP_H_MIN * 8 then
			del(bullets, b)
		else
			if check_location_collision(b.x, b.y, 2) then
				current_targets_destroyed += 1
				mset(flr(b.x / 8), flr(b.y / 8), 0)
				del(bullets, b)
			else
				b.x += b.dx
				b.y += b.dy
			end
		end
	end
end

function drawBullets()
	for b in all(bullets) do
		circfill(b.x, b.y, 1, negativeMaskColor)
	end
	print(current_targets_destroyed)
end