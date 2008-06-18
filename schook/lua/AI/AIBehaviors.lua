do
local UCBC = import('/lua/editor/UnitCountBuildConditions.lua')
local SBC = import('/lua/editor/SorianBuildConditions.lua')
local SUtils = import('/lua/AI/sorianutilities.lua')

function NukeCheck(aiBrain)
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
				if v:GetWorkProgress() * 100 > waitcount then
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
		until numNukes > lastNukes and waitcount < 65 and rollcount < 2
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
	'EXPERIMENTAL ORBITALSYSTEM',
	'TECH3 STRATEGIC STRUCTURE',
    'EXPERIMENTAL LAND',
	'TECH2 STRATEGIC STRUCTURE',
	'TECH3 DEFENSE STRUCTURE',
	'TECH2 DEFENSE STRUCTURE',
    'TECH3 ENERGYPRODUCTION STRUCTURE',
	'TECH3 MASSFABRICATION STRUCTURE',
    'TECH2 ENERGYPRODUCTION STRUCTURE',
    'TECH3 MASSEXTRACTION STRUCTURE',
    'TECH3 SHIELD STRUCTURE',
    'TECH2 SHIELD STRUCTURE',
    'TECH3 INTELLIGENCE STRUCTURE',
    'TECH2 INTELLIGENCE STRUCTURE',
    'TECH1 INTELLIGENCE STRUCTURE',
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
	'ALLUNITS',
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
    if cdr:GetHealthPercent() < .70 or shieldPercent < .30 or nmeHardcore > 0 or nmeT3 > 4 then
        #AIUtils.AIFindDefensiveArea( aiBrain, cdr, categories.DEFENSE * categories.ANTIAIR, 10000 )
        #LOG('*AI DEBUG: ARMY ' .. aiBrain.Nickname .. ': CDR AI ACTIVATE - CDR RUNNING AWAY' )
        local nmeAir = aiBrain:GetNumUnitsAroundPoint( categories.AIR - categories.SCOUT - categories.INTELLIGENCE, cdrPos, 30, 'Enemy' )
        local nmeLand = aiBrain:GetNumUnitsAroundPoint( categories.COMMAND + categories.LAND - categories.ENGINEER - categories.SCOUT - categories.TECH1, cdrPos, 40, 'Enemy' )
		local nmaShield = aiBrain:GetNumUnitsAroundPoint( categories.SHIELD * categories.STRUCTURE, cdrPos, 100, 'Ally' )
        if nmeAir > 4 or nmeLand > 9 or nmeT3 > 4 or nmeHardcore > 0 or cdr:GetHealthPercent() < .70 or shieldPercent < .30 then
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
            until cdr:IsDead() or (cdr:GetHealthPercent() > .75 and shieldPercent > .35 and nmeAir < 5 and nmeLand < 10 and nmeHardcore == 0 and nmeT3 < 5)
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
	local commanderResponse = false

    for k,v in weapBPs do
        if v.Label == 'OverCharge' then
            weapon = v
            break
        end
    end
    local distressRange = 100
    local beingBuilt = false
    local maxRadius = weapon.MaxRadius * 4.5 * Mult
	local weapRange = weapon.MaxRadius
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
        local priList = { categories.ENERGYPRODUCTION * categories.STRUCTURE * categories.DRAGBUILD, categories.TECH3 * categories.INDIRECTFIRE,
            categories.TECH3 * categories.MOBILE, categories.TECH2 * categories.INDIRECTFIRE, categories.MOBILE * categories.TECH2,
            categories.TECH1 * categories.INDIRECTFIRE, categories.TECH1 * categories.MOBILE, categories.CONSTRUCTION * categories.STRUCTURE, categories.ECONOMIC * categories.STRUCTURE, categories.ALLUNITS }
        #LOG('*AI DEBUG: ARMY ' .. aiBrain.Nickname .. ': CDR AI ACTIVATE - Commander go fight stuff! -- ' .. totalUnits)
		plat:SetPrioritizedTargetList( 'support', priList )
		cdr:SetTargetPriorities( priList )
        local target
        local continueFighting = true
        local counter = 0
        
        local cdrThreat = cdr:GetBlueprint().Defense.SurfaceThreatLevel or 75
        local enemyThreat
        repeat
            #LOG("*AI DEBUG: " .. aiBrain.Nickname .. " overcharging")
            overCharging = false
			local cdrCurrentPos = cdr:GetPosition()
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
                    if enemyThreat - enemyCdrThreat >= friendlyThreat + (cdrThreat / 1.5) then
                        return
                    end
                    if aiBrain:GetEconomyStored('ENERGY') >= weapon.EnergyRequired and target and not target:IsDead() and Utilities.XZDistanceTwoVectors(cdrCurrentPos, target:GetPosition()) <= weapRange then
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
                    if enemyThreat - enemyCdrThreat >= friendlyThreat + (cdrThreat / 1.5) then
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
    local distSqAway = rad * rad #1600
    if not cdr:IsDead() and VDist2Sq(cdrPos[1], cdrPos[3], loc[1], loc[3]) > distSqAway then
        local plat = aiBrain:MakePlatoon( '', '' )
        aiBrain:AssignUnitsToPlatoon( plat, {cdr}, 'support', 'None' )
		IssueClearCommands( {cdr} )
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
		until cdr:IsDead() or VDist2Sq(cdrPos[1], cdrPos[3], loc[1], loc[3]) <= distSqAway
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
		IssueClearCommands( {cdr} )
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
		#LOG("*AI DEBUG: " .. aiBrain.Nickname .. " Commander hiding")
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
			IssueClearCommands( {cdr} )
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
	local Mult = platoon.PlatoonData.Mult or 1
	local Delay = platoon.PlatoonData.Delay or 0
	local WaitTaunt = 600 + Random(1,600)
    
    SetCDRHome(cdr, platoon)
	
	aiBrain:BuildScoutLocationsSorian()
	SUtils.CheckForMapMarkers(aiBrain)
	moveOnNext = false
	moveWait = 0
	
	local cmdrDamaged = function(cdr, instigator)
		local aiBrain = cdr:GetAIBrain()
		if not instigator:IsDead() and instigator:GetPosition() then
			#LOG('*AI DEBUG: cmdrDamaged in action!')
			local attackPos = instigator:GetPosition()
		#Bombard area
			if not aiBrain.AttackPoints then
				aiBrain.AttackPoints = {}
			end
			table.insert(aiBrain.AttackPoints,
				{
				Position = attackPos,
				}
			)
			aiBrain:ForkThread(aiBrain.AttackPointsTimeout, attackPos)
		#Set off base alert
			table.insert(aiBrain.BaseMonitor.AlertsTable,
				{
				Position = attackPos,
				Threat = 150,
				}
			)
			aiBrain.BaseMonitor.AlertSounded = true
			aiBrain:ForkThread(aiBrain.BaseMonitorAlertTimeout, attackPos)
			aiBrain.BaseMonitor.ActiveAlerts = aiBrain.BaseMonitor.ActiveAlerts + 1
		#Add area to high prio scout list
			table.insert(aiBrain.InterestList.HighPriority,
				{
				Position = attackPos,
				LastScouted = GetGameTimeSeconds(),
				}
			)
		end
	end
	import('/lua/ScenarioTriggers.lua').CreateUnitDamagedTrigger(cmdrDamaged, cdr, .2, -1)
	
    while not cdr:IsDead() do
		#LOG('*AI DEBUG: '.. aiBrain.Nickname ..' CommanderThread Loop')
		#AIAttackUtils.DrawPathGraph()
		
		if Mult > 1 and (GetGameTimeSeconds() > 600 or aiBrain.NumOpponents > 1 or not SBC.ClosestEnemyLessThan(aiBrain, 256)) then
			Mult = 1
		end
        WaitTicks(2)
        # Overcharge
        if not cdr:IsDead() and not cdr.Upgrading and GetGameTimeSeconds() > Delay and UCBC.HaveGreaterThanUnitsWithCategory(aiBrain,  1, 'FACTORY') and aiBrain:GetNoRushTicks() <= 0 then CDROverChargeSorian( aiBrain, cdr, Mult ) end
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
		if not cdr:IsDead() and cdr:IsIdleState() and not cdr.GoingHome and not cdr.Fighting and not cdr.Upgrading and not cdr:IsUnitState("Building")
		and not cdr:IsUnitState("Attacking") and not cdr:IsUnitState("Repairing") and not cdr.UnitBeingBuiltBehavior and not cdr:IsUnitState("Upgrading")
		and not moveOnNext then 
			moveWait = moveWait + 1
			if moveWait >= 20 then
				moveWait = 0
				moveOnNext = true
			end
		end
		WaitTicks(1)
		
        #call platoon resume building deal...
        if not cdr:IsDead() and cdr:IsIdleState() and not cdr.GoingHome and not cdr.Fighting and not cdr.Upgrading and not cdr:IsUnitState("Building")
		and not cdr:IsUnitState("Attacking") and not cdr:IsUnitState("Repairing") and not cdr.UnitBeingBuiltBehavior and not cdr:IsUnitState("Upgrading") 
		and not ( Utilities.XZDistanceTwoVectors(cdr.CDRHome, cdr:GetPosition()) > 100 ) then
            if not cdr.EngineerBuildQueue or table.getn(cdr.EngineerBuildQueue) == 0 then
				#LOG('*AI DEBUG: '.. aiBrain.Nickname ..' CommanderThread Assign to pool')
                local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
                aiBrain:AssignUnitsToPlatoon( pool, {cdr}, 'Unassigned', 'None' )
            elseif cdr.EngineerBuildQueue and table.getn(cdr.EngineerBuildQueue) != 0 then
                if not cdr.NotBuildingThread then
					#LOG('*AI DEBUG: '.. aiBrain.Nickname ..' CommanderThread Watch for not building')
                    cdr.NotBuildingThread = cdr:ForkThread(platoon.WatchForNotBuildingSorian)
                end             
            end
        end
		WaitSeconds(1)
		if GetGameTimeSeconds() > WaitTaunt and (not aiBrain.LastVocTaunt or GetGameTimeSeconds() - aiBrain.LastVocTaunt > WaitTaunt) then
			SUtils.AIRandomizeTaunt(aiBrain)
			WaitTaunt = 600 + Random(1,900)
		end
    end
