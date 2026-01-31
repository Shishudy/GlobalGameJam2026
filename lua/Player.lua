playerPos={}
playerVelocity={}
playerPos.x=5
playerPos.y=5
playerSpriteW=1
playerSpriteH=1
playerVelocity.x=0
playerVelocity.y=0
playerDirection={}
playerDirection.x=1
playerDirection.y=0
AimDirection=0
AimTarget=0
AimSpeed=0.6
acceleration=0.4
slowMotion=false

function _drawPlayer()
	-- draw the player
	spr(128,      -- frame index
	 playerPos.x,playerPos.y, -- x,y (pixels)
	 playerSpriteW,playerSpriteH		-- w,h
	)

	spr_rotate(133, playerPos.x + playerSpriteW*8/2, playerPos.y + playerSpriteH*8/4, AimDirection, 
	2,2,	--wh
	0.5,0.5,	--pivot
	0)

	print(isSlowMotion())
end

function _updatePlayer()

	playerDirection.x=0
	playerDirection.y=0


	if (btn(⬅️)) then 
		if (not btn(4)) playerVelocity.x-= acceleration
		playerDirection.x=1
	end
	if (btn(➡️)) then 
		if (not btn(4)) playerVelocity.x+= acceleration
		playerDirection.x=-1
	end
	if (btn(⬆️)) then
		if (not btn(4)) playerVelocity.y-= acceleration 
		playerDirection.y=-1
	end
	if (btn(⬇️)) then
		if (not btn(4)) playerVelocity.y+= acceleration 
		playerDirection.y=1
	end

	if(playerDirection.x !=0 or playerDirection.y !=0) AimTarget=atan2(playerDirection.y,playerDirection.x) * 360

	slowMotion = isSlowMotion()

	AimSpeed=0.5
	if(slowMotion) AimSpeed = 0.1

	AimDirection = lerp_angle(AimDirection, AimTarget, AimSpeed)

	-- move (add velocity)
	playerPos.x+=playerVelocity.x
	playerPos.y+=playerVelocity.y
	
	-- friction (lower for more)
	playerVelocity.x *=.8
	playerVelocity.y *=.8
end

function isSlowMotion()
	return (playerDirection.x ==0 and playerDirection.y ==0 or btn(4)) 
end


function spr_rotate(
 s, x, y, a,
 w, h,
 px, py,
 col
)
 w=w or 1
 h=h or 1
 px=px or 0.5
 py=py or 0.5
 col=col or 0

 local sw=w*8
 local sh=h*8

 local sx=(s%16)*8
 local sy=flr(s/16)*8

 -- pivot in pixels
 local ox=px*sw
 local oy=py*sh

 -- angle
 a=a/360
 local sa=sin(a)
 local ca=cos(a)

 -- max radius (half diagonal)
 local r=sqrt(sw*sw+sh*sh)

 -- destination bounding box size
 local dw=flr(r)
 local dh=dw

 for ix=-dw,dw do
  for iy=-dh,dh do
   -- inverse rotate destination pixel
   local dx=ix
   local dy=iy

   local xx=flr(dx*ca+dy*sa+ox)
   local yy=flr(-dx*sa+dy*ca+oy)

   if (xx>=0 and xx<sw and yy>=0 and yy<sh) then
    local c=sget(sx+xx,sy+yy)
    if (c~=col) pset(x+ix,y+iy,c)
   end
  end
 end
end


function lerp_angle(a, b, t)
 local diff = (b - a + 540) % 360 - 180
 return (a + diff * t) % 360
end

