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
		b.x += b.dx
		b.y += b.dy
	end
end

function drawBullets()
	for b in all(bullets) do
		circfill(b.x, b.y, 1, 7)
	end
end