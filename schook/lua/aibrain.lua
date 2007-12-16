do

oldAIBrain = AIBrain

AIBrain = Class(oldAIBrain) {
	
    PickEnemyLogic = function(self)
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
            if not self:GetCurrentEnemy() or per == 'sorian' or per == 'sorianrush' then
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

    UnderMassThresholdSorian = function(self)
        self:SetupOverMassStatTrigger(0.1)
		self.LowMassMode = true
    end,

    OverMassThresholdSorian = function(self)
        self:SetupUnderMassStatTrigger(0.1)
		self.LowMassMode = true
    end,

    SetupUnderMassStatTriggerSorian = function(self, threshold)
        import('/lua/scenariotriggers.lua').CreateArmyStatTrigger( self.UnderMassThresholdSorian, self, 'SkirmishUnderMassThreshold',
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
        import('/lua/scenariotriggers.lua').CreateArmyStatTrigger( self.OverMassThresholdSorian, self, 'SkirmishOverMassThreshold',
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
