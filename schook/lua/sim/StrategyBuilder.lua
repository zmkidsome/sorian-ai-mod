#***************************************************************************
#*
#**  File     :  /lua/sim/StrategyBuilder.lua
#**
#**  Summary  : Strategy Builder class
#**
#**  Copyright © 2007 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local AIUtils = import('/lua/ai/aiutilities.lua')
local Builder = import('/lua/sim/Builder.lua').Builder


# StrategyBuilderSpec
# This is the spec to have analyzed by the StrategyManager
#{
#   BuilderData = {
#       Some stuff could go here, eventually.
#   }
#}

StrategyBuilder = Class(Builder) {
    Create = function(self,brain,data,locationType)
        Builder.Create(self,brain,data,locationType)
        return true
    end,
	
	GetActivateBuilders = function(self)
		if Builders[self.BuilderName].AddBuilders then
			return Builders[self.BuilderName].AddBuilders
		end
		return false
	end,
	
	GetRemoveBuilders = function(self)
		if Builders[self.BuilderName].RemoveBuilders then
			return Builders[self.BuilderName].RemoveBuilders
		end
		return false
	end,
	
	GetStrategyTime = function(self)
        if Builders[self.BuilderName].StrategyTime then
            return Builders[self.BuilderName].StrategyTime
        end
        return false
	end,
	
	IsInterruptStrategy = function(self)
		if Builders[self.BuilderName].InterruptStrategy then
			return true
		end
		return false
	end,
}

function CreateStrategy(brain, data, locationType)
    local builder = StrategyBuilder()
    if builder:Create(brain, data, locationType) then
        return builder
    end
    return false
end
