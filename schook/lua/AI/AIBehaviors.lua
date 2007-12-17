do

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
        local nmeLand = aiBrain:GetNumUnitsAroundPoint( categories.LAND - categories.ENGINEER - categories.SCOUT - categories.TECH1, cdrPos, 40, 'Enemy' )
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
                    runSpot = AIUtils.AIFindDefensiveAreaSorian( aiBrain, cdr, category, 50, runShield )
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
                    nmeLand = aiBrain:GetNumUnitsAroundPoint( categories.LAND - categories.ENGINEER - categories.SCOUT - categories.TECH1, cdrPos, 40, 'Enemy' )
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


function CDROverChargeSorian( aiBrain, cdr )
    local weapBPs = cdr:GetBlueprint().Weapon
    local weapon

    for k,v in weapBPs do
        if v.Label == 'OverCharge' then
            weapon = v
            break
        end
    end
    local distressRange = 95
    local beingBuilt = false
    local maxRadius = weapon.MaxRadius * 4.5
    cdr.UnitBeingBuiltBehavior = false
	
    local cdrPos = cdr.CDRHome
	local numUnits1 = aiBrain:GetNumUnitsAroundPoint( categories.LAND * categories.TECH1 - categories.SCOUT - categories.ENGINEER, cdrPos, maxRadius, 'Enemy' )
	local numUnits2 = aiBrain:GetNumUnitsAroundPoint( categories.LAND * categories.TECH2 - categories.SCOUT - categories.ENGINEER, cdrPos, maxRadius, 'Enemy' )
	local numUnits3 = aiBrain:GetNumUnitsAroundPoint( categories.LAND * categories.TECH3 - categories.SCOUT - categories.ENGINEER, cdrPos, maxRadius, 'Enemy' )
	local numUnits4 = aiBrain:GetNumUnitsAroundPoint( categories.EXPERIMENTAL, cdrPos, maxRadius + 130, 'Enemy' )
	local numStructs = aiBrain:GetNumUnitsAroundPoint( categories.STRUCTURE, cdrPos, maxRadius, 'Enemy' )
	local numUnitsDF = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE - categories.TECH1, cdrPos, maxRadius + 50, 'Enemy' )
	local numUnitsDF1 = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.STRUCTURE * categories.DIRECTFIRE * categories.TECH1, cdrPos, maxRadius + 30, 'Enemy' )
	local numUnitsIF = aiBrain:GetNumUnitsAroundPoint( categories.DEFENSE * categories.STRUCTURE * categories.INDIRECTFIRE - categories.TECH1, cdrPos, maxRadius + 130, 'Enemy' )
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
    
    if Utilities.XZDistanceTwoVectors(cdrPos, cdr:GetPosition()) > distressRange then
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
		elseif numUnits1 > 9 or numUnits2 > 9 or numUnits3 > 4 or numUnits4 > 0 or numUnitsDF > 0 or numUnitsIF > 0 or numUnitsDF1 > 3 then
			commanderResponse = false
		else
			commanderResponse = true
			#LOG('*AI DEBUG: AIBehavior Safe to Respond')
		end
	end
    
    if (cdr:GetHealthPercent() > .85 and shieldPercent > .35) and (( totalUnits > 0 and numUnits1 < 10 and numUnits2 < 10 and numUnits3 < 5 and numUnits4 < 1 and numUnitsDF1 < 4 and numUnitsDF < 1 and numUnitsIF < 1) or ( not cdr.DistressCall and distressLoc and commanderResponse and Utilities.XZDistanceTwoVectors( distressLoc, cdrPos ) < distressRange )) then
        CDRRevertPriorityChange( aiBrain, cdr )
        if cdr:GetUnitBeingBuilt() then
            #LOG('*AI DEBUG: ARMY ' .. aiBrain:GetArmyIndex() .. ': CDR was building something')
            cdr.UnitBeingBuiltBehavior = cdr:GetUnitBeingBuilt()
        end
		cdr.Fighting = true
        local plat = aiBrain:MakePlatoon( '', '' )
        aiBrain:AssignUnitsToPlatoon( plat, {cdr}, 'support', 'None' )
        plat:Stop()
        local priList = { categories.EXPERIMENTAL, categories.TECH3 * categories.INDIRECTFIRE,
            categories.TECH3 * categories.MOBILE, categories.TECH2 * categories.INDIRECTFIRE, categories.MOBILE * categories.TECH2,
            categories.TECH1 * categories.INDIRECTFIRE, categories.TECH1 * categories.MOBILE, categories.ALLUNITS }
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
                    if enemyThreat >= cdrThreat / 2 then
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
                    if enemyThreat >= cdrThreat / 2 then
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
		if cdr.UnitBeingBuiltBehavior then
			cdr:ForkThread( CDRFinishUnit )
		end
    end
end

function CDRReturnHomeSorian(aiBrain, cdr)
    local loc, rad
    loc = cdr.CDRHome
    rad = 100
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
    
    SetCDRHome(cdr, platoon)
    
	aiBrain:BuildScoutLocations()
	
    while not cdr:IsDead() do
		#LOG('*AI DEBUG: '.. aiBrain.Nickname ..' CommanderThread Loop')
        WaitTicks(2)
        # Overcharge
        if not cdr:IsDead() then CDROverChargeSorian( aiBrain, cdr ) end
        WaitTicks(1)
        # Run away (not really useful right now, without teleport ability kicking in... might as well just go home)
        if not cdr:IsDead() then CDRRunAwaySorian( aiBrain, cdr ) end
        WaitTicks(1)
        # Go back to base
        if not cdr:IsDead() then CDRReturnHomeSorian( aiBrain, cdr ) end
        WaitTicks(1)
        
        #call platoon resume building deal...
        if not cdr:IsDead() and cdr:IsIdleState() and not cdr.GoingHome and not cdr.Fighting and not cdr.UnitBeingBuiltBehavior then
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

function BuildOnceAISorian(platoon)
    local aiBrain = platoon:GetBrain()
	platoon.BuilderHandle:SetPriority(0)
end

end