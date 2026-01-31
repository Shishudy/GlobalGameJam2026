function _init()
    player = {
        x = flr(rnd(120)),
        y = flr(rnd(114) + 8),
        startsprite = 0,
        endsprite = 1,
        sprite = 0,
        speed = 2,
        stuck = 0,
        w = 8,
        h = 8
    }

    enemy = {
        x = flr(rnd(120)),
        y = flr(rnd(114) + 8),
        startsprite = 4,
        endsprite = 5,
        sprite = 4,
        speed = 0.1,
        stuck = 0,
        w = 8,
        h = 8
    }

    -- each = {tiles = {{tx,ty}, } , vertices = {{tx,ty}, } , visible_vertices = {{tx,ty}, }}
    shadow_objects = {}

    state = in_progress
    score = 0

    init_objects()
end

function move(unit)
    unit.sprite += 1
    if unit.sprite > unit.endsprite then
        unit.sprite = unit.startsprite
    end
end

function draw_unit(unit)
    spr(unit.sprite, unit.x, unit.y)
end

function hit_house(unit)
    return get_map_cell(unit) == map_sand_sprite
end

function move_unit(unit, direction)
    if hit_house(unit) then
        unit.stuck += 1
        if unit.stuck > 4 then
            unit.stuck = 0
        else
            return
        end
    end

    if direction == left then
        unit.x -= unit.speed
        unit.moving = true
    end
    if direction == right then
        unit.x += unit.speed
        unit.moving = true
    end
    if direction == up then
        unit.y -= unit.speed
        unit.moving = true
    end
    if direction == down then
        unit.y += unit.speed
        unit.moving = true
    end
end

function move_player()
    player.moving = false
    for i = 1, #valid_moves do
        if btn(valid_moves[i]) then
            move_unit(player, valid_moves[i])
        end
    end
    if player.moving then
        move(player)
    else
        player.sprite = player.startsprite
    end
end

function move_enemy()
    if enemy.x > player.x then move_unit(enemy, left) end
    if enemy.x < player.x then move_unit(enemy, right) end
    if enemy.y > player.y then move_unit(enemy, up) end
    if enemy.y < player.y then move_unit(enemy, down) end
    move(enemy)
    enemy.speed += 0.0005
end

function check_game_over()
    if distance_units(enemy, player) < 7 and state != game_over then
        state = start_end_game
    end
end

function _update()
    move_player()
    move_enemy()
    check_game_over()
end

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

                -- store final object (group of tiles)
                add(shadow_objects, obj)
            end
        end
    end
end

function get_angles(v, tile)
    local px, py = player.x, player.y
    local tile_x, tile_y = tile[1], tile[2]

    -- angle to tile center
    local cx, cy = tile_x*8 + 4, tile_y*8 + 4
    local a_ref = atan2(cy - py, cx - px)*360
    if a_ref < 0 then a_ref += 360 end

    -- find two farthest vertices
    local i1, i2 = 1, 1
    local d1, d2 = -1, -1
    for i=1,#v do
        local vx, vy = v[i][1], v[i][2]
        local dx, dy = vx - px, vy - py
        local dist2 = dx*dx + dy*dy
        if dist2 > d1 then
            d2, i2 = d1, i1
            d1, i1 = dist2, i
        elseif dist2 > d2 then
            d2, i2 = dist2, i
        end
    end

    -- angles of the two farthest vertices
    local function ang_deg(x,y)
        local a = atan2(y-py, x-px)*360
        if a < 0 then a += 360 end
        return a
    end

    local a1 = ang_deg(v[i1][1], v[i1][2])
    local a2 = ang_deg(v[i2][1], v[i2][2])

    -- build clockwise span [left → right] that MUST include a_ref
    local function cw(a,b)
        return (a - b + 360) % 360  -- clockwise distance from a to b
    end

    -- check which ordering includes the reference
    if cw(a1, a_ref) + cw(a_ref, a2) == cw(a1, a2) then
        -- a_ref lies between a1 → a2 clockwise
        return a1, a2
    else
        -- must swap
        return a2, a1
    end
end


function draw_shadow()
    get_shadow_vertices()
    for o = 1, #shadow_objects do
        local obj = shadow_objects[o]
        local tiles = obj.tiles
        local vertices = obj.vertices
        local vvertices = obj.visible_vertices
        local r1, r2 = get_angles(vvertices, tiles[1])
        --draw_shadow_cone(r1,r2)
        --draw_object_shadow()
    end
end

function _draw()
    cls()
    if state == in_progress then
        map(0, 0, 0, 0, 16, 16)
        draw_unit(player)
        draw_unit(enemy)
        draw_shadow()

        for i = 1, #shadow_objects do
            for j = 1, #shadow_objects[i].vertices do
                pset(shadow_objects[i].vertices[j][1], shadow_objects[i].vertices[j][2], 8)
            end
        end
        for i = 1, #shadow_objects do
            for j = 1, #shadow_objects[i].visible_vertices do
                pset(shadow_objects[i].visible_vertices[j][1], shadow_objects[i].visible_vertices[j][2], 2)
            end
        end

        score += 1
        print("score: " .. score, 2, 2, 7)
    elseif state == start_end_game then
        sfx(0)
        state = game_over
    elseif state == game_over then
        camera()
        print("\135 game over \135")
        print("your final score was: " .. score)
        print("press action to try again")
        if btn(4) then _init() end
    end
end