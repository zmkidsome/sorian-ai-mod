do
local UCBC = import('/lua/editor/UnitCountBuildConditions.lua')

function NukeCheck(aiBrain)
	local SUtils = import('/lua/AI/sorianutilities.lua')
	local Nukes
	local lastNukes = 0
	local waitcount = 0
	local rollcount = 0	
	local nukeCount = 0
	local numNukes = aiBrain:GetCurrentUnits( categories.NUKE * categories.SILO * categories.STRUCTURE * categories.TECH3 )
	#LOG('*NukeCheck Starting')
	while true do
		lastNukes = numNukes
		repeat
			WaitSeconds(60)
			waitcount = 0
			nukeCount = 0
			numNukes = aiBrain:GetCurrentUnits( categories.NUKE * categories.SILO * categories.STRUCTURE )
			Nukes = aiBrain:GetListOfUnits( categories.NUKE * categories.SILO * categories.STRUCTURE, true )
			for k, v in Nukes do
				if k < 2 then
					waitcount = v:GetWorkProgress() * 100
				end
				if v:GetNukeSiloAmmoCount() > 0 then
					nukeCount = nukeCount + 1
				end            
			end
			if nukeCount > 0 and lastNukes > 0 then				
				WaitSeconds(5)
				SUtils.Nuke(aiBrain)
				#LOG('*AI DEBUG: Moving on!')				
				rollcount = 0
			end
		until numNukes > lastNukes and waitcount < 75 and rollcount < 2
		Nukes = aiBrain:GetListOfUnits( categories.NUKE * categories.SILO * categories.STRUCTURE, true )
		rollcount = rollcount + (numNukes - lastNukes)
		
		for k, v in Nukes do
			#v:SetAutoMode(false)
			IssueStop({v})
			#LOG('*NukeCheck 4 Nuke Off: ', v)
		end
			
		WaitSeconds(5)
			
		for k, v in Nukes do
			v:SetAutoMode(true)
			#LOG('*NukeCheck 5 Nuke On: ', v)
		end
	end
end

local SurfacePrioritiesSorian = { 
    'COMMAND',
    'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE',
	'EXPERIMENTAL STRATEGIC STRUCTURE',
	'TECH3 STRATEGIC STRUCTURE',
    'TECH3 ENERGYPRODUCTION STRUCTURE',
    'TECH2 ENERGYPRODUCTION STRUCTURE',
    'TECH3 MASSEXTRACTION STRUCTURE',
    'TECH3 INTELLIGENCE STRUCTURE',
    'TECH2 INTELLIGENCE STRUCTURE',
    'TECH1 INTELLIGENCE STRUCTURE',
    'TECH3 SHIELD STRUCTURE',
    'TECH2 SHIELD STRUCTURE',
    'TECH2 MASSEXTRACTION STRUCTURE',
    'TECH3 FACTORY LAND STRUCTURE',
    'TECH3 FACTORY AIR STRUCTURE',
    'TECH3 FACTORY NAVAL STRUCTURE',
    'TECH2 FACTORY LAND STRUCTURE',
    'TECH2 FACTORY AIR STRUCTURE',
    'TECH2 FACTORY NAVAL STRUCTURE',
    'TECH1 FACTORY LAND STRUCTURE',
    'TECH1 FACTORY AIR STRUCTURE',
    'TECH1 FACTORY NAVAL STRUCTURE',
    'TECH1 MASSEXTRACTION STRUCTURE',
    'TECH3 STRUCTURE',
    'TECH2 STRUCTURE',
    'TECH1 STRUCTURE',
    'TECH3 MOBILE LAND',
    'TECH2 MOBILE LAND',
    'TECH1 MOBILE LAND',
    'EXPERIMENTAL LAND',
}

