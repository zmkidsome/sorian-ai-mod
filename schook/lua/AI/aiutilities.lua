do

function AIFindBrainTargetInRangeSorian( aiBrain, platoon, squad, maxRange, atkPri )
    local position = platoon:GetPlatoonPosition()
    if not aiBrain or not position or not maxRange then
        return false
    end
    local targetUnits = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, position, maxRange, 'Enemy' )
    for k,v in atkPri do
        local category = ParseEntityCategory( v )
        local retUnit = false
        local distance = false
		local targetShields = false
        for num, unit in targetUnits do
            if not unit:IsDead() and EntityCategoryContains( category, unit ) and platoon:CanAttackTarget( squad, unit ) then
                local unitPos = unit:GetPosition()
				local numShields = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.SHIELD * categories.STRUCTURE, unitPos, 40, 'Enemy' )
                if not retUnit or numShields < targetShields or (numShields == targetShields and Utils.XZDistanceTwoVectors( position, unitPos ) < distance) then
                    retUnit = unit
                    distance = Utils.XZDistanceTwoVectors( position, unitPos )
					targetShields = numShields
                end
            end
        end
        if retUnit then
            return retUnit
        end
    end
    return false
end

function AIFindBrainNukeTargetInRangeSorian( aiBrain, platoon, maxRange, atkPri, nukeCount, oldTarget )
    local position = platoon:GetPosition()	
    if not aiBrain or not position or not maxRange then
        return false
    end
    local targetUnits = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, position, maxRange, 'Enemy' )
    for k,v in atkPri do
        local category = ParseEntityCategory( v )
        local retUnit = false
		local retPosition = false
        local distance = false
        for num, unit in targetUnits do
            if not unit:IsDead() and EntityCategoryContains( category, unit ) then
                local unitPos = unit:GetPosition()
				local antiNukes = aiBrain:GetNumUnitsAroundPoint( categories.ANTIMISSILE * categories.TECH3 * categories.STRUCTURE, unitPos, 80, 'Enemy' )
				local dupTarget = false
				for x,z in oldTarget do
					if unit == z or (not z:IsDead() and Utils.XZDistanceTwoVectors( z:GetPosition(), unitPos ) < 30) then
						dupTarget = true
					end
				end
				for k,v in ArmyBrains do
					if IsAlly(v:GetArmyIndex(), aiBrain:GetArmyIndex()) or (aiBrain:GetArmyIndex() == v:GetArmyIndex()) then
						local estartX, estartZ = v:GetArmyStartPos()
						if VDist2(estartX, estartZ, unitPos[1], unitPos[3]) < 220 then
							dupTarget = true
						end
					end
				end
                if (not retUnit or (distance and Utils.XZDistanceTwoVectors( position, unitPos ) < distance)) and ((antiNukes + 1 < nukeCount or antiNukes == 0) and not dupTarget) then
                    retUnit = unit
					retPosition = unitPos
                    distance = Utils.XZDistanceTwoVectors( position, unitPos )
				elseif (not retUnit or (distance and Utils.XZDistanceTwoVectors( position, unitPos ) < distance)) and not dupTarget then
					for i=-1,1 do
						for j=-1,1 do
							if i ~= 0 and j~= 0 then
								local pos = {unitPos[1] + (i * 18), 0, unitPos[3] + (j * 18)}
								antiNukes = aiBrain:GetNumUnitsAroundPoint( categories.ANTIMISSILE * categories.TECH3 * categories.STRUCTURE, pos, 80, 'Enemy' )
								if (antiNukes + 1 < nukeCount or antiNukes == 0) then
									retUnit = unit
									retPosition = pos
									distance = Utils.XZDistanceTwoVectors( position, unitPos )
								end
							end
							if retUnit then break end
						end
						if retUnit then break end
					end
                end
            end
        end
        if retUnit then
            return retUnit, retPosition
        end
    end
    return false
end

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

