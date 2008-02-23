#****************************************************************************
#**
#**  File     :  /lua/AI/sorianutilities.lua
#**  Author(s): Michael Robbins aka Sorian
#**
#**  Summary  : Utility functions for the Sorian AIs
#**
#****************************************************************************

local AIUtils = import('/lua/ai/aiutilities.lua')
local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
local Utils = import('/lua/utilities.lua')

function CanRespondEffectively(aiBrain, location, platoon)
	local targets = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, location, 32, 'Enemy' )
	if aiBrain:GetThreatAtPosition(location, 0, true, 'Air') > 0 and AIAttackUtils.GetAirThreatOfUnits(platoon) > 0 then
		return true
	elseif aiBrain:GetThreatAtPosition(location, 0, true, 'Land') > 0 and AIAttackUtils.GetSurfaceThreatOfUnits(platoon) > 0 then
		return true
	end
	if table.getn(targets) == 0 then
		#LOG('*AI DEBUG: CanRespondEffectively returned True 2')
		return true
	end
	#LOG('*AI DEBUG: CanRespondEffectively returned False')
	return false
end

function FindClosestUnitToAttack( aiBrain, platoon, squad, maxRange, atkPri, selectedWeaponArc, turretPitch )
    local position = platoon:GetPlatoonPosition()
    if not aiBrain or not position or not maxRange then
        return false
    end
    local targetUnits = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, position, maxRange, 'Enemy' )
    local retUnit = false
    local distance = false
    for num, unit in targetUnits do
        if not unit:IsDead() and not EntityCategoryContains(categories.AIR, unit) then
            local unitPos = unit:GetPosition()
            if (not retUnit or Utils.XZDistanceTwoVectors( position, unitPos ) < distance) and (not turretPitch or not CheckBlockingTerrain(position, unitPos, selectedWeaponArc, turretPitch)) then
                retUnit = unit
                distance = Utils.XZDistanceTwoVectors( position, unitPos )
            end
        end
    end
    if retUnit then
        return retUnit
    end
    return false
end

function CheckBlockingTerrain(pos, targetPos, firingArc, turretPitch)
	if firingArc == 'high' then
		return false
	end
	local distance = VDist2Sq(pos[1], pos[3], targetPos[1], targetPos[3])
	distance = math.sqrt(distance)
	local step = math.ceil(distance / 5)
	local xstep = (pos[1] - targetPos[1]) / step
	local ystep = (pos[3] - targetPos[3]) / step
	for i = 0, step do
		if i > 0 then
			local lastPos = {pos[1] - (xstep * (i - 1)), 0, pos[3] - (ystep * (i - 1))}
			local nextpos = {pos[1] - (xstep * i), 0, pos[3] - (ystep * i)}
			local lastPosHeight = GetTerrainHeight( lastPos[1], lastPos[3] )
			local nextposHeight = GetTerrainHeight( nextpos[1], nextpos[3] )
			if GetSurfaceHeight( lastPos[1], lastPos[3] ) > lastPosHeight then
				lastPosHeight = GetSurfaceHeight( lastPos[1], lastPos[3] )
			end
			if GetSurfaceHeight( nextpos[1], nextpos[3] ) > nextposHeight then
				nextposHeight = GetSurfaceHeight( nextpos[1], nextpos[3] )
			end
			if not GetSlope(lastPos, nextpos, lastPosHeight, nextposHeight) < turretPitch then
				return true
			end
		end
	end
	return false
end

function GetSlope(pos, targetPos, posHeight, targetHeight)
	local distance = VDist2Sq(pos[1], pos[3], targetPos[1], targetPos[3])
	distance = math.sqrt(distance)
	local heightDif
	if targetHeight > posHeight then
		heightDif = targetHeight - posHeight
	elseif targetHeight < posHeight then
		heightDif = posHeight - targetHeight
	else
		return 0
	end
	local slope = heightDif / distance
	local angle = math.deg(math.atan(slope))
	#LOG('*AI DEBUG: GetSlope: heightDif = '..heightDif..' distance = '..distance..' slope = '..slope..' angle = '..angle)
	return angle
end

