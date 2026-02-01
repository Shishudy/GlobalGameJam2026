inverted = false
maskFlag = 0

local prevBTN = false

function update_mask()
    local curBTN = btn(5)
    if not prevBTN and curBTN then
        activate_mask()
    end
    prevBTN = curBTN
end

function activate_mask()
    if (inverted == true) then
        pal()
        maskFlag = 0
    else
        pal(0, 7, 1)
        pal(7, 0, 1)
        maskFlag = 1
    end
    inverted = not inverted
end