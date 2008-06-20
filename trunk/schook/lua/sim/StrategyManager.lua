#***************************************************************************
#*
#**  File     :  /lua/sim/StrategyManager.lua
#**
#**  Summary  : Manage Skirmish Strategies
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved. All lefts reserved too.
#****************************************************************************

local BuilderManager = import('/lua/sim/BuilderManager.lua').BuilderManager
local AIUtils = import('/lua/ai/aiutilities.lua')
local Builder = import('/lua/sim/Builder.lua')
local StrategyBuilder = import('/lua/sim/StrategyBuilder.lua')
local AIBuildUnits = import('/lua/ai/aibuildunits.lua')
#local StrategyList = import('/lua/ai/SkirmishStrategyList.lua').StrategyList
local AIAddBuilderTable = import('/lua/ai/AIAddBuilderTable.lua')
local SUtils = import('/lua/AI/sorianutilities.lua')

StrategyManager = Class(BuilderManager) {
    Create = function(self, brain, lType, location, radius, useCenterPoint)
        BuilderManager.Create(self,brain)
        
        self.Location = location
        self.Radius = radius
        self.LocationType = lType
		
        self.LastChange = 0
		self.NextChange = 300
		self.LastStrategy = false
		self.OverallStrategy = false
		
        self.UseCenterPoint = useCenterPoint or false
        
        self:AddBuilderType('Any')
        
        #self:LoadStrategies()        
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
	
	ExecuteChanges = function(self, builder)
		local turnOff = builder:GetRemoveBuilders()
		local turnOn = builder:GetActivateBuilders()
		for mname, manager in turnOff do
			for _, bname in manager do
				local Managers = self.Brain.BuilderManagers[self.LocationType]
				Managers[mname]:SetBuilderPriority(bname, 0, true, true)
			end
		end
		for mname, manager in turnOn do
			for _, bname in manager do
				local Managers = self.Brain.BuilderManagers[self.LocationType]
				local newPriority = Managers[mname]:GetActivePriority(bname)
				Managers[mname]:SetBuilderPriority(bname, newPriority)
			end
		end
	end,
	
	UndoChanges = function(self, builder)
		local turnOn = builder:GetRemoveBuilders()
		local turnOff = builder:GetActivateBuilders()
		for mname, manager in turnOff do
			for _, bname in manager do
				local Managers = self.Brain.BuilderManagers[self.LocationType]
				Managers[mname]:SetBuilderPriority(bname, 0)
			end
		end
		for mname, manager in turnOn do
			for _, bname in manager do
				local Managers = self.Brain.BuilderManagers[self.LocationType]
				Managers[mname]:ResetBuilderPriority(bname)
			end
		end
	end,
    
    ManagerLoopBody = function(self,builder,bType)
        BuilderManager.ManagerLoopBody(self,builder,bType)
		
		if builder:GetStrategyType() == 'Intermediate' then
			if (GetGameTimeSeconds() - self.LastChange > self.NextChange or builder:IsInterruptStrategy()) and builder:GetPriority() > 0 and builder:GetBuilderStatus() and builder != self.LastStrategy then
				#LOG('*AI DEBUG: '..self.Brain.Nickname..' '..SUtils.TimeConvert(GetGameTimeSeconds())..' Changing Intermediate Strategy to '..builder.BuilderName)
				self.LastChange = GetGameTimeSeconds()
				self.NextChange = builder:GetStrategyTime() or 300
				if self.LastStrategy then
					self:UndoChanges(self.LastStrategy)
				end
				self.LastStrategy = builder
				self:ExecuteChanges(builder)
			elseif GetGameTimeSeconds() - self.LastChange > self.NextChange and self.LastStrategy and builder == self.LastStrategy and not builder:GetBuilderStatus() then
				#LOG('*AI DEBUG: '..self.Brain.Nickname..' '..SUtils.TimeConvert(GetGameTimeSeconds())..' Changing Intermediate Strategy to none.')
				self:UndoChanges(self.LastStrategy)
				self.LastStrategy = false
			end
		elseif builder:GetStrategyType() == 'Overall' then
			if builder:GetPriority() > 0 and builder:GetBuilderStatus() and builder != self.OverallStrategy then
				#LOG('*AI DEBUG: '..self.Brain.Nickname..' '..SUtils.TimeConvert(GetGameTimeSeconds())..' Changing Overall Strategy to '..builder.BuilderName)
				if self.OverallStrategy then
					self:UndoChanges(self.OverallStrategy)
				end
				self.OverallStrategy = builder
				self:ExecuteChanges(builder)
			elseif self.OverallStrategy and builder == self.OverallStrategy and not builder:GetBuilderStatus() then
				#LOG('*AI DEBUG: '..self.Brain.Nickname..' '..SUtils.TimeConvert(GetGameTimeSeconds())..' Changing Overall Strategy to none.')
				self:UndoChanges(self.OverallStrategy)
				self.LastStrategy = false
			end
		end
    end,
}

function CreateStrategyManager(brain, lType, location, radius, useCenterPoint)
    local stratman = StrategyManager()
    stratman:Create(brain, lType, location, radius, useCenterPoint)
    return stratman
end