function _init()
    init_mask()
    visible_vertices_coroutine = cocreate(coroutine_get_shadow_vertices)
    init_shadow_objects()
    parse_levels()
    timer_start(false)
end

function _draw()
    pal(2, MaskColor1)
    pal(7, MaskColor2)
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
    timer_update()
    coresume(visible_vertices_coroutine)
    updatePlayer()
    updateBullets()
end