function CDRRunAwaySorian( aiBrain, cdr )
	local shieldPercent
	local cdrPos = cdr:GetPosition()
	
	cdr.UnitBeingBuiltBehavior = false
	
	if (cdr:HasEnhancement( 'Shield' ) or cdr:HasEnhancement( 'ShieldGeneratorField' ) or cdr:HasEnhancement( 'ShieldHeavy' )) and cdr:ShieldIsOn() then
		shieldPercent = (cdr.MyShield:GetHealth() / cdr.MyShield:GetMaxHealth())
	else
		shieldPercent = 1
	end
	local nmeHardcore = aiBrain:GetNumUnitsAroundPoint( categories.EXPERIMENTAL, cdrPos, 130, 'Enemy' )
	local nmeT3 = aiBrain:GetNumUnitsAroundPoint( categories.LAND * categories.TECH3 - categories.ENGINEER, cdrPos, 50, 'Enemy' )
    if cdr:GetHealthPercent() < .80 or shieldPercent < .30 or nmeHardcore > 0 or nmeT3 > 4 then
        #AIUtils.AIFindDefensiveArea( aiBrain, cdr, categories.DEFENSE * categories.ANTIAIR, 10000 )
        #LOG('*AI DEBUG: ARMY ' .. aiBrain.Nickname .. ': CDR AI ACTIVATE - CDR RUNNING AWAY' )
        local nmeAir = aiBrain:GetNumUnitsAroundPoint( categories.AIR - categories.SCOUT - categories.INTELLIGENCE, cdrPos, 30, 'Enemy' )
        local nmeLand = aiBrain:GetNumUnitsAroundPoint( categories.COMMAND + categories.LAND - categories.ENGINEER - categories.SCOUT - categories.TECH1, cdrPos, 40, 'Enemy' )
		local nmaShield = aiBrain:GetNumUnitsAroundPoint( categories.SHIELD * categories.STRUCTURE, cdrPos, 100, 'Ally' )
        if nmeAir > 4 or nmeLand > 9 or nmeT3 > 4 or nmeHardcore > 0 or cdr:GetHealthPercent() < .80 or shieldPercent < .30 then
			if cdr:GetUnitBeingBuilt() then
				cdr.UnitBeingBuiltBehavior = cdr:GetUnitBeingBuilt()
			end
			cdr.GoingHome = true
            local canTeleport = false #cdr:HasEnhancement( 'Teleporter' )
            CDRRevertPriorityChange( aiBrain, cdr )
			local runShield = false
            local category
				if nmaShield > 0 then
					category = categories.SHIELD * categories.STRUCTURE
					runShield = true
                elseif nmeAir > 3 then
                    category = categories.DEFENSE * categories.ANTIAIR
                else
                    category = categories.DEFENSE * categories.DIRECTFIRE
                end
            local runSpot, prevSpot
            local plat = aiBrain:MakePlatoon( '', '' )
            aiBrain:AssignUnitsToPlatoon( plat, {cdr}, 'support', 'None' )
            repeat                
				#LOG("*AI DEBUG: " .. aiBrain.Nickname .. " running")
				if not aiBrain:PlatoonExists(plat) then 
					#LOG("*AI DEBUG: " .. aiBrain.Nickname .. " not running; no platoon")
					return 
				end
				if canTeleport then
                    runSpot = AIUtils.AIFindDefensiveAreaSorian( aiBrain, cdr, category, 10000, runShield )
                else
                    runSpot = AIUtils.AIFindDefensiveAreaSorian( aiBrain, cdr, category, 100, runShield )
                end
                if not prevSpot or runSpot[1] ~= prevSpot[1] or runSpot[3] ~= prevSpot[3] then
					IssueClearCommands( {cdr} )
                    #plat:Stop()
                    if VDist2( cdrPos[1], cdrPos[3], runSpot[1], runSpot[3] ) >= 10 then
                        if canTeleport then
                            IssueTeleport( {cdr}, runSpot )
                        else
							IssueMove( {cdr}, runSpot )
                            #cmd = plat:MoveToLocation( runSpot, false )
                        end
                    end
                end
                WaitSeconds(3)
                if not cdr:IsDead() then
                    cdrPos = cdr:GetPosition()
                    nmeAir = aiBrain:GetNumUnitsAroundPoint( categories.AIR - categories.SCOUT - categories.INTELLIGENCE, cdrPos, 30, 'Enemy' )
                    nmeLand = aiBrain:GetNumUnitsAroundPoint( categories.COMMAND + categories.LAND - categories.ENGINEER - categories.SCOUT - categories.TECH1, cdrPos, 40, 'Enemy' )
					nmeT3 = aiBrain:GetNumUnitsAroundPoint( categories.LAND * categories.TECH3 - categories.ENGINEER, cdrPos, 50, 'Enemy' )
                    nmeHardcore = aiBrain:GetNumUnitsAroundPoint( categories.EXPERIMENTAL, cdrPos, 130, 'Enemy' )
					if (cdr:HasEnhancement( 'Shield' ) or cdr:HasEnhancement( 'ShieldGeneratorField' ) or cdr:HasEnhancement( 'ShieldHeavy' )) and cdr:ShieldIsOn() then
						shieldPercent = (cdr.MyShield:GetHealth() / cdr.MyShield:GetMaxHealth())
						#LOG('*AI DEBUG: Shield Percent: ', shieldPercent)
					else
						shieldPercent = 1
						#LOG('*AI DEBUG: No Shield')
					end
                end
            until cdr:IsDead() or (cdr:GetHealthPercent() > .85 and shieldPercent > .35 and nmeAir < 5 and nmeLand < 10 and nmeHardcore == 0 and nmeT3 < 5)
			#LOG("*AI DEBUG: " .. aiBrain.Nickname .. " done running")
            cdr.GoingHome = false
			IssueClearCommands( {cdr} )
			if cdr.UnitBeingBuiltBehavior then
				cdr:ForkThread( CDRFinishUnit )
			end
        end
    end 
end


