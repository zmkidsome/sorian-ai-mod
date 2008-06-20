do
local SUtils = import('/lua/AI/sorianutilities.lua')
local AIBehaviors = import('/lua/ai/AIBehaviors.lua')

function AIGetEconomyNumbers(aiBrain)
    #LOG('*AI DEBUG: RETURNING ECONOMY NUMBERS FROM AIBRAIN ', repr(aiBrain))
    local econ = {}
    econ.MassTrend = aiBrain:GetEconomyTrend('MASS')
    econ.EnergyTrend = aiBrain:GetEconomyTrend('ENERGY')
    econ.MassStorageRatio = aiBrain:GetEconomyStoredRatio('MASS')
    econ.EnergyStorageRatio = aiBrain:GetEconomyStoredRatio('ENERGY')
    econ.EnergyIncome = aiBrain:GetEconomyIncome('ENERGY')
    econ.MassIncome = aiBrain:GetEconomyIncome('MASS')
    econ.EnergyUsage = aiBrain:GetEconomyUsage('ENERGY')
    econ.MassUsage = aiBrain:GetEconomyUsage('MASS')
    econ.EnergyRequested = aiBrain:GetEconomyRequested('ENERGY')
    econ.MassRequested = aiBrain:GetEconomyRequested('MASS')
    econ.EnergyEfficiency = math.min(econ.EnergyIncome / econ.EnergyRequested, 2)
    econ.MassEfficiency = math.min(econ.MassIncome / econ.MassRequested, 2)
    econ.MassRequested = aiBrain:GetEconomyRequested('MASS')
    econ.EnergyStorage = aiBrain:GetEconomyStored('ENERGY')
    econ.MassStorage = aiBrain:GetEconomyStored('MASS')

    if aiBrain.EconomyMonitorThread then
        local econTime = aiBrain:GetEconomyOverTime()
        
        econ.EnergyRequestOverTime = econTime.EnergyRequested
        econ.MassRequestOverTime = econTime.MassRequested
        
        econ.EnergyIncomeOverTime = SUtils.Round(econTime.EnergyIncome, 2)
        econ.MassIncomeOverTime = SUtils.Round(econTime.MassIncome, 2)
		
        econ.EnergyEfficiencyOverTime = math.min(econTime.EnergyIncome / econTime.EnergyRequested, 2)
        econ.MassEfficiencyOverTime = math.min(econTime.MassIncome / econTime.MassRequested, 2)
    end
        
    if econ.MassStorageRatio != 0 then
        econ.MassMaxStored = econ.MassStorage / econ.MassStorageRatio
    else
        econ.MassMaxStored = econ.MassStorage
    end
    if econ.EnergyStorageRatio != 0 then
        econ.EnergyMaxStored = econ.EnergyStorage / econ.EnergyStorageRatio
    else
        econ.EnergyMaxStored = econ.EnergyStorage
    end
    return econ
end

function EngineerTryReclaimCaptureAreaSorian(aiBrain, eng, pos)
    if not pos then
        return false
    end
    
    # Check if enemy units are at location
    local checkUnits = aiBrain:GetUnitsAroundPoint( categories.STRUCTURE + ( categories.MOBILE * categories.LAND), pos, 10, 'Enemy' )
    #( Rect( pos[1] - 7, pos[3] - 7, pos[1] + 7, pos[3] + 7 ) )
    if checkUnits and table.getn(checkUnits) > 0 then
        for num,unit in checkUnits do
            #if not unit:IsDead() and EntityCategoryContains( categories.ENGINEER, unit ) and ( unit:GetAIBrain():GetFactionIndex() ~= aiBrain:GetFactionIndex() ) then
            #    IssueReclaim( {eng}, unit )
            #elseif 
			if not EntityCategoryContains( categories.COMMAND, eng ) then
                IssueCapture( {eng}, unit )
            end
        end
        return true
    end
    
    return false
end