end

function AirUnitRefitSorian(self)
    for k,v in self:GetPlatoonUnits() do
        if not v:IsDead() and not v.RefitThread then
            v.RefitThread = v:ForkThread( AirUnitRefitThreadSorian, self:GetPlan(), self.PlatoonData )
        end
    end
end

function AirUnitRefitThreadSorian(unit, plan, data)
    unit.PlanName = plan
    if data then
        unit.PlatoonData = data
    end
    local aiBrain = unit:GetAIBrain()
    while not unit:IsDead() do
        local fuel = unit:GetFuelRatio()
        local health = unit:GetHealthPercent()
        if not unit.Loading and ( fuel < .2 or health < .4 ) then
			#LOG('*AI DEBUG: AirUnitRefitThreadSorian need airstage')
            # Find air stage
            if aiBrain:GetCurrentUnits( categories.AIRSTAGINGPLATFORM - categories.CARRIER - categories.EXPERIMENTAL ) > 0 then
                local unitPos = unit:GetPosition()
                local plats = AIUtils.GetOwnUnitsAroundPoint( aiBrain, categories.AIRSTAGINGPLATFORM - categories.CARRIER - categories.EXPERIMENTAL, unitPos, 400 )
                if table.getn( plats ) > 0 then
                    local closest, distance
                    for k,v in plats do
                        if not v:IsDead() then
                            local roomAvailable = false
                            if EntityCategoryContains( categories.CARRIER, v ) then
                                #roomAvailable = v:TransportHasAvailableStorage( unit )
                            else
                                roomAvailable = v:TransportHasSpaceFor( unit )
                            end
                            if roomAvailable and (not v.Refueling or table.getn(v.Refueling) < 6) then
                                local platPos = v:GetPosition()
                                local tempDist = VDist2( unitPos[1], unitPos[3], platPos[1], platPos[3] )
                                if ( not closest or tempDist < distance ) then
                                    closest = v
                                    distance = tempDist
                                end
                            end
                        end
                    end
                    if closest then
						#LOG('*AI DEBUG: AirUnitRefitThreadSorian found airstage')
                        local plat = aiBrain:MakePlatoon( '', '' )
                        aiBrain:AssignUnitsToPlatoon( plat, {unit}, 'Attack', 'None' )
                        IssueStop( {unit} )
                        IssueClearCommands( {unit} )
                        IssueTransportLoad( {unit}, closest )
                        if EntityCategoryContains( categories.AIRSTAGINGPLATFORM, closest ) and not closest.AirStaging then
							#LOG('*AI DEBUG: AirUnitRefitThreadSorian activate stage thread')
                            closest.AirStaging = closest:ForkThread( AirStagingThreadSorian )
                            closest.Refueling = {}
                        elseif EntityCategoryContains( categories.CARRIER, closest) and not closest.CarrierStaging then
                            closest.CarrierStaging = closest:ForkThread( CarrierStagingThread )
                            closest.Refueling = {}
                        end
                        table.insert( closest.Refueling, unit )
                        unit.Loading = true
                    end
                end
            end
        end
        WaitSeconds(1)
    end
