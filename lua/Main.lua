
function _init()
    init_objects()
end

function _draw()
    cls()
    map(0, 0, 0, 0, 16, 16)
    draw_shadow()
    drawPlayer()
    drawBullets()
end

function _update()
    if (btn(5)) do 
        activate_mask()
    end
    updatePlayer()
    updateBullets()
end