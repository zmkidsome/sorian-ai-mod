#***************************************************************************
#*
#**  File     :  /lua/sim/StrategyManager.lua
#**
#**  Summary  : Manage Skirmish Strategies
#**
#**  Copyright � 2007 Gas Powered Games, Inc.  All rights reserved. All lefts reserved too.
#****************************************************************************

local BuilderManager = import('/lua/sim/BuilderManager.lua').BuilderManager
local AIUtils = import('/lua/ai/aiutilities.lua')
local Builder = import('/lua/sim/Builder.lua')
local StrategyBuilder = import('/lua/sim/StrategyBuilder.lua')
local AIBuildUnits = import('/lua/ai/aibuildunits.lua')
local StrategyList = import('/lua/ai/SkirmishStrategyList.lua').StrategyList

StrategyManager = Class(BuilderManager) {
    Create = function(self, brain, lType, location, radius, useCenterPoint)
        BuilderManager.Create(self,brain)
        
        self.Location = location
        self.Radius = radius
        self.LocationType = lType
		
        self.LastChange = 0
		self.LastStrategy= false
		
        self.UseCenterPoint = useCenterPoint or false
        
        self:AddBuilderType('Any')
        
        self:LoadStrategies()        
    end,

    AddBuilder = function(self, builderData, locationType, builderType)
        local newBuilder = StrategyBuilder.CreateStrategy(self.Brain, builderData, locationType)
        self:AddInstancedBuilder(newBuilder, builderType)
        return newBuilder
    end,
    
    # Load all strategies in the Strategy List table
    LoadStrategies = function(self)
        for i,v in StrategyList do
            self:AddBuilder(v)
        end
    end,
    
    ManagerLoopBody = function(self,builder,bType)
        BuilderManager.ManagerLoopBody(self,builder,bType)
        # Try to form all builders that pass
        if GetGameTimeSeconds() - self.LastChange > 300 and builder:GetBuilderStatus() and builder:CheckInstanceCount() then
			self.LastChange = GetGameTimeSeconds()
			if self.LastStrategy then
				self.LastStrategy:UndoChanges()
			end
			self.LastStrategy = builder
			builder:ExecuteChanges()
        end
    end,
}

function CreateStrategyManager(brain, lType, location, radius, useCenterPoint)
    local stratman = StrategyManager()
    stratman:Create(brain, lType, location, radius, useCenterPoint)
    return stratman
end