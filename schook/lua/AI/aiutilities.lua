do

function AIFindDefensiveAreaSorian( aiBrain, unit, category, range, runShield )
    if not unit:IsDead() then
        # Build a grid to find units near
        local gridSize = range / 5
        if gridSize > 150 then
            gridSize = 150
        end
        local grid = {}
        local highPoint = false
        local highNum = false
        local unitPos = unit:GetPosition()
        local distance
        local startPosX, startPosZ = aiBrain:GetArmyStartPos()
		local found = false
        for i=-5,5 do
            for j=-5,5 do
                local height = GetTerrainHeight( unitPos[1] - ( gridSize * i ), unitPos[3] - ( gridSize * j ) )
                if GetSurfaceHeight( unitPos[1] - ( gridSize * i ), unitPos[3] - ( gridSize * j ) ) > height then
                    height = GetSurfaceHeight( unitPos[1] - ( gridSize * i ), unitPos[3] - ( gridSize * j ) )
                end
                local checkPos = { unitPos[1] - ( gridSize * i ), height, unitPos[3] - ( gridSize * j ) }
                local units = aiBrain:GetUnitsAroundPoint( category, checkPos, gridSize, 'Ally' )
                local tempNum = 0
                for k,v in units do
					found = true
                    if ( EntityCategoryContains( categories.TECH3, v ) and not runShield ) or ( EntityCategoryContains( categories.TECH3, v ) and runShield and v:ShieldIsOn() ) then
                        tempNum = tempNum + 10
                    elseif ( EntityCategoryContains( categories.TECH2, v ) and not runShield ) or ( EntityCategoryContains( categories.TECH2, v ) and runShield and v:ShieldIsOn() ) then
                        tempNum = tempNum + 5
                    else
                        tempNum = tempNum + 1
                    end
                end
                local units = aiBrain:GetUnitsAroundPoint( categories.MOBILE, checkPos, gridSize, 'Enemy' )
                for k,v in units do
                    if EntityCategoryContains( categories.TECH3, v ) then
                        tempNum = tempNum - 10
                    elseif EntityCategoryContains( categories.TECH2, v ) then
                        tempNum = tempNum - 5
                    else
                        tempNum = tempNum - 1
                    end
                end
                if not highNum or tempNum > highNum then
                    highNum = tempNum
                    distance = VDist2( startPosX, startPosZ, checkPos[1], checkPos[3] )
                    highPoint = checkPos
                elseif tempNum == highNum then
                    local tempDist = VDist2( startPosX, startPosZ, checkPos[1], checkPos[3] )
                    if tempDist < distance then
                        highNum = tempNum
                        highPoint = checkPos
                    end
                end
            end
        end
		if not found then
			local x,z = aiBrain:GetArmyStartPos()
			return RandomLocation(x,z)
		else
			return highPoint
		end
    else
        return { 0, 0, 0 }
    end
end

function GetTransports(platoon, units)
    local data = platoon.PlatoonData
    local aiBrain = platoon:GetBrain()

    if not units then
        units = platoon:GetPlatoonUnits()
    end
    
    # check for empty platoon
    if table.getn(units) == 0 then
        return 0
    end
    
    local neededTable = GetNumTransports(units)
    local numTransports = 0
    local transportsNeeded = false
    if neededTable.Small > 0 or neededTable.Medium > 0 or neededTable.Large > 0 then
        transportsNeeded = true
    end
    local transSlotTable = {}

    local pool = aiBrain:GetPlatoonUniquelyNamed( 'ArmyPool' )

    # make sure more are needed
    local tempNeeded = {}
    tempNeeded.Small = neededTable.Small
    tempNeeded.Medium = neededTable.Medium
    tempNeeded.Large = neededTable.Large

    local location = platoon:GetPlatoonPosition()
    if not location then 
        # we can assume we have at least one unit here
        location = units[1]:GetCachePosition()
    end
    if not location then
        LOG("*AI DEBUG: Passed in no units into AIUtilities' GetTransports" )
        return 0
    end

    local transports = {}
    # Determine distance of transports from platoon
    for k,unit in pool:GetPlatoonUnits() do
        if not unit:IsDead() and EntityCategoryContains( categories.TRANSPORTATION - categories.uea0203, unit ) and not unit:IsUnitState('Busy') and unit:GetFractionComplete() == 1 then
            local unitPos = unit:GetPosition()
            local curr = { Unit=unit, Distance=VDist2( unitPos[1], unitPos[3], location[1], location[3] ),
                           Id = unit:GetUnitId() }
            table.insert( transports, curr )
        end
    end
    if table.getn(transports) > 0 then
        local sortedList = {}
        # Sort distances
        for k = 1,table.getn(transports) do
            local lowest = -1
            local key, value
            for j,u in transports do
                if lowest == -1 or u.Distance < lowest then
                    lowest = u.Distance
                    value = u
                    key = j
                end
            end
            sortedList[k] = value
            # remove from unsorted table
            table.remove( transports, key )
        end


        # Take transports as needed
        for i=1,table.getn(sortedList) do
            if transportsNeeded then
                local id = sortedList[i].Id
                aiBrain:AssignUnitsToPlatoon(platoon, {sortedList[i].Unit}, 'Scout', 'GrowthFormation')
                numTransports = numTransports + 1
                if not transSlotTable[id] then
                    transSlotTable[id] = GetNumTransportSlots(sortedList[i].Unit)
                end
                local tempSlots = {}
                tempSlots.Small = transSlotTable[id].Small
                tempSlots.Medium = transSlotTable[id].Medium
                tempSlots.Large = transSlotTable[id].Large
                # update number of slots needed
                while tempNeeded.Large > 0 and tempSlots.Large > 0 do
                    tempNeeded.Large = tempNeeded.Large - 1
                    tempSlots.Large = tempSlots.Large - 1
                    tempSlots.Medium = tempSlots.Medium - 2
                    tempSlots.Small = tempSlots.Small - 4
                end
                while tempNeeded.Medium > 0 and tempSlots.Medium > 0 do
                    tempNeeded.Medium = tempNeeded.Medium - 1
                    tempSlots.Medium = tempSlots.Medium - 1
                    tempSlots.Small = tempSlots.Small - 2
                end
                while tempNeeded.Small > 0 and tempSlots.Small > 0 do
                    tempNeeded.Small = tempNeeded.Small - 1
                    tempSlots.Small = tempSlots.Small - 1
                end
                if tempNeeded.Small <= 0 and tempNeeded.Medium <= 0 and tempNeeded.Large <= 0 then
                    transportsNeeded = false
                end
            end
        end
    end

    if transportsNeeded then
#        if platoon:GetSquadUnits('Scout') then
#            LOG('*AI DEBUG: Attack force attempting to get enough transport failed: TransTotal - ' .. repr(table.getn(platoon:GetSquadUnits('Scout'))) .. ' Large - ' .. repr(tempNeeded.Large) .. ' Medium - ' .. repr(tempNeeded.Medium) .. ' Small - ' .. repr(tempNeeded.Small) )
#        end
        ReturnTransportsToPool( platoon:GetSquadUnits('Scout'), false )
        return false, tempNeeded.Small, tempNeeded.Medium, tempNeeded.Large
    else
        platoon.UsingTransport = true
        return numTransports, 0, 0, 0
    end
end

end