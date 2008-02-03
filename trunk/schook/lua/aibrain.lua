do

oldAIBrain = AIBrain

AIBrain = Class(oldAIBrain) {

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
        
        self:AddBuilderManagers(self:GetStartVector3f(), 100, 'MAIN', false)
        #self.BuilderManagers.MAIN.StrategyManager = StratManager.CreateStrategyManager(self, 'MAIN', self:GetStartVector3f(), 100)

        # Begin the base monitor process
		local per = ScenarioInfo.ArmySetup[self.Brain.Name].AIPersonality
		
		if per == 'sorian' or per == 'sorianrush' or per == 'sorianair' then
			local spec = {
				DefaultDistressRange = 200,
			}
			self:BaseMonitorInitialization(spec)
		else		
			self:BaseMonitorInitialization()
		end
        local plat = self:GetPlatoonUniquelyNamed('ArmyPool')
        
        plat:ForkThread( plat.BaseManagersDistressAI )
        
        self.EnemyPickerThread = self:ForkThread( self.PickEnemy )
    end,
	
    BaseMonitorAlertTimeout = function(self, pos)
        local timeout = self.BaseMonitor.DefaultAlertTimeout
        local threat
        local threshold = self.BaseMonitor.AlertLevel
        repeat
            WaitSeconds(timeout)
            threat = self:GetThreatAtPosition( pos, 0, true, 'AntiSurface' )
        until threat <= threshold
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
                    if v.Threat > alertThreat then
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

    PickEnemy = function(self)
        while true do
            self:PickEnemyLogic(true)
            WaitSeconds(120)
        end
    end,
	
    PickEnemyLogic = function(self, brainbool)
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
        if allyEnemy  then
            self:SetCurrentEnemy( allyEnemy )
        else
			local per = ScenarioInfo.ArmySetup[self.Name].AIPersonality
            local findEnemy = false
            if not self:GetCurrentEnemy() or ((per == 'sorian' or per == 'sorianrush' or per == 'sorianair') and brainbool) then
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
                        enemy = v.Brain
                    end
                end
                
                if enemy then
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
}

end