function MajorLandThreatExists( aiBrain )
	local StartX, StartZ = aiBrain:GetArmyStartPos()
	local numET2 = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.STRATEGIC * categories.TECH2, Vector(StartX,0,StartZ), 360, 'Enemy' )
	local numET3Art = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.ARTILLERY * categories.TECH3, Vector(StartX,0,StartZ), 900, 'Enemy' )
	local numENuke = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.NUKE * categories.SILO, Vector(StartX,0,StartZ), 100000, 'Enemy' )
	local numET4Art = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.STRATEGIC * categories.EXPERIMENTAL, Vector(StartX,0,StartZ), 100000, 'Enemy' )
	local numET4Sat = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * categories.ORBITALSYSTEM * categories.EXPERIMENTAL, Vector(StartX,0,StartZ), 100000, 'Enemy' )
	local numET4Exp = aiBrain:GetNumUnitsAroundPoint( categories.EXPERIMENTAL * (categories.LAND + categories.NAVAL), Vector(StartX,0,StartZ), 100000, 'Enemy' )
	local numEDef = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.STRUCTURE * (categories.DIRECTFIRE + categories.ANTIAIR), Vector(StartX,0,StartZ), 150, 'Enemy' )
	local retcat = false
	if numET4Art > 0 then
		retcat = categories.STRUCTURE * categories.STRATEGIC * categories.EXPERIMENTAL #'STRUCTURE STRATEGIC EXPERIMENTAL'
	elseif numET4Sat > 0 then
		retcat = categories.STRUCTURE * categories.ORBITALSYSTEM * categories.EXPERIMENTAL #'STRUCTURE ORBITALSYSTEM EXPERIMENTAL'
	elseif numENuke > 0 then
		retcat = categories.STRUCTURE * categories.NUKE * categories.SILO #'STRUCTURE NUKE SILO'
	elseif numET4Exp > 0 then
		retcat = categories.EXPERIMENTAL * (categories.LAND + categories.NAVAL) #'EXPERIMENTAL LAND + NAVAL'
	elseif numET3Art > 0 then
		retcat = categories.STRUCTURE * categories.ARTILLERY * categories.TECH3 #'STRUCTURE ARTILLERY TECH3'
	elseif numET2 > 0 then
		retcat = categories.STRUCTURE * categories.STRATEGIC * categories.TECH2 #'STRUCTURE STRATEGIC TECH2'
	elseif numEDef > 0 then
		retcat = categories.DEFENSE * categories.STRUCTURE * (categories.DIRECTFIRE + categories.ANTIAIR)
	end
	return retcat
end

function MajorAirThreatExists( aiBrain )
	local StartX, StartZ = aiBrain:GetArmyStartPos()
	local numET4Exp = aiBrain:GetUnitsAroundPoint( categories.EXPERIMENTAL * categories.AIR, Vector(StartX,0,StartZ), 100000, 'Enemy' )
	local retcat = false
	for k,v in numET4Exp do
		if v:GetFractionComplete() == 1 then
			retcat = categories.EXPERIMENTAL * categories.AIR #'EXPERIMENTAL AIR'
			break
		end
	end

	return retcat
end

function GetGuards(aiBrain, Unit)
	local engs = aiBrain:GetUnitsAroundPoint( categories.ENGINEER, Unit:GetPosition(), 10, 'Ally' )
	local count = 0
	local UpgradesFrom = Unit:GetBlueprint().General.UpgradesFrom
	for k,v in engs do
		if v:GetUnitBeingBuilt() == Unit then
			count = count + 1
		end
	end
	if UpgradesFrom and UpgradesFrom != 'none' then -- Used to filter out upgrading units
		local oldCat = ParseEntityCategory(UpgradesFrom)
		local oldUnit = aiBrain:GetUnitsAroundPoint( oldCat, Unit:GetPosition(), 0, 'Ally' )
		if oldUnit then
			count = count + 1
		end
	end
	return count
end