function GetAssisteesSorian(aiBrain, locationType, assisteeType, buildingCategory, assisteeCategory )
    if assisteeType == 'Factory' then
        # Sift through the factories in the location
        local manager = aiBrain.BuilderManagers[locationType].FactoryManager
        return manager:GetFactoriesWantingAssistance(buildingCategory, assisteeCategory)
    elseif assisteeType == 'Engineer' then
        local manager = aiBrain.BuilderManagers[locationType].EngineerManager
        return manager:GetEngineersWantingAssistance( buildingCategory, assisteeCategory )
    elseif assisteeType == 'Structure' then
        local manager = aiBrain.BuilderManagers[locationType].PlatoonFormManager
        return manager:GetUnitsBeingBuilt(buildingCategory, assisteeCategory)
    elseif assisteeType == 'NonUnitBuildingStructure' then
        return GetUnitsBeingBuilt(aiBrain, locationType, assisteeCategory)
    else
        WARN('*AI ERROR: Invalid assisteeType - ' .. assisteeType )
    end
    return false    
end

function GetUnitsBeingBuilt(aiBrain, locationType, assisteeCategory)
	if not aiBrain or not locationType or not assisteeCategory then
		WARN('*AI ERROR: GetUnitsBeingBuilt missing data!')
		return false
	end
	local manager = aiBrain.BuilderManagers[locationType].EngineerManager
    if not manager then
        return false
    end
	local filterUnits = GetOwnUnitsAroundPoint( aiBrain, assisteeCategory, manager:GetLocationCoords(), manager:GetLocationRadius() )
	
	local retUnits = {}
	
	for k,v in filterUnits do
            
		if not v:IsUnitState('Building') and not v:IsUnitState('Upgrading') then
			continue
		end
		
		table.insert( retUnits, v )
	end
	return retUnits
end

function GetBasePatrolPointsSorian( aiBrain, location, radius, layer )
    if type(location) == 'string' then
        if aiBrain:PBMHasPlatoonList() then
            for k,v in aiBrain.PBM.Locations do
                if v.LocationType == location then
                    radius = v.Radius
                    location = v.Location
                    break
                end
            end
        elseif aiBrain.BuilderManagers[location] then
            radius = aiBrain.BuilderManagers[location].FactoryManager:GetLocationRadius()
            location = aiBrain.BuilderManagers[location].FactoryManager:GetLocationCoords()
        end
        if not radius then
            error('*AI ERROR: Invalid locationType- '..location..' for army- '..aiBrain.Name, 2)
        end
    end
    if not location or not radius then
        error('*AI ERROR: Need location and radius or locationType for AIUtilities.GetBasePatrolPoints', 2)
    end
    local vecs = aiBrain:GetBaseVectors()
    local locList = {}
    if not layer then
        layer = 'Land'
    end
    for k,v in vecs do
        if LayerCheckPosition( v, layer) and VDist2( v[1], v[3], location[1], location[3] ) < radius then
            table.insert(locList, v)
        end
    end
    local sortedList = {}
    local lastX = location[1]
    local lastZ = location[3]
    if table.getsize(locList) == 0 then return {} end
    local num = table.getsize(locList)
	local startX, startZ = aiBrain:GetArmyStartPos()
	local tempdistance = false
	local edistance
	local closeX, closeZ
    #Sort the locations from point to closest point, that way it  makes a nice patrol path
	for k,v in ArmyBrains do
        if IsEnemy(v:GetArmyIndex(), aiBrain:GetArmyIndex()) then
			local estartX, estartZ = v:GetArmyStartPos()
			local tempdistance = VDist2(startX, startZ, estartX, estartZ)
			if not edistance or tempdistance < edistance then
				edistance = tempdistance
				closeX = estartX
				closeZ = estartZ
			end
		end
	end
    for i = 1, num do
        local lowest
        local czX, czZ, pos, distance, key
        for k, v in locList do
            local x = v[1]
            local z = v[3]
			if i == 1 then
				distance = VDist2(closeX, closeZ, x, z)
			else
				distance = VDist2(lastX, lastZ, x, z)
			end
            if not lowest or distance < lowest then
                pos = v
                lowest = distance
                key = k
            end
        end
        if not pos then return {} end
        sortedList[i] = pos
        lastX = pos[1]
        lastZ = pos[3]
        table.remove(locList, key)
    end
    return sortedList
