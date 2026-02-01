function _init()
    load_level()
    init_mask()
    visible_vertices_coroutine = cocreate(coroutine_get_shadow_vertices)
    init_shadow_objects()
    timer_start(false)
end

function _draw()
    pal(2, MaskColor1)
    pal(7, MaskColor2)
    mset(flr(player.x / 8) + MAP_W_MIN, flr(player.y / 8) + MAP_H_MIN, 0)
    cls(currentMaskColor)
	-- draw the portion of the map relative to the level
    map((current_level - 1) * 16)
    draw_shadow()
    pal()
    drawBullets()
    drawPlayer()
    timer_draw()
    draw_bullet_clip()
end

function _update()
    load_next_level()
    timer_update()
    coresume(visible_vertices_coroutine)
    updatePlayer()
    updateBullets()
end