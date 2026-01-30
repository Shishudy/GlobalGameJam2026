-- api.p8 by zep
-- demos most api functions

-- _draw() called once per frame
function _draw()
	
	-- clear screen to dark blue
	cls(1)
	
	-- ❎: mess with camera / clipping
	camera() -- reset
	if (btn(❎)) then
	 camera(cos(t()/6)*20,0)
	 clip(4,16,120,96)--x,y,w,h
	end
	
	-- draw whole map
	map()
	
	-- circles  x,y,radius,col
	circfill(64,160,63,6)
	circ(64,160,67,14)
	
	-- with fill pattern
	fillp(░)
	circfill(64,160,52,7)
	fillp() -- reset
	
	-- rectangles x0,y0,x1,y1,col
	rectfill(4,4,124,10,0)
	rect(2,2,126,12,0)
	
	-- lines: x0,y0,x1,y1,col
	-- (palette at top)
	for i=1,15 do
	 line(i*8-1, 6, i*8+1, 8, i)
	end
	
	-- strings
 
	num=8
	str="hello "
	str..="from api.p"..num
	str_len=#str
	
	-- print: str,x,y,col
	print(str, 64-str_len*2, 20, 7)
	
	-- tables / arrays
	
	tbl={"a"} -- single element
	
	add(tbl,"b") -- add to end
	add(tbl,"d")
	add(tbl,"c")
	del(tbl,"d") --remove by value
	
	-- iterate over the table
	-- (draw letters bottom left)
	cursor(2,104,5) -- x,y,col
	foreach(tbl,print)
	
	-- another way to iterate
	cursor(123,104,5)
	for i in all(tbl) do
	 print(i)
	end
	
	-- iterate with a for loop
	-- starts at index 1! (not 0)
	tbl={"ヒ゜","コ","◆"}
	
	for i=1,#tbl do
	 print(tbl[i],2,  10+i*6,13)
	 print(tbl[i],114,10+i*6,13)
	end
	
	
	-- draw sprites
	palt(2,true) --draw transparent
	palt(0,false)--draw solid (eyes)
	spr(2,48,32,4,4)
	
	-- stretched sprites
	-- (spinning bunnys)
	
	-- w: width to draw
	-- (1 turn ever 2 seconds)
	w = cos(t()/2) * 32
	
	-- draw back sides indigo
	if (w < 0) pal(7,13)
	
	--[[
	sspr: stretch sprite
	■ first 4 parameters specify
	  the source rect (x,y,w,h)
	■ last 4 params specify the
	  rectangle to draw (x,y,w,h)
	--]]
	sspr(16,0,32,32,
	    24-w/2,32,w,32)
	-- re-use w to mean height
	-- for vertical spinning
	sspr(16,0,32,32,
	    88,48-w/2,32,w)
	
	pal() -- reset palette
	
	-- rotating star sprites
	for i=0,31 do
	
	 -- angle based on time
	 local a=(i+t()*2)/32
	 
	 -- screen position
	 sx=64 +cos(a)*57 - 4
	 sy=160+sin(a)*57 - 4
	 
	 -- grab pixels from spritesheet
	 -- to use as color
	 ssx = 64+i%16   -- x location
	 col=sget(ssx,0) -- grab it
	 
	 -- draw star in that color
	 pal(7,col) -- (remap white)
	 spr(16, sx,sy)
	 
	end
	pal() -- reset
	
	-- draw state of buttons
	for pl=0,7 do
		for b=0,7 do
		 sx=57+b*2
		 sy=70+pl*2
		 col=5
		 if (btn(b,pl)) col=b+7
		 pset(sx,sy,col)
		end
	end

end

-- _update(): called 30 fps
-- (use _update60 for 60fps)
function _update()
	
	-- button pressed: play a sfx
	if (btnp(🅾️)) then
		sfx(0)
	end
	
end

-- _init() called once at start
function _init()
	
	-- music loops every 4 patterns
	-- because the loop-back flag
	-- is set on pattern 3
	music(0)
	
	-- make a custom menu item
	menuitem(1, "play sfx", 
	 function()
	  sfx(3)
	 end
	)
	
end