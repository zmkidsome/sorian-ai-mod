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
    if aiBrain:GetEconomyStoredRatio('MASS') > .5 and aiBrain:GetEconomyStoredRatio('ENERGY') > .5 then
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

function MarkerLessThanDistance(aiBrain, markerType, distance, threatMin, threatMax, threatRings, threatType, startX, startZ)
    if not startX and not startZ then
         startX, startZ = aiBrain:GetArmyStartPos()
    end
    local loc
    if threatMin and threatMax and threatRings then
        loc = AIUtils.AIGetClosestThreatMarkerLoc(aiBrain, markerType, startX, startZ, threatMin, threatMax, threatRings, threatType)
    else
        loc = AIUtils.AIGetClosestMarkerLocation(aiBrain, markerType, startX, startZ)
    end
    if loc and loc[1] and loc[3] then
        if VDist2(startX, startZ, loc[1], loc[3]) < distance and aiBrain:CanBuildStructureAt( 'ueb1102', loc ) then
            return true
        end
    end
    return false
end

##############################################################################################################
# function: MapGreaterThan = BuildCondition
#
# parameter 0: string   aiBrain         = "default_brain"
# parameter 1: integer  sizeX           = "sizeX"
# parameter 2: integer  sizeZ           = "sizeZ"
#
##############################################################################################################
function MapGreaterThan(aiBrain, sizeX, sizeZ)	
	local mapSizeX, mapSizeZ = GetMapSize()
	if mapSizeX > sizeX and mapSizeZ > sizeZ then
		#LOG('*AI DEBUG: MapGreaterThan returned True SizeX: ' .. sizeX .. ' sizeZ: ' .. sizeZ)
		return true
	end
	#LOG('*AI DEBUG: MapGreaterThan returned False SizeX: ' .. sizeX .. ' sizeZ: ' .. sizeZ)
	return false
end

##############################################################################################################
# function: MapLessThan = BuildCondition
#
# parameter 0: string   aiBrain         = "default_brain"
# parameter 1: integer  sizeX           = "sizeX"
# parameter 2: integer  sizeZ           = "sizeZ"
#
##############################################################################################################
function MapLessThan(aiBrain, sizeX, sizeZ)	
	local mapSizeX, mapSizeZ = GetMapSize()	
	if mapSizeX < sizeX and mapSizeZ < sizeZ then
		#LOG('*AI DEBUG: MapLessThan returned True SizeX: ' .. sizeX .. ' sizeZ: ' .. sizeZ)
		return true
	end
	#LOG('*AI DEBUG: MapLessThan returned False SizeX: ' .. sizeX .. ' sizeZ: ' .. sizeZ)
	return false
end