function UseTransports(units, transports, location, transportPlatoon)
    local aiBrain
    for k,v in units do
        if not v:IsDead() then
            aiBrain = v:GetAIBrain()
            break
        end
    end
    if not aiBrain then
        LOG('*AI DEBUG: Attack force failed no brain - transports')
        return false
    end
        # Load transports
    local transportTable = {}
    local transSlotTable = {}
    if not transports then
        LOG('*AI DEBUG: Attack force failed no transports')
        return false
    end
    #LOG('*AI DEBUG: Attack force using Transports')
    for num,unit in transports do
        local id = unit:GetUnitId()
        if not transSlotTable[id] then
            transSlotTable[id] = GetNumTransportSlots(unit)
        end
        table.insert( transportTable,
            {
                Transport = unit,
                LargeSlots = transSlotTable[id].Large,
                MediumSlots = transSlotTable[id].Medium,
                SmallSlots = transSlotTable[id].Small,
                Units = {}
            }
        )
    end

    local shields = {}
    local remainingSize3 = {}
    local remainingSize2 = {}
    local remainingSize1 = {}
    local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
    for num, unit in units do
        if not unit:IsDead() then
            if unit:IsUnitState( 'Attached' ) then
                aiBrain:AssignUnitsToPlatoon( pool, {unit}, 'Unassigned', 'None' )
                LOG('*AI DEBUG: ARMY ' .. aiBrain:GetArmyIndex() .. ': Already Attached units adding to pool' )
            elseif EntityCategoryContains( categories.url0306 + categories.DEFENSE, unit ) then
                table.insert( shields, unit )
            elseif unit:GetBlueprint().Transport.TransportClass == 3 then
                table.insert( remainingSize3, unit )
            elseif unit:GetBlueprint().Transport.TransportClass == 2 then
                table.insert( remainingSize2, unit )
            elseif unit:GetBlueprint().Transport.TransportClass == 1 then
                table.insert( remainingSize1, unit )
            else
                table.insert( remainingSize1, unit )
            end
        end
    end
#    LOG( '*AI DEBUG: NUM SHIELDS= ', table.getn( shields ) )
#    LOG( '*AI DEBUG: NUM LARGE = ', table.getn( remainingSize3 ) )
#    LOG( '*AI DEBUG: NUM MEDIUM = ', table.getn( remainingSize2 ) )
#    LOG( '*AI DEBUG: NUM SMALL = ', table.getn( remainingSize1 ) )

    local needed = GetNumTransports(units)
    local largeHave = 0
    for num, data in transportTable do
        largeHave = largeHave + data.LargeSlots
    end
    local leftoverUnits = {}
    local currLeftovers = {}
    local leftoverShields = {}
    transportTable, leftoverShields = SortUnitsOnTransports( transportTable, shields, largeHave - needed.Large )

    transportTable, leftoverUnits = SortUnitsOnTransports( transportTable, remainingSize3, -1 )

    transportTable, currLeftovers = SortUnitsOnTransports( transportTable, leftoverShields, -1 )

    for k,v in currLeftovers do table.insert(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports( transportTable, remainingSize2, -1 )

    for k,v in currLeftovers do table.insert(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports( transportTable, remainingSize1, -1 )

    for k,v in currLeftovers do table.insert(leftoverUnits, v) end
    transportTable, currLeftovers = SortUnitsOnTransports( transportTable, currLeftovers, -1 )

    aiBrain:AssignUnitsToPlatoon( pool, currLeftovers, 'Unassigned', 'None' )


    if transportPlatoon then
        transportPlatoon.UsingTransport = true
    end

    #LOG('*AI DEBUG: ARMY ' .. aiBrain:GetArmyIndex() .. ': Loading Attack force on transports - Faction = ' .. aiBrain:GetFactionIndex() )
    local monitorUnits = {}
    for num, data in transportTable do
        if table.getn( data.Units ) > 0 then
            IssueClearCommands( data.Units )
            IssueTransportLoad( data.Units, data.Transport )
            for k,v in data.Units do table.insert( monitorUnits, v) end
        end
    end

    local attached = true
    repeat
        WaitSeconds(2)
        local allDead = true
		local transDead = true
        for k,v in units do
            if not v:IsDead() then
                allDead = false
                break
            end
        end
        for k,v in transports do
            if not v:IsDead() then
                transDead = false
                break
            end
        end
        if allDead or transDead then return false end
        attached = true
        for k,v in monitorUnits do
            if not v:IsDead() and not v:IsIdleState() then
                attached = false
                break
            end
        end
    until attached
    # Any units that aren't transports and aren't attached send back to pool
    for k,unit in units do
        if not unit:IsDead() and not EntityCategoryContains( categories.TRANSPORTATION, unit ) then
            if not unit:IsUnitState('Attached') then
                aiBrain:AssignUnitsToPlatoon( pool, {unit}, 'Unassigned', 'None' )
            end
        end
    end
    
    #LOG('*AI DEBUG: Transport loaded')

    
    if table.getn(transports) != 0 then
        local safePath = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Air', transports[1]:GetPosition(), location, 200)
        if safePath then 
            for _,p in safePath do
                IssueMove(transports, p)
            end
            #LOG('*AI DEBUG: Transport using safe path')
        end
    end

    IssueTransportUnload( transports, location )
    local attached = true
    while attached do
        WaitSeconds(3)
        local allDead = true
        for k,v in transports do
            if not v:IsDead() then
                allDead = false
                break
            end
        end
        if allDead then
            return false
        end
        attached = false
        for num, unit in units do
            if not unit:IsDead() and unit:IsUnitState('Attached') then
                attached = true
                break
            end
        end
    end
    
    if transportPlatoon then
        transportPlatoon.UsingTransport = false
    end    
    ReturnTransportsToPool( transports, true )
    #LOG('*AI DEBUG: Finished using transports')
    return true
end

end