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