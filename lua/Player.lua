player = {
	x = 64,
	y = 64,
	spriteW = 1,
	spriteH = 1,
	frame = 0,
	mask = 0,
	maskMax = 8,
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
	maxBullets = 6,
	currentBullet = 6,
	reloading = false,
	reloadingTime = 30
}

local prevMaskBTN = false
local prevShootinBtn = false
local maskBtnTime = 0
local currentReloadTime = 0

function drawPlayer()
	-- draw the player
	spr(
		32 + player.frame, -- frame index
		player.x, player.y, -- x,y (pixels)
		player.spriteW, player.spriteH -- w,h
	)

	-- draw mask
	spr(
		1 + player.mask, -- frame index
		player.x - player.velocityX / 2 + player.maskOffsetX, player.y - 2 - player.velocityY / 2 + player.maskOffsetY, -- x,y (pixels)
		player.spriteW, player.spriteH -- w,h
	)

	--aiming
	spr_rotate(
		46,
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

	if btn(5) then
		maskBtnTime += 1
		if maskBtnTime >= 10 then
			change_mask_inputs()
		else
			update_movement_inputs()
		end
	else
		maskBtnTime = 0
		update_movement_inputs()
	end

	-- checks walls / move
	if not check_space_collision(
		player.x + player.velocityX + player.spriteW * 4,
		player.y + player.spriteH * 4,
		player.collisionSizeX, player.collisionSizeY
	)
			and 0<player.x + player.velocityX and player.x + player.velocityX <120 then
		player.x += player.velocityX
	end
	if not check_space_collision(
		player.x + player.spriteW * 4,
		player.y + player.velocityY + player.spriteH * 4,
		player.collisionSizeX, player.collisionSizeY
	)
			and  0<player.y + player.velocityY and player.y + player.velocityY <120 then
		player.y += player.velocityY
	end

	-- friction (lower for more)
	player.velocityX *= 0.8
	player.velocityY *= 0.8

	--animation
	local spd = sqrt(player.velocityX * player.velocityX + player.velocityY * player.velocityY)
	player.frame = (player.frame + spd) % 4
	-- 4 frames
	if (spd < 0.05) then player.frame = 0 end

	player.maskOffsetX = cos(time())
	player.maskOffsetY = sin(time())

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
		player.currentBullet -= 1
		slow_motion()
		if (player.currentBullet == 0) then
			currentReloadTime = player.reloadingTime
			player.reloading = true
		end
	end
	prevShootinBtn = curShootingBTN

	if player.reloading then
		currentReloadTime -= 1
		if currentReloadTime <= 0 then
			player.reloading = false
			player.currentBullet = player.maxBullets
		end
	end

	if (player.directionX != 0 or player.directionY != 0) player.aimTarget = atan2(player.directionY, player.directionX * -1) * 360
	player.aimLock = isAiming()

	player.aimSpeed = 0.5
	if (player.aimLock) player.aimSpeed = 0.1
	player.aimDirection = lerp_angle(player.aimDirection, player.aimTarget, player.aimSpeed)
end

function isAiming()
	return btn(4)
end

function update_movement_inputs()
	if btn(⬅️) then
		if not btn(4) then player.velocityX -= player.acceleration end
		player.directionX = -1
	end
	if btn(➡️) then
		if not btn(4) then player.velocityX += player.acceleration end
		player.directionX = 1
	end
	if btn(⬆️) then
		if not btn(4) then player.velocityY -= player.acceleration end
		player.directionY = -1
	end
	if btn(⬇️) then
		if not btn(4) then player.velocityY += player.acceleration end
		player.directionY = 1
	end
	
	local curMaskBTN = btn(5)
    if not prevMaskBTN and curMaskBTN then
        activate_mask()
    end
    prevMaskBTN = curMaskBTN
end

local prevMaskLeftBTN = false
local prevMaskRightBTN = false

function change_mask_inputs()
	local curMaskLeftBTN = btn(⬅️)
	if not prevMaskLeftBTN and curMaskLeftBTN then
		player.mask += 1
		if player.mask > player.maskMax then
			player.mask = 0
		end
		change_pallete(player.mask)
	end
	prevMaskLeftBTN = curMaskLeftBTN

	local curMaskRightBTN = btn(➡️)
	if not prevMaskRightBTN and curMaskRightBTN then
		player.mask -= 1
		if player.mask < 0 then
			player.mask = player.maskMax
		end
		change_pallete(player.mask)
	end
	prevMaskRightBTN = curMaskRightBTN
end