function CDROverChargeSorian( aiBrain, cdr, Mult )
    local weapBPs = cdr:GetBlueprint().Weapon
    local weapon

    for k,v in weapBPs do
        if v.Label == 'OverCharge' then
            weapon = v
            break
        end
    end
    local distressRange = 100
    local beingBuilt = false
    local maxRadius = weapon.MaxRadius * 4.5 * Mult
    cdr.UnitBeingBuiltBehavior = false
	
    local cdrPos = cdr.CDRHome
	local numUnits1 = aiBrain:GetNumUnitsAroundPoint( categories.LAND * categories.TECH1 - categories.SCOUT - categories.ENGINEER, cdrPos, maxRadius, 'Enemy' )
	local numUnits2 = aiBrain:GetNumUnitsAroundPoint( categories.LAND * categories.TECH2 - categories.SCOUT - categories.ENGINEER, cdrPos, maxRadius, 'Enemy' )
	local numUnits3 = aiBrain:GetNumUnitsAroundPoint( categories.LAND * categories.TECH3 - categories.SCOUT - categories.ENGINEER, cdrPos, maxRadius, 'Enemy' )
	local numUnits4 = aiBrain:GetNumUnitsAroundPoint( categories.EXPERIMENTAL, cdrPos, maxRadius + 130, 'Enemy' )
	local numStructs = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE, cdrPos, maxRadius, 'Enemy' )
	local numUnitsDF = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE - categories.TECH1, cdrPos, maxRadius + 50, 'Enemy' )
	local numUnitsDF1 = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE * categories.TECH1, cdrPos, maxRadius + 30, 'Enemy' )
	local numUnitsIF = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.STRUCTURE * categories.INDIRECTFIRE - categories.TECH1, cdrPos, maxRadius + 260, 'Enemy' )
	local totalUnits = numUnits1 + numUnits2 + numUnits3 + numUnits4 + numStructs
    local distressLoc = aiBrain:BaseMonitorDistressLocation(cdrPos)
	if (cdr:HasEnhancement( 'Shield' ) or cdr:HasEnhancement( 'ShieldGeneratorField' ) or cdr:HasEnhancement( 'ShieldHeavy' )) and cdr:ShieldIsOn() then
		shieldPercent = (cdr.MyShield:GetHealth() / cdr.MyShield:GetMaxHealth())
		#LOG('*AI DEBUG: Shield Percent: ', shieldPercent)
	else
		shieldPercent = 1
		#LOG('*AI DEBUG: No Shield')
	end
	
    local overCharging = false
    
    if Utilities.XZDistanceTwoVectors(cdrPos, cdr:GetPosition()) > distressRange * Mult then
        return
    end
	
	if distressLoc then
		local distressUnitsNaval = aiBrain:GetNumUnitsAroundPoint( categories.NAVAL, distressLoc, 40, 'Enemy' ) 
		local distressUnitsAir = aiBrain:GetNumUnitsAroundPoint( categories.AIR * (categories.BOMBER + categories.GROUNDATTACK + categories.ANTINAVY), distressLoc, 30, 'Enemy' ) 
		local distressUnitsexp = aiBrain:GetNumUnitsAroundPoint( categories.EXPERIMENTAL, distressLoc, 50, 'Enemy' )
		#LOG('*AI DEBUG: AIBehavior Distress Call')
		if distressUnitsNaval > 0 then					
			if cdr:HasEnhancement( 'NaniteTorpedoTube' ) and distressUnitsNaval < 5 and distressUnitsexp < 1 then
				commanderResponse = true
				#LOG('*AI DEBUG: AIBehavior Commander Has Enhancement')
			else
				commanderResponse = false
				#LOG('*AI DEBUG: AIBehavior Commander Does Not Have Enhancement!')
			end
		elseif distressUnitsAir > 0 then
			commanderResponse = false
			#LOG('*AI DEBUG: AIBehavior Cannot Attack Air!')					
		elseif distressUnitsexp > 0 then
			commanderResponse = false
			#LOG('*AI DEBUG: AIBehavior Experimental In Range!')
		elseif numUnits1 > 14 or numUnits2 > 9 or numUnits3 > 4 or numUnits4 > 0 or numUnitsDF > 0 or numUnitsIF > 0 or numUnitsDF1 > 2 then
			commanderResponse = false
		else
			commanderResponse = true
			#LOG('*AI DEBUG: AIBehavior Safe to Respond')
		end
	end
    
    if (cdr:GetHealthPercent() > .85 and shieldPercent > .35) and (( totalUnits > 0 and numUnits1 < 15 and numUnits2 < 10 and numUnits3 < 5 and numUnits4 < 1 and numUnitsDF1 < 3 and numUnitsDF < 1 and numUnitsIF < 1) or ( not cdr.DistressCall and distressLoc and commanderResponse and Utilities.XZDistanceTwoVectors( distressLoc, cdrPos ) < distressRange )) then
        CDRRevertPriorityChange( aiBrain, cdr )
        if cdr:GetUnitBeingBuilt() then
            #LOG('*AI DEBUG: ARMY ' .. aiBrain:GetArmyIndex() .. ': CDR was building something')
            cdr.UnitBeingBuiltBehavior = cdr:GetUnitBeingBuilt()
        end
		cdr.Fighting = true
        local plat = aiBrain:MakePlatoon( '', '' )
        aiBrain:AssignUnitsToPlatoon( plat, {cdr}, 'support', 'None' )
        plat:Stop()
        local priList = { categories.TECH3 * categories.INDIRECTFIRE,
            categories.TECH3 * categories.MOBILE, categories.TECH2 * categories.INDIRECTFIRE, categories.MOBILE * categories.TECH2,
            categories.TECH1 * categories.INDIRECTFIRE, categories.TECH1 * categories.MOBILE, categories.CONSTRUCTION * categories.STRUCTURE, categories.ECONOMIC * categories.STRUCTURE, categories.ALLUNITS }
        #LOG('*AI DEBUG: ARMY ' .. aiBrain.Nickname .. ': CDR AI ACTIVATE - Commander go fight stuff! -- ' .. totalUnits)
        local target
        local continueFighting = true
        local counter = 0
        
        local cdrThreat = cdr:GetBlueprint().Defense.SurfaceThreatLevel or 75
        local enemyThreat
        repeat
            #LOG("*AI DEBUG: " .. aiBrain.Nickname .. " overcharging")
            overCharging = false
            if counter >= 5 or not target or target:IsDead() or Utilities.XZDistanceTwoVectors(cdrPos, target:GetPosition()) > maxRadius then
                counter = 0
                for k,v in priList do
                    target = plat:FindClosestUnit( 'Support', 'Enemy', true, v )
                    if target and Utilities.XZDistanceTwoVectors(cdrPos, target:GetPosition()) < maxRadius then
                        local cdrLayer = cdr:GetCurrentLayer()
                        local targetLayer = target:GetCurrentLayer()
                        if not (cdrLayer == 'Land' and (targetLayer == 'Air' or targetLayer == 'Sub' or targetLayer == 'Seabed')) and
                           not (cdrLayer == 'Seabed' and (targetLayer == 'Air' or targetLayer == 'Water')) then
                            break
                        end
                    end
                    target = false
                end
                if target then
                    local targetPos = target:GetPosition()
                    enemyThreat = aiBrain:GetThreatAtPosition( targetPos, 1, true, 'AntiSurface')
					enemyCdrThreat = aiBrain:GetThreatAtPosition( targetPos, 1, true, 'Commander')
					friendlyThreat = aiBrain:GetThreatAtPosition( targetPos, 1, true, 'AntiSurface', aiBrain:GetArmyIndex() )
                    if enemyThreat - enemyCdrThreat >= friendlyThreat + (cdrThreat / 2) then
                        return
                    end
                    if aiBrain:GetEconomyStored('ENERGY') >= weapon.EnergyRequired and target and not target:IsDead() then
					#LOG("*AI DEBUG: " .. aiBrain.Nickname .. " issue OC")
                        overCharging = true
                        IssueClearCommands({cdr})
                        IssueOverCharge( {cdr}, target )
                    elseif target and not target:IsDead() then
					#LOG("*AI DEBUG: " .. aiBrain.Nickname .. " attacking")
                        local tarPos = target:GetPosition()
                        IssueClearCommands( {cdr} )
                        IssueMove( {cdr}, tarPos )
                        IssueMove( {cdr}, cdr.CDRHome )
                    end
                elseif distressLoc then
                    enemyThreat = aiBrain:GetThreatAtPosition( distressLoc, 1, true, 'AntiSurface')
					enemyCdrThreat = aiBrain:GetThreatAtPosition( distressLoc, 1, true, 'Commander')
					friendlyThreat = aiBrain:GetThreatAtPosition( distressLoc, 1, true, 'AntiSurface', aiBrain:GetArmyIndex() )
                    if enemyThreat - enemyCdrThreat >= friendlyThreat + (cdrThreat / 2) then
                        return
                    end                
                    if distressLoc and ( Utilities.XZDistanceTwoVectors( distressLoc, cdrPos ) < distressRange ) then
                        IssueClearCommands( {cdr} )
                        IssueMove( {cdr}, distressLoc )
                        IssueMove( {cdr}, cdr.CDRHome )
                    end
				#else
					#LOG('*AI DEBUG: No Target or DistressLoc')
                end
            end
            if overCharging then
                while target and not target:IsDead() and not cdr:IsDead() and counter <= 5 do
                    WaitSeconds(0.5)
                    counter = counter + 0.5
                end
            else
                WaitSeconds(5)
                counter = counter + 5
            end
            distressLoc = aiBrain:BaseMonitorDistressLocation(cdrPos)
            if cdr:IsDead() then
                return
            end
			if (cdr:HasEnhancement( 'Shield' ) or cdr:HasEnhancement( 'ShieldGeneratorField' ) or cdr:HasEnhancement( 'ShieldHeavy' )) and cdr:ShieldIsOn() then
				shieldPercent = (cdr.MyShield:GetHealth() / cdr.MyShield:GetMaxHealth())
				#LOG('*AI DEBUG: Shield Percent: ', shieldPercent)
			else
				shieldPercent = 1
				#LOG('*AI DEBUG: No Shield')
			end
            if (( aiBrain:GetNumUnitsAroundPoint( categories.LAND - categories.SCOUT, cdrPos, maxRadius, 'Enemy' ) == 0 )
                and ( not distressLoc or ( Utilities.XZDistanceTwoVectors( distressLoc, cdrPos ) > distressRange )
                and ( Utilities.XZDistanceTwoVectors(cdr.CDRHome, cdr:GetPosition()) < maxRadius ) )) or ( aiBrain:GetNumUnitsAroundPoint( categories.LAND - categories.SCOUT, cdrPos, maxRadius, 'Enemy' )) >= 15 or (cdr:GetHealthPercent() < .80 or shieldPercent < .30) then
                continueFighting = false
            end           
        until not continueFighting or not aiBrain:PlatoonExists(plat)
		#if not aiBrain:PlatoonExists(plat) then
		#	LOG("*AI DEBUG: " .. aiBrain.Nickname .. " overcharge platoon gone")
		#end
        #LOG("*AI DEBUG: " .. aiBrain.Nickname .. " done overcharging")
		cdr.Fighting = false
        IssueClearCommands( {cdr} )
        if overCharging then
			IssueMove( {cdr}, cdr.CDRHome )
        end
		if cdr.UnitBeingBuiltBehavior then
			cdr:ForkThread( CDRFinishUnit )
		end
    end
