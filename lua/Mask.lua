local inverted = false

function activate_mask()
    if (inverted == true) do
        pal()
    else
        pal(0, 7, 1)
        pal(7, 0, 1)
    end
    inverted = not inverted
end