end

function IsMex(building)
	return building == 'uab1103' or building == 'uab1202' or building == 'uab1302' or
	 building == 'urb1103' or building == 'urb1202' or building == 'urb1302' or
	  building == 'ueb1103' or building == 'ueb1202' or building == 'ueb1302' or
	   building == 'xsb1103' or building == 'xsb1202' or building == 'xsb1302'
end

function LayerCheckPosition( pos, layer )
    if pos[1] > 0 and pos[1] < ScenarioInfo.size[1] and pos[3] > 0 and pos[3] < ScenarioInfo.size[2] then
        local surf = GetSurfaceHeight( pos[1], pos[3] )
        local terr = GetTerrainHeight( pos[1], pos[3] )
        if layer == 'Air' then
			return true
		elseif surf > terr and layer == 'Sea' then
            return true
        elseif terr >= surf and layer == 'Land' then
            return true
        else
            return false
        end
    else
        return false
    end
end

function AIGetSortedHydroLocations(aiBrain, maxNum, tMin, tMax, tRings, tType, position)
    local markerList = AIGetMarkerLocations(aiBrain, 'Hydrocarbon')
    local newList = {}
    for k,v in markerList do
        if aiBrain:CanBuildStructureAt( 'ueb1102', v.Position ) then
            table.insert( newList, v )
        end
    end
    return AISortMarkersFromLastPos(aiBrain, newList, maxNum, tMin, tMax, tRings, tType, position)
end

# used by engineers to move to a safe location
function EngineerMoveWithSafePathSorian(aiBrain, unit, destination)
    if not destination then
        return false
    end
    local pos = unit:GetPosition()
    local result, bestPos = unit:CanPathTo( destination )

    local bUsedTransports = false
    if not result or VDist2Sq(pos[1], pos[3], destination[1], destination[3]) > 65536 and unit.PlatoonHandle and not EntityCategoryContains(categories.COMMAND, unit) then
        # if we can't path to our destination, we need, rather than want, transports
        local needTransports = not result
		# if distance > 512
        if VDist2Sq( pos[1], pos[3], destination[1], destination[3] ) > 262144 then #and unit.PlatoonHandle.PlatoonData.RequireTransport then
            needTransports = true
        end
        # skip the last move... we want to return and do a build
        bUsedTransports = AIAttackUtils.SendPlatoonWithTransportsSorian(aiBrain, unit.PlatoonHandle, destination, needTransports, true, false)
        
        if bUsedTransports then
            return true
        end
    end
    
    # if we're here, we haven't used transports and we can path to the destination
    if result then
        local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Amphibious', unit:GetPosition(), destination, 10)
        if path then
            local pathSize = table.getn(path)
            # move to way points (but not to destination... leave that for the final command)
            for widx,waypointPath in path do
                if pathSize != widx then
                    IssueMove({unit},waypointPath)
                end
            end  
        end
        # if there wasn't a *safe* path (but dest was pathable), then the last move would have been to go there directly
        # so don't bother... the build/capture/reclaim command will take care of that after we return
        return true
    end
    
    return false
end   

function EngineerTryRepairSorian(aiBrain, eng, whatToBuild, pos)
    if not pos then 
        return false 
    end
	local checkRange = 75
    local structureCat = ParseEntityCategory( whatToBuild )

	if IsMex(whatToBuild) then
		checkRange = 1
	end
	
    local checkUnits = aiBrain:GetUnitsAroundPoint(structureCat, pos, checkRange, 'Ally' )
    if checkUnits and table.getn(checkUnits) > 0 then
		for num,unit in checkUnits do
			if unit:IsBeingBuilt() then
				IssueRepair( {eng}, unit )
				return true
			end
		end
    end
    
    return false
