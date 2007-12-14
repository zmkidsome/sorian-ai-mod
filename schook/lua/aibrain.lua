do

oldAIBrain = AIBrain

AIBrain = Class(oldAIBrain) {

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
