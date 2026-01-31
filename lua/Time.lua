time_table = { 15, 10, 3, 5, 5 }

-- rep helper: repeat char n times
function rep(ch, n)
	local s = ""
	for i = 1, n do
		s ..= ch
	end
	return s
end

-- right-pad a string (add spaces on the right)
function pad_r(s, w)
	return s .. rep(" ", w - #s)
end

-- left-pad a string (add spaces on the left)
function pad_l(s, w)
	return rep(" ", w - #s) .. s
end

-- center a string within width w
function pad_c(s, w)
	local pad = w - #s
	local l = flr(pad / 2)
	local r = pad - l
	return rep(" ", l) .. s .. rep(" ", r)
end

function time_table:display()
	local x, y = 64, 64

	local total = 0
	local n = #self

	-- 1. Compute max label width (consider data labels + header + "TOTAL")
	local label_w = 0
	for i = 1, n do
		label_w = max(label_w, #("l" .. i))
	end
	label_w = max(label_w, #"level", #"total")

	-- 2. Compute max value width (consider scores + header + total)
	local max_val_w = #"score"
	for i = 1, n do
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

	-- 6. Compute vertical height: total rows = scoreboard + header + sep + n data + sep + total
	local total_rows = 1 + 1 + 1 + n + 1 + 1
	local table_h = total_rows * 8
	local top = y - (table_h / 2)

	local yy = top

	-- Print "SCOREBOARD" centered over full width
	print(pad_c("scoreboard", table_w), left, yy)
	yy += 8

	-- Print header: labels right aligned, values left aligned with colon fixed
	print(pad_r("level", label_w) .. " : " .. pad_l("score", max_val_w), left, yy)
	yy += 8

	-- Print separator line
	print(rep("-", table_w), left, yy)
	yy += 8

	-- Print each data row, labels right aligned, values left aligned
	for i = 1, n do
		local label = "l" .. i
		local value = tostring(self[i])
		print(pad_r(label, label_w) .. " : " .. pad_l(value, max_val_w), left, yy)
		yy += 8
	end

	-- Bottom separator
	print(rep("-", table_w), left, yy)
	yy += 8

	-- Print total row
	print(pad_r("total", label_w) .. " : " .. pad_l(tostring(total), max_val_w), left, yy)
end