end

function AIFindPingTargetInRangeSorian( aiBrain, platoon, squad, maxRange, atkPri, avoidbases )
    local position = platoon:GetPlatoonPosition()
    if not aiBrain or not position or not maxRange then
        return false
    end
	local AttackPositions = AIGetAttackPointsAroundLocation( aiBrain, position, maxRange )
	for x,z in AttackPositions do
		local targetUnits = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, z, 100, 'Enemy' )
		for k,v in atkPri do
			local category = ParseEntityCategory( v )
			local retUnit = false
			local distance = false
			local targetShields = 9999
			for num, unit in targetUnits do
				if not unit:IsDead() and EntityCategoryContains( category, unit ) and platoon:CanAttackTarget( squad, unit ) then
					local unitPos = unit:GetPosition()
					if avoidbases then
						for k,v in ArmyBrains do
							if IsAlly(v:GetArmyIndex(), aiBrain:GetArmyIndex()) or (aiBrain:GetArmyIndex() == v:GetArmyIndex()) then
								local estartX, estartZ = v:GetArmyStartPos()
								if VDist2Sq(estartX, estartZ, unitPos[1], unitPos[3]) < 22500 then
									continue
								end
							end
						end
					end
					local numShields = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.SHIELD * categories.STRUCTURE, unitPos, 50, 'Enemy' )
					if not retUnit or numShields < targetShields or (numShields == targetShields and Utils.XZDistanceTwoVectors( position, unitPos ) < distance) then
						retUnit = unit
						distance = Utils.XZDistanceTwoVectors( position, unitPos )
						targetShields = numShields
					end
				end
			end
			if retUnit and targetShields > 0 then
				local platoonUnits = platoon:GetPlatoonUnits()
				for k,v in platoonUnits do
					if not v:IsDead() then
						unit = v
						break
					end
				end
				local closestBlockingShield = AIBehaviors.GetClosestShieldProtectingTargetSorian(unit, retUnit)
				if closestBlockingShield then
					return closestBlockingShield
				end
			end
			if retUnit then
				return retUnit
			end
		end
	end
	return false
end

# We use both Blank Marker that are army names as well as the new Large Expansion Area to determine big expansion bases
function AIFindStartLocationNeedsEngineerSorian( aiBrain, locationType, radius, tMin, tMax, tRings, tType, eng)
    local pos = aiBrain:PBMGetLocationCoords( locationType )
    if not pos then
        return false
    end
	local validStartPos = {}
    local validPos = AIGetMarkersAroundLocation( aiBrain, 'Large Expansion Area', pos, radius, tMin, tMax, tRings, tType)

    local positions = AIGetMarkersAroundLocation( aiBrain, 'Blank Marker', pos, radius, tMin, tMax, tRings, tType)
    local startX, startZ = aiBrain:GetArmyStartPos()
    for k,v in positions do
        if string.sub(v.Name,1,5) == 'ARMY_' then
            if startX != v.Position[1] and startZ != v.Position[3] then
                table.insert( validStartPos, v )
            end
        end
    end
    
    local retPos, retName
    if eng then
		if table.getn(validStartPos) > 0 then
			retPos, retName = AIFindMarkerNeedsEngineer( aiBrain, eng:GetPosition(), radius, tMin, tMax, tRings, tType, validStartPos )
		end
		if not retPos then
			retPos, retName = AIFindMarkerNeedsEngineer( aiBrain, eng:GetPosition(), radius, tMin, tMax, tRings, tType, validPos )
		end
    else
		if table.getn(validStartPos) > 0 then
			retPos, retName = AIFindMarkerNeedsEngineer( aiBrain, pos, radius, tMin, tMax, tRings, tType, validStartPos )
		end
		if not retPos then
			retPos, retName = AIFindMarkerNeedsEngineer( aiBrain, pos, radius, tMin, tMax, tRings, tType, validPos )
		end
    end
    return retPos, retName
