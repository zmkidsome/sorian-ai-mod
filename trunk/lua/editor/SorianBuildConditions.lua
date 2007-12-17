#****************************************************************************
#**
#**  File     :  /lua/SorianBuildConditions.lua
#**  Author(s): Mike Robbins
#**
#**  Summary  : Generic AI Platoon Build Conditions
#**             Build conditions always return true or false
#**
#****************************************************************************
local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utils = import('/lua/utilities.lua')

##############################################################################################################
# function: ReclaimablesInArea = BuildCondition   doc = "Please work function docs."
#
# parameter 0: string   aiBrain     = "default_brain"
# parameter 1: string   locType     = "MAIN"
#
##############################################################################################################
function ReclaimablesInArea(aiBrain, locType)
    if aiBrain:GetEconomyStoredRatio('MASS') > .9 and aiBrain:GetEconomyStoredRatio('ENERGY') > .9 then
        return false
    end
	
    local ents = AIUtils.AIGetReclaimablesAroundLocation( aiBrain, locType )
    if ents and table.getn( ents ) > 0 then
		return true
    end
	
    return false
end

function DamagedStructuresInArea(aiBrain, locationtype)
	local engineerManager = aiBrain.BuilderManagers[locationtype].EngineerManager
    if not engineerManager then
        return false
    end
    local Structures = AIUtils.GetOwnUnitsAroundPoint( aiBrain, categories.STRUCTURE - (categories.TECH1 - categories.FACTORY), engineerManager:GetLocationCoords(), engineerManager:GetLocationRadius() )
    for k,v in Structures do
        if not v:IsDead() and v:GetHealthPercent() < .8 then
		#LOG('*AI DEBUG: DamagedStructuresInArea return true')
			return true
        end
    end
	#LOG('*AI DEBUG: DamagedStructuresInArea return false')
    return false
end