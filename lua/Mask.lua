inverted = false
maskFlag = 0
currentMaskColor = 0
negativeMaskColor = 1

local prevBTN = false

function init_mask()
    currentMaskColor = MaskColor1
    negativeMaskColor = MaskColor2
end

function update_mask()
    local curBTN = btn(5)
    if not prevBTN and curBTN then
        activate_mask()
    end
    prevBTN = curBTN
end

function activate_mask()
    if (inverted == true) then
        maskFlag = 0
        currentMaskColor = MaskColor1
        negativeMaskColor = MaskColor2
    else
        maskFlag = 1
        currentMaskColor = MaskColor2
        negativeMaskColor = MaskColor1
    end
    inverted = not inverted
end