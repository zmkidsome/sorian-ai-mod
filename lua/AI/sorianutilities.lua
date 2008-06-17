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
local Mods = import('/lua/mods.lua')

local AIChatText = import('/lua/AI/sorianlang.lua').AIChatText

local AITaunts = {
	{3,4,5,6,7,8,9,10,11,12,14,15,16},
	{19,21,23,24,26,27,28,29,30,31,32},
	{33,34,35,36,37,38,39,40,41,43,46,47,48},
	{49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64},
}

function T4Timeout(aiBrain)
	WaitSeconds(30)
	aiBrain.T4Building = false
end

function AddCustomUnitSupport(aiBrain)
	aiBrain.CustomUnits = {}
	for i, m in __active_mods do
		#LOG('*AI DEBUG: Checking mod: '..m.name..' for custom units')
		local CustomUnitFiles = DiskFindFiles(m.location..'/lua/CustomUnits', '*.lua')
		#LOG('*AI DEBUG: Custom unit files found: '..repr(CustomUnitFiles))
		for k, v in CustomUnitFiles do
			local tempfile = import(v).UnitList
			for plat, t in tempfile do
				for fac, b in t do
					if aiBrain.CustomUnits[plat] and aiBrain.CustomUnits[plat][fac] then
						#LOG('*AI DEBUG: Adding to EXISTING template and EXISTING faction: '..plat..' faction = '..fac..' new ID = '..b[1]..' chance = '..b[2] )
						table.insert(aiBrain.CustomUnits[plat][fac], { b[1], b[2] } )
					elseif aiBrain.CustomUnits[plat] then
						#LOG('*AI DEBUG: Adding to EXISTING template and NEW faction: '..plat..' faction = '..fac..' new ID = '..b[1]..' chance = '..b[2] )
						aiBrain.CustomUnits[plat][fac] = {}
						table.insert(aiBrain.CustomUnits[plat][fac], { b[1], b[2] } )
					else
						#LOG('*AI DEBUG: Adding to NEW template and NEW faction: '..plat..' faction = '..fac..' new ID = '..b[1]..' chance = '..b[2] )
						aiBrain.CustomUnits[plat] = {}
						aiBrain.CustomUnits[plat][fac] = {}
						table.insert(aiBrain.CustomUnits[plat][fac], { b[1], b[2] } )
					end
				end
			end
		end
	end
end

function GetPlatoonTechLevel(platoonUnits)
	local highest = false
	for k,v in platoonUnits do
		if EntityCategoryContains(categories.TECH3, v) then
			highest = 3
		elseif EntityCategoryContains(categories.TECH2, v) and highest < 3 then
			highest = 2
		elseif EntityCategoryContains(categories.TECH1, v) and highest < 2 then
			highest = 1
		end
		if highest == 3 then break end
	end
	return highest
end

function CanRespondEffectively(aiBrain, location, platoon)
	local targets = aiBrain:GetUnitsAroundPoint( categories.ALLUNITS, location, 32, 'Enemy' )
	if AIAttackUtils.GetAirThreatOfUnits(platoon) > 0 and aiBrain:GetThreatAtPosition(location, 0, true, 'Air') > 0 then
		return true
	elseif AIAttackUtils.GetSurfaceThreatOfUnits(platoon) > 0 and (aiBrain:GetThreatAtPosition(location, 0, true, 'Land') > 0 or aiBrain:GetThreatAtPosition(location, 0, true, 'Naval') > 0) then
		return true
	end
	if table.getn(targets) == 0 then
		#LOG('*AI DEBUG: CanRespondEffectively returned True 2')
		return true
	end
	#LOG('*AI DEBUG: CanRespondEffectively returned False')
	return false
end

