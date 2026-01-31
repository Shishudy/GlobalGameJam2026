 
player = {
	x = 5,
	y = 5,
	spriteW = 1,
	spriteH = 1,
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
		0			--alpha color
	)
end

function updatePlayer()
	player.directionX = 0
	player.directionY = 0

	if btn(⬅️) then
		if (not btn(4)) player.velocityX -= player.acceleration 
		player.directionX = 1
	end
	if btn(➡️) then
		if (not btn(4)) player.velocityX += player.acceleration 
		player.directionX = -1
	end
	if btn(⬆️) then
		if (not btn(4)) player.velocityY -= player.acceleration 
		player.directionY = -1
	end
	if btn(⬇️) then
		if (not btn(4)) player.velocityY += player.acceleration 
		player.directionY = 1
	end

	if (player.directionX != 0 or player.directionY != 0) player.aimTarget = atan2(player.directionY, player.directionX) * 360
	player.aimLock = isAiming()

	player.aimSpeed = 0.5
	if (player.aimLock) player.aimSpeed = 0.1
	player.aimDirection = lerp_angle(player.aimDirection, player.aimTarget, player.aimSpeed)

	-- move (add velocity)
	player.x += player.velocityX
	player.y += player.velocityY

	-- friction (lower for more)
	player.velocityX *= .8
	player.velocityY *= .8
end

function isAiming()
	return (player.directionX == 0 and player.directionY == 0 or btn(4))
end

