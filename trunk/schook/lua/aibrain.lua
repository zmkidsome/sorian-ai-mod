do
local AIAttackUtils = import('/lua/AI/aiattackutilities.lua')
local SUtils = import('/lua/AI/sorianutilities.lua')
local StratManager = import('/lua/sim/StrategyManager.lua')
oldAIBrain = AIBrain

AIBrain = Class(oldAIBrain) {
	
    OnDefeat = function(self)
		if self.BrainType == 'AI' then
			SUtils.AISendChat('enemies', ArmyBrains[self:GetArmyIndex()].Nickname, 'ilost')
		end
        SetArmyOutOfGame(self:GetArmyIndex())
        table.insert( Sync.GameResult, { self:GetArmyIndex(), "defeat" } )
        import('/lua/SimUtils.lua').UpdateUnitCap()
        import('/lua/SimPing.lua').OnArmyDefeat(self:GetArmyIndex())
        local function KillArmy()
            WaitSeconds(20)
            local units = self:GetListOfUnits(categories.ALLUNITS - categories.WALL, false)
            for index,unit in units do
                unit:Kill()
            end
        end
        ForkThread(KillArmy)
        if self.BuilderManagers then
			self.ConditionsMonitor:Destroy()
            for k,v in self.BuilderManagers do
				v.EngineerManager:SetEnabled(false)
				v.FactoryManager:SetEnabled(false)
				v.PlatoonFormManager:SetEnabled(false)
				v.StrategyManager:SetEnabled(false)
				v.FactoryManager:Destroy()
                v.PlatoonFormManager:Destroy()
                v.EngineerManager:Destroy()
                v.StrategyManager:Destroy()
            end
        end
        if self.Trash then
            self.Trash:Destroy()
        end
    end,
	
    OnCreateAI = function(self, planName)
        self:CreateBrainShared(planName)

        #LOG('*AI DEBUG: AI planName = ', repr(planName))
        #LOG('*AI DEBUG: SCENARIO AI PLAN LIST = ', repr(aiScenarioPlans))
        local civilian = false
        for name,data in ScenarioInfo.ArmySetup do
            if name == self.Name then
                civilian = data.Civilian
                break
            end
        end
        if not civilian then
            local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
            
            # Flag this brain as a possible brain to have skirmish systems enabled on
            self.SkirmishSystems = true
            
            local cheatPos = string.find( per, 'cheat')
            if cheatPos then
                AIUtils.SetupCheat(self, true)
                ScenarioInfo.ArmySetup[self.Name].AIPersonality = string.sub( per, 1, cheatPos - 1 )
            end

            self.CurrentPlan = self.AIPlansList[self:GetFactionIndex()][1]

            #LOG('*AI DEBUG: AI PLAN LIST = ', repr(self.AIPlansList))
            #LOG('===== AI DEBUG: AI Brain Fork Theads =====')
            self.EvaluateThread = self:ForkThread(self.EvaluateAIThread)
            self.ExecuteThread = self:ForkThread(self.ExecuteAIThread)

            self.PlatoonNameCounter = {}
            self.PlatoonNameCounter['AttackForce'] = 0
            self.BaseTemplates = {}
            self.RepeatExecution = true
            self:InitializeEconomyState()
            self.IntelData = {
                ScoutCounter = 0,
            }
            
            #Flag enemy starting locations with threat?        
            if ScenarioInfo.type == 'skirmish' and string.find(per, 'sorian') then
                self:AddInitialEnemyThreatSorian(200, 0.005, 'Economy')
			elseif ScenarioInfo.type == 'skirmish' then
				self:AddInitialEnemyThreat(200, 0.005)
            end           
        end        
        self.UnitBuiltTriggerList = {}
        self.FactoryAssistList = {}
        self.BrainType = 'AI'
    end,

    InitializeSkirmishSystems = function(self)
    
        # Make sure we don't do anything for the human player!!!
        if self.BrainType == 'Human' then
            return
        end
    
        #TURNING OFF AI POOL PLATOON, I MAY JUST REMOVE THAT PLATOON FUNCTIONALITY LATER
        local poolPlatoon = self:GetPlatoonUniquelyNamed('ArmyPool')
        if poolPlatoon then
            poolPlatoon:TurnOffPoolAI()
        end

        # Stores handles to all builders for quick iteration and updates to all
        self.BuilderHandles = {}

        # Condition monitor for the whole brain
        self.ConditionsMonitor = BrainConditionsMonitor.CreateConditionsMonitor(self)

        # Economy monitor for new skirmish - stores out econ over time to get trend over 10 seconds
        self.EconomyData = {}
        self.EconomyTicksMonitor = 50
        self.EconomyCurrentTick = 1
        self.EconomyMonitorThread = self:ForkThread(self.EconomyMonitor)
        self.LowEnergyMode = false

        # Add default main location and setup the builder managers
        self.NumBases = 1

        self.BuilderManagers = {}
		
		SUtils.AddCustomUnitSupport(self)
		#SUtils.AddCustomFactionSupport(self)
        
        self:AddBuilderManagers(self:GetStartVector3f(), 100, 'MAIN', false)
        #self.BuilderManagers.MAIN.StrategyManager = StratManager.CreateStrategyManager(self, 'MAIN', self:GetStartVector3f(), 100)

        # Begin the base monitor process
		local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
		
		if string.find(per, 'sorian') then
			local spec = {
				DefaultDistressRange = 200,
				AlertLevel = 8,
			}
			self:BaseMonitorInitializationSorian(spec)
		else		
			self:BaseMonitorInitialization()
		end
        local plat = self:GetPlatoonUniquelyNamed('ArmyPool')
        
        plat:ForkThread( plat.BaseManagersDistressAI )
		
		self.DeadBaseThread = self:ForkThread( self.DeadBaseMonitor )
        if string.find(per, 'sorian') then
			self.EnemyPickerThread = self:ForkThread( self.PickEnemySorian )
		else
			self.EnemyPickerThread = self:ForkThread( self.PickEnemy )
		end
    end,
	
    AddInitialEnemyThreatSorian = function(self, amount, decay, threatType)
        local aiBrain = self
        local myArmy = ScenarioInfo.ArmySetup[self.Name]
            
        if ScenarioInfo.Options.TeamSpawn == 'fixed' then
            #Spawn locations were fixed. We know exactly where our opponents are. 
            
            for i=1,8 do
                local token = 'ARMY_' .. i
                local army = ScenarioInfo.ArmySetup[token]
                
                if army then
                    if army.ArmyIndex ~= myArmy.ArmyIndex and (army.Team ~= myArmy.Team or army.Team == 1) then
                        local startPos = ScenarioUtils.GetMarker('ARMY_' .. i).position
                        self:AssignThreatAtPosition(startPos, amount, decay, threatType or 'Overall')
                    end
                end
            end
        end
    end,
	
    AddBuilderManagers = function(self, position, radius, baseName, useCenter )
        self.BuilderManagers[baseName] = {
            FactoryManager = FactoryManager.CreateFactoryBuilderManager(self, baseName, position, radius, useCenter),
            PlatoonFormManager = PlatoonFormManager.CreatePlatoonFormManager(self, baseName, position, radius, useCenter),
            EngineerManager = EngineerManager.CreateEngineerManager(self, baseName, position, radius),
			StrategyManager = StratManager.CreateStrategyManager(self, baseName, position, radius),

            # Table to track consumption
            MassConsumption = {
                Resources = { Units = {}, Drain = 0, },
                Units = { Units = {}, Drain = 0, },
                Defenses = { Units = {}, Drain = 0, },
                Upgrades = { Units = {}, Drain = 0, },
                Engineers = { Units = {}, Drain = 0, },
                TotalDrain = 0,
            },

            BuilderHandles = {},
            
            Position = position,
        }
        self.NumBases = self.NumBases + 1
    end,
	
	DeadBaseMonitor = function(self)
		while true do
			WaitSeconds(5)
			local changed = false
			for k,v in self.BuilderManagers do
				if k != 'MAIN' and v.EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) <= 0 and v.FactoryManager:GetNumCategoryFactories(categories.ALLUNITS) <= 0 then
					if v.EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) <= 0 then
						v.EngineerManager:SetEnabled(false)
						v.FactoryManager:SetEnabled(false)
						v.PlatoonFormManager:SetEnabled(false)
						v.StrategyManager:SetEnabled(false)
						v.FactoryManager:Destroy()
						v.PlatoonFormManager:Destroy()
						v.EngineerManager:Destroy()
						v.StrategyManager:Destroy()
						self.BuilderManagers[k] = nil
						self.NumBases = self.NumBases - 1
						changed = true
					end
				end
			end
			if changed then
				self.BuilderManagers = self:RebuildTable(self.BuilderManagers)
			end
		end
	end,
	
	RebuildTable = function(self, oldtable)
		local temptable = {}
		for k,v in oldtable do
			if v != nil then
				if type(k) == 'string' then
					temptable[k] = v
				else
					table.insert(temptable, v)
				end
			end
		end
		return temptable
	end,
	
    GetManagerCount = function(self, type)
        local count = 0
        for k,v in self.BuilderManagers do
            if type then
                if type == 'Start Location' and not ( string.find(k, 'ARMY_') or string.find(k, 'Large Expansion') ) then
                    continue
                elseif type == 'Naval Area' and not ( string.find(k, 'Naval Area') ) then
                    continue
                elseif type == 'Expansion Area' and ( not (string.find(k, 'Expansion Area') or string.find(k, 'EXPANSION_AREA')) or string.find(k, 'Large Expansion') ) then
                    continue
                end
            end
        
            if v.EngineerManager:GetNumCategoryUnits('Engineers', categories.ALLUNITS) <= 0 and v.FactoryManager:GetNumCategoryFactories(categories.ALLUNITS) <= 0 then
                continue
            end
            
            count = count + 1
        end
        return count
    end,
	
    BaseMonitorInitializationSorian = function(self, spec)
        self.BaseMonitor = {
            BaseMonitorStatus = 'ACTIVE',
            BaseMonitorPoints = {},
            AlertSounded = false,
            AlertsTable = {},
            AlertLocation = false,
            AlertSoundedThreat = 0,
            ActiveAlerts = 0,

            PoolDistressRange = 75,
            PoolReactionTime = 7,

            # Variables for checking a radius for enemy units
            UnitRadiusThreshold = spec.UnitRadiusThreshold or 3,
            UnitCategoryCheck = spec.UnitCategoryCheck or ( categories.MOBILE - ( categories.SCOUT + categories.ENGINEER ) ),
            UnitCheckRadius = spec.UnitCheckRadius or 40,

            # Threat level must be greater than this number to sound a base alert
            AlertLevel = spec.AlertLevel or 0,
            # Delay time for checking base
            BaseMonitorTime = spec.BaseMonitorTime or 11,
            # Default distance a platoon will travel to help around the base
            DefaultDistressRange = spec.DefaultDistressRange or 75,
            # Default how often platoons will check if the base is under duress
            PlatoonDefaultReactionTime = spec.PlatoonDefaultReactionTime or 5,
            # Default duration for an alert to time out
            DefaultAlertTimeout = spec.DefaultAlertTimeout or 10,
            
            PoolDistressThreshold = 1,


            ## Monitor platoons for help
            PlatoonDistressTable = {},
            PlatoonDistressThread = false,
            PlatoonAlertSounded = false,
        }
		self.SelfMonitor = {
			CheckRadius = spec.SelfCheckRadius or 150,
			ArtyCheckRadius = spec.SelfArtyCheckRadius or 300,
			ThreatRadiusThreshold = spec.SelfThreatRadiusThreshold or 8,
		}
        self:ForkThread( self.BaseMonitorThreadSorian )
    end,
	
    BaseMonitorThreadSorian = function(self)
        while true do
            if self.BaseMonitor.BaseMonitorStatus == 'ACTIVE' then
				self:SelfMonitorCheck()
                self:BaseMonitorCheck()
            end
            WaitSeconds( self.BaseMonitor.BaseMonitorTime )
        end
    end,
	
	SelfMonitorCheck = function(self)
		if not self.BaseMonitor.AlertSounded then
			local startlocx, startlocz = self:GetArmyStartPos()
			local threatTable = self:GetThreatsAroundPosition({startlocx, 0, startlocz}, 16, true, 'AntiSurface')
			local artyThreatTable = self:GetThreatsAroundPosition({startlocx, 0, startlocz}, 16, true, 'Artillery')
			local highThreat = false
			local highThreatPos = false
			local radius = self.SelfMonitor.CheckRadius * self.SelfMonitor.CheckRadius
			local artyRadius = self.SelfMonitor.ArtyCheckRadius * self.SelfMonitor.ArtyCheckRadius
			for tIndex,threat in threatTable do
				local enemyThreat = self:GetThreatAtPosition( {threat[1], 0, threat[2]}, 0, true, 'AntiSurface')
				local dist = VDist2Sq(threat[1], threat[2], startlocx, startlocz)
				if (not highThreat or enemyThreat > highThreat) and enemyThreat > self.SelfMonitor.ThreatRadiusThreshold and dist < radius then
					highThreat = enemyThreat
					highThreatPos = {threat[1], 0, threat[2]}
				end
			end
			if highThreat then
				table.insert( self.BaseMonitor.AlertsTable,
					{
					Position = highThreatPos,
					Threat = highThreat,
					}
				)
				self:ForkThread(self.BaseMonitorAlertTimeout, highThreatPos)
				self.BaseMonitor.ActiveAlerts = self.BaseMonitor.ActiveAlerts + 1
				self.BaseMonitor.AlertSounded = true
			end
			highThreat = false
			highThreatPos = false
			for tIndex,threat in artyThreatTable do
				local enemyThreat = self:GetThreatAtPosition( {threat[1], 0, threat[2]}, 0, true, 'Artillery')
				local dist = VDist2Sq(threat[1], threat[2], startlocx, startlocz)
				if (not highThreat or enemyThreat > highThreat) and enemyThreat > self.SelfMonitor.ThreatRadiusThreshold and dist < artyRadius then
					highThreat = enemyThreat
					highThreatPos = {threat[1], 0, threat[2]}
				end
			end
			if highThreat then
				table.insert( self.BaseMonitor.AlertsTable,
					{
					Position = highThreatPos,
					Threat = highThreat,
					}
				)
				self:ForkThread(self.BaseMonitorAlertTimeout, highThreatPos, 'Artillery')
				self.BaseMonitor.ActiveAlerts = self.BaseMonitor.ActiveAlerts + 1
				self.BaseMonitor.AlertSounded = true
			end
		end
	end,
	
    BaseMonitorPlatoonDistressThread = function(self)
        self.BaseMonitor.PlatoonAlertSounded = true
        while true do
            local numPlatoons = 0
            for k,v in self.BaseMonitor.PlatoonDistressTable do
                if self:PlatoonExists(v.Platoon) then
                    local threat = self:GetThreatAtPosition( v.Platoon:GetPlatoonPosition(), 0, true, 'AntiSurface')
					local myThreat = self:GetThreatAtPosition( v.Platoon:GetPlatoonPosition(), 0, true, 'Overall', self:GetArmyIndex())
                    # Platoons still threatened
				if threat and threat > (myThreat * 1.5) then
                        v.Threat = threat
                        numPlatoons = numPlatoons + 1
                    # Platoon not threatened
                    else
                        self.BaseMonitor.PlatoonDistressTable[k] = nil
                        v.Platoon.DistressCall = false
                    end
                else
                    self.BaseMonitor.PlatoonDistressTable[k] = nil
                end
            end
            
            # If any platoons still want help; continue sounding
            if numPlatoons > 0 then
                self.BaseMonitor.PlatoonAlertSounded = true
            else
                self.BaseMonitor.PlatoonAlertSounded = false
            end
            WaitSeconds(self.BaseMonitor.BaseMonitorTime)
        end
    end,
	
    BaseMonitorAlertTimeout = function(self, pos, threattype)
        local timeout = self.BaseMonitor.DefaultAlertTimeout
        local threat
        local threshold = self.BaseMonitor.AlertLevel
		local myThreat
        repeat
            WaitSeconds(timeout)
            threat = self:GetThreatAtPosition( pos, 0, true, threattype or 'AntiSurface' )
			myThreat = self:GetThreatAtPosition( pos, 0, true, 'Overall', self:GetArmyIndex())
			if threat - myThreat < 1 then
				local eEngies = self:GetNumUnitsAroundPoint( categories.ENGINEER, pos, 10, 'Enemy' )
				if eEngies > 0 then
					threat = threat + (eEngies * 10)
				end
			end	
        until threat - myThreat <= threshold
        for k,v in self.BaseMonitor.AlertsTable do
            if pos[1] == v.Position[1] and pos[3] == v.Position[3] then
                self.BaseMonitor.AlertsTable[k] = nil
                break
            end
        end
        for k,v in self.BaseMonitor.BaseMonitorPoints do
            if pos[1] == v.Position[1] and pos[3] == v.Position[3] then
                v.Alert = false
                break
            end
        end
        self.BaseMonitor.ActiveAlerts = self.BaseMonitor.ActiveAlerts - 1
        if self.BaseMonitor.ActiveAlerts == 0 then
            self.BaseMonitor.AlertSounded = false
            #LOG('*AI DEBUG: ARMY ' .. self:GetArmyIndex() .. ': --- ALERTS DEACTIVATED ---')
        end
    end,
	
    BaseMonitorCheck = function(self)
        local vecs = self:GetStructureVectors()
        if table.getn(vecs) > 0 then
            # Find new points to monitor
            for k,v in vecs do
                local found = false
                for subk, subv in self.BaseMonitor.BaseMonitorPoints do
                    if v[1] == subv.Position[1] and v[3] == subv.Position[3] then
                        continue
                    end
                end
                table.insert( self.BaseMonitor.BaseMonitorPoints,
                             {
                                Position = v,
                                Threat = self:GetThreatAtPosition( v, 0, true, 'AntiSurface' ),
                                Alert = false
                             }
                         )
            end
            # Remove any points that we dont monitor anymore
            for k,v in self.BaseMonitor.BaseMonitorPoints do
                local found = false
                for subk, subv in vecs do
                    if v.Position[1] == subv[1] and v.Position[3] == subv[3] then
                        found = true
                        break
                    end
                end
                # If point not in list and the num units around the point is small
                if not found and not self:GetNumUnitsAroundPoint( categories.STRUCTURE, v.Position, 16, 'Ally' ) > 1 then
                    self.BaseMonitor.BaseMonitorPoints[k] = nil
                end
            end
            # Check monitor points for change
            local alertThreat = self.BaseMonitor.AlertLevel
            for k,v in self.BaseMonitor.BaseMonitorPoints do
                if not v.Alert then
                    v.Threat = self:GetThreatAtPosition( v.Position, 0, true, 'AntiSurface' )
					local myThreat = self:GetThreatAtPosition( v.Position, 0, true, 'AntiSurface', self:GetArmyIndex())
					if v.Threat - myThreat < 1 then
						local eEngies = self:GetNumUnitsAroundPoint( categories.ENGINEER, v.Position, 10, 'Enemy' )
						if eEngies > 0 then
							v.Threat = v.Threat + (eEngies * 10)
						end
					end						
                    if v.Threat - myThreat > alertThreat then
                        v.Alert = true
                        table.insert( self.BaseMonitor.AlertsTable,
                            {
                                Position = v.Position,
                                Threat = v.Threat,
                            }
                        )
                        self.BaseMonitor.AlertSounded = true
                        self:ForkThread(self.BaseMonitorAlertTimeout, v.Position)
                        self.BaseMonitor.ActiveAlerts = self.BaseMonitor.ActiveAlerts + 1
                    end
                end
            end
        end
    end,
	
    ParseIntelThreadSorian = function(self)
        if not self.InterestList or not self.InterestList.MustScout then
            error('Scouting areas must be initialized before calling AIBrain:ParseIntelThread.',2)
        end
		if not self.T4ThreatFound then
			self.T4ThreatFound = {}
		end
		if not self.AttackPoints then
			self.AttackPoints = {}
		end
		if not self.TacticalBases then
			self.TacticalBases = {}
		end
		local intelChecks = {
			#ThreatType	= {dist to merge squared, threat minimum, timeout (-1 = never timeout)}
			StructuresNotMex = { 10000, 0, 60 },
			Commander = { 2500, 0, 120 },
			Experimental = { 2500, 0, 120 },
			Land = { 10000, 50, 120 },
		}
        while true do
			local changed = false
			for threatType, v in intelChecks do
			
	            local threats = self:GetThreatsAroundPosition(self.BuilderManagers.MAIN.Position, 16, true, threatType)

	            for _,threat in threats do
	                local dupe = false
	                local newPos = {threat[1], 0, threat[2]}
	                
	                for _,loc in self.InterestList.HighPriority do
	                    if loc.Type == threatType and VDist2Sq(newPos[1], newPos[3], loc.Position[1], loc.Position[3]) < v[1] then
	                        dupe = true
							loc.LastUpdate = GetGameTimeSeconds()
	                        break
	                    end
	                end
	                
	                if not dupe then
	                    #Is it in the low priority list?
	                    for i=1, table.getn(self.InterestList.LowPriority) do
	                        local loc = self.InterestList.LowPriority[i]
	                        if VDist2Sq(newPos[1], newPos[3], loc.Position[1], loc.Position[3]) < v[1] and threat[3] > v[2] then
	                            #Found it in the low pri list. Remove it so we can add it to the high priority list.
	                            table.remove(self.InterestList.LowPriority, i)
	                            break
	                        end
	                    end
	                    if threat[3] > v[2] then
							changed = true
							table.insert(self.InterestList.HighPriority,
								{
									Position = newPos,
									Type = threatType,
									Threat = threat[3],
									LastUpdate = GetGameTimeSeconds(),
									LastScouted = GetGameTimeSeconds(),
								}
							)
						end
					end
	            end
			end
			#Get rid of outdated intel
			for k, v in self.InterestList.HighPriority do
				if not v.Permanent and intelChecks[v.Type][3] > 0 and v.LastUpdate + intelChecks[v.Type][3] < GetGameTimeSeconds() then
					self.InterestList.HighPriority[k] = nil
					changed = true
				end
			end
			if changed then
				self.InterestList.HighPriority = self:RebuildTable(self.InterestList.HighPriority)
			end
			#Sort the list based on low long it has been since it was scouted
			table.sort(self.InterestList.HighPriority, function(a,b) 
				if a.LastScouted == b.LastScouted then
					local MainPos = self.BuilderManagers.MAIN.Position
					local distA = VDist2(MainPos[1], MainPos[3], a.Position[1], a.Position[3])
					local distB = VDist2(MainPos[1], MainPos[3], b.Position[1], b.Position[3])
					
					return distA < distB
				else
					return a.LastScouted < b.LastScouted
				end
			end)
			#Draw intel data on map
			if ScenarioInfo.Options.DebugIntel and not self.IntelDebugThread then #self:GetArmyIndex() == GetFocusArmy() then
				self.IntelDebugThread = self:ForkThread( SUtils.DrawIntel ) #SUtils.DrawIntel(self)
			end
			if changed then
				SUtils.AIHandleIntelData(self)
			end
            
            WaitSeconds(5)
        end
    end,
	
	T4ThreatMonitorTimeout = function(self, threattypes)
		WaitSeconds(180)
		for k,v in threattypes do
			self.T4ThreatFound[v] = false
		end
	end,
	
    BuildScoutLocationsSorian = function(self)
        local aiBrain = self
        
        local opponentStarts = {}
        local allyStarts = {}
        
        if not aiBrain.InterestList then
            
            aiBrain.InterestList = {}
            aiBrain.IntelData.HiPriScouts = 0
            aiBrain.IntelData.AirHiPriScouts = 0
            aiBrain.IntelData.AirLowPriScouts = 0
            
            #Add each enemy's start location to the InterestList as a new sub table
            aiBrain.InterestList.HighPriority = {}
            aiBrain.InterestList.LowPriority = {}
            aiBrain.InterestList.MustScout = {}
            
            local myArmy = ScenarioInfo.ArmySetup[self.Name]
            
            if ScenarioInfo.Options.TeamSpawn == 'fixed' then
                #Spawn locations were fixed. We know exactly where our opponents are. 
                #Don't scout areas owned by us or our allies.  
                local numOpponents = 0
                
                for i=1,8 do
                    local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
                    local startPos = ScenarioUtils.GetMarker('ARMY_' .. i).position
                    
                    if army then
                        if army.ArmyIndex ~= myArmy.ArmyIndex and (army.Team ~= myArmy.Team or army.Team == 1) then
                        #Add the army start location to the list of interesting spots.
                        opponentStarts['ARMY_' .. i] = startPos
                        numOpponents = numOpponents + 1
                        table.insert(aiBrain.InterestList.HighPriority,
                            {
                                Position = startPos,
								Type = 'StructuresNotMex',
                                LastScouted = 0,
								LastUpdate = 0,
								Threat = 75,
								Permanent = true,
                            }
                        )
                        else 
                            allyStarts['ARMY_' .. i] = startPos
                        end
                    end
                end
                
                aiBrain.NumOpponents = numOpponents
                
                #For each vacant starting location, check if it is closer to allied or enemy start locations (within 100 ogrids)
                #If it is closer to enemy territory, flag it as high priority to scout.
                local starts = AIUtils.AIGetMarkerLocations(aiBrain, 'Start Location')
                for _,loc in starts do
                    #if vacant
                    if not opponentStarts[loc.Name] and not allyStarts[loc.Name] then
                        local closestDistSq = 999999999
                        local closeToEnemy = false
                        
                        for _,pos in opponentStarts do
                            local distSq = VDist2Sq(pos[1], pos[3], loc.Position[1], loc.Position[3])
                            #Make sure to scout for bases that are near equidistant by giving the enemies 100 ogrids
                            if distSq-10000 < closestDistSq then
                                closestDistSq = distSq-10000
                                closeToEnemy = true
                            end
                        end 
                        
                        for _,pos in allyStarts do
                            local distSq = VDist2Sq(pos[1],pos[3], loc.Position[1], loc.Position[3])
                            if distSq < closestDistSq then
                                closestDistSq = distSq
                                closeToEnemy = false
                                break
                            end
                        end
                        
                        if closeToEnemy then
                            table.insert(aiBrain.InterestList.LowPriority,
                                {
                                    Position = loc.Position,
									Type = 'StructuresNotMex',
                                    LastScouted = 0,
									LastUpdate = 0,
									Threat = 0,
									Permanent = true,
                                }
                            )
                        end
                    end
                end
                
            else #Spawn locations were random. We don't know where our opponents are. Add all non-ally start locations to the scout list              
                local numOpponents = 0
                
                for i=1,8 do
                    local army = ScenarioInfo.ArmySetup['ARMY_' .. i]
                    local startPos = ScenarioUtils.GetMarker('ARMY_' .. i).position
                    
                    if army then
                        if army.ArmyIndex == myArmy.ArmyIndex or (army.Team == myArmy.Team and army.Team ~= 1) then
                            allyStarts['ARMY_' .. i] = startPos
                        else
                            numOpponents = numOpponents + 1
                        end
                    end
                end
                
                aiBrain.NumOpponents = numOpponents
                
                #If the start location is not ours or an ally's, it is suspicious
                local starts = AIUtils.AIGetMarkerLocations(aiBrain, 'Start Location')
                for _,loc in starts do
                    #if vacant
                    if not allyStarts[loc.Name] then
                        table.insert(aiBrain.InterestList.LowPriority,
                                {
                                    Position = loc.Position,
                                    LastScouted = 0,
									LastUpdate = 0,
									Threat = 0,
									Permanent = true,
                                }
                            )
                    end
                end
            end
            
            aiBrain:ForkThread(self.ParseIntelThreadSorian)
        end
    end,

    PickEnemySorian = function(self)
		self.targetoveride = false
        while true do
            self:PickEnemyLogicSorian(true)
            WaitSeconds(120)
        end
    end,
	
    PickEnemyLogicSorian = function(self, brainbool)
        local armyStrengthTable = {}
        
        local selfIndex = self:GetArmyIndex()
        for k,v in ArmyBrains do
            local insertTable = {
                Enemy = true,
                Strength = 0,
                Position = false,
                Brain = v,
            }
            # Share resources with friends but don't regard their strength
            if IsAlly( selfIndex, v:GetArmyIndex() ) then
                self:SetResourceSharing(true)
                insertTable.Enemy = false
            elseif not IsEnemy( selfIndex, v:GetArmyIndex() ) then
                insertTable.Enemy = false
            end
            
            insertTable.Position, insertTable.Strength = self:GetHighestThreatPosition( 2, true, 'Structures', v:GetArmyIndex() )
            armyStrengthTable[v:GetArmyIndex()] = insertTable
        end
        
        local allyEnemy = self:GetAllianceEnemy(armyStrengthTable)
        if allyEnemy and not self.targetoveride then
            self:SetCurrentEnemy( allyEnemy )
        else
            local findEnemy = false
            if not self:GetCurrentEnemy() or brainbool and not self.targetoveride then
                findEnemy = true
            else
                local cIndex = self:GetCurrentEnemy():GetArmyIndex()
                # If our enemy has been defeated or has less than 20 strength, we need a new enemy
                if self:GetCurrentEnemy():IsDefeated() or armyStrengthTable[cIndex].Strength < 20 then
                    findEnemy = true
                end
            end
            if findEnemy then
                local enemyStrength = false
                local enemy = false
                
                for k,v in armyStrengthTable do
                    # dont' target self
                    if k == selfIndex then
                        continue
                    end
                    
                    # Ignore allies
                    if not v.Enemy then
                        continue
                    end
                    
                    # If we have a better candidate; ignore really weak enemies
                    if enemy and v.Strength < 20 then
                        continue
                    end
                    
                    # the closer targets are worth more because then we get their mass spots
                    local distanceWeight = 0.1
                    local distance = VDist3( self:GetStartVector3f(), v.Position )
                    local threatWeight = (1 / ( distance * distanceWeight )) * v.Strength
                    
                    #LOG('*AI DEBUG: Army ' .. v.Brain:GetArmyIndex() .. ' - Weighted enemy threat = ' .. threatWeight)
                    if not enemy or threatWeight > enemyStrength then
						enemyStrength = threatWeight
                        enemy = v.Brain
                    end
                end
                
                if enemy then
					if not self:GetCurrentEnemy() or self:GetCurrentEnemy() != enemy then
						SUtils.AISendChat('allies', ArmyBrains[self:GetArmyIndex()].Nickname, 'targetchat', ArmyBrains[enemy:GetArmyIndex()].Nickname)
					end
                    self:SetCurrentEnemy( enemy )
                    #LOG('*AI DEBUG: Choosing enemy - ' .. enemy:GetArmyIndex())
                end
            end
        end
    end,
	
    UnderEnergyThresholdSorian = function(self)
        self:SetupOverEnergyStatTriggerSorian(0.15)
        #for k,v in self.BuilderManagers do
        #   v.EngineerManager:LowEnergySorian()
        #end
		self.LowEnergyMode = true
    end,

    OverEnergyThresholdSorian = function(self)
        self:SetupUnderEnergyStatTriggerSorian(0.1)
        #for k,v in self.BuilderManagers do
        #    v.EngineerManager:RestoreEnergySorian()
        #end
		self.LowEnergyMode = false
    end,

    UnderMassThresholdSorian = function(self)
        self:SetupOverMassStatTriggerSorian(0.15)
        #for k,v in self.BuilderManagers do
        #    v.EngineerManager:LowMassSorian()
        #end
		self.LowMassMode = true
    end,

    OverMassThresholdSorian = function(self)
        self:SetupUnderMassStatTriggerSorian(0.1)
        #for k,v in self.BuilderManagers do
        #    v.EngineerManager:RestoreMassSorian()
        #end
		self.LowMassMode = false
    end,
	
    SetupUnderEnergyStatTriggerSorian = function(self, threshold)
        import('/lua/scenariotriggers.lua').CreateArmyStatTrigger( self.UnderEnergyThresholdSorian, self, 'SkirmishUnderEnergyThresholdSorian',
            {
                {
                    StatType = 'Economy_Ratio_Energy',
                    CompareType = 'LessThanOrEqual',
                    Value = threshold,
                },
            }
        )
    end,

    SetupOverEnergyStatTriggerSorian = function(self, threshold)
        import('/lua/scenariotriggers.lua').CreateArmyStatTrigger( self.OverEnergyThresholdSorian, self, 'SkirmishOverEnergyThresholdSorian',
            {
                {
                    StatType = 'Economy_Ratio_Energy',
                    CompareType = 'GreaterThanOrEqual',
                    Value = threshold,
                },
            }
        )
    end,

    SetupUnderMassStatTriggerSorian = function(self, threshold)
        import('/lua/scenariotriggers.lua').CreateArmyStatTrigger( self.UnderMassThresholdSorian, self, 'SkirmishUnderMassThresholdSorian',
            {
                {
                    StatType = 'Economy_Ratio_Mass',
                    CompareType = 'LessThanOrEqual',
                    Value = threshold,
                },
            }
        )
    end,

    SetupOverMassStatTriggerSorian = function(self, threshold)
        import('/lua/scenariotriggers.lua').CreateArmyStatTrigger( self.OverMassThresholdSorian, self, 'SkirmishOverMassThresholdSorian',
            {
                {
                    StatType = 'Economy_Ratio_Mass',
                    CompareType = 'GreaterThanOrEqual',
                    Value = threshold,
                },
            }
        )
    end,
	
	DoAIPing = function(self, pingData)
		local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
		
		if string.find(per, 'sorian') then
			if pingData.Type then
				SUtils.AIHandlePing(self, pingData)
			end
		end
    end,
	
    AttackPointsTimeout = function(self, pos)
		WaitSeconds(300)
        for k,v in self.AttackPoints do
            if pos[1] == v.Position[1] and pos[3] == v.Position[3] then
                self.AttackPoints[k] = nil
                break
            end
        end
    end,
}

end