function AISendPing(position, pingType, army)
	local PingTypes = {
       alert = {Lifetime = 6, Mesh = 'alert_marker', Ring = '/game/marker/ring_yellow02-blur.dds', ArrowColor = 'yellow', Sound = 'UEF_Select_Radar'},
       move = {Lifetime = 6, Mesh = 'move', Ring = '/game/marker/ring_blue02-blur.dds', ArrowColor = 'blue', Sound = 'Cybran_Select_Radar'},
       attack = {Lifetime = 6, Mesh = 'attack_marker', Ring = '/game/marker/ring_red02-blur.dds', ArrowColor = 'red', Sound = 'Aeon_Select_Radar'},
       marker = {Lifetime = 5, Ring = '/game/marker/ring_yellow02-blur.dds', ArrowColor = 'yellow', Sound = 'UI_Main_IG_Click', Marker = true},
   }
	local data = {Owner = army - 1, Type = pingType, Location = position}
	data = table.merged(data, PingTypes[pingType])
	import('/lua/simping.lua').SpawnPing(data)
end

function AIDelayChat(aigroup, ainickname, aiaction, targetnickname, delaytime)
	WaitSeconds(delaytime)
	AISendChat(aigroup, ainickname, aiaction, targetnickname)
end

function AISendChat(aigroup, ainickname, aiaction, targetnickname)
	if aigroup and not GetArmyData(ainickname):IsDefeated() and (aigroup !='allies' or AIHasAlly(GetArmyData(ainickname))) then
		if aiaction and AIChatText[aiaction] then
			local ranchat = Random(1, table.getn(AIChatText[aiaction]))
			local chattext
			if targetnickname then
				if IsAIArmy(targetnickname) then
					targetnickname = trim(string.gsub(targetnickname,'%b()', '' ))
				end
				chattext = string.gsub(AIChatText[aiaction][ranchat],'%[target%]', targetnickname )
			else
				chattext = AIChatText[aiaction][ranchat]
			end
			table.insert(Sync.AIChat, {group=aigroup, text=chattext, sender=ainickname} )
		else
			table.insert(Sync.AIChat, {group=aigroup, text=aiaction, sender=ainickname} )
		end
	end
end

function AIRandomizeTaunt(aiBrain)
	local factionIndex = aiBrain:GetFactionIndex()
	tauntid = Random(1,table.getn(AITaunts[factionIndex]))
	aiBrain.LastVocTaunt = GetGameTimeSeconds()
	AISendChat('all', aiBrain.Nickname, '/'..AITaunts[factionIndex][tauntid])
end

function FinishAIChat(data)
	if data.NewTarget then
		if data.NewTarget == 'at will' then
			ArmyBrains[data.Army].targetoveride = false
			AISendChat('allies', ArmyBrains[data.Army].Nickname, 'Targeting at will')
		else
			if IsEnemy(data.NewTarget, data.Army) then
				ArmyBrains[data.Army]:SetCurrentEnemy( ArmyBrains[data.NewTarget] )
				ArmyBrains[data.Army].targetoveride = true
				AISendChat('allies', ArmyBrains[data.Army].Nickname, 'tcrespond', ArmyBrains[data.NewTarget].Nickname)
			elseif IsAlly(data.NewTarget, data.Army) then
				AISendChat('allies', ArmyBrains[data.Army].Nickname, 'tcerrorally', ArmyBrains[data.NewTarget].Nickname)
			end
		end
	end
end

