level=0

function LoadLevel()
    -- move camera to level
	camera(level*128,0)

	-- draw the whole map (128⁙32)
	map()
end