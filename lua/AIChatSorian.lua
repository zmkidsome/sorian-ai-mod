#****************************************************************************
#**
#**  File     :  /lua/modules/AIChatSorian.lua
#**  Author(s): Sorian
#**
#**  Summary  : AI Chat Functions
#**  Version  : 0.1
#****************************************************************************
local Chat = import('/lua/ui/game/chat.lua')
local ChatTo = import('/lua/lazyvar.lua').Create()

function AIChat(group, text, sender)
	if text then
		ChatTo:Set(group)
		msg = { to = ChatTo(), Chat = true }
		msg.text = text
		msg.sender = sender
		local armynumber = GetArmyData(sender)
		if ChatTo() == 'allies' then
			SessionSendChatMessage(Chat.FindClients(armynumber, true), msg)
		elseif type(ChatTo()) == 'number' then
			SessionSendChatMessage(Chat.FindClients(ChatTo()), msg)
			msg.echo = true
			Chat.ReceiveChat(Chat.GetArmyData(ChatTo()).nickname, msg)
		else
			SessionSendChatMessage(msg)
		end
	end
end

function GetArmyData(army)
    local armies = GetArmiesTable()
    local result
    if type(army) == 'string' then
        for i, v in armies.armiesTable do
            if v.nickname == army then
                result = i
                break
            end
        end
    end
    return result
end