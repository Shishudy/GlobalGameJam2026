function _init()
    init_mask()
    visible_vertices_coroutine = cocreate(coroutine_get_shadow_vertices)
    init_shadow_objects()
    parse_levels()
    timer_start(false)
end

function _draw()
    cls(currentMaskColor)
    drawPlayer()
    drawBullets()
    draw_shadow()
    timer_draw()
	-- draw the portion of the map relative to the level
    map((current_level - 1) * 16)
end

function _update()
    update_mask()
    timer_update()
    coresume(visible_vertices_coroutine)
    load_next_level()
    updatePlayer()
    updateBullets()
end