end

function AirStagingThreadSorian(unit)
    local aiBrain = unit:GetAIBrain()
	#LOG('*AI DEBUG: AirStagingThreadSorian started')
    while not unit:IsDead() do
		#LOG('*AI DEBUG: AirStagingThreadSorian loop')
        local ready = true
        local numUnits = 0
        for k,v in unit.Refueling do
            if not v:IsDead() and ( v:GetFuelRatio() < .9 or v:GetHealthPercent() < .9 ) then
                ready = false
				#LOG('*AI DEBUG: AirStagingThreadSorian not ready')
            elseif not v:IsDead() then
                numUnits = numUnits + 1
            end
        end
		local cargo = unit:GetCargo()
		if ready and numUnits == 0 and table.getn(cargo) > 0 then
            local pos = unit:GetPosition()
            IssueClearCommands( {unit} )
            IssueTransportUnload( {unit}, { pos[1] + 5, pos[2], pos[3] + 5 } )
			for k,v in cargo do
                local plat
                if not v.PlanName then
                    plat = aiBrain:MakePlatoon( '', 'AirHuntAI' )
                else
                    plat = aiBrain:MakePlatoon( '', v.PlanName )
                end
                if v.PlatoonData then
                    plat.PlatoonData = {}
                    plat.PlatoonData = v.PlatoonData
                end
                aiBrain:AssignUnitsToPlatoon( plat, {v}, 'Attack', 'GrowthFormation' )
			end
		end
		#LOG('*AI DEBUG: AirStagingThreadSorian numUnits = '..numUnits)
        if numUnits > 0 then #ready and numUnits > 0 then
            #LOG('*AI DEBUG: Release the doves')
            #local pos = unit:GetPosition()
            #IssueClearCommands( {unit} )
            #IssueTransportUnload( {unit}, { pos[1] + 5, pos[2], pos[3] + 5 } )
            WaitSeconds(2)
            for k,v in unit.Refueling do
                if not v:IsDead() and not v:IsUnitState('Attached') and ( v:GetFuelRatio() < .9 or v:GetHealthPercent() < .9 ) then
                    v.Loading = false
                    local plat
                    if not v.PlanName then
                        plat = aiBrain:MakePlatoon( '', 'AirHuntAI' )
                    else
                        plat = aiBrain:MakePlatoon( '', v.PlanName )
                    end
                    if v.PlatoonData then
                        plat.PlatoonData = {}
                        plat.PlatoonData = v.PlatoonData
                    end
                    aiBrain:AssignUnitsToPlatoon( plat, {v}, 'Attack', 'GrowthFormation' )
					unit.Refueling[k] = nil
                end
            end
        end
        WaitSeconds( 10 )
    end