end

function AIGetAttackPointsAroundLocation( aiBrain, pos, maxRange )
    local markerList = {}

	if aiBrain.AttackPoints then
		for k,v in aiBrain.AttackPoints do
			local dist = VDist2( pos[1], pos[3], v.Position[1], v.Position[3] )
			if dist < maxRange then
				table.insert( markerList, { Position = v.Position } )
			end
		end
	end

    return AISortMarkersFromStartPos(aiBrain, markerList, 100, nil, nil, nil, nil, nil, pos)
end

function SortUnitsOnTransports( transportTable, unitTable, numSlots )
    local leftoverUnits = {}
    numSlots = numSlots or -1
    for num, unit in unitTable do
        if numSlots == -1 or num <= numSlots then
            local transSlotNum = 0
            local remainingLarge = 0
            local remainingMed = 0
            local remainingSml = 0
            for tNum, tData in transportTable do
                if tData.LargeSlots > remainingLarge then
                    transSlotNum = tNum
                    remainingLarge = tData.LargeSlots
                    remainingMed = tData.MediumSlots
                    remainingSml = tData.SmallSlots
                elseif tData.LargeSlots == remainingLarge and tData.MediumSlots > remainingMed then
                    transSlotNum = tNum
                    remainingLarge = tData.LargeSlots
                    remainingMed = tData.MediumSlots
                    remainingSml = tData.SmallSlots
                elseif tData.LargeSlots == remainingLarge and tData.MediumSlots == remainingMed and tData.SmallSlots > remainingSml then
                    transSlotNum = tNum
                    remainingLarge = tData.LargeSlots
                    remainingMed = tData.MediumSlots
                    remainingSml = tData.SmallSlots
                end
            end
            if transSlotNum > 0 then
                table.insert( transportTable[transSlotNum].Units, unit )
                if unit:GetBlueprint().Transport.TransportClass == 3 and remainingLarge >= 1 then
                    transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - 1
                    transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 2
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 4
                elseif unit:GetBlueprint().Transport.TransportClass == 2 and remainingMed > 0 then
                    if transportTable[transSlotNum].LargeSlots > 0 then
                        transportTable[transSlotNum].LargeSlots = transportTable[transSlotNum].LargeSlots - .5
                    end
                    transportTable[transSlotNum].MediumSlots = transportTable[transSlotNum].MediumSlots - 1
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 2
                elseif unit:GetBlueprint().Transport.TransportClass == 1 and remainingSml > 0 then
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 1
                elseif remainingSml > 0 then
                    transportTable[transSlotNum].SmallSlots = transportTable[transSlotNum].SmallSlots - 1
                else
                    #LOG('*AI DEBUG: FOUND TRANSPORT NOT ENOUGH SLOTS')
                    table.insert(leftoverUnits, unit)
                end
            else
                #LOG('*AI DEBUG: NO TRANSPORT FOUND')
                table.insert(leftoverUnits, unit)
            end
        end
    end
    return transportTable, leftoverUnits
end

