function k(tx,ty)
  return tx.."|"..ty
end

function contains_pair(list, tx, ty)
  for i=1,#list do
    local p = list[i]
    if p[1] == tx and p[2] == ty then
      return true
    end
  end
  return false
end

function tile_at_pixel(x, y)
  local tx = flr(x / TILE)
  local ty = flr(y / TILE)
  -- clamp to map bounds
  if tx < 0 then tx = 0 elseif tx > 15 then tx = 15 end
  if ty < 0 then ty = 0 elseif ty > 15 then ty = 15 end
  return tx, ty
end

function get_tile_at_pixel(px, py)
    -- Uses pixels
    return mget(flr(px / 8), flr(py / 8))
end

function get_map_cell(unit)
    return get_tile_at_pixel(unit.x + unit.w / 2, unit.y + unit.h / 2)
end

function distance(p0x, p0y, p1x, p1y)
    -- Between 2 points
    local dx = p0x - p1x
    local dy = p0y - p1y
    return sqrt(dx * dx + dy * dy)
end

function distance_units(u0, u1)
    -- Between 2 units
    return distance(u0.x, u0.y, u1.x, u1.y)
end

function spr_rotate(s, x, y, a, w, h, px, py, col)
	w = w or 1
	h = h or 1
	px = px or 0.5
	py = py or 0.5
	col = col or 0

	local sw = w * 8
	local sh = h * 8

	local sx = (s % 16) * 8
	local sy = flr(s / 16) * 8

	-- pivot in pixels
	local ox = px * sw
	local oy = py * sh

	-- angle
	a = a / 360
	local sa = sin(a)
	local ca = cos(a)

	-- max radius (half diagonal)
	local r = sqrt(sw * sw + sh * sh)

	-- destination bounding box size
	local dw = flr(r)
	local dh = dw

	for ix = -dw, dw do
		for iy = -dh, dh do
			-- inverse rotate destination pixel
			local dx = ix
			local dy = iy

			local xx = flr(dx * ca + dy * sa + ox)
			local yy = flr(-dx * sa + dy * ca + oy)

			if (xx >= 0 and xx < sw and yy >= 0 and yy < sh) then
				local c = sget(sx + xx, sy + yy)
				if (c ~= col) pset(x + ix, y + iy, c)
			end
		end
	end
end

function lerp_angle(a, b, t)
	local diff = (b - a + 540) % 360 - 180
	return (a + diff * t) % 360
end