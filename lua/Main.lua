
function _init()
    init_objects()
end

function _draw()
    cls()
    map(0, 0, 0, 0, 16, 16)
    drawPlayer()
    drawBullets()
    draw_shadow()
end

function _update()
    updatePlayer()
    updateBullets()
end