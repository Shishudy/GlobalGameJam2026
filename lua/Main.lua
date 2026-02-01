function _init()
    visible_vertices_coroutine = cocreate(coroutine_get_shadow_vertices)
    init_shadow_objects()
end

function _draw()
    cls()
    map(0, 0, 0, 0, 16, 16)
    draw_shadow()
    drawPlayer()
    drawBullets()
end

function _update()
    update_mask()
    coresume(visible_vertices_coroutine)
    updatePlayer()
    updateBullets()
end