end

function CDRReturnHomeSorian(aiBrain, cdr, Mult)
    local loc, rad
    loc = cdr.CDRHome
    rad = 100 * Mult
    # this is a reference... so it will autoupdate
    local cdrPos = cdr:GetPosition()
    local distSqAway = rad #1600
    if not cdr:IsDead() and VDist2(cdrPos[1], cdrPos[3], loc[1], loc[3]) > distSqAway then
        local plat = aiBrain:MakePlatoon( '', '' )
        aiBrain:AssignUnitsToPlatoon( plat, {cdr}, 'support', 'None' )
        repeat
            #LOG("*AI DEBUG: " .. aiBrain.Nickname .. " going home")
            CDRRevertPriorityChange( aiBrain, cdr )
			cdr.GoingHome = true
            if not aiBrain:PlatoonExists(plat) then 
                return 
            end
            IssueMove( {cdr}, loc )
            WaitSeconds(7)
			cdrPos = cdr:GetPosition()
       until cdr:IsDead() or VDist2(cdrPos[1], cdrPos[3], loc[1], loc[3]) <= distSqAway
       cdr.GoingHome = false
       IssueClearCommands( {cdr} )
       #LOG("*AI DEBUG: " .. aiBrain.Nickname .. " done going home")
    end

end

function CDRFinishUnit( cdr )
	local aiBrain = cdr:GetAIBrain()
    if cdr.UnitBeingBuiltBehavior and not cdr.UnitBeingBuiltBehavior:BeenDestroyed() then
		#LOG("*AI DEBUG: " .. aiBrain.Nickname .. " Finishing unit")
        IssueClearCommands( {cdr} )
        IssueRepair( {cdr}, cdr.UnitBeingBuiltBehavior )
        repeat
            WaitSeconds(1)
			if cdr.GoingHome or cdr:IsUnitState("Attacking") or cdr.Fighting then
				return
			end
        until cdr:IsIdleState()
		cdr.UnitBeingBuiltBehavior = false
    end