end

AssignExperimentalPrioritiesSorian = function(platoon)
	#local experimental = GetExperimentalUnit(platoon)
	local platoonUnits = platoon:GetPlatoonUnits()
	for k,v in platoonUnits do
		if v and not v:IsDead() then
			SetLandTargetPrioritiesSorian( v, SurfacePrioritiesSorian )
		end
	end
end

SetLandTargetPrioritiesSorian = function(self, priTable)
    for i = 1, self:GetWeaponCount() do
        local wep = self:GetWeapon(i)
        
		if wep:GetBlueprint().CannotAttackGround then
			continue
		end
		
        for onLayer, targetLayers in wep:GetBlueprint().FireTargetLayerCapsTable do
            if string.find(targetLayers, 'Land') then
                wep:SetWeaponPriorities(priTable)
                break
            end
        end
    end
end

WreckBaseSorian = function(self, base)   
    for _, priority in SurfacePrioritiesSorian do
        local numUnitsAtBase = 0
        local notDeadUnit = false
        local unitsAtBase = self:GetBrain():GetUnitsAroundPoint(ParseEntityCategory(priority), base.Position, 200, 'Enemy')
        
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
	return false, false
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
	return false, false
end

CommanderOverrideCheckSorian = function(self)
    local aiBrain = self:GetBrain()
	local platoonUnits = self:GetPlatoonUnits()
    local experimental # = self:GetPlatoonUnits()[1]
	
	for k,v in platoonUnits do
		if not v:IsDead() then
			experimental = v
			break
		end
	end
	
	if not experimental or experimental:IsDead() then
		return false
	end
    
    local mainWeapon = experimental:GetWeapon(1)
    local weaponRange = mainWeapon:GetBlueprint().MaxRadius
   
    local commanders = aiBrain:GetUnitsAroundPoint(categories.COMMAND, self:GetPlatoonPosition(), weaponRange, 'Enemy')
    
    if table.getn(commanders) == 0 or commanders[1]:IsDead() or commanders[1]:GetCurrentLayer() == 'Seabed' then
        return false
    end

    local currentTarget = mainWeapon:GetCurrentTarget()
    
    if commanders[1] ~= currentTarget then
        #Commander in range who isn't our current target. Force weapons to reacquire targets so they'll grab him.
		for k,v in platoonUnits do
			if not v:IsDead() then
				for i=1, v:GetWeaponCount() do
					v:GetWeapon(i):ResetTarget()
				end
			end
		end
    end
    
    #return the commander so an attack order can be issued or something
    return commanders[1]
