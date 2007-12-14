do

sorianoldPlatoon = Platoon

Platoon = Class(sorianoldPlatoon) {

    AirHuntAI = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local armyIndex = aiBrain:GetArmyIndex()
        local target
        local blip
		local hadtarget = false
        while aiBrain:PlatoonExists(self) do
            if self:IsOpponentAIRunning() then
                target = self:FindClosestUnit('Attack', 'Enemy', true, categories.ALLUNITS - categories.WALL)
                if target then
                    blip = target:GetBlip(armyIndex)
                    self:Stop()
                    self:AggressiveMoveToLocation( table.copy(target:GetPosition()) )
					hadtarget = true
				elseif not target and hadtarget then
					local x,z = aiBrain:GetArmyStartPos()
					local position = AIUtils.RandomLocation(x,z)
					local safePath, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, 'Air', self:GetPlatoonPosition(), position, 200)
					if safePath then
						for _,p in safePath do
							self:MoveToLocation( p, false )
						end
					else
						self:MoveToLocation( position, false )
					end
					hadtarget = false
                end
            end
            WaitSeconds(17)
        end
    end,    
          
    #-----------------------------------------------------
    #   Function: GuardMarkerSorian
    #   Args:
    #       platoon - platoon to run the AI
    #   Description:
    #       Will guard the location of a marker
    #   Returns:  
    #       nil
    #-----------------------------------------------------
    GuardMarkerSorian = function(self)
        local aiBrain = self:GetBrain()
        
        local platLoc = self:GetPlatoonPosition()        
        
        if not aiBrain:PlatoonExists(self) or not platLoc then
            return
        end
        
        #---------------------------------------------------------------------
        # Platoon Data
        #---------------------------------------------------------------------
        # type of marker to guard
        # Start location = 'Start Location'... see MarkerTemplates.lua for other types
        local markerType = self.PlatoonData.MarkerType or 'Expansion Area'

        # what should we look for for the first marker?  This can be 'Random',
        # 'Threat' or 'Closest'
        local moveFirst = self.PlatoonData.MoveFirst or 'Threat'
        
        # should our next move be no move be (same options as before) as well as 'None'
        # which will cause the platoon to guard the first location they get to
        local moveNext = self.PlatoonData.MoveNext or 'None'         

        # Minimum distance when looking for closest
        local avoidClosestRadius = self.PlatoonData.AvoidClosestRadius or 0        
        
        # set time to wait when guarding a location with moveNext = 'None'
        local guardTimer = self.PlatoonData.GuardTimer or 0
        
        # threat type to look at      
        local threatType = self.PlatoonData.ThreatType or 'AntiSurface'
        
        # should we look at our own threat or the enemy's
        local bSelfThreat = self.PlatoonData.SelfThreat or false
        
        # if true, look to guard highest threat, otherwise, 
        # guard the lowest threat specified                 
        local bFindHighestThreat = self.PlatoonData.FindHighestThreat or false 
        
        # minimum threat to look for
        local minThreatThreshold = self.PlatoonData.MinThreatThreshold or -1
        # maximum threat to look for
        local maxThreatThreshold = self.PlatoonData.MaxThreatThreshold  or 99999999
  
        # Avoid bases (true or false)
        local bAvoidBases = self.PlatoonData.AvoidBases or false
             
        # Radius around which to avoid the main base
        local avoidBasesRadius = self.PlatoonData.AvoidBasesRadius or 0
        
        # Use Aggresive Moves Only
        local bAggroMove = self.PlatoonData.AggressiveMove or false
        
        local PlatoonFormation = self.PlatoonData.UseFormation or 'NoFormation'
        #---------------------------------------------------------------------
         
           
        AIAttackUtils.GetMostRestrictiveLayer(self)
        self:SetPlatoonFormationOverride(PlatoonFormation)
        local markerLocations = AIUtils.AIGetMarkerLocations(aiBrain, markerType)
        
        local bestMarker = false
        
        if not self.LastMarker then
            self.LastMarker = {nil,nil}
        end
            
        # look for a random marker
        if moveFirst == 'Random' then
            if table.getn(markerLocations) <= 2 then
                self.LastMarker[1] = nil
                self.LastMarker[2] = nil
            end        	
            for _,marker in RandomIter(markerLocations) do
	            if table.getn(markerLocations) <= 2 then
	                self.LastMarker[1] = nil
	                self.LastMarker[2] = nil
	            end            	
                if self:AvoidsBases(marker.Position, bAvoidBases, avoidBasesRadius) then
            		if self.LastMarker[1] and marker.Position[1] == self.LastMarker[1][1] and marker.Position[3] == self.LastMarker[1][3] then
            		    continue                
            		end                        
            		if self.LastMarker[2] and marker.Position[1] == self.LastMarker[2][1] and marker.Position[3] == self.LastMarker[2][3] then
            		    continue                
            		end                    	
                    bestMarker = marker
                    break
                end
            end
        elseif moveFirst == 'Threat' then
            #Guard the closest least-defended marker
            local bestMarkerThreat = 0
            if not bFindHighestThreat then
                bestMarkerThreat = 99999999
            end
            
            local bestDistSq = 99999999
                      
             
            # find best threat at the closest distance
            for _,marker in markerLocations do
                local markerThreat
                if bSelfThreat then
                    markerThreat = aiBrain:GetThreatAtPosition( marker.Position, 0, true, threatType, aiBrain:GetArmyIndex())
                else
                    markerThreat = aiBrain:GetThreatAtPosition( marker.Position, 0, true, threatType)
                end
                local distSq = VDist2Sq(marker.Position[1], marker.Position[3], platLoc[1], platLoc[3])

                if markerThreat >= minThreatThreshold and markerThreat <= maxThreatThreshold then
                    if self:AvoidsBases(marker.Position, bAvoidBases, avoidBasesRadius) then
                        if self.IsBetterThreat(bFindHighestThreat, markerThreat, bestMarkerThreat) then
                            bestDistSq = distSq
                            bestMarker = marker
                            bestMarkerThreat = markerThreat
                        elseif markerThreat == bestMarkerThreat then
                            if distSq < bestDistSq then
                                bestDistSq = distSq
                                bestMarker = marker  
                                bestMarkerThreat = markerThreat  
                            end
                        end
                     end
                 end
            end
            
        else 
            # if we didn't want random or threat, assume closest (but avoid ping-ponging)
            local bestDistSq = 99999999
            if table.getn(markerLocations) <= 2 then
                self.LastMarker[1] = nil
                self.LastMarker[2] = nil
            end
            for _,marker in markerLocations do
                local distSq = VDist2Sq(marker.Position[1], marker.Position[3], platLoc[1], platLoc[3])
                if self:AvoidsBases(marker.Position, bAvoidBases, avoidBasesRadius) and distSq > (avoidClosestRadius * avoidClosestRadius) then
                    if distSq < bestDistSq then
                		if self.LastMarker[1] and marker.Position[1] == self.LastMarker[1][1] and marker.Position[3] == self.LastMarker[1][3] then
                		    continue                
                		end                        
                		if self.LastMarker[2] and marker.Position[1] == self.LastMarker[2][1] and marker.Position[3] == self.LastMarker[2][3] then
                		    continue                
                		end                      		
                        bestDistSq = distSq
                        bestMarker = marker 
                    end
                end
            end            
        end
        
        
        # did we find a threat?
		local usedTransports = false
        if bestMarker then
        	self.LastMarker[2] = self.LastMarker[1]
            self.LastMarker[1] = bestMarker.Position
            #LOG("GuardMarker: Attacking " .. bestMarker.Name)
            local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, self:GetPlatoonPosition(), bestMarker.Position, 200)
            IssueClearCommands(self:GetPlatoonUnits())
            if path then
				local position = self:GetPlatoonPosition()
				if VDist2( position[1], position[3], bestMarker.Position[1], bestMarker.Position[3] ) > 512 then
					usedTransports = AIAttackUtils.SendPlatoonWithTransports(aiBrain, self, bestMarker.Position, true)
				elseif VDist2( position[1], position[3], bestMarker.Position[1], bestMarker.Position[3] ) > 256 then
					usedTransports = AIAttackUtils.SendPlatoonWithTransports(aiBrain, self, bestMarker.Position, false)
				end
				if not usedTransports then
					local pathLength = table.getn(path)
					for i=1, pathLength-1 do
						if bAggroMove then
							self:AggressiveMoveToLocation(path[i])
						else
							self:MoveToLocation(path[i], false)
						end
					end 
				end
            elseif (not path and reason == 'NoPath') then
                usedTransports = AIAttackUtils.SendPlatoonWithTransports(aiBrain, self, bestMarker.Position, true)
            else
                self:PlatoonDisband()
                return
            end
			
			if not path and not usedTransports then
                self:PlatoonDisband()
                return
			end
            
            if moveNext == 'None' then
                # guard
                IssueGuard( self:GetPlatoonUnits(), bestMarker.Position )
                # guard forever
                if guardTimer <= 0 then return end
            else
                # otherwise, we're moving to the location
                self:AggressiveMoveToLocation(bestMarker.Position)
            end
            
            # wait till we get there
            repeat
                WaitSeconds(5)    
                platLoc = self:GetPlatoonPosition() 
            until VDist2Sq(platLoc[1], platLoc[3], bestMarker.Position[1], bestMarker.Position[3]) < 64 or not aiBrain:PlatoonExists(self)
            
            # if we're supposed to guard for some time
            if moveNext == 'None' then
                # this won't be 0... see above
                WaitSeconds(guardTimer)
                self:PlatoonDisband()
                return
            end
            
            if moveNext == 'Guard Base' then
                return self:GuardBase()
            end
            
            # we're there... wait here until we're done
            local numGround = aiBrain:GetNumUnitsAroundPoint( ( categories.LAND + categories.NAVAL + categories.STRUCTURE ), bestMarker.Position, 15, 'Enemy' )
            while numGround > 0 and aiBrain:PlatoonExists(self) do
                WaitSeconds(Random(5,10))
                numGround = aiBrain:GetNumUnitsAroundPoint( ( categories.LAND + categories.NAVAL + categories.STRUCTURE ), bestMarker.Position, 15, 'Enemy' )    
            end
            
            if not aiBrain:PlatoonExists(self) then
                return
            end
            
            # set our MoveFirst to our MoveNext
            self.PlatoonData.MoveFirst = moveNext
            return self:GuardMarker()
        else
            # no marker found, disband!
            self:PlatoonDisband()
        end               
    end,
    
    #-----------------------------------------------------
    #   Function: LandScoutingAISorian
    #   Args:
    #       platoon - platoon to run the AI
    #   Description:
    #       Handles sending land scouts to important locations.
    #   Returns:  
    #       nil (loops until platoon is destroyed)
    #-----------------------------------------------------
    LandScoutingAISorian = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self)
        
        local aiBrain = self:GetBrain()
        local scout = self:GetPlatoonUnits()[1]
        
        aiBrain:BuildScoutLocations()
        
        #If we have cloaking (are cybran), then turn on our cloaking
        if scout:TestToggleCaps('RULEUTC_CloakToggle') then
			#LOG('*AI DEBUG: Enable Land Scout Cloak')
            scout:EnableUnitIntel('Cloak')
			#scout:SetScriptBit('RULEUTC_CloakToggle', false)
        end
        
		if scout:TestToggleCaps('RULEUTC_StealthToggle') then
            scout:EnableUnitIntel('RadarStealth')
			#scout:SetScriptBit('RULEUTC_StealthToggle', false)
        end
               
        while not scout:IsDead() do
            #Head towards the the area that has not had a scout sent to it in a while           
            local targetData = false
            
            #For every scouts we send to all opponents, send one to scout a low pri area.
            if aiBrain.IntelData.HiPriScouts < aiBrain.NumOpponents and table.getn(aiBrain.InterestList.HighPriority) > 0 then
                targetData = aiBrain.InterestList.HighPriority[1]
                aiBrain.IntelData.HiPriScouts = aiBrain.IntelData.HiPriScouts + 1
                targetData.LastScouted = GetGameTimeSeconds()
                
                aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)
                
            elseif table.getn(aiBrain.InterestList.LowPriority) > 0 then
                targetData = aiBrain.InterestList.LowPriority[1]
                aiBrain.IntelData.HiPriScouts = 0
                targetData.LastScouted = GetGameTimeSeconds()
                
                aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
            end
            
            #Is there someplace we should scout?
            if targetData then
                #Can we get there safely?
                local path, reason = AIAttackUtils.PlatoonGenerateSafePathTo(aiBrain, self.MovementLayer, scout:GetPosition(), targetData.Position, 100)
                
                IssueClearCommands(self)

                if path then
                    local pathLength = table.getn(path)
                    for i=1, pathLength-1 do
                        self:MoveToLocation(path[i], false)
                    end 
                end

                self:MoveToLocation(targetData.Position, false)  
                
                #Scout until we reach our destination
                while not scout:IsDead() and not scout:IsIdleState() do                                       
                    WaitSeconds(2.5)
                end
            end
            
            WaitSeconds(1)
        end
    end,
    
    #-----------------------------------------------------
    #   Function: AirScoutingAISorian
    #   Args:
    #       platoon - platoon to run the AI
    #   Description:
    #       Handles sending air scouts to important locations.
    #   Returns:  
    #       nil (loops until platoon is destroyed)
    #-----------------------------------------------------
    AirScoutingAISorian = function(self)
        
        local aiBrain = self:GetBrain()
        local scout = self:GetPlatoonUnits()[1]
        
        aiBrain:BuildScoutLocations()
        
        if scout:TestToggleCaps('RULEUTC_CloakToggle') then
            scout:EnableUnitIntel('Cloak')
			#scout:SetScriptBit('RULEUTC_CloakToggle', false)
        end
        
		if scout:TestToggleCaps('RULEUTC_StealthToggle') then
            scout:EnableUnitIntel('RadarStealth')
			#scout:SetScriptBit('RULEUTC_StealthToggle', false)
        end
        
        while not scout:IsDead() do
            local targetArea = false
            local highPri = false
            
            local mustScoutArea, mustScoutIndex = aiBrain:GetUntaggedMustScoutArea()
            local unknownThreats = aiBrain:GetThreatsAroundPosition(scout:GetPosition(), 16, true, 'Unknown')
            
            #1) If we have any "must scout" (manually added) locations that have not been scouted yet, then scout them
            if mustScoutArea then
                mustScoutArea.TaggedBy = scout
                targetArea = mustScoutArea.Position
            
            #2) Scout "unknown threat" areas with a threat higher than 25
            elseif table.getn(unknownThreats) > 0 and unknownThreats[1][3] > 25 then
                aiBrain:AddScoutArea({unknownThreats[1][1], 0, unknownThreats[1][2]})
            
            #3) Scout high priority locations    
            elseif aiBrain.IntelData.AirHiPriScouts < aiBrain.NumOpponents and aiBrain.IntelData.AirLowPriScouts < 1 
            and table.getn(aiBrain.InterestList.HighPriority) > 0 then
                aiBrain.IntelData.AirHiPriScouts = aiBrain.IntelData.AirHiPriScouts + 1
                
                highPri = true
                
                targetData = aiBrain.InterestList.HighPriority[1]
                targetData.LastScouted = GetGameTimeSeconds()
                targetArea = targetData.Position
                
                aiBrain:SortScoutingAreas(aiBrain.InterestList.HighPriority)
                
            #4) Every time we scout NumOpponents number of high priority locations, scout a low priority location               
            elseif aiBrain.IntelData.AirLowPriScouts < 1 and table.getn(aiBrain.InterestList.LowPriority) > 0 then
                aiBrain.IntelData.AirHiPriScouts = 0
                aiBrain.IntelData.AirLowPriScouts = aiBrain.IntelData.AirLowPriScouts + 1
                
                targetData = aiBrain.InterestList.LowPriority[1]
                targetData.LastScouted = GetGameTimeSeconds()
                targetArea = targetData.Position
                
                aiBrain:SortScoutingAreas(aiBrain.InterestList.LowPriority)
            else
                #Reset number of scoutings and start over
                aiBrain.IntelData.AirLowPriScouts = 0
                aiBrain.IntelData.AirHiPriScouts = 0
            end
            
            #Air scout do scoutings.
            if targetArea then
                self:Stop()
                
                local vec = self:DoAirScoutVecs(scout, targetArea)
                
                while not scout:IsDead() and not scout:IsIdleState() do                   
                    
                    #If we're close enough...
                    if VDist2Sq(vec[1], vec[3], scout:GetPosition()[1], scout:GetPosition()[3]) < 15625 then
                        if mustScoutArea then
                            #Untag and remove
                            for idx,loc in aiBrain.InterestList.MustScout do
                                if loc == mustScoutArea then
                                   table.remove(aiBrain.InterestList.MustScout, idx)
                                   break 
                                end
                            end
                        end
                        #Break within 125 ogrids of destination so we don't decelerate trying to stop on the waypoint.
                        break
                    end
                    
                    if VDist3( scout:GetPosition(), targetArea ) < 25 then
                        break
                    end

                    WaitSeconds(5)
                end
            else
                WaitSeconds(1)
            end
            WaitTicks(1)
        end
    end,
	
    #-----------------------------------------------------
    #   Function: ScoutingAISorian
    #   Args:
    #       platoon - a single-scout platoon to run the AI for
    #   Description:
    #       Switches to AirScoutingAI or LandScoutingAI depending on the unit's movement capabilities.
    #   Returns:  
    #       nil. (Tail call into other AI functions)
    #-----------------------------------------------------
    ScoutingAISorian = function(self)
        AIAttackUtils.GetMostRestrictiveLayer(self)
        
        if self.MovementLayer == 'Air' then 
            return self:AirScoutingAISorian() 
        else 
            return self:LandScoutingAISorian()
        end
    end,
	
	#-----------------------------------------------------
    #   Function: AirIntelToggle
    #   Args:
    #       self - platoon to run the AI
    #   Description:
    #       Turns on Air unit cloak/stealth.
    #   Returns:  
    #       nil
    #-----------------------------------------------------	
	AirIntelToggle = function(self)
		#LOG('*AI DEBUG: AirIntelToggle run')
		for k,v in self:GetPlatoonUnits() do
			if v:TestToggleCaps('RULEUTC_CloakToggle') then
				v:EnableUnitIntel('Cloak')
				#v:SetScriptBit('RULEUTC_CloakToggle', false)
			end
        
			if v:TestToggleCaps('RULEUTC_StealthToggle') then
				v:EnableUnitIntel('RadarStealth')
				#v:SetScriptBit('RULEUTC_StealthToggle', false)
			end
		end
	end,
	
    ReclaimAISorian = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local locationType = self.PlatoonData.LocationType
        local timeAlive = 0
        local closest, entType, closeDist
        local oldClosest
        while aiBrain:PlatoonExists(self) do
            local massRatio = aiBrain:GetEconomyStoredRatio('MASS')
            local energyRatio = aiBrain:GetEconomyStoredRatio('ENERGY')
            local massFirst = true
            if energyRatio < massRatio then
                massFirst = false
            end

            local ents = AIUtils.AIGetReclaimablesAroundLocation( aiBrain, locationType )
            if not ents or table.getn( ents ) == 0 then
                WaitTicks(1)
                self:PlatoonDisband()
            end
			local reclaimables = {}
            for k,v in ents do
                if (v.MassReclaim and v.MassReclaim > 0) or (v.EnergyReclaim and v.EnergyReclaim > 0) then
                    table.insert( reclaimables, v )
                end
            end
            
            local unitPos = self:GetPlatoonPosition()
            if not unitPos then break end
            local recPos = nil
            closest = false
            for k, v in reclaimables do
                recPos = v:GetPosition()
                if not recPos then 
                    WaitTicks(1)
                    self:PlatoonDisband()
                end
                if not (unitPos[1] and unitPos[3] and recPos[1] and recPos[3]) then return end
                local tempDist = VDist2( unitPos[1], unitPos[3], recPos[1], recPos[3] )
                # We don't want any reclaimables super close to us
                if ( ( not closest or tempDist < closeDist ) and ( not oldClosest or closest != oldClosest ) ) then
                    closest = v
                    closeDist = tempDist
                end
            end

            if closest and ( massRatio < .9 or energyRatio < .9 ) then
                oldClosest = closest
                IssueClearCommands( self:GetPlatoonUnits() )
				IssueReclaim( self:GetPlatoonUnits(), closest )
                local count = 0
				local allIdle
                repeat
                    WaitSeconds(2)
                    if not aiBrain:PlatoonExists(self) then
                        return
                    end
                    timeAlive = timeAlive + 2
                    count = count + 1
                    if self.PlatoonData.ReclaimTime and timeAlive >= self.PlatoonData.ReclaimTime then
                        self:PlatoonDisband()
                        return
                    end
					allIdle = true
                    for k,v in self:GetPlatoonUnits() do
                        if not v:IsDead() and not v:IsIdleState() then
                            allIdle = false
                            break
                        end
                    end
                until allIdle or count >= 14
            else
                self:PlatoonDisband()
            end
        end
    end,
	
    RepairAI = function(self)
        if not self.PlatoonData or not self.PlatoonData.LocationType then
            self:PlatoonDisband()
        end
		#LOG('*AI DEBUG: Engineer Repairing')
        local aiBrain = self:GetBrain()
		local engineerManager = aiBrain.BuilderManagers[self.PlatoonData.LocationType].EngineerManager
        local Structures = AIUtils.GetOwnUnitsAroundPoint( aiBrain, categories.STRUCTURE - (categories.TECH1 - categories.FACTORY), engineerManager:GetLocationCoords(), engineerManager:GetLocationRadius() )
        for k,v in Structures do
            if not v:IsDead() and v:GetHealthPercent() < .8 then
                self:Stop()
                IssueRepair( self:GetPlatoonUnits(), v )
				break
            end
        end
		WaitSeconds(60)
        self:PlatoonDisband()
    end,
	
    #-----------------------------------------------------
    #   Function: EngineerBuildAI
    #   Args:
    #       self - the single-engineer platoon to run the AI on
    #   Description:
    #       a single-unit platoon made up of an engineer, this AI will determine
    #       what needs to be built (based on platoon data set by the calling
    #       abstraction, and then issue the build commands to the engineer
    #   Returns:  
    #       nil (tail calls into a behavior function)
    #-----------------------------------------------------
    EngineerBuildAISorian = function(self)
        self:Stop()
        local aiBrain = self:GetBrain()
        local platoonUnits = self:GetPlatoonUnits()
        local armyIndex = aiBrain:GetArmyIndex()
        local x,z = aiBrain:GetArmyStartPos()
        local cons = self.PlatoonData.Construction
        local buildingTmpl, buildingTmplFile, baseTmpl, baseTmplFile
        
        local factionIndex = cons.FactionIndex or self:GetFactionIndex()
        
        buildingTmplFile = import(cons.BuildingTemplateFile or '/lua/BuildingTemplates.lua')
        baseTmplFile = import(cons.BaseTemplateFile or '/lua/BaseTemplates.lua')
        buildingTmpl = buildingTmplFile[(cons.BuildingTemplate or 'BuildingTemplates')][factionIndex]
        baseTmpl = baseTmplFile[(cons.BaseTemplate or 'BaseTemplates')][factionIndex]

        local eng
        for k, v in platoonUnits do
            if not v:IsDead() and EntityCategoryContains(categories.CONSTRUCTION, v ) then
                if not eng then
                    eng = v
                else
                    IssueClearCommands( {v} )
                    IssueGuard({v}, eng)
                end
            end
        end

        if not eng or eng:IsDead() then
            WaitTicks(1)
            self:PlatoonDisband()
            return
        end

        if self.PlatoonData.NeedGuard then
            eng.NeedGuard = true
        end

        #### CHOOSE APPROPRIATE BUILD FUNCTION AND SETUP BUILD VARIABLES ####
        local reference = false
        local refName = false
        local buildFunction
        local closeToBuilder
        local relative
        local baseTmplList = {}
        
        # if we have nothing to build, disband!
        if not cons.BuildStructures then
            WaitTicks(1)
            self:PlatoonDisband()
            return
        end
        
        if cons.NearUnitCategory then
            self:SetPrioritizedTargetList('support', {ParseEntityCategory(cons.NearUnitCategory)})
            local unitNearBy = self:FindPrioritizedUnit('support', 'Ally', false, self:GetPlatoonPosition(), cons.NearUnitRadius or 50)
            #LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." attempt near: ", cons.NearUnitCategory)
            if unitNearBy then
                reference = table.copy( unitNearBy:GetPosition() )
                # get commander home position
                #LOG("ENGINEER BUILD: " .. cons.BuildStructures[1] .." Near unit: ", cons.NearUnitCategory)
                if cons.NearUnitCategory == 'COMMAND' and unitNearBy.CDRHome then
                    reference = unitNearBy.CDRHome
                end
            else
                reference = table.copy( eng:GetPosition() )
            end
            relative = false
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
            table.insert( baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation( baseTmpl, reference ) )
        elseif cons.Wall then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100
            relative = false
            reference = AIUtils.GetLocationNeedingWalls( aiBrain, 200, 4, 'STRUCTURE - WALLS', cons.ThreatMin, cons.ThreatMax, cons.ThreatRings )
            table.insert( baseTmplList, 'Blank' )
            buildFunction = AIBuildStructures.WallBuilder
        elseif cons.NearBasePatrolPoints then
            relative = false
            reference = AIUtils.GetBasePatrolPoints(aiBrain, cons.Location or 'MAIN', cons.Radius or 100)
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            for k,v in reference do
                table.insert( baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation( baseTmpl, v ) )
            end
            # Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            buildFunction = AIBuildStructures.AIBuildBaseTemplateOrdered
        elseif cons.NearMarkerType and cons.ExpansionBase then
            local pos = aiBrain:PBMGetLocationCoords(cons.LocationType) or cons.Position or self:GetPlatoonPosition()
            local radius = cons.LocationRadius or aiBrain:PBMGetLocationRadius(cons.LocationType) or 100
            
            if cons.FireBase and cons.FireBaseRange then
                reference, refName = AIUtils.AIFindFirebaseLocation(aiBrain, cons.LocationType, cons.FireBaseRange, cons.NearMarkerType,
                                                    cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType, 
                                                    cons.MarkerUnitCount, cons.MarkerUnitCategory, cons.MarkerRadius)
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            elseif cons.NearMarkerType == 'Expansion Area' then
                reference, refName = AIUtils.AIFindExpansionAreaNeedsEngineer( aiBrain, cons.LocationType, 
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType )
                # didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            elseif cons.NearMarkerType == 'Naval Area' then
                reference, refName = AIUtils.AIFindNavalAreaNeedsEngineer( aiBrain, cons.LocationType, 
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType )
                # didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            else
                reference, refName = AIUtils.AIFindStartLocationNeedsEngineer( aiBrain, cons.LocationType, 
                        (cons.LocationRadius or 100), cons.ThreatMin, cons.ThreatMax, cons.ThreatRings, cons.ThreatType )
                # didn't find a location to build at
                if not reference or not refName then
                    self:PlatoonDisband()
                end
            end
            
            # If moving far from base, tell the assisting platoons to not go with
            if cons.FireBase or cons.ExpansionBase then
                local guards = eng:GetGuards()
                for k,v in guards do
                    if not v:IsDead() and v.PlatoonHandle then
                        v.PlatoonHandle:PlatoonDisband()
                    end
                end
            end
                    
            if not cons.BaseTemplate and ( cons.NearMarkerType == 'Naval Area' or cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area' ) then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase( aiBrain, refName, reference, eng, cons)
            end
            relative = false
            if reference and aiBrain:GetThreatAtPosition( reference , 1, true, 'AntiSurface' ) > 0 then
                #aiBrain:ExpansionHelp( eng, reference )
            end
            table.insert( baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation( baseTmpl, reference ) )
            # Must use BuildBaseOrdered to start at the marker; otherwise it builds closest to the eng
            #buildFunction = AIBuildStructures.AIBuildBaseTemplateOrdered
            buildFunction = AIBuildStructures.AIBuildBaseTemplate
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindDefensivePointNeedsStructure( aiBrain, cons.LocationType, (cons.LocationRadius or 100), 
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1), 
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface') )

            table.insert( baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation( baseTmpl, reference ) )

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType and cons.NearMarkerType == 'Naval Defensive Point' then
            baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]

            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIFindNavalDefensivePointNeedsStructure( aiBrain, cons.LocationType, (cons.LocationRadius or 100), 
                            cons.MarkerUnitCategory, cons.MarkerRadius, cons.MarkerUnitCount, (cons.ThreatMin or 0), (cons.ThreatMax or 1), 
                            (cons.ThreatRings or 1), (cons.ThreatType or 'AntiSurface') )

            table.insert( baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation( baseTmpl, reference ) )

            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.NearMarkerType then
            #WARN('*Data weird for builder named - ' .. self.BuilderName )
            if not cons.ThreatMin or not cons.ThreatMax or not cons.ThreatRings then
                cons.ThreatMin = -1000000
                cons.ThreatMax = 1000000
                cons.ThreatRings = 0
            end
            if not cons.BaseTemplate and ( cons.NearMarkerType == 'Defensive Point' or cons.NearMarkerType == 'Expansion Area' ) then
                baseTmpl = baseTmplFile['ExpansionBaseTemplates'][factionIndex]
            end
            relative = false
            local pos = self:GetPlatoonPosition()
            reference, refName = AIUtils.AIGetClosestThreatMarkerLoc(aiBrain, cons.NearMarkerType, pos[1], pos[3],
                                                            cons.ThreatMin, cons.ThreatMax, cons.ThreatRings)
            if cons.ExpansionBase and refName then
                AIBuildStructures.AINewExpansionBase( aiBrain, refName, reference, (cons.ExpansionRadius or 100), cons.ExpansionTypes, nil, cons )
            end
            if reference and aiBrain:GetThreatAtPosition( reference, 1, true ) > 0 then
                #aiBrain:ExpansionHelp( eng, reference )
            end
            table.insert( baseTmplList, AIBuildStructures.AIBuildBaseTemplateFromLocation( baseTmpl, reference ) )
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        elseif cons.AdjacencyCategory then
            relative = false
            local pos = aiBrain.BuilderManagers[eng.BuilderManagerData.LocationType].EngineerManager:GetLocationCoords()
            local cat = ParseEntityCategory(cons.AdjacencyCategory)
            local radius = ( cons.AdjacencyDistance or 50 )
            if not pos or not pos then
                WaitTicks(1)
                self:PlatoonDisband()
                return
            end
            reference  = AIUtils.GetOwnUnitsAroundPoint( aiBrain, cat, pos, radius, cons.ThreatMin,
                                                        cons.ThreatMax, cons.ThreatRings)
            buildFunction = AIBuildStructures.AIBuildAdjacency
            table.insert( baseTmplList, baseTmpl )
        else
            table.insert( baseTmplList, baseTmpl )
            relative = true
            reference = true
            buildFunction = AIBuildStructures.AIExecuteBuildStructure
        end
        if cons.BuildClose then
            closeToBuilder = eng
        end
        if cons.BuildStructures[1] == 'T1Resource' or cons.BuildStructures[1] == 'T2Resource' or cons.BuildStructures[1] == 'T3Resource' then
            relative = true
            closeToBuilder = eng
            local guards = eng:GetGuards()
            for k,v in guards do
                if not v:IsDead() and v.PlatoonHandle and aiBrain:PlatoonExists(v.PlatoonHandle) then
                    #WaitTicks(1)
                    v.PlatoonHandle:PlatoonDisband()
                end
            end
        end                   

        #LOG("*AI DEBUG: Setting up Callbacks for " .. eng.Sync.id)
        self.SetupEngineerCallbacksSorian(eng)
              
        #### BUILD BUILDINGS HERE ####
        for baseNum, baseListData in baseTmplList do
            for k, v in cons.BuildStructures do
                if aiBrain:PlatoonExists(self) then
                    if not eng:IsDead() then
                        buildFunction(aiBrain, eng, v, closeToBuilder, relative, buildingTmpl, baseListData, reference, cons.NearMarkerType)
                    else
                        if aiBrain:PlatoonExists(self) then
                            WaitTicks(1)
                            self:PlatoonDisband()
                            return
                        end
                    end
                end
            end
        end
        
        # wait in case we're still on a base
        if not eng:IsDead() then
            local count = 0
            while eng:IsUnitState( 'Attached' ) and count < 2 do
                WaitSeconds(6)
                count = count + 1
            end
        end

        if not eng:IsUnitState('Building') then
            return self.ProcessBuildCommand(eng, false)
        end
    end,
	
    SetupEngineerCallbacksSorian = function(eng)
        if eng and not eng:IsDead() and not eng.BuildDoneCallbackSet and eng.PlatoonHandle and eng:GetAIBrain():PlatoonExists(eng.PlatoonHandle) then                
            import('/lua/ScenarioTriggers.lua').CreateUnitBuiltTrigger(eng.PlatoonHandle.EngineerBuildDoneSorian, eng, categories.ALLUNITS)
            eng.BuildDoneCallbackSet = true
        end
        if eng and not eng:IsDead() and not eng.CaptureDoneCallbackSet and eng.PlatoonHandle and eng:GetAIBrain():PlatoonExists(eng.PlatoonHandle) then
            import('/lua/ScenarioTriggers.lua').CreateUnitStopCaptureTrigger(eng.PlatoonHandle.EngineerCaptureDoneSorian, eng )
            eng.CaptureDoneCallbackSet = true
        end
        if eng and not eng:IsDead() and not eng.ReclaimDoneCallbackSet and eng.PlatoonHandle and eng:GetAIBrain():PlatoonExists(eng.PlatoonHandle) then
            import('/lua/ScenarioTriggers.lua').CreateUnitStopReclaimTrigger(eng.PlatoonHandle.EngineerReclaimDoneSorian, eng )
            eng.ReclaimDoneCallbackSet = true
        end
        if eng and not eng:IsDead() and not eng.FailedToBuildCallbackSet and eng.PlatoonHandle and eng:GetAIBrain():PlatoonExists(eng.PlatoonHandle) then
            import('/lua/ScenarioTriggers.lua').CreateOnFailedToBuildTrigger(eng.PlatoonHandle.EngineerFailedToBuildSorian, eng )
            eng.FailedToBuildCallbackSet = true
        end      
    end,
    
    # Callback functions for EngineerBuildAI
    EngineerBuildDoneSorian = function(unit, params)
        if not unit.PlatoonHandle then return end
        if not unit.PlatoonHandle.PlanName == 'EngineerBuildAI' then return end
        #LOG("*AI DEBUG: Build done " .. unit.Sync.id)
        if not unit.ProcessBuild then
            unit.ProcessBuild = unit:ForkThread(unit.PlatoonHandle.ProcessBuildCommandSorian, true)
            unit.ProcessBuildDone = true
        end
    end,
    EngineerCaptureDoneSorian = function(unit, params)
        if not unit.PlatoonHandle then return end
        if not unit.PlatoonHandle.PlanName == 'EngineerBuildAI' then return end
        #LOG("*AI DEBUG: Capture done" .. unit.Sync.id)
        if not unit.ProcessBuild then
            unit.ProcessBuild = unit:ForkThread(unit.PlatoonHandle.ProcessBuildCommandSorian, false)
        end
    end,
    EngineerReclaimDoneSorian = function(unit, params)
        if not unit.PlatoonHandle then return end
        if not unit.PlatoonHandle.PlanName == 'EngineerBuildAI' then return end
        #LOG("*AI DEBUG: Reclaim done" .. unit.Sync.id)
        if not unit.ProcessBuild then
            unit.ProcessBuild = unit:ForkThread(unit.PlatoonHandle.ProcessBuildCommandSorian, false)
        end
    end,
    EngineerFailedToBuildSorian = function(unit, params)
        if not unit.PlatoonHandle then return end
        if not unit.PlatoonHandle.PlanName == 'EngineerBuildAI' then return end
        if unit.ProcessBuildDone and unit.ProcessBuild then
            KillThread(unit.ProcessBuild)
            unit.ProcessBuild = nil
        end
        if not unit.ProcessBuild then
            unit.ProcessBuild = unit:ForkThread(unit.PlatoonHandle.ProcessBuildCommandSorian, false)
        end   
    end,

    #-----------------------------------------------------
    #   Function: WatchForNotBuildingSorian
    #   Args:
    #       eng - the engineer that's gone through EngineerBuildAI
    #   Description:
    #       After we try to build something, watch the engineer to
    #       make sure that the build goes through.  If not,
    #       try the next thing in the queue
    #   Returns:  
    #       nil
    #-----------------------------------------------------
    WatchForNotBuildingSorian = function(eng)
        WaitTicks(5)
        local aiBrain = eng:GetAIBrain()
        while not eng:IsDead() and (eng.GoingHome or eng.Fighting or eng:IsUnitState("Building") or 
                  eng:IsUnitState("Attacking") or eng:IsUnitState("Repairing") or 
                  eng:IsUnitState("Reclaiming") or eng:IsUnitState("Capturing") or eng.ProcessBuild != nil 
				  or eng.UnitBeingBuiltBehavior) do
                  
            WaitSeconds(3)
            #if eng.CDRHome then eng:PrintCommandQueue() end
        end
        eng.NotBuildingThread = nil
        if not eng:IsDead() and eng:IsIdleState() and table.getn(eng.EngineerBuildQueue) != 0 and eng.PlatoonHandle then
            eng.PlatoonHandle.SetupEngineerCallbacksSorian(eng)
            if not eng.ProcessBuild then
                eng.ProcessBuild = eng:ForkThread(eng.PlatoonHandle.ProcessBuildCommandSorian, true)
            end
        end  
    end,
    
    #-----------------------------------------------------
    #   Function: ProcessBuildCommandSorian
    #   Args:
    #       eng - the engineer that's gone through EngineerBuildAI
    #   Description:
    #       Run after every build order is complete/fails.  Sets up the next
    #       build order in queue, and if the engineer has nothing left to do
    #       will return the engineer back to the army pool by disbanding the
    #       the platoon.  Support function for EngineerBuildAI
    #   Returns:  
    #       nil (tail calls into a behavior function)
    #-----------------------------------------------------
    ProcessBuildCommandSorian = function(eng, removeLastBuild)
        if not eng or eng:IsDead() or not eng.PlatoonHandle or eng.GoingHome or eng.Fighting or eng.UnitBeingBuiltBehavior then
            if eng then eng.ProcessBuild = nil end
            return
        end
        
        local aiBrain = eng.PlatoonHandle:GetBrain()            
        if not aiBrain or eng:IsDead() or not eng.EngineerBuildQueue or table.getn(eng.EngineerBuildQueue) == 0 then
            if aiBrain:PlatoonExists(eng.PlatoonHandle) then
                #LOG("*AI DEBUG: Disbanding Engineer Platoon in ProcessBuildCommand " .. eng.Sync.id)
				#if EntityCategoryContains( categories.COMMAND, eng ) then
				#	LOG("*AI DEBUG: Commander Platoon Disbanded in ProcessBuildCommand")
				#end
                eng.PlatoonHandle:PlatoonDisband()
            end
            if eng then eng.ProcessBuild = nil end
            return
        end
         
        # it wasn't a failed build, so we just finished something
        if removeLastBuild then
            table.remove(eng.EngineerBuildQueue, 1)
        end
        
        function BuildToNormalLocation(location)
            return {location[1], 0, location[2]}
        end
        
        function NormalToBuildLocation(location)
            return {location[1], location[3], 0}
        end
        
        eng.ProcessBuildDone = false  
        IssueClearCommands({eng}) 
        local commandDone = false
        while not eng:IsDead() and not commandDone and table.getn(eng.EngineerBuildQueue) > 0  do
            local whatToBuild = eng.EngineerBuildQueue[1][1]
            local buildLocation = BuildToNormalLocation(eng.EngineerBuildQueue[1][2])
            local buildRelative = eng.EngineerBuildQueue[1][3]
			local threadStarted = false
            # see if we can move there first        
            if AIUtils.EngineerMoveWithSafePath(aiBrain, eng, buildLocation) then
                if not eng or eng:IsDead() or not eng.PlatoonHandle or not aiBrain:PlatoonExists(eng.PlatoonHandle) then
                    if eng then eng.ProcessBuild = nil end
                    return
                end
                # check to see if we need to reclaim or capture...
                if not AIUtils.EngineerTryReclaimCaptureArea(aiBrain, eng, buildLocation) then
                    # check to see if we can repair
                    if not AIUtils.EngineerTryRepair(aiBrain, eng, whatToBuild, buildLocation) then
                        # otherwise, go ahead and build the next structure there
                        aiBrain:BuildStructure( eng, whatToBuild, NormalToBuildLocation(buildLocation), buildRelative )
                        if not eng.NotBuildingThread then
							threadStarted = true
                            eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuildingSorian)
                        end
                    end
                end
				if not threadStarted and not eng.NotBuildingThread then
					eng.NotBuildingThread = eng:ForkThread(eng.PlatoonHandle.WatchForNotBuildingSorian)
				end
                commandDone = true             
            else
                # we can't move there, so remove it from our build queue
                table.remove(eng.EngineerBuildQueue, 1)
            end
        end
        
        # final check for if we should disband
        if not eng or eng:IsDead() or table.getn(eng.EngineerBuildQueue) == 0 then
            if eng.PlatoonHandle and aiBrain:PlatoonExists(eng.PlatoonHandle) then
                #LOG("*AI DEBUG: Disbanding Engineer Platoon in ProcessBuildCommand " .. eng.Sync.id)
				#if EntityCategoryContains( categories.COMMAND, eng ) then
				#	LOG("*AI DEBUG: Commander Platoon Disbanded in ProcessBuildCommand")
				#end
                eng.PlatoonHandle:PlatoonDisband()
            end
            if eng then eng.ProcessBuild = nil end
            return
        end
        if eng then eng.ProcessBuild = nil end       
    end,       
}

end
