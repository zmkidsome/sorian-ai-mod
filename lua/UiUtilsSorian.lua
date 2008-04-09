#****************************************************************************
#**
#**  File     :  /lua/modules/AI/UiUtilsSorian.lua
#**  Author(s): Sorian
#**
#**  Summary  :
#**
#****************************************************************************
function ProcessAIChat(to, from, text)
	local armies = GetArmiesTable()
	if (to == 'allies' or type(to) == 'number') then
		for i, v in armies.armiesTable do
			if not v.human and not v.civilian and IsAlly(i, from) and (to == 'allies' or to == i) then
				local testtext = string.gsub(text, '%s(.*)', '')
				local aftertext = string.gsub(text, '^%a+%s', '')
				aftertext = trim(aftertext)
				if string.lower(testtext) == 'target' and aftertext != '' then
					if string.lower(aftertext) == 'at will' then
						SimCallback({Func = 'AIChat', Args = {Army = i, NewTarget = 'at will'}})
					else
						for x, z in armies.armiesTable do
							if trim(string.lower(string.gsub(z.nickname,'%b()', '' ))) == string.lower(aftertext) then
								SimCallback({Func = 'AIChat', Args = {Army = i, NewTarget = x}})
							end
						end
					end
				end
			end
		end
	end				
end

function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end