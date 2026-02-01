function slow_motion()
	if not active then
		active = true
		timer_set_slow(true)
		-- timer(true)
	else
		if (player.bullets > 0) then
			return
		end
		-- timer(false)
		timer_set_slow(false)
		active = false
	end

end