end

function CommanderBehaviorSorian(platoon)
    for k,v in platoon:GetPlatoonUnits() do
        if not v:IsDead() and not v.CommanderThread then
            v.CommanderThread = v:ForkThread( CommanderThreadSorian, platoon )
        end
    end
end

function CDRHideBehavior(aiBrain, cdr)
	if cdr:IsIdleState() then
		local category = false
		local runShield = false
		local nmaShield = aiBrain:GetNumUnitsAroundPoint( categories.SHIELD * categories.STRUCTURE, cdr:GetPosition(), 100, 'Ally' )
		local nmaPD = aiBrain:GetNumUnitsAroundPoint( categories.DIRECTFIRE * categories.DEFENSE, cdr:GetPosition(), 100, 'Ally' )
		local nmaAA = aiBrain:GetNumUnitsAroundPoint( categories.ANTIAIR * categories.DEFENSE, cdr:GetPosition(), 100, 'Ally' )
		if nmaShield > 0 then
			category = categories.SHIELD * categories.STRUCTURE
			runShield = true
		elseif nmaAA > 0 then
			category = categories.DEFENSE * categories.ANTIAIR
		elseif nmaPD > 0 then
			category = categories.DEFENSE * categories.DIRECTFIRE
		end
		if category then
			local baseLocation = AIUtils.AIFindDefensiveAreaSorian( aiBrain, cdr, category, 100, runShield )
			IssueMove( {cdr}, baseLocation )
		end
	end
end

function CommanderThread(cdr, platoon)
    local aiBrain = cdr:GetAIBrain()
    
    SetCDRHome(cdr, platoon)
	
	aiBrain:BuildScoutLocations()
    
    while not cdr:IsDead() do

        WaitTicks(2)
        # Overcharge
        if not cdr:IsDead() then CDROverCharge( aiBrain, cdr ) end
        WaitTicks(1)
        # Run away (not really useful right now, without teleport ability kicking in... might as well just go home)
        #if not cdr:IsDead() then CDRRunAway( aiBrain, cdr ) end
        #WaitTicks(1)
        # Go back to base
        if not cdr:IsDead() then CDRReturnHome( aiBrain, cdr ) end
        WaitTicks(1)
        
        #call platoon resume building deal...
        if not cdr:IsDead() and cdr:IsIdleState() then
            if not cdr.EngineerBuildQueue or table.getn(cdr.EngineerBuildQueue) == 0 then
                local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
                aiBrain:AssignUnitsToPlatoon( pool, {cdr}, 'Unassigned', 'None' )
            elseif cdr.EngineerBuildQueue and table.getn(cdr.EngineerBuildQueue) != 0 then
                if not cdr.NotBuildingThread then
                    cdr.NotBuildingThread = cdr:ForkThread(platoon.WatchForNotBuilding)
                end             
            end
        end        
    end
end

