do

function DoHackyLogic(buildingType, builder)
    if buildingType == 'T2StrategicMissile' then
        local unitInstance = false
        
        builder:ForkThread(function()
            while true do
                if not unitInstance then
                    unitInstance = builder:GetUnitBeingBuilt()
                end
                aiBrain = builder:GetAIBrain()
                if unitInstance then
                    TriggerFile.CreateUnitStopBeingBuiltTrigger( function(unitBeingBuilt)
                        local newPlatoon = aiBrain:MakePlatoon('', '')
                        aiBrain:AssignUnitsToPlatoon(newPlatoon, {unitBeingBuilt}, 'Attack', 'None')
                        newPlatoon:StopAI()
                        newPlatoon:ForkAIThread(newPlatoon.TacticalAI)
                    end, unitInstance )
                    break
                end
                WaitSeconds(1)
            end
        end)
    end
end

end