end

GetHighestThreatClusterLocationSorian = function(aiBrain, experimental)

    if not aiBrain or not aiBrain:PlatoonExists(experimental) then
        return nil
    end
    
    # look for commander first
    local position = experimental:GetPlatoonPosition()
    local threatTable = aiBrain:GetThreatsAroundPosition(position, 16, true, 'Commander')
    
    for _,threat in threatTable do
        if threat[3] > 0 then
            local unitsAtLocation = aiBrain:GetUnitsAroundPoint(ParseEntityCategory('COMMAND'), {threat[1],0,threat[2]}, ScenarioInfo.size[1] / 16, 'Enemy')
            local validUnit = false
            for _,unit in unitsAtLocation do
                if not unit:IsDead() then
                    validUnit = unit
                    break
                end
            end
            if validUnit then
                return table.copy(validUnit:GetPosition())
            end         
        end
    end    

    # now look through the bases for the highest economic threat and largest cluster of units
    local enemyBases = aiBrain.InterestList.HighPriority
   
    if not aiBrain.InterestList or not aiBrain.InterestList.HighPriority then
        #No target. :(
        return aiBrain:GetHighestThreatPosition( 0, true, 'Economy' )
    end
    
    local bestBaseThreat = nil
    local maxBaseThreat = 0
    for _,base in enemyBases do
        local threatTable = aiBrain:GetThreatsAroundPosition(base.Position, 1, true, 'Economy')
        
        if table.getn(threatTable) != 0 then
            if threatTable[1][3] > maxBaseThreat then
                maxBaseThreat = threatTable[1][3]
                bestBaseThreat = threatTable
            end
        end
    end
    
    if not bestBaseThreat then
        #no threat
        return
    end
    
    local maxUnits = -1
    local maxThreat = 0
    local bestThreat = 1
    
    # look for a cluster of structures
    for idx, threat in bestBaseThreat do
        if threat[3] > 0 then
            local unitsAtLocation = aiBrain:GetUnitsAroundPoint(ParseEntityCategory('STRUCTURE'), {threat[1],0,threat[2]}, ScenarioInfo.size[1] / 16, 'Enemy')
            local numunits = table.getn(unitsAtLocation)

            if numunits > maxUnits then
                maxUnits = numunits
                bestThreat = idx
            end 
        end
    end
    
    
    if bestBaseThreat[bestThreat] then
        local bestPos = {0,0,0}
        local maxUnits = 0
        local lookAroundTable = {-2,-1,0,1,2}
        local squareRadius = (ScenarioInfo.size[1] / 16) / table.getn(lookAroundTable)
        for ix, offsetX in lookAroundTable do
            for iz, offsetZ in lookAroundTable do
                local unitsAtLocation = aiBrain:GetUnitsAroundPoint(ParseEntityCategory('STRUCTURE'), {bestBaseThreat[bestThreat][1] + offsetX*squareRadius,0,bestBaseThreat[bestThreat][2]+offsetZ*squareRadius}, squareRadius, 'Enemy')
                local numUnits = table.getn(unitsAtLocation)
                if numUnits > maxUnits then
                    maxUnits = numUnits
                    bestPos = table.copy(unitsAtLocation[1]:GetPosition())
                end
            end
        end
        
        if bestPos[1] != 0 and bestPos[3] != 0 then
            return bestPos
        end
    end
   
    
    return nil    

end

CzarBehaviorSorian = function(self)
    local aiBrain = self:GetBrain()
	local platoonUnits = self:GetPlatoonUnits()
    #local experimental = GetExperimentalUnit(self)
    if not aiBrain:PlatoonExists(self) then #not experimental then
        return
    end
    #if not EntityCategoryContains( categories.uaa0310, experimental ) then
    #    return
    #end
    
    AssignExperimentalPrioritiesSorian(self)
    
    local targetUnit, targetBase = FindExperimentalTargetSorian(self)
	
    local oldTargetUnit = nil		
    while aiBrain:PlatoonExists(self) do #not experimental:IsDead() do
		self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)
		
        if targetUnit and targetUnit != oldTargetUnit then			
			if targetUnit and VDist3( targetUnit:GetPosition(), self:GetPlatoonPosition() ) > 100 then #VDist3( targetUnit:GetPosition(), experimental:GetPosition() ) > 100 then
			    IssueClearCommands(platoonUnits)
				WaitTicks(5)
				IssueMove(platoonUnits, targetUnit:GetPosition())
			else 
			    IssueClearCommands(platoonUnits)
				WaitTicks(5)
				IssueAttack(platoonUnits, experimental:GetPosition())
				WaitTicks(5)
				IssueMove(platoonUnits, targetUnit:GetPosition())
                WaitTicks(5)
                IssueAttack(platoonUnits, targetUnit)
			end
        end
        
        
        local nearCommander = CommanderOverrideCheckSorian(self)
        local oldCommander = nil
        while nearCommander and aiBrain:PlatoonExists(self) do #not experimental:IsDead() and not experimental:IsIdleState() do            
            if nearCommander and nearCommander != oldCommander then
                IssueClearCommands(platoonUnits)
                WaitTicks(5)
                IssueAttack(platoonUnits, experimental:GetPosition())
                WaitTicks(5)
                IssueMove(platoonUnits, nearCommander:GetPosition())
                WaitTicks(5)
                IssueAttack(platoonUnits, nearCommander)
                targetUnit = nearCommander
            end
            
            WaitSeconds(1)
            oldCommander = nearCommander
            nearCommander = CommanderOverrideCheckSorian(self)
        end
    
        WaitSeconds(1)
        oldTargetUnit = targetUnit
        targetUnit, targetBase = FindExperimentalTarget(self)
    end
