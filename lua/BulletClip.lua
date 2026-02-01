function draw_bullet_clip()
    rectfill(119,128 - player.maxBullets*5,128,128, 1)
    
    for i=1, player.currentBullet do
        spr(
		49,
		120, 127 - i*5,
		1,1
	)
    end
end