function Nuke(aiBrain)
    local atkPri = { 'STRUCTURE ARTILLERY EXPERIMENTAL', 'STRUCTURE NUKE EXPERIMENTAL', 'EXPERIMENTAL ORBITALSYSTEM', 'STRUCTURE ARTILLERY TECH3', 'STRUCTURE NUKE TECH3', 'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE', 'COMMAND', 'TECH3 MASSFABRICATION', 'TECH3 ENERGYPRODUCTION', 'STRUCTURE STRATEGIC', 'STRUCTURE DEFENSE TECH3', 'STRUCTURE DEFENSE TECH2', 'STRUCTURE FACTORY', 'STRUCTURE', 'SPECIALLOWPRI', 'ALLUNITS' }
	local maxFire = false
	local Nukes = aiBrain:GetListOfUnits( categories.NUKE * categories.SILO * categories.STRUCTURE, true )
	local nukeCount = 0
	local launcher
	local bp
	local weapon
	local maxRadius
	local fired = {}
    for k, v in Nukes do
		if not maxFire then
			bp = v:GetBlueprint()
			weapon = bp.Weapon[1]
			maxRadius = weapon.MaxRadius
			launcher = v
			maxFire = true
		end
		fired[k] = false
        if v:GetNukeSiloAmmoCount() > 0 then
			nukeCount = nukeCount + 1
        end            
    end
	if nukeCount > 0 then
		local oldTarget = {}
		local target
		local fireCount = 0
		local aitarget
		local tarPosition
		repeat
			target, tarPosition = AIUtils.AIFindBrainNukeTargetInRangeSorian( aiBrain, launcher, maxRadius, atkPri, nukeCount, oldTarget )
			if target then
				aitarget = target:GetAIBrain():GetArmyIndex()
				#AISendChat('allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'nukechat', ArmyBrains[aitarget].Nickname)
				#AISendPing(tarPosition, 'attack', aiBrain:GetArmyIndex())
				local antiNukes = aiBrain:GetNumUnitsAroundPoint( categories.ANTIMISSILE * categories.TECH3 * categories.STRUCTURE, tarPosition, 80, 'Enemy' )
				for k, v in Nukes do
					if v:GetNukeSiloAmmoCount() > 0 and not fired[k] then
						IssueNuke( {v}, tarPosition )
						nukeCount = nukeCount - 1
						fireCount = fireCount + 1
						fired[k] = true
					end
					if fireCount > (antiNukes + 1) or nukeCount == 0 or (fireCount > 0 and antiNukes == 0) then
						break
					end
				end
			end
			table.insert( oldTarget, target )
			fireCount = 0
			#WaitSeconds(15)
		until nukeCount <= 0 or target == false
	end
end

function FindUnfinishedUnits(aiBrain, locationType, buildCat)
	local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
	local unfinished = aiBrain:GetUnitsAroundPoint( buildCat, engineerManager:GetLocationCoords(), engineerManager:GetLocationRadius(), 'Ally' )
	local retUnfinished = false
	for num, unit in unfinished do
		donePercent = unit:GetFractionComplete()
		if donePercent < 1 and GetGuards(aiBrain, unit) < 1 and not unit:IsUnitState('Upgrading') then
			retUnfinished = unit
			break
		end
	end
	return retUnfinished
end

function FindDamagedShield(aiBrain, locationType, buildCat)
	local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
	local shields = aiBrain:GetUnitsAroundPoint( buildCat, engineerManager:GetLocationCoords(), engineerManager:GetLocationRadius(), 'Ally' )
	local retShield = false
	for num, unit in shields do
		if not unit:IsDead() and unit:ShieldIsOn() then
			shieldPercent = (unit.MyShield:GetHealth() / unit.MyShield:GetMaxHealth())
			if shieldPercent < 1 and GetGuards(aiBrain, unit) < 3 then
				retShield = unit
				break
			end
		end
	end
	return retShield
end

function DestinationBetweenPoints(destination, start, finish)
	local distance = VDist2Sq(start[1], start[3], finish[1], finish[3])
	distance = math.sqrt(distance)
	local step = math.ceil(distance / 100)
	local xstep = (start[1] - finish[1]) / step
	local ystep = (start[3] - finish[3]) / step
	for i = 1, step do
		#DrawCircle( {start[1] - (xstep * i), 0, start[3] - (ystep * i)}, 5, '0000ff' )
		#DrawCircle( {start[1] - (xstep * i), 0, start[3] - (ystep * i)}, 100, '0000ff' )
		if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), finish[1], finish[3]) <= 10000 then break end
		if VDist2Sq(start[1] - (xstep * i), start[3] - (ystep * i), destination[1], destination[3]) < 10000 then
			return true
		end
	end	
	return false
end

function GetNumberOfAIs(aiBrain)
	local numberofAIs = 0
	for k,v in ArmyBrains do
		if not v:IsDefeated() and not ArmyIsCivilian(v:GetArmyIndex()) and v:GetArmyIndex() != aiBrain:GetArmyIndex() then
			numberofAIs = numberofAIs + 1
		end
	end
	return numberofAIs
end

function Round(x, places)
	if places then
		shift = 10 ^ places
		result = math.floor( x * shift + 0.5 ) / shift
		return result
	else
		result = math.floor( x + 0.5 )
		return result
	end
end