function CommanderThreadSorian(cdr, platoon)
    local aiBrain = cdr:GetAIBrain()
	Mult = platoon.PlatoonData.Mult or 1
	Delay = platoon.PlatoonData.Delay or 0
    
    SetCDRHome(cdr, platoon)
    
	aiBrain:BuildScoutLocations()
	moveOnNext = false
	moveWait = 0
    while not cdr:IsDead() do
		#LOG('*AI DEBUG: '.. aiBrain.Nickname ..' CommanderThread Loop')
        WaitTicks(2)
        # Overcharge
        if not cdr:IsDead() and GetGameTimeSeconds() > Delay and UCBC.HaveGreaterThanUnitsWithCategory(aiBrain,  1, 'FACTORY') then CDROverChargeSorian( aiBrain, cdr, Mult ) end
        WaitTicks(1)
        # Run away (not really useful right now, without teleport ability kicking in... might as well just go home)
        if not cdr:IsDead() then CDRRunAwaySorian( aiBrain, cdr ) end
        WaitTicks(1)
        # Go back to base
        if not cdr:IsDead() then CDRReturnHomeSorian( aiBrain, cdr, Mult ) end
        WaitTicks(1)
        if not cdr:IsDead() and cdr:IsIdleState() and moveOnNext then 
			CDRHideBehavior( aiBrain, cdr ) 
			moveOnNext = false
		end
        WaitTicks(1)
		if not cdr:IsDead() and not cdr:IsIdleState() and moveWait > 0 then moveWait = 0 end
		if not cdr:IsDead() and cdr:IsIdleState() and not moveOnNext then 
			moveWait = moveWait + 1
			if moveWait >= 10 then
				moveWait = 0
				moveOnNext = true
			end
		end
		WaitTicks(1)
		
        #call platoon resume building deal...
        if not cdr:IsDead() and cdr:IsIdleState() and not cdr.GoingHome and not cdr.Fighting and not cdr:IsUnitState("Building")
		and not cdr:IsUnitState("Attacking") and not cdr:IsUnitState("Repairing") and not cdr.UnitBeingBuiltBehavior and not cdr:IsUnitState("Upgrading") 
		and not ( Utilities.XZDistanceTwoVectors(cdr.CDRHome, cdr:GetPosition()) > 250 ) then
            if not cdr.EngineerBuildQueue or table.getn(cdr.EngineerBuildQueue) == 0 then
                local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
                aiBrain:AssignUnitsToPlatoon( pool, {cdr}, 'Unassigned', 'None' )
            elseif cdr.EngineerBuildQueue and table.getn(cdr.EngineerBuildQueue) != 0 then
                if not cdr.NotBuildingThread then
                    cdr.NotBuildingThread = cdr:ForkThread(platoon.WatchForNotBuildingSorian)
                end             
            end
        end        
    end
end

function AirUnitRefit(self)
    for k,v in self:GetPlatoonUnits() do
        if not v:IsDead() and not v.RefitThread then
            v.RefitThread = v:ForkThread( AirUnitRefitThread, self:GetPlan(), self.PlatoonData )
        end
    end
end

AssignExperimentalPrioritiesSorian = function(platoon)
	local experimental = GetExperimentalUnit(platoon)
	if experimental then
    	experimental:SetLandTargetPriorities( SurfacePrioritiesSorian )
	end
end

WreckBaseSorian = function(self, base)   
    for _, priority in SurfacePrioritiesSorian do
        local numUnitsAtBase = 0
        local notDeadUnit = false
        local unitsAtBase = self:GetBrain():GetUnitsAroundPoint(ParseEntityCategory(priority), base.Position, 100, 'Enemy')
        
        for _,unit in unitsAtBase do
            if not unit:IsDead() then
                notDeadUnit = unit
                numUnitsAtBase = numUnitsAtBase + 1
            end
        end        
        
        if numUnitsAtBase > 0 then
            return notDeadUnit, base
        end
    end
end

FindExperimentalTargetSorian = function(self)
    local aiBrain = self:GetBrain()
    local enemyBases = aiBrain.InterestList.HighPriority
   
    if not aiBrain.InterestList or not aiBrain.InterestList.HighPriority then
        #No target. :(
        return
    end
   
    #For each priority in SurfacePriorities list, check against each enemy base we're aware of (through scouting/intel),
    #The base with the most number of the highest-priority targets gets selected. If there's a tie, pick closer. 
    for _, priority in SurfacePrioritiesSorian do
        local bestBase = false
        local mostUnits = 0
        local bestUnit = false
        
        for _, base in enemyBases do
            local unitsAtBase = aiBrain:GetUnitsAroundPoint(ParseEntityCategory(priority), base.Position, 100, 'Enemy')
            local numUnitsAtBase = 0
            local notDeadUnit = false
            
            for _,unit in unitsAtBase do
                if not unit:IsDead() then
                    notDeadUnit = unit
                    numUnitsAtBase = numUnitsAtBase + 1
                end
            end
            
            if numUnitsAtBase > 0 then
                if numUnitsAtBase > mostUnits then
                    bestBase = base
                    mostUnits = numUnitsAtBase
                    bestUnit = notDeadUnit
                elseif numUnitsAtBase == mostUnits then
                    local myPos = self:GetPlatoonPosition()
                    local dist1 = VDist2(myPos[1], myPos[3], base.Position[1], base.Position[3])
                    local dist2 = VDist2(myPos[1], myPos[3], bestBase.Position[1], bestBase.Position[3])
                    
                    if dist1 < dist2 then
                        bestBase = base
                        bestUnit = notDeadUnit
                    end
                end
            end
        end
        
        if bestBase and bestUnit then
            return bestUnit, bestBase
        end
    end
end

