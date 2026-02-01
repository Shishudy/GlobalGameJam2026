slow_motion_status = false

function slow_motion()
	if not slow_motion_status then
		slow_motion_status = true
		timer_set_slow(true)
		-- timer(true)
	else
		if (player.bullets > 0) then
			return
		end
		-- timer(false)
		timer_set_slow(false)
		slow_motion_status = false
	end

end