end

AhwassaBehaviorSorian = function(self)
    local aiBrain = self:GetBrain()
	local platoonUnits = self:GetPlatoonUnits()
    #local experimental = GetExperimentalUnit(self)
    if not aiBrain:PlatoonExists(self) then #not experimental then
        return
    end
    #if not EntityCategoryContains( categories.xsa0402, experimental ) then
    #    return
    #end
    
    AssignExperimentalPrioritiesSorian(self)
    local targetLocation = GetHighestThreatClusterLocationSorian(aiBrain, self)
    local oldTargetLocation = nil
    while aiBrain:PlatoonExists(self) do #not experimental:IsDead() do
		self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)

        if targetLocation and targetLocation != oldTargetLocation then
            IssueClearCommands(platoonUnits)
            IssueAttack(platoonUnits, targetLocation)           
            WaitSeconds(25)
        end
       
        WaitSeconds(1)
        oldTargetLocation = targetLocation
        targetLocation = GetHighestThreatClusterLocationSorian(aiBrain, self)
    end
end

TickBehaviorSorian = function(self)
    local aiBrain = self:GetBrain()
	local platoonUnits = self:GetPlatoonUnits()
    #local experimental = GetExperimentalUnit(self)
    if not aiBrain:PlatoonExists(self) then #not experimental then
        return
    end
    #if not EntityCategoryContains( categories.ura0401, experimental ) then
    #    return
    #end
    
    AssignExperimentalPrioritiesSorian(self)
    local targetLocation = GetHighestThreatClusterLocationSorian(aiBrain, self)
    local oldTargetLocation = nil
    while aiBrain:PlatoonExists(self) do #not experimental:IsDead() do
		self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)

        if targetLocation and targetLocation != oldTargetLocation then
            IssueClearCommands(platoonUnits)
            IssueAggressiveMove(platoonUnits, targetLocation)           
            WaitSeconds(25)
        end
       
        WaitSeconds(1)
        oldTargetLocation = targetLocation
        targetLocation = GetHighestThreatClusterLocationSorian(aiBrain, self)
    end
end

function ScathisBehaviorSorian(self)   
	local aiBrain = self:GetBrain()
	local platoonUnits = self:GetPlatoonUnits()
    AssignExperimentalPrioritiesSorian(self)
    
    local experimental #= GetExperimentalUnit(self)
    local targetUnit = false
    local lastBase = false
    local airUnit = false #EntityCategoryContains(categories.AIR, experimental)
    
    #Find target loop
    while aiBrain:PlatoonExists(self) do #experimental and not experimental:IsDead() do
        if lastBase then
            targetUnit, lastBase = WreckBaseSorian(self, lastBase)
        end
        if not lastBase then
            targetUnit, lastBase = FindExperimentalTargetSorian(self)
        end
        
        if targetUnit then
            IssueClearCommands(platoonUnits)
            #IssueAttack(platoonUnits, targetUnit)
			IssueAggressiveMove(platoonUnits, targetUnit:GetPosition())
        end
        
        #Walk to and kill target loop
        while aiBrain:PlatoonExists(self) and targetUnit and not targetUnit:IsDead() do #not experimental:IsDead() and not experimental:IsIdleState() do
            local nearCommander = CommanderOverrideCheckSorian(self)
            
            if nearCommander and nearCommander ~= targetUnit then
                IssueClearCommands(platoonUnits)
                #IssueAttack(platoonUnits, nearCommander)
				IssueAggressiveMove(platoonUnits, nearCommander:GetPosition())
                targetUnit = nearCommander
            end
            
            #Check if we or the target are under a shield
            local closestBlockingShield = false
			for k,v in platoonUnits do
				if not v:IsDead() then
					experimental = v
					break
				end
			end
            if not airUnit then
                closestBlockingShield = GetClosestShieldProtectingTargetSorian(experimental, experimental) 
            end
            closestBlockingShield = closestBlockingShield or GetClosestShieldProtectingTargetSorian(experimental, targetUnit)
            
            #Kill shields loop
            while closestBlockingShield do
                IssueClearCommands({experimental})
                #IssueAttack({experimental}, closestBlockingShield)
				IssueAggressiveMove({experimental}, closestBlockingShield:GetPosition())
                
                #Wait for shield to die loop
                while not closestBlockingShield:IsDead() and aiBrain:PlatoonExists(self) do #not experimental:IsDead() do
					self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)
                    WaitSeconds(1)
                end             

                closestBlockingShield = false
				for k,v in platoonUnits do
					if not v:IsDead() then
						experimental = v
						break
					end
				end
                if not airUnit then
                    closestBlockingShield = GetClosestShieldProtectingTargetSorian(experimental, experimental) 
                end
                closestBlockingShield = closestBlockingShield or GetClosestShieldProtectingTargetSorian(experimental, targetUnit)
                
                WaitSeconds(1)
            end
            
            WaitSeconds(1)
        end
    
        WaitSeconds(1)
    end
