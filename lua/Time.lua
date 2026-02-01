time_table = { 10, 15 }

-- rep helper: repeat char n times
function rep(c, n)
	local str = ""
	for i = 1, n do
		str ..= c
	end
	return str
end

-- right-pad a string (add spaces on the right)
function pad_r(str, n, c)
	return str .. rep(c, n - #str)
end

-- left-pad a string (add spaces on the left)
function pad_l(str, n, c)
	return rep(c, n - #str) .. str
end

-- center a string within width n
function pad_c(str, n, c)
	local pad = n - #str
	local left = flr(pad / 2)
	local right = pad - left
	return rep(c, left) .. str .. rep(c, right)
end

function time_table:display()
	local x, y = 64, 64
	local total = 0

	-- 1. Compute max label width (consider data labels + header + "TOTAL")
	local label_w = 0
	for i = 1, #self do
		label_w = max(label_w, #("l" .. i))
	end
	label_w = max(label_w, #"level", #"total")

	-- 2. Compute max value width (consider scores + header + total)
	local max_val_w = #"score"
	for i = 1, #self do
		max_val_w = max(max_val_w, #tostring(self[i]))
		total += self[i]
	end
	max_val_w = max(max_val_w, #tostring(total))

	-- 3. Full table width in characters = label + " : " + value
	local table_w = label_w + 3 + max_val_w

	-- 4. Convert to pixels (4 pixels per char)
	local table_px = table_w * 4

	-- 5. Compute top-left corner for horizontal centering (x)
	local left = x - (table_px / 2)

	-- 6. Compute vertical height: total rows = (scoreboard + header + sep + sep + total) + n data
	local total_rows = 5 + #self
	local table_h = total_rows * 8
	local top = y - (table_h / 2)

	local yy = top

	-- Print "SCOREBOARD" centered over full width
	print(pad_c("scoreboard", table_w, " "), left, yy)
	yy += 8

	-- Print header: labels right aligned, values left aligned with colon fixed
	print(pad_r("level", label_w, " ") .. " : " .. pad_l("score", max_val_w, " "), left, yy)
	yy += 8

	-- Print separator line
	print(rep("-", table_w), left, yy)
	yy += 8

	-- Print each data row, labels right aligned, values left aligned
	for i = 1, #self do
		local label = "l" .. i
		local value = tostring(self[i])
		print(pad_r(label, label_w, " ") .. " : " .. pad_l(value, max_val_w, " "), left, yy)
		yy += 8
	end

	-- Bottom separator
	print(rep("-", table_w), left, yy)
	yy += 8

	-- Print total row
	print(pad_r("total", label_w, " ") .. " : " .. pad_l(tostring(total), max_val_w, " "), left, yy)
end

timer = {
	elapsed = 0,
	running = false,
	slow = false,
	slow_factor = 0.2,
	last_time = 0
}

function timer_start(slow)
	timer.elapsed = 0
	timer.slow = slow or false
	timer.running = true
	timer.last_time = time()
end

function timer_set_slow(slow)
	timer.slow = slow
end

function timer_update()
	if not timer.running then return end

	local now = time()
	local dt = now - timer.last_time

	if timer.slow then
		dt *= timer.slow_factor
	end

	timer.elapsed += dt
	timer.last_time = now
end

function timer_draw()
	print(format_time(timer.elapsed), 128 - 16, 2, 7)
end

function reset_timer()
	timer.elapsed = 0
	timer.slow = false
	timer.slow_factor = 0.2
	timer.last_time = 0
end

function stop_timer()
	timer.running = false
end

function format_time(t)
	local whole = flr(t)
	local hundredths = flr((t - whole) * 10)
	return whole .. "." .. hundredths
end