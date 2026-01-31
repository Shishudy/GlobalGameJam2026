

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


function object_has_shadow(x, y)
    -- Uses tile index
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

function check_outer_vertices(x1, y1)
    -- returns a list of pixel coords { {px,py}, ... } of exposed outer vertices
    local results = {}
    -- name, pixel offset within tile, and the three neighbor tiles that must be empty
    local corners = {
        {
            name = "tl",
            pix_dx = 0, pix_dy = 0,
            nbs = { { -1, 0 }, { 0, -1 }, { -1, -1 } } -- left, up, up-left
        },
        {
            name = "tr",
            pix_dx = 7, pix_dy = 0,
            nbs = { { 1, 0 }, { 0, -1 }, { 1, -1 } } -- right, up, up-right
        },
        {
            name = "bl",
            pix_dx = 0, pix_dy = 7,
            nbs = { { -1, 0 }, { 0, 1 }, { -1, 1 } } -- left, down, down-left
        },
        {
            name = "br",
            pix_dx = 7, pix_dy = 7,
            nbs = { { 1, 0 }, { 0, 1 }, { 1, 1 } } -- right, down, down-right
        }
    }

    for c in all(corners) do
        -- Skip vertices corners
        if (x1 == 0 and y1 == 0) or (x1 == 15 and y1 == 0) or (x1 == 0 and y1 == 15) or (x1 == 15 and y1 == 15) then
            goto continue_corner
        end

        -- check all three neighbor tiles around this corner dont have shadow
        local good_vertice = true
        for nb in all(c.nbs) do
            local nx = x1 + nb[1]
            local ny = y1 + nb[2]
            if object_has_shadow(nx, ny) then
                good_vertice = false
                break
            end
        end

        -- base pixel of this tile
        local base_px = x1 * 8
        local base_py = y1 * 8
        if good_vertice then
            -- Add outside offset
            add(results, { base_px + c.pix_dx + c.nbs[3][1], base_py + c.pix_dy + c.nbs[3][2] })
        end
        ::continue_corner::
    end
    return results
end

function is_vertice_visible(px, py, vx, vy, tiles)
    -- returns true if segment (px,py) -> (vx,vy) does NOT hit other part of the same object
    local dx = vx - px
    local dy = vy - py

    -- number px to cover the segment
    local steps = max(1, ceil(max(abs(dx), abs(dy))))
    local stepx = dx / steps
    local stepy = dy / steps

    local x = px
    local y = py

    -- march along the ray
    for i = 1, steps do
        x += stepx
        y += stepy

        -- close enough to vertex? then it's visible
        if abs(x - vx) < 0.5 and abs(y - vy) < 0.5 then
            return true
        end

        -- check current tile
        local tx, ty = tile_at_pixel(x, y)
        if object_has_shadow(tx, ty) and contains_pair(tiles, tx, ty) then
            return false
        end
    end
    return true
end

function get_shadow_vertices()
    for o = 1, #shadow_objects do
        local obj = shadow_objects[o]
        local tiles = obj.tiles
        local verts = obj.vertices or {}
        local visible_vertices = {}
        -- for vertice of object
        for v = 1, #verts do
            local vx, vy = verts[v][1], verts[v][2]
            local px, py = player.x, player.y

            if is_vertice_visible(px, py, vx, vy, tiles) then
                add(visible_vertices, { verts[v][1], verts[v][2] })
            end
        end
        shadow_objects[o].visible_vertices = visible_vertices
    end
end