end

function InWaterCheck(platoon)
	local t4Pos = platoon:GetPlatoonPosition()
	local inWater = GetTerrainHeight(t4Pos[1], t4Pos[3]) < GetSurfaceHeight(t4Pos[1], t4Pos[3])
	return inWater
end

function FatBoyBehaviorSorian(self)   
	local aiBrain = self:GetBrain()
	local platoonUnits = self:GetPlatoonUnits()
    AssignExperimentalPrioritiesSorian(self)
    
    local experimental #= GetExperimentalUnit(self)
    local targetUnit = false
    local lastBase = false
    local airUnit = false #EntityCategoryContains(categories.AIR, experimental)
	local useMove = true
	
    #Find target loop
    while aiBrain:PlatoonExists(self) do #experimental and not experimental:IsDead() do
		self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)
		useMove = InWaterCheck(self)
		
        if lastBase then
            targetUnit, lastBase = WreckBaseSorian(self, lastBase)
        end
        if not lastBase then
            targetUnit, lastBase = FindExperimentalTargetSorian(self)
        end
        
        if targetUnit then
            IssueClearCommands(platoonUnits)
			if useMove then
				IssueMove(platoonUnits, targetUnit:GetPosition())
			else
				IssueAggressiveMove(platoonUnits, targetUnit:GetPosition())
			end
        end
        
        #Walk to and kill target loop
        while aiBrain:PlatoonExists(self) and targetUnit and not targetUnit:IsDead() and useMove == InWaterCheck(self) do #not experimental:IsDead() and not experimental:IsIdleState() do
			self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)
			useMove = InWaterCheck(self)
            local nearCommander = CommanderOverrideCheckSorian(self)
            
            if nearCommander and nearCommander ~= targetUnit then
                IssueClearCommands(platoonUnits)
				if useMove then
					IssueMove(platoonUnits, nearCommander:GetPosition())
				else
					IssueAggressiveMove(platoonUnits, nearCommander:GetPosition())
				end
                targetUnit = nearCommander
            end
            
            #Check if we or the target are under a shield
            local closestBlockingShield = false
			for k,v in platoonUnits do
				if not v:IsDead() then
					experimental = v
					break
				end
			end
            if not airUnit then
                closestBlockingShield = GetClosestShieldProtectingTargetSorian(experimental, experimental) 
            end
            closestBlockingShield = closestBlockingShield or GetClosestShieldProtectingTargetSorian(experimental, targetUnit)
            
            #Kill shields loop
            while closestBlockingShield and targetUnit and not targetUnit:IsDead() do
				self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)
				useMove = InWaterCheck(self)
                IssueClearCommands(platoonUnits)
				if useMove then
					IssueMove(platoonUnits, closestBlockingShield:GetPosition())
				else
					IssueAggressiveMove(platoonUnits, closestBlockingShield:GetPosition())
				end
                
                #Wait for shield to die loop
                while not closestBlockingShield:IsDead() and aiBrain:PlatoonExists(self) and useMove == InWaterCheck(self) do #not experimental:IsDead() do
					self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)
					useMove = InWaterCheck(self)
                    WaitSeconds(1)
                end             

                closestBlockingShield = false
				for k,v in platoonUnits do
					if not v:IsDead() then
						experimental = v
						break
					end
				end
                if not airUnit then
                    closestBlockingShield = GetClosestShieldProtectingTargetSorian(experimental, experimental) 
                end
                closestBlockingShield = closestBlockingShield or GetClosestShieldProtectingTargetSorian(experimental, targetUnit)
                
                WaitSeconds(1)
            end
            
            WaitSeconds(1)
        end
    
        WaitSeconds(1)
    end