function AIFindBrainTargetInRangeSorian( aiBrain, platoon, squad, maxRange, atkPri, avoidbases )
    local position = platoon:GetPlatoonPosition()
    if not aiBrain or not position or not maxRange then
        return false
    end
    local targetUnits = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, position, maxRange, 'Enemy' )
    for k,v in atkPri do
        local category = ParseEntityCategory( v )
        local retUnit = false
        local distance = false
		local targetShields = 9999
        for num, unit in targetUnits do
            if not unit:IsDead() and EntityCategoryContains( category, unit ) and platoon:CanAttackTarget( squad, unit ) then
                local unitPos = unit:GetPosition()
				if avoidbases then
					for k,v in ArmyBrains do
						if IsAlly(v:GetArmyIndex(), aiBrain:GetArmyIndex()) or (aiBrain:GetArmyIndex() == v:GetArmyIndex()) then
							local estartX, estartZ = v:GetArmyStartPos()
							if VDist2Sq(estartX, estartZ, unitPos[1], unitPos[3]) < 22500 then
								continue
							end
						end
					end
				end
				local numShields = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.SHIELD * categories.STRUCTURE, unitPos, 50, 'Enemy' )
                if not retUnit or numShields < targetShields or (numShields == targetShields and Utils.XZDistanceTwoVectors( position, unitPos ) < distance) then
                    retUnit = unit
                    distance = Utils.XZDistanceTwoVectors( position, unitPos )
					targetShields = numShields
                end
            end
        end
		if retUnit and targetShields > 0 then
			local platoonUnits = platoon:GetPlatoonUnits()
			for k,v in platoonUnits do
				if not v:IsDead() then
					unit = v
					break
				end
			end
			local closestBlockingShield = AIBehaviors.GetClosestShieldProtectingTargetSorian(unit, retUnit)
			if closestBlockingShield then
				return closestBlockingShield
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
								local pos = {unitPos[1] + (i * 15), 0, unitPos[3] + (j * 15)}
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

function GetOwnUnitsAroundPointSorian( aiBrain, category, location, radius, min, max, rings, tType, minRadius )
    local units = aiBrain:GetUnitsAroundPoint( category, location, radius, 'Ally' )
    local index = aiBrain:GetArmyIndex()
	local minDist = minRadius * minRadius
    local retUnits = {}
    local checkThreat = false
    if min and max and rings then
        checkThreat = true
    end
    for k,v in units do
        if not v:IsDead() and not v:IsBeingBuilt() and v:GetAIBrain():GetArmyIndex() == index then
			local loc = v:GetPosition()
			if VDist2Sq(location[1], location[3], loc[1], loc[3]) > minDist then
				if checkThreat then
					local threat = aiBrain:GetThreatAtPosition( v:GetPosition(), rings, true, tType or 'Overall' )
					if threat >= min and threat <= max then
						table.insert(retUnits, v)
					end
				else
					table.insert(retUnits, v)
				end
			end
        end
    end
    return retUnits
end

function AIFindExpansionPointNeedsStructure( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)
    local pos = aiBrain:PBMGetLocationCoords( locationType )
    if not pos then
        return false
    end
    local positions = AIGetMarkersAroundLocation( aiBrain, 'Expansion Area', pos, radius, tMin, tMax, tRings, tType)
    
    local retPos, retName, lowest
    for k,v in positions do
        local numUnits = table.getn( GetOwnUnitsAroundPoint( aiBrain, ParseEntityCategory(category), v.Position, markerRadius ) )
        if numUnits < unitMax then
            if not retPos or numUnits < lowest then
                lowest = numUnits
                retName = v.Name
                retPos = v.Position
            end
        end
    end
    
    return retPos, retName
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

function AIGetPingMarkersAroundLocation( aiBrain, threatMin, threatMax, threatRings, threatType )
    local returnMarkers = {}

	if aiBrain.TacticalBases then
		for k,v in aiBrain.TacticalBases do
			if not threatMin then
	            table.insert( returnMarkers, v )
			else
				local threat = aiBrain:GetThreatAtPosition( v.Position, threatRings, true, threatType or 'Overall' )
				if threat >= threatMin and threat <= threatMax then
					table.insert( returnMarkers, v )
				end
			end
		end
	end
	
    return returnMarkers
end

function AIGetMarkerLocationsSorian(aiBrain, markerType)
    local markerList = {}
    if aiBrain.TacticalBases then
		for k,v in aiBrain.TacticalBases do
			table.insert( markerList, { Position = v.Position, Name = k } )
		end
	end
    local markers = ScenarioUtils.GetMarkers()
    if markers then
        for k, v in markers do
            if v.type == markerType then
                table.insert(markerList, { Position = v.position, Name = k } )
            end
        end
    end
    
    return markerList
end

