local micro = GetPart("Microphone")
local gyro = GetPart("Gyro")

micro.Chatted:Connect(function(plr, txt)
	if txt:sub(1, 1) == " " then
		txt = txt:gsub(1, 1, "")
	end
	if plr == 1686825919 then
		local identifier = ""
		for i = 1, txt:len() do
			identifier = identifier .. txt:sub(i, i)
			if identifier:match("&gt;Target ") then
				identifier = ""
				for i2 = i, txt:len() do
					identifier = identifier .. txt:sub(i2, i2)
				end
				gyro.Seek = identifier
			elseif identifier:match("&gt;TargetClear") then
				gyro.Seek = ""
			end
		end
	end
end)