function FatBoyBehaviorSorian(self)   
    local aiBrain = self:GetBrain()
    AssignExperimentalPrioritiesSorian(self)
    
    local experimental = GetExperimentalUnit(self)
    local targetUnit = false
    local lastBase = false
    local airUnit = EntityCategoryContains(categories.AIR, experimental)
    
    local mainWeapon = experimental:GetWeapon(1)
    local weaponRange = mainWeapon:GetBlueprint().MaxRadius
    
    experimental.Platoons = experimental.Platoons or {}
    
    #Find target loop
    while experimental and not experimental:IsDead() do
        targetUnit, lastBase = FindExperimentalTargetSorian(self)
        
        if targetUnit then
            IssueClearCommands({experimental})
            IssueAttack({experimental}, targetUnit)       
        
            local pos = experimental:GetPosition()
            
            #Wait to get in range
            while VDist2(pos[1], pos[3], lastBase.Position[1], lastBase.Position[3]) > weaponRange + 50
            and not experimental:IsDead() and not experimental:IsIdleState() do
                WaitSeconds(5)
            end
            
            IssueClearCommands({experimental})
            
            #Send our homies to wreck this base
            local goodList = {}
            for _, platoon in experimental.Platoons do
                local platoonUnits = false
                
                if aiBrain:PlatoonExists(platoon) then
                    platoonUnits = platoon:GetPlatoonUnits()
                end
                
                if platoonUnits and table.getn(platoonUnits) > 0 then
                    table.insert(goodList, platoon)
                end
            end
            
            experimental.Platoons = goodList
            
            for _, platoon in goodList do
                platoon:ForkAIThread(FatboyChildBehavior, experimental, lastBase)
            end
            
            #Setup shop outside this guy's base
            while not experimental:IsDead() and WreckBaseSorian(self, lastBase) do
                #Build stuff if we haven't hit the unit cap.
                FatBoyBuildCheck(self)
                
                #Once we have 20 units, form them into a platoon and send them to attack the base we're attacking!
                if experimental.NewPlatoon and table.getn(experimental.NewPlatoon:GetPlatoonUnits()) >= 20 then
                    experimental.NewPlatoon:ForkAIThread(FatboyChildBehavior, experimental, lastBase)
                    
                    table.insert(experimental.Platoons, experimental.NewPlatoon)
                    experimental.NewPlatoon = nil
                end
                            
                WaitSeconds(1)
            end
        end
    
        WaitSeconds(1)
    end
end

TempestBehaviorSorian = function(self)
    local aiBrain = self:GetBrain()
    local unit
    for k,v in self:GetPlatoonUnits() do
        if not v:IsDead() then
            unit = v
            break
        end
    end
    if not unit then
        return
    end
    if not EntityCategoryContains( categories.uas0401, unit ) then
        return
    end
    local otherPlat
    unit.BuiltUnitCount = 0
    self.Patrolling = false
    while aiBrain:PlatoonExists(self) and not unit:IsDead() do
        local position = unit:GetPosition()
        local numStrucs = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE - ( categories.MASSEXTRACTION + categories.WALL ), position, 65, 'Enemy' )
        local numNaval = aiBrain:GetNumUnitsAroundPoint( ( categories.MOBILE * categories.NAVAL ) * ( categories.EXPERIMENTAL + categories.TECH3 + categories.TECH2 ), position, 65, 'Enemy' )
        while unit.BuiltUnitCount < 8 and ( numStrucs > 5 or numNaval > 10 ) do
            self.Patrolling = false
            self.BreakOff = true
            local numAir = aiBrain:GetNumUnitsAroundPoint( ( categories.MOBILE * categories.AIR ) * ( categories.EXPERIMENTAL + categories.TECH3 ), position, 65, 'Enemy' )
            local numDef = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE * ( categories.DEFENSE + categories.STRATEGIC ), position, 75, 'Enemy' )
            local unitToBuild = false
            if numDef > numNaval and numDef > numAir then
                if Random(1,2) == 1 then
                    unitToBuild = 'uas0201'
                else
                    unitToBuild = 'uas0201'
                    #unitToBuild = 'ual0309'
                end
                # Build fatboy protectin
            elseif numNaval > numStrucs and numNaval > numAir then
                unitToBuild = 'uas0203'
                # Build Land killin
            elseif numStrucs > numAir and numStrucs > numLand then
                unitToBuild = 'uas0201'
                # Build struc killin
            else
                unitToBuild = 'uas0202'
                # build air killin
            end
            if unitToBuild then
                IssueStop( {unit} )
                IssueClearCommands( {unit} )
                aiBrain:BuildUnit( unit, unitToBuild, 1 )
            end
            local unitBeingBuilt = false
            local building
            repeat
                WaitSeconds(5)
                unitBeingBuilt = unit:GetUnitBeingBuilt()
                building = false
                for k,v in self:GetPlatoonUnits() do
                    if not v:IsDead() and v:IsUnitState('Building') then
                        building = true
                        break
                    end
                end
            until not building
            if unitBeingBuilt and not unitBeingBuilt:IsDead() then
                local testHeading = false
                testHeading = unit:GetHeading()
                unit.BuiltUnitCount = unit.BuiltUnitCount + 1
                ScenarioFramework.CreateUnitDestroyedTrigger( TempestUnitDeath, unitBeingBuilt )
                aiBrain:AssignUnitsToPlatoon( self, {unitBeingBuilt}, 'Attack', 'GrowthFormation' )
                IssueClearCommands( {unitBeingBuilt} )
                unitBeingBuilt:ForkThread( TempestBuiltUnitMoveOut, position, testHeading )
            end
            self.BreakOff = false
            numStrucs = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE - ( categories.MASSEXTRACTION + categories.WALL ), position, 65, 'Enemy' )
            numNaval = aiBrain:GetNumUnitsAroundPoint( ( categories.MOBILE * categories.NAVAL ) * ( categories.EXPERIMENTAL + categories.TECH3 + categories.TECH2 ), position, 65, 'Enemy' )
        end
        if aiBrain:PlatoonExists(self) and self:IsOpponentAIRunning() and not self.Patrolling then
            self:Stop()
            self.Patrolling = true
            scoutPath = AIUtils.AIGetSortedNavalLocations(self:GetBrain())
            for k, v in scoutPath do
                self:Patrol(v)
            end
        end
        WaitSeconds( 5 )
    end
end