function AIHandlePing(aiBrain, pingData)
	if pingData.Type == 'move' then
		if not aiBrain.TacticalBases then
			aiBrain.TacticalBases = {}
		end
		nextping = (table.getn(aiBrain.TacticalBases) + 1)
		table.insert(aiBrain.TacticalBases,
			{
			Position = pingData.Location,
			Name = 'BasePing'..nextping,
			}
		)
		AISendChat('allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'genericchat')
	elseif pingData.Type == 'attack' then
		if not aiBrain.AttackPoints then
			aiBrain.AttackPoints = {}
		end
		table.insert(aiBrain.AttackPoints,
			{
			Position = pingData.Location,
			}
		)
		aiBrain:ForkThread(aiBrain.AttackPointsTimeout, pingData.Location)
		AISendChat('allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'genericchat')
	elseif pingData.Type == 'alert' then
		table.insert(aiBrain.BaseMonitor.AlertsTable,
			{
			Position = pingData.Location,
			Threat = 80,
			}
		)
        aiBrain.BaseMonitor.AlertSounded = true
		aiBrain:ForkThread(aiBrain.BaseMonitorAlertTimeout, pingData.Location)
        aiBrain.BaseMonitor.ActiveAlerts = aiBrain.BaseMonitor.ActiveAlerts + 1
		AISendChat('allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'genericchat')
	end
end

function FindClosestUnitPosToAttack( aiBrain, platoon, squad, maxRange, atkCat, selectedWeaponArc, turretPitch )
    local position = platoon:GetPlatoonPosition()
    if not aiBrain or not position or not maxRange then
		#LOG('*AI DEBUG: FindClosestUnitToAttack missing data')
        return false
    end
    local targetUnits = aiBrain:GetUnitsAroundPoint( atkCat, position, maxRange, 'Enemy' )
    local retUnit = false
    local distance = 999999
    for num, unit in targetUnits do
        if not unit:IsDead() then
            local unitPos = unit:GetPosition()
            if (not retUnit or Utils.XZDistanceTwoVectors( position, unitPos ) < distance) and platoon:CanAttackTarget( squad, unit ) and (not turretPitch or not CheckBlockingTerrain(position, unitPos, selectedWeaponArc, turretPitch)) then
                retUnit = unit:GetPosition()
                distance = Utils.XZDistanceTwoVectors( position, unitPos )
            end
        end
    end
    if retUnit then
        return retUnit
    end
    return false
end

function LeadTarget(platoon, target)
	position = platoon:GetPlatoonPosition()
	pos = target:GetPosition()
	Tpos1 = {pos[1], 0, pos[3]}
	WaitSeconds(1)
	pos = target:GetPosition()
	Tpos2 = {pos[1], 0, pos[3]}
	xmove = (Tpos1[1] - Tpos2[1])
	ymove = (Tpos1[3] - Tpos2[3])
	dist1 = VDist2Sq(position[1], position[3], Tpos1[1], Tpos1[3])
	dist2 = VDist2Sq(position[1], position[3], Tpos2[1], Tpos2[3])
	dist1 = math.sqrt(dist1)
	dist2 = math.sqrt(dist2)
	time1 = (dist1 / 12) 
	time2 = (dist2 / 12)
	newtime = time2 - (time1 - time2) + 5.82 #2.32 (time for missile to speed up) + 3.5 seconds for launch
	newx = xmove * newtime
	newy = ymove * newtime
    if Tpos2[1] < 0 or Tpos2[3] < 0 or Tpos2[1] > ScenarioInfo.size[1] or Tpos2[3] > ScenarioInfo.size[2] then
        return false
    end
	return {Tpos2[1] - newx, 0, Tpos2[3] - newy}
end

function LeadTargetArtillery(platoon, unit, target)
	position = platoon:GetPlatoonPosition()
	mainweapon = unit:GetBlueprint().Weapon[1]
	pos = target:GetPosition()
	Tpos1 = {pos[1], 0, pos[3]}
	WaitSeconds(1)
	pos = target:GetPosition()
	Tpos2 = {pos[1], 0, pos[3]}
	xmove = (Tpos1[1] - Tpos2[1])
	ymove = (Tpos1[3] - Tpos2[3])
	dist1 = VDist2Sq(position[1], position[3], Tpos1[1], Tpos1[3])
	dist2 = VDist2Sq(position[1], position[3], Tpos2[1], Tpos2[3])
	dist1 = math.sqrt(dist1)
	dist2 = math.sqrt(dist2)
	# get firing angle, gravity constant = 100m/s = 5.12 MU/s
	firingangle1 = math.deg(math.asin((5.12 * dist1) / (mainweapon.MuzzleVelocity * mainweapon.MuzzleVelocity)) / 2)
	firingangle2 = math.deg(math.asin((5.12 * dist2) / (mainweapon.MuzzleVelocity * mainweapon.MuzzleVelocity)) / 2)
	# convert angle for high arc
	if mainweapon.BallisticArc == 'RULEUBA_HighArc' then
		firingangle1 = 90 - firingangle1
		firingangle2 = 90 - firingangle2
	end
	# get flight time
	time1 = mainweapon.MuzzleVelocity * math.deg(math.sin(firingangle1)) / 2.56
	time2 = mainweapon.MuzzleVelocity * math.deg(math.sin(firingangle2)) / 2.56
	newtime = time2 - (time1 - time2)
	newx = xmove * newtime
	newy = ymove * newtime
	return {Tpos2[1] - newx, 0, Tpos2[3] - newy}
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
			else
				nextposHeight = nextposHeight + .5
			end
			if GetSlope(lastPos, nextpos, lastPosHeight, nextposHeight) > turretPitch then
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
	local numET4AExp = aiBrain:GetNumUnitsAroundPoint( categories.EXPERIMENTAL * categories.AIR, Vector(StartX,0,StartZ), 100000, 'Enemy' )
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
	elseif numET4AExp > 0 then
		retcat = categories.EXPERIMENTAL * categories.AIR #'EXPERIMENTAL AIR'
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
    local atkPri = { 'STRUCTURE ARTILLERY EXPERIMENTAL', 'STRUCTURE NUKE EXPERIMENTAL', 'EXPERIMENTAL ORBITALSYSTEM', 'STRUCTURE ARTILLERY TECH3', 'STRUCTURE NUKE TECH3', 'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE', 'COMMAND', 'TECH3 MASSFABRICATION', 'TECH3 ENERGYPRODUCTION', 'STRUCTURE DEFENSE TECH3', 'STRUCTURE FACTORY TECH3', 'STRUCTURE STRATEGIC TECH2', 'STRUCTURE DEFENSE TECH2', 'STRUCTURE FACTORY TECH2', 'STRUCTURE' }
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
		fired[v] = false
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
				AISendChat('allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'nukechat', ArmyBrains[aitarget].Nickname)
				AISendPing(tarPosition, 'attack', aiBrain:GetArmyIndex())
				if Random(1,5) == 3 and (not aiBrain.LastTaunt or GetGameTimeSeconds() - aiBrain.LastTaunt > 90) then
					aiBrain.LastTaunt = GetGameTimeSeconds()
					AISendChat(aitarget, ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'nuketaunt')
				end
				local antiNukes = aiBrain:GetNumUnitsAroundPoint( categories.ANTIMISSILE * categories.TECH3 * categories.STRUCTURE, tarPosition, 80, 'Enemy' )
				for k, v in Nukes do
					if v:GetNukeSiloAmmoCount() > 0 and not fired[v] then
						IssueNuke( {v}, tarPosition )
						nukeCount = nukeCount - 1
						fireCount = fireCount + 1
						fired[v] = true
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

function trim(s)
	return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function GetArmyData(army)
    local result
    if type(army) == 'string' then
        for i, v in ArmyBrains do
            if v.Nickname == army then
                result = v
                break
            end
        end
    end
    return result
end

function IsAIArmy(army)
    if type(army) == 'string' then
        for i, v in ArmyBrains do
			if v.Nickname == army and v.BrainType == 'AI' then
				return true
			end
        end
	elseif type(army) == 'number' then
		if ArmyBrains[army].BrainType == 'AI' then
			return true		
		end
	end
    return false
end

function AIHasAlly(army)
	for k, v in ArmyBrains do
		if IsAlly(army:GetArmyIndex(), v:GetArmyIndex()) and army:GetArmyIndex() != v:GetArmyIndex() and not v:IsDefeated() then
			return true
		end
	end
	return false
end

function TimeConvert(temptime)
	hours = math.floor(temptime / 3600)
	minutes = math.floor(temptime/60)
	seconds = math.floor(math.mod(temptime, 60))
	returntext = tostring(hours)..':'..tostring(minutes)..':'..tostring(seconds)
	return returntext
end