function AIFindDefensivePointNeedsStructureSorian( aiBrain, locationType, radius, category, markerRadius, unitMax, tMin, tMax, tRings, tType)
    local pos = aiBrain:PBMGetLocationCoords( locationType )
    if not pos then
        return false
    end
	local primarkers = AIGetPingMarkersAroundLocation( aiBrain, tMin, tMax, tRings, tType )
    local positions = AIGetMarkersAroundLocation( aiBrain, 'Defensive Point', pos, radius, tMin, tMax, tRings, tType)
    
    local retPos, retName, lowest
	for k,v in primarkers do
		local numUnits = table.getn( GetOwnUnitsAroundPoint( aiBrain, ParseEntityCategory(category), v.Position, markerRadius ) )
        if numUnits < unitMax then
            if not retPos or numUnits < lowest then
                lowest = numUnits
                retName = v.Name
                retPos = v.Position
            end
        end
	end
	if retPos and retName then
		return retPos, retName
	end
    for k,v in positions do
        local numUnits = table.getn( GetOwnUnitsAroundPoint( aiBrain, ParseEntityCategory(category), v.Position, markerRadius ) )
        if numUnits < unitMax then
            if not retPos or numUnits < lowest then
                lowest = numUnits
                retName = v.Name
                retPos = v.Position
            end
        end
    end
    
    return retPos, retName
end

function AIFindFirebaseLocationSorian( aiBrain, locationType, radius, markerType, tMin, tMax, tRings, tType, maxUnits, unitCat, markerRadius)
    #Get location of commander
    #local threatPos, threatVal = aiBrain:GetHighestThreatPosition(0, true, 'Commander', aiBrain:GetCurrentEnemy():GetArmyIndex())
    #if threatVal == 0 then
    #    local threatPos, threatVal = aiBrain:GetHighestThreatPosition(1, true, tType or 'Structures', aiBrain:GetCurrentEnemy():GetArmyIndex())
    #end
    local estartX, estartZ = aiBrain:GetCurrentEnemy():GetArmyStartPos()
	local threatPos = {estartX, 0, estartZ}
    #Get markers
    local markerList = AIGetMarkerLocationsSorian(aiBrain, markerType)
    
    #For each marker, check against threatpos. Save markers that are within the FireBaseRange
    local inRangeList = {}
    for _,marker in markerList do
        local distSq = VDist2Sq(marker.Position[1], marker.Position[3], threatPos[1], threatPos[3])
        
        if distSq < radius * radius  then
            table.insert(inRangeList, marker)
        end
    end
    
    #Pick the closest, least-threatening position in range
    local bestDistSq = 9999999999
    local bestThreat = 9999999999
    local bestMarker = false
    
    local maxThreat = tMax or 1
    
    local catCheck = ParseEntityCategory(unitCat) or categories.ALLUNITS
    
    local reference = false
    local refName = false
    
    for _,marker in inRangeList do
        local threat = aiBrain:GetThreatAtPosition(marker.Position, 1, true, 'AntiSurface')
        if threat < maxThreat then
            local numUnits = table.getn( GetOwnUnitsAroundPoint( aiBrain, catCheck, marker.Position, markerRadius or 20) )
            if numUnits < maxUnits then
                if threat < bestThreat and threat < maxThreat then
                    bestDistSq = VDist2Sq(threatPos[1], threatPos[3], marker.Position[1], marker.Position[3])
                    bestThreat = threat
                    bestMarker = marker
                elseif threat == bestThreat then
                    local distSq = VDist2Sq(threatPos[1], threatPos[3], marker.Position[1], marker.Position[3])
                    if distSq > bestDistSq then
                        bestDistSq = distSq
                        bestMarker = marker
                    end
                end
            end
        end
    end
    
    if bestMarker then
        reference = bestMarker.Position
        refName = bestMarker.Name
    end
    return reference, refName
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
                #LOG('*AI DEBUG: ARMY ' .. aiBrain:GetArmyIndex() .. ': Already Attached units adding to pool' )
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