CzarBehaviorSorian = function(self)
    local aiBrain = self:GetBrain()
    local experimental = GetExperimentalUnit(self)
    if not experimental then
        return
    end
    if not EntityCategoryContains( categories.uaa0310, experimental ) then
        return
    end
    
    AssignExperimentalPrioritiesSorian(self)
    
    local targetUnit, targetBase = FindExperimentalTargetSorian(self)
    local oldTargetUnit, attackedUnit = nil
    while not experimental:IsDead() do

        if targetUnit and attackedUnit != targetUnit and VDist3( targetUnit:GetPosition(), experimental:GetPosition() ) < 100 then
            IssueClearCommands({experimental})
            WaitTicks(5)
            IssueAttack({experimental}, experimental:GetPosition())
            WaitTicks(5)
            IssueMove({experimental}, targetUnit:GetPosition())
			attackedUnit = targetUnit
		elseif targetUnit and oldTargetUnit != targetUnit then
		    IssueClearCommands({experimental})
            WaitTicks(5)
			IssueMove({experimental}, targetUnit:GetPosition())
			attackedUnit = nil
        end        
        
        local nearCommander = CommanderOverrideCheck(self)
        local oldCommander = nil
        while nearCommander and not experimental:IsDead() and not experimental:IsIdleState() do
            
            if nearCommander and nearCommander != oldCommander and nearCommander != targetUnit then
                IssueClearCommands({experimental})
                WaitTicks(5)
                IssueAttack({experimental}, experimental:GetPosition())
                WaitTicks(5)
                IssueMove({experimental}, nearCommander:GetPosition())
                targetUnit = nearCommander
				attackedUnit = nil
            end
            
            WaitSeconds(1)
            oldCommander = nearCommander
            nearCommander = CommanderOverrideCheck(self)
        end
    
        WaitSeconds(1)
        oldTargetUnit = targetUnit
        targetUnit, targetBase = FindExperimentalTargetSorian(self)
    end
end

AhwassaBehaviorSorian = function(self)
    local aiBrain = self:GetBrain()
    local experimental = GetExperimentalUnit(self)
    if not experimental then
        return
    end
    if not EntityCategoryContains( categories.xsa0402, experimental ) then
        return
    end
    
    AssignExperimentalPrioritiesSorian(self)
    local targetLocation = GetHighestThreatClusterLocation(aiBrain, experimental)
    local oldTargetLocation = nil
    while not experimental:IsDead() do

        if targetLocation and targetLocation != oldTargetLocation then
            IssueClearCommands({experimental})
            IssueAttack({experimental}, targetLocation)           
            WaitSeconds(25)
        end
       
        WaitSeconds(1)
        oldTargetLocation = targetLocation
        targetLocation = GetHighestThreatClusterLocation(aiBrain, experimental)
    end
end

TickBehaviorSorian = function(self)
    local aiBrain = self:GetBrain()
    local experimental = GetExperimentalUnit(self)
    if not experimental then
        return
    end
    if not EntityCategoryContains( categories.ura0401, experimental ) then
        return
    end
    
    AssignExperimentalPrioritiesSorian(self)
    local targetLocation = GetHighestThreatClusterLocation(aiBrain, experimental)
    local oldTargetLocation = nil
    while not experimental:IsDead() do

        if targetLocation and targetLocation != oldTargetLocation then
            IssueClearCommands({experimental})
            IssueAggressiveMove({experimental}, targetLocation)           
            WaitSeconds(25)
        end
       
        WaitSeconds(1)
        oldTargetLocation = targetLocation
        targetLocation = GetHighestThreatClusterLocation(aiBrain, experimental)
    end
end

function BehemothBehaviorSorian(self)   
    AssignExperimentalPrioritiesSorian(self)
    
    local experimental = GetExperimentalUnit(self)
    local targetUnit = false
    local lastBase = false
    local airUnit = EntityCategoryContains(categories.AIR, experimental)
    
    #Find target loop
    while experimental and not experimental:IsDead() do
        if lastBase then
            targetUnit, lastBase = WreckBaseSorian(self, lastBase)
        end
        if not lastBase then
            targetUnit, lastBase = FindExperimentalTargetSorian(self)
        end
        
        if targetUnit then
            IssueClearCommands({experimental})
            IssueAttack({experimental}, targetUnit)
        end
        
        #Walk to and kill target loop
        while not experimental:IsDead() and not experimental:IsIdleState() do
            local nearCommander = CommanderOverrideCheck(self)
            
            if nearCommander and nearCommander ~= targetUnit then
                IssueClearCommands({experimental})
                IssueAttack({experimental}, nearCommander)
                targetUnit = nearCommander
            end
            
            #Check if we or the target are under a shield
            local closestBlockingShield = false
            if not airUnit then
                closestBlockingShield = GetClosestShieldProtectingTarget(experimental, experimental) 
            end
            closestBlockingShield = closestBlockingShield or GetClosestShieldProtectingTarget(experimental, targetUnit)
            
            #Kill shields loop
            while closestBlockingShield do
                IssueClearCommands({experimental})
                IssueAttack({experimental}, closestBlockingShield)
                
                #Wait for shield to die loop
                while not closestBlockingShield:IsDead() and not experimental:IsDead() do
                    WaitSeconds(1)
                end             

                closestBlockingShield = false
                if not airUnit then
                    closestBlockingShield = GetClosestShieldProtectingTarget(experimental, experimental) 
                end
                closestBlockingShield = closestBlockingShield or GetClosestShieldProtectingTarget(experimental, targetUnit)
                
                WaitTicks(1)
            end
            
            WaitSeconds(1)
        end
    
        WaitSeconds(1)
    end
end

end