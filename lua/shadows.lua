-- each = {tiles = {{tx,ty}, } , vertices = {{tx,ty}, } , visible_vertices = {{tx,ty}, }}
shadow_objects = {}

function init_objects()
    shadow_objects = {}
    local seen = {}

    -- 8‑way neighbor offsets
    local nb = {
        { -1, -1 }, { 0, -1 }, { 1, -1 },
        { -1, 0 }, { 1, 0 },
        { -1, 1 }, { 0, 1 }, { 1, 1 }
    }

    for ty = 0, 15 do
        for tx = 0, 15 do
            local id = mget(tx, ty)

            -- is this a shadow tile and not visited yet?
            if (fget(id, 0) or fget(id, 1)) and not seen[k(tx, ty)] then
                local obj = { tiles = {}, vertices = {} }
                local queue = { { tx, ty } }
                seen[k(tx, ty)] = true

                -- flood fill
                while #queue > 0 do
                    local t = deli(queue, 1)
                    add(obj.tiles, t)

                    local x, y = t[1], t[2]

                    -- check all 8 neighbors
                    for n in all(nb) do
                        local nx = x + n[1]
                        local ny = y + n[2]

                        -- clamp to 0..15 to avoid weird wraparound
                        if nx >= 0 and nx <= 15 and ny >= 0 and ny <= 15 then
                            local nid = mget(nx, ny)
                            if (fget(nid, 0) or fget(nid, 1)) and not seen[k(nx, ny)] then
                                seen[k(nx, ny)] = true
                                add(queue, { nx, ny })
                            end
                        end
                    end
                end

                for i = 1, #obj.tiles do
                    -- Block location
                    local px, py = obj.tiles[i][1], obj.tiles[i][2]
                    result = check_outer_vertices(px, py)
                    for r = 1, #result do
                        add(obj.vertices, result[r])
                    end
                end

                -- store final object (group of tiles and outer vertices)
                add(shadow_objects, obj)
            end
        end
    end
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
            if object_has_collision(nx, ny) then
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
        if object_has_collision(tx, ty) and contains_pair(tiles, tx, ty) then
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

function get_shadow_angles(v, tile)
    -- best 2 angles that have to include the tile, of the visible vertices
    local px, py = player.x, player.y
    local tile_x, tile_y = tile[1], tile[2]

    -- angle to tile center
    local cx, cy = tile_x * 8 + 4, tile_y * 8 + 4
    local a_ref = atan2(cy - py, cx - px) * 360
    if a_ref < 0 then a_ref += 360 end

    -- get the 2 farthest vertices and their angle
    local angles = {}
    -- {{index,distance,angle},}
    for i = 1, #v do
        local vx, vy = v[i][1], v[i][2]
        local d = distance(vx, vy, px, py)
        local a = ang_deg(vx, vy, px, py)
        add(angles, { i, d, a })
    end

    -- Sort angles by distance in descending order (farthest first)
    qsort(angles, function(a, b) return a[2] > b[2] end)
    -- Remove vertices with similar angles from the 2 selected
    while true do
        if abs(angles[1][3] - angles[2][3]) < 3 then
            del(angles, angles[2])
        else
            break
        end
    end

    local i1, a1, i2, a2 = angles[1][1], angles[1][3], angles[2][1], angles[2][3]

    -- build clockwise span [left -> right] that MUST include a_ref
    local function cw(a, b)
        return (a - b + 360) % 360
        -- clockwise distance from a to b
    end

    -- check which ordering includes the reference
    if cw(a1, a_ref) + cw(a_ref, a2) == cw(a1, a2) then
        -- a_ref lies between a1 -> a2 clockwise
        return i1, a1, i2, a2
    else
        -- must swap
        return i2, a2, i1, a1
    end
end

function adjust_vertice(x,y)
    local nbs = { { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } }
    for nb = 1, #nbs do
        local nx = x + nbs[nb][1]
        local ny = y + nbs[nb][2]
        if object_has_collision(flr(nx / 8), flr(ny / 8)) then
            return nx, ny
        end
    end
end

function draw_shadow()
    local color = 7
    get_shadow_vertices()
    all_shadows = {}
    for o = 1, #shadow_objects do
        local obj = shadow_objects[o]
        local tiles = obj.tiles
        local vertices = obj.vertices
        local vvertices = obj.visible_vertices
        if #vvertices >= 2 then
            local i1, a1, i2, a2 = get_shadow_angles(vvertices, tiles[1])
            local px, py = player.x, player.y

            local x1, y1 = vvertices[i1][1], vvertices[i1][2]
            local x2, y2 = vvertices[i2][1], vvertices[i2][2]

            -- check all all neighbor tiles around this corner for collision
            nbs = { { -1, -1 }, { 1, -1 }, { -1, 1 }, { -1, -1 } }
            local good_vertice = true

            x1, y1 = adjust_vertice(x1,y1)
            x2, y2 = adjust_vertice(x2,y2)

            local fx1, fy1 = x1 + sin(a1 / 360) * shadow_len, y1 + cos(a1 / 360) * shadow_len
            local fx2, fy2 = x2 + sin(a2 / 360) * shadow_len, y2 + cos(a2 / 360) * shadow_len

            pelogen_tri_hvb(x1, y1, x2, y2, fx1, fy1, color)
            pelogen_tri_hvb(x2, y2, fx1, fy1, fx2, fy2, color)
        end
    end
    print(stat(7), 2 * 8, 2 * 8)
end