end

function BehemothBehaviorSorian(self)   
	local aiBrain = self:GetBrain()
	local platoonUnits = self:GetPlatoonUnits()
    AssignExperimentalPrioritiesSorian(self)
    
    local experimental #= GetExperimentalUnit(self)
    local targetUnit = false
    local lastBase = false
    local airUnit = false #EntityCategoryContains(categories.AIR, experimental)
    
    #Find target loop
    while aiBrain:PlatoonExists(self) do #experimental and not experimental:IsDead() do
		self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)
		
        if lastBase then
            targetUnit, lastBase = WreckBaseSorian(self, lastBase)
        end
        if not lastBase then
            targetUnit, lastBase = FindExperimentalTargetSorian(self)
        end
        
        if targetUnit then
            IssueClearCommands(platoonUnits)
            #IssueAttack(platoonUnits, targetUnit)
			IssueMove(platoonUnits, targetUnit:GetPosition())
        end
        
        #Walk to and kill target loop
        while aiBrain:PlatoonExists(self) and targetUnit and not targetUnit:IsDead() do #not experimental:IsDead() and not experimental:IsIdleState() do
			self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)
			
            local nearCommander = CommanderOverrideCheckSorian(self)
            
            if nearCommander and nearCommander ~= targetUnit then
                IssueClearCommands(platoonUnits)
                #IssueAttack(platoonUnits, nearCommander)
				IssueMove(platoonUnits, nearCommander:GetPosition())
                targetUnit = nearCommander
            end
            
            #Check if we or the target are under a shield
            local closestBlockingShield = false
			for k,v in platoonUnits do
				if not v:IsDead() then
					experimental = v
					break
				end
			end
            if not airUnit then
                closestBlockingShield = GetClosestShieldProtectingTargetSorian(experimental, experimental) 
            end
            closestBlockingShield = closestBlockingShield or GetClosestShieldProtectingTargetSorian(experimental, targetUnit)
            
            #Kill shields loop
            while closestBlockingShield do
				self:MergeWithNearbyPlatoonsSorian('ExperimentalAIHubSorian', 50, true)
                IssueClearCommands(platoonUnits)
                #IssueAttack(platoonUnits, closestBlockingShield)
				IssueMove(platoonUnits, closestBlockingShield:GetPosition())
                
                #Wait for shield to die loop
                while not closestBlockingShield:IsDead() and aiBrain:PlatoonExists(self) do #not experimental:IsDead() do
                    WaitSeconds(1)
                end             

                closestBlockingShield = false
				for k,v in platoonUnits do
					if not v:IsDead() then
						experimental = v
						break
					end
				end
                if not airUnit then
                    closestBlockingShield = GetClosestShieldProtectingTargetSorian(experimental, experimental) 
                end
                closestBlockingShield = closestBlockingShield or GetClosestShieldProtectingTargetSorian(experimental, targetUnit)
                
                WaitSeconds(1)
            end
            
            WaitSeconds(1)
        end
    
        WaitSeconds(1)
    end
end

function GetClosestShieldProtectingTargetSorian(attackingUnit, targetUnit)
    local aiBrain = attackingUnit:GetAIBrain()
	if not targetUnit or not attackingUnit then
		return false
	end
    local tPos = targetUnit:GetPosition()
    local aPos = attackingUnit:GetPosition()
    
    local blockingList = {}
    
    #If targetUnit is within the radius of any shields, the shields need to be destroyed.
    local shields = aiBrain:GetUnitsAroundPoint( categories.SHIELD * categories.STRUCTURE, targetUnit:GetPosition(), 50, 'Enemy' )
    for _,shield in shields do
        if not shield:IsDead() then
            local shieldPos = shield:GetPosition()
            local shieldSizeSq = GetShieldRadiusAboveGroundSquared(shield)
            
            if VDist2Sq(tPos[1], tPos[3], shieldPos[1], shieldPos[3]) < shieldSizeSq then
                table.insert(blockingList, shield)
            end
        end
    end

    #return the closest blocking shield
    local closest = false
    local closestDistSq = 999999
    for _,shield in blockingList do
        local shieldPos = shield:GetPosition()
        local distSq = VDist2Sq(aPos[1], aPos[3], shieldPos[1], shieldPos[3])
        
        if distSq < closestDistSq then
            closest = shield
            closestDistSq = distSq
        end
    end
    
    return closest
end

end