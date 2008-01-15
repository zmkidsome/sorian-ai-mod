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
# function: HaveLessThanUnitsInCategoryBeingBuilt = BuildCondition
#
# parameter 0: string   aiBrain         = "default_brain"
# parameter 1: integer  numunits        = "Number of units"
# parameter 2: integer  radius          = "radius"
#
##############################################################################################################
function HaveLessThanUnitsInCategoryBeingBuilt(aiBrain, numunits, category)
    if type(category) == 'string' then
        category = ParseEntityCategory(category)
    end
	
    local unitsBuilding = aiBrain:GetListOfUnits( categories.CONSTRUCTION, false )
	local numBuilding = 0
    for unitNum, unit in unitsBuilding do
        if not unit:BeenDestroyed() and unit:IsUnitState('Building') then
            local buildingUnit = unit:GetUnitBeingBuilt()
            if buildingUnit and not buildingUnit:IsDead() and EntityCategoryContains( category, buildingUnit ) then
				numBuilding = numBuilding + 1	
            end
        end
		if numunits <= numBuilding then
			return false
		end
    end
	if numunits > numBuilding then
		return true
	end
	return false
end

##############################################################################################################
# function: HaveGreaterThanUnitsInCategoryBeingBuilt = BuildCondition
#
# parameter 0: string   aiBrain         = "default_brain"
# parameter 1: integer  numunits        = "Number of units"
# parameter 2: integer  radius          = "radius"
#
##############################################################################################################
function HaveGreaterThanUnitsInCategoryBeingBuilt(aiBrain, numunits, category)
    if type(category) == 'string' then
        category = ParseEntityCategory(category)
    end
	
    local unitsBuilding = aiBrain:GetListOfUnits( categories.CONSTRUCTION, false )
	local numBuilding = 0
    for unitNum, unit in unitsBuilding do
        if not unit:BeenDestroyed() and unit:IsUnitState('Building') then
            local buildingUnit = unit:GetUnitBeingBuilt()
            if buildingUnit and not buildingUnit:IsDead() and EntityCategoryContains( category, buildingUnit ) then
				numBuilding = numBuilding + 1	
            end
        end
		if numunits < numBuilding then
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

##############################################################################################################
# function: GreaterThanEconEfficiencyOverTimeExp = BuildCondition	doc = "Please work function docs."
# 
# parameter 0: string	aiBrain		= "default_brain"				doc = "docs for param1"
# parameter 1: int	MassEfficiency	= 1             doc = "docs for param1"
# parameter 2: int	EnergyEfficiency	= 1             doc = "param2 docs"
#
##############################################################################################################
function GreaterThanEconEfficiencyOverTimeExp(aiBrain, MassEfficiency, EnergyEfficiency)
    local unitsBuilding = aiBrain:GetListOfUnits( categories.CONSTRUCTION, false )
	local numBuilding = 0
    for unitNum, unit in unitsBuilding do
        if not unit:BeenDestroyed() and unit:IsUnitState('Building') then
            local buildingUnit = unit:GetUnitBeingBuilt()
            if buildingUnit and not buildingUnit:IsDead() and EntityCategoryContains( categories.EXPERIMENTAL, buildingUnit ) then
				numBuilding = numBuilding + 1	
            end
        end
    end
	
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassEfficiencyOverTime >= MassEfficiency + (numBuilding * .2) and econ.EnergyEfficiencyOverTime >= EnergyEfficiency + (numBuilding * .2)) then
        return true
    end
    return false
end

##############################################################################################################
# function: GreaterThanEconIncomeOverTime = BuildCondition	doc = "Please work function docs."
# 
# parameter 0: string	aiBrain		= "default_brain"				doc = "docs for param1"
# parameter 1: int	MassIncome	= 0.1             doc = "docs for param1"
# parameter 2: int	EnergyIncome	= 1             doc = "param2 docs"
#
##############################################################################################################
function GreaterThanEconIncomeOverTime(aiBrain, MassIncome, EnergyIncome)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassIncomeOverTime >= MassIncome and econ.EnergyIncomeOverTime >= EnergyIncome) then
        return true
    end
    return false
end


##############################################################################################################
# function: LessThanEconIncomeOverTime = BuildCondition	doc = "Please work function docs."
# 
# parameter 0: string	aiBrain		= "default_brain"				doc = "docs for param1"
# parameter 1: int	MassIncome	= 0.1             doc = "docs for param1"
# parameter 2: int	EnergyIncome	= 1             doc = "param2 docs"
#
##############################################################################################################
function LessThanEconIncomeOverTime(aiBrain, MassIncome, EnergyIncome)
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassIncomeOverTime < MassIncome and econ.EnergyIncomeOverTime < EnergyIncome) then
        return true
    end
    return false
end