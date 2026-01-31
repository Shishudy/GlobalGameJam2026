function k(tx, ty)
	return tx .. "|" .. ty
end

function contains_pair(list, tx, ty)
	for i = 1, #list do
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
	if tx < 0 then
		tx = 0
	elseif tx > 15 then
		tx = 15
	end
	if ty < 0 then
		ty = 0
	elseif ty > 15 then
		ty = 15
	end
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

function ang_deg(x, y, px, py)
	-- angles of the two pixels from the player perspective
	local a = atan2(y - py, x - px) * 360
	if a < 0 then a += 360 end
	return a
end

function pelogen_tri_hvb(l, t, c, m, r, b, col)
	color(col)
	local a = rectfill
	::_w_::
	if (t > m) then l, t, c, m = c, m, l, t end
	if (m > b) then c, m, r, b = r, b, c, m end
	if (t > m) then l, t, c, m = c, m, l, t end
	local q, p = l, c
	if (q < c) then q = c end
	if (q < r) then q = r end
	if (p > l) then p = l end
	if (p > r) then p = r end
	if b - t > q - p then
		l, t, c, m, r, b, col = t, l, m, c, b, r
		goto _w_
	end

	local e, j, i = l, (r - l) / (b - t)
	while m do
		i = (c - l) / (m - t)
		local f = m \ 1 - 1
		f = f > 127 and 127 or f
		if (t < 0) then t, l, e = 0, l - i * t, b and e - j * t or e end
		if col then
			for t = t \ 1, f do
				a(l, t, e, t)
				l = i + l
				e = j + e
			end
		else
			for t = t \ 1, f do
				a(t, l, t, e)
				l = i + l
				e = j + e
			end
		end
		l, t, m, c, b = c, m, b, r
	end
	if i < 8 and i > -8 then
		if col then
			pset(r, t)
		else
			pset(t, r)
		end
	end
end

function object_has_collision(x, y)
    -- Uses tile index(need to divide pixels by 8 and use floor)
    if x < 0 or x > MAP_W - 1 or y < 0 or y > MAP_H - 1 then
        return false
    end
    local id = mget(x, y)
    local shadow_flags = { 0, 1 }
    for f in all(shadow_flags) do
        if fget(id, f) then return true end
    end
    return false
end


function qsort(a, c, l, r)
	-- qsort(a,c,l,r)
	--
	-- a
	--    array to be sorted,
	--    in-place
	-- c
	--    comparator function(a,b)
	--    (default=return a<b)
	-- l
	--    first index to be sorted
	--    (default=1)
	-- r
	--    last index to be sorted
	--    (default=#a)
	--
	-- typical usage:
	--   qsort(array)
	--   -- custom descending sort
	--   qsort(array,function(a,b) return a>b end)
	--
	c, l, r = c or function(a, b) return a < b end, l or 1, r or #a
	if l < r then
		if c(a[r], a[l]) then
			a[l], a[r] = a[r], a[l]
		end
		local lp, k, rp, p, q = l + 1, l + 1, r - 1, a[l], a[r]
		while k <= rp do
			local swaplp = c(a[k], p)
			-- "if a or b then else"
			-- saves a token versus
			-- "if not (a or b) then"
			if swaplp or c(a[k], q) then
			else
				while c(q, a[rp]) and k < rp do
					rp -= 1
				end
				a[k], a[rp], swaplp = a[rp], a[k], c(a[rp], p)
				rp -= 1
			end
			if swaplp then
				a[k], a[lp] = a[lp], a[k]
				lp += 1
			end
			k += 1
		end
		lp -= 1
		rp += 1
		-- sometimes lp==rp, so
		-- these two lines *must*
		-- occur in sequence;
		-- don't combine them to
		-- save a token!
		a[l], a[lp] = a[lp], a[l]
		a[r], a[rp] = a[rp], a[r]
		qsort(a, c, l, lp - 1)
		qsort(a, c, lp + 1, rp - 1)
		qsort(a, c, rp + 1, r)
	end
end


function lerp_angle(a, b, t)
	local diff = (b - a + 540) % 360 - 180
	return (a + diff * t) % 360
end

function check_location_collision(x, y)
	val = mget(flr(x / 8),flr(y/8))
	return fget(val, 0)
	-- change tag number
end

function check_space_collision(x, y, w, h)
	return check_location_collision(x - w, y - h)
			or check_location_collision(x + w, y - h)
			or check_location_collision(x - w, y + h)
			or check_location_collision(x + w, y + h)
end