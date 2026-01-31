 
player = {
	x = 64,
	y = 64,
	spriteW = 1,
	spriteH = 1,
	collisionSizeX = 3,
	collisionSizeY = 3,
	velocityX = 0,
	velocityY = 0,
	sprite = 0,
	acceleration = 0.4,
	directionX = 1,
	directionY = 0,
	aimTarget = 0,
	aimDirection = 0,
	aimSpeed = 0.6,
	aimLock = false
}

prevShootinBtn = false

function drawPlayer()
	-- draw the player
	spr(
		128, -- frame index
		player.x, player.y, -- x,y (pixels)
		player.spriteW, player.spriteH -- w,h
	)

	spr_rotate(
		133,
		player.x + player.spriteW * 8 / 2, player.y + player.spriteH * 8 / 4, player.aimDirection,
		2, 2, --wh
		0.5, 0.5, --pivot
		0 --alpha color
	)

end

function updatePlayer()
	player.directionX = 0
	player.directionY = 0

	--read inputs
	if btn(⬅️) then
		if (not btn(4)) then player.velocityX -= player.acceleration end
		player.directionX = -1
	end
	if btn(➡️) then
		if (not btn(4)) then player.velocityX += player.acceleration end
		 player.directionX = 1
	end
	if btn(⬆️) then
		if (not btn(4)) then player.velocityY -= player.acceleration end
		player.directionY = -1
	end
	if btn(⬇️) then
		if (not btn(4)) then player.velocityY += player.acceleration end
		player.directionY = 1
	end
	
	-- checks walls / move
	if (not check_space_collision(
		player.x + player.velocityX + player.spriteW*4,
		player.y + player.spriteH*4,
		player.collisionSizeX, player.collisionSizeY)) and
		0 < player.x + player.velocityX and player.x + player.velocityX < 120 then

		player.x += player.velocityX
	end
	if (not check_space_collision(
		player.x + player.spriteW*4, 
		player.y + player.velocityY + player.spriteH*4, 
		player.collisionSizeX, player.collisionSizeY)) and
		0 < player.y + player.velocityY and player.y + player.velocityY < 120 then
		player.y += player.velocityY
	end

	-- friction (lower for more)
	player.velocityX *= 0.8
	player.velocityY *= 0.8

	--shooting
	local curShootingBTN = btn(4)
	if prevShootinBtn and not curShootingBTN then
		local shootingAngle = (player.aimDirection - 90) / 360
		spawnBullet(
			player.x + 4 + 8 * cos(shootingAngle),
			player.y + 4 + 8 * sin(shootingAngle),
			cos(shootingAngle),
			sin(shootingAngle)
		)
	end
	prevShootinBtn = curShootingBTN

	if (player.directionX != 0 or player.directionY != 0) player.aimTarget = atan2(player.directionY, player.directionX * -1) * 360
	player.aimLock = isAiming()

	player.aimSpeed = 0.5
	if (player.aimLock) player.aimSpeed = 0.1
	player.aimDirection = lerp_angle(player.aimDirection, player.aimTarget, player.aimSpeed)

	
end

function isAiming()
	return (btn(4))
end

