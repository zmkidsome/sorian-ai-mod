#****************************************************************************
#**
#**  File     :  /lua/SorianInstantBuildConditions.lua
#**  Author(s): Michael Robbins aka Sorian
#**
#**  Summary  : Generic AI Platoon Build Conditions
#**             Build conditions always return true or false
#**
#****************************************************************************
local AIUtils = import('/lua/ai/aiutilities.lua')
local ScenarioFramework = import('/lua/scenarioframework.lua')
local ScenarioUtils = import('/lua/sim/ScenarioUtilities.lua')
local Utils = import('/lua/utilities.lua')
local SUtils = import('/lua/AI/sorianutilities.lua')

function DefensivePointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType )
    local pos, name = AIUtils.AIFindDefensivePointNeedsStructureSorian( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType )
    if pos then
        return true
    end
    return false    
end

function ExpansionPointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType )
    local pos, name = AIUtils.AIFindExpansionPointNeedsStructure( aiBrain, locationType, locationRadius, category, markerRadius, unitMax, threatMin, threatMax, threatRings, threatType )
    if pos then
        return true
    end
    return false    
end

##############################################################################################################
# function: HaveGreaterThanUnitsWithCategory = BuildCondition	doc = "Please work function docs."
#
# parameter 0: string   aiBrain		    = "default_brain"
# parameter 1: int      numReq     = 0					doc = "docs for param1"
# parameter 2: expr   category        = categories.ALLUNITS		doc = "param2 docs"
# parameter 3: expr   idleReq       = false         doc = "docs for param3"
# parameter 4: bool		special		= "Whether numReq varies depending on game time"
#
##############################################################################################################
function HaveGreaterThanUnitsWithCategory(aiBrain, numReq, category, idleReq)
    local numUnits
	local total = 0
    if type(category) == 'string' then
        category = ParseEntityCategory(category)
    end
    if not idleReq then
        numUnits = aiBrain:GetListOfUnits(category, false)
    else
        numUnits = aiBrain:GetListOfUnits(category, true)
    end
	for k,v in numUnits do
		if v:GetFractionComplete() == 1 then
			total = total + 1
			if total > numReq then
				return true
			end
		end
	end
	if total > numReq then
		return true
	end
    return false
end


##############################################################################################################
# function: HaveLessThanUnitsWithCategory = BuildCondition	doc = "Please work function docs."
#
# parameter 0: string	aiBrain		= "default_brain"
# parameter 1: int	numReq          = 0				doc = "docs for param1"
# parameter 2: expr   category        = categories.ALLUNITS		doc = "param2 docs"
# parameter 3: expr   idleReq       = false         doc = "docs for param3"
#
##############################################################################################################
function HaveLessThanUnitsWithCategory(aiBrain, numReq, category, idleReq)
    local numUnits
	local total = 0
    if type(category) == 'string' then
        category = ParseEntityCategory(category)
    end
    if not idleReq then
        numUnits = aiBrain:GetListOfUnits(category, false)
    else
        numUnits = aiBrain:GetListOfUnits(category, true)
    end
	for k,v in numUnits do
		if v:GetFractionComplete() == 1 then
			total = total + 1
			if total >= numReq then
				return false
			end
		end
	end
	if total >= numReq then
		return false
	end
    return true
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

##############################################################################################################
# function: EngineerNeedsAssistance = BuildCondition
#
# parameter 0: string   aiBrain         = "default_brain"
# parameter 1: bool    doesbool        = "true: Engineer does need assistance false: Engineer does not need assistance"
# parameter 2: string   LocationType   = "LocationType"
# parameter 3: string   category        = "Being built category"
#
##############################################################################################################
function EngineerNeedsAssistance(aiBrain, doesbool, locationType, category)
	local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
	if not engineerManager or not type(category) == 'string' then
		return false
	end
	local bCategory = ParseEntityCategory(category)

	local engs = engineerManager:GetEngineersBuildingCategory(bCategory, categories.ALLUNITS )
	local numFound = 0
	for k,v in engs do
		if v.DesiresAssist == true then
			if v.NumAssistees and SUtils.GetGuards(aiBrain, v) < v.NumAssistees then
				numFound = numFound + 1
			end
		end
		if numFound > 0 and doesbool then return true end
	end
	
	local engs = engineerManager:GetEngineersBuildQueue(category)
	for k,v in engs do
		if v.DesiresAssist == true then
			if v.NumAssistees and SUtils.GetGuards(aiBrain, v) < v.NumAssistees then
				numFound = numFound + 1
			end
		end
		if numFound > 0 and doesbool then return true end
	end
	
	if numFound == 0 and not doesbool then return true end
	return false
end

function LessThanExpansionBases(aiBrain, checkNum)
	local expBaseCount = 0
	local numberofAIs = SUtils.GetNumberOfAIs(aiBrain)
    local startX, startZ = aiBrain:GetArmyStartPos()
	local isWaterMap = false
    local navalMarker = AIUtils.AIGetClosestMarkerLocation(aiBrain, 'Naval Area', startX, startZ)
    if navalMarker then
        isWaterMap = true
    end
	expBaseCount = aiBrain:GetManagerCount('Start Location')
	expBaseCount = expBaseCount + aiBrain:GetManagerCount('Expansion Area')
	checkNum = checkNum - numberofAIs
	if isWaterMap and expBaseCount < checkNum then
		return true
	elseif not isWaterMap and expBaseCount < checkNum + 1 then
		return true
	end
	return false
end

function GreaterThanExpansionBases(aiBrain, checkNum)
	return not LessThanExpansionBases(aiBrain, checkNum)
end

function LessThanNavalBases(aiBrain, checkNum)
	local expBaseCount = 0
	expBaseCount = aiBrain:GetManagerCount('Naval Area')
	#LOG('*AI DEBUG: '.. aiBrain.Nickname ..' LessThanNavalBases Total = '..expBaseCount)
	if expBaseCount < checkNum then
		return true
	end
	return false
end

function GreaterThanNavalBases(aiBrain, checkNum)
	return not LessThanNavalBases(aiBrain, checkNum)
end

function T4BuildingCheck(aiBrain)
    if aiBrain.T4Building then
        return false
    end
    return true
end