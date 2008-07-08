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
# function: GreaterThanEconIncome = BuildCondition	doc = "Please work function docs."
# 
# parameter 0: string	aiBrain		= "default_brain"				doc = "docs for param1"
# parameter 1: int	MassIncome	= 0.1             doc = "docs for param1"
# parameter 2: int	EnergyIncome	= 1             doc = "param2 docs"
#
##############################################################################################################
function GreaterThanEconIncome(aiBrain, MassIncome, EnergyIncome)
	if HaveGreaterThanUnitsWithCategory(aiBrain, 0, 'ENERGYPRODUCTION EXPERIMENTAL STRUCTURE') then
		#LOG('*AI DEBUG: Found Paragon')
		return true
	end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassIncome >= MassIncome and econ.EnergyIncome >= EnergyIncome) then
        return true
    end
    return false
end


##############################################################################################################
# function: LessThanEconIncome = BuildCondition	doc = "Please work function docs."
# 
# parameter 0: string	aiBrain		= "default_brain"				doc = "docs for param1"
# parameter 1: int	MassIncome	= 0.1             doc = "docs for param1"
# parameter 2: int	EnergyIncome	= 1             doc = "param2 docs"
#
##############################################################################################################
function LessThanEconIncome(aiBrain, MassIncome, EnergyIncome)
	if HaveGreaterThanUnitsWithCategory(aiBrain, 0, 'ENERGYPRODUCTION EXPERIMENTAL STRUCTURE') then
		#LOG('*AI DEBUG: Found Paragon')
		return false
	end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassIncome < MassIncome and econ.EnergyIncome < EnergyIncome) then
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
# function: GreaterThanEconEfficiency = BuildCondition	doc = "Please work function docs."
# 
# parameter 0: string	aiBrain		= "default_brain"				doc = "docs for param1"
# parameter 1: int	MassEfficiency	= 1             doc = "docs for param1"
# parameter 2: int	EnergyEfficiency	= 1             doc = "param2 docs"
#
##############################################################################################################
function GreaterThanEconEfficiency(aiBrain, MassEfficiency, EnergyEfficiency)
	if HaveGreaterThanUnitsWithCategory(aiBrain, 0, 'ENERGYPRODUCTION EXPERIMENTAL STRUCTURE') then
		#LOG('*AI DEBUG: Found Paragon')
		return true
	end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassEfficiency >= MassEfficiency and econ.EnergyEfficiency >= EnergyEfficiency) then
        return true
    end
    return false
end

function LessThanEconEfficiency(aiBrain, MassEfficiency, EnergyEfficiency)
	if HaveGreaterThanUnitsWithCategory(aiBrain, 0, 'ENERGYPRODUCTION EXPERIMENTAL STRUCTURE') then
		#LOG('*AI DEBUG: Found Paragon')
		return false
	end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassEfficiency <= MassEfficiency and econ.EnergyEfficiency <= EnergyEfficiency) then
        return true
    end
    return false
end

##############################################################################################################
# function: GreaterThanEconEfficiencyOverTime = BuildCondition	doc = "Please work function docs."
# 
# parameter 0: string	aiBrain		= "default_brain"				doc = "docs for param1"
# parameter 1: int	MassEfficiency	= 1             doc = "docs for param1"
# parameter 2: int	EnergyEfficiency	= 1             doc = "param2 docs"
#
##############################################################################################################
function GreaterThanEconEfficiencyOverTime(aiBrain, MassEfficiency, EnergyEfficiency)
	if HaveGreaterThanUnitsWithCategory(aiBrain, 0, 'ENERGYPRODUCTION EXPERIMENTAL STRUCTURE') then
		#LOG('*AI DEBUG: Found Paragon')
		return true
	end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassEfficiencyOverTime >= MassEfficiency and econ.EnergyEfficiencyOverTime >= EnergyEfficiency) then
        return true
    end
    return false
end

function LessThanEconEfficiencyOverTime(aiBrain, MassEfficiency, EnergyEfficiency)
	if HaveGreaterThanUnitsWithCategory(aiBrain, 0, 'ENERGYPRODUCTION EXPERIMENTAL STRUCTURE') then
		#LOG('*AI DEBUG: Found Paragon')
		return false
	end
    local econ = AIUtils.AIGetEconomyNumbers(aiBrain)
    if (econ.MassEfficiencyOverTime <= MassEfficiency and econ.EnergyEfficiencyOverTime <= EnergyEfficiency) then
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
			if v.MinNumAssistees and SUtils.GetGuards(aiBrain, v) < v.MinNumAssistees then
				numFound = numFound + 1
			end
		end
		if numFound > 0 and doesbool then return true end
	end
	
	local engs = engineerManager:GetEngineersBuildQueue(category)
	for k,v in engs do
		if v.DesiresAssist == true then
			if v.MinNumAssistees and SUtils.GetGuards(aiBrain, v) < v.MinNumAssistees then
				numFound = numFound + 1
			end
		end
		if numFound > 0 and doesbool then return true end
	end
	
	if numFound == 0 and not doesbool then return true end
	return false
end

function LessThanExpansionBases(aiBrain)
	local expBaseCount = 0
	local numberofAIs = SUtils.GetNumberOfAIs(aiBrain)
    local startX, startZ = aiBrain:GetArmyStartPos()
	local isWaterMap = false
	local checkNum = tonumber(ScenarioInfo.Options.LandExpansionsAllowed) or 5
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

function GreaterThanExpansionBases(aiBrain)
	return not LessThanExpansionBases(aiBrain)
end

function LessThanNavalBases(aiBrain)
	local expBaseCount = 0
	local checkNum = tonumber(ScenarioInfo.Options.NavalExpansionsAllowed) or 2
	expBaseCount = aiBrain:GetManagerCount('Naval Area')
	#LOG('*AI DEBUG: '.. aiBrain.Nickname ..' LessThanNavalBases Total = '..expBaseCount)
	if expBaseCount < checkNum then
		return true
	end
	return false
end

function GreaterThanNavalBases(aiBrain)
	return not LessThanNavalBases(aiBrain)
end

function T4BuildingCheck(aiBrain)
    if aiBrain.T4Building then
        return false
    end
    return true
end

function HavePoolUnitComparisonAtLocationExp( aiBrain, locationType, unitCount, unitCategory, compareType )
    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    local testCat = unitCategory
    if type(unitCategory) == 'string' then
        testCat = ParseEntityCategory(unitCategory)
    end
    if not engineerManager then
        WARN('*AI WARNING: HavePoolUnitComparisonAtLocation - Invalid location - ' .. locationType)
        return false
    end
    local poolPlatoon = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
    local numUnits = poolPlatoon:GetNumCategoryUnits(testCat, engineerManager:GetLocationCoords(), engineerManager:GetLocationRadius() * 2)
    return CompareBody(numUnits, unitCount, compareType)
end

function PoolLessAtLocationExp( aiBrain, locationType, unitCount, unitCategory)
    return HavePoolUnitComparisonAtLocationExp( aiBrain, locationType, unitCount, unitCategory, '<')
end

function PoolGreaterAtLocationExp( aiBrain, locationType, unitCount, unitCategory)
    return HavePoolUnitComparisonAtLocationExp( aiBrain, locationType, unitCount, unitCategory, '>')
end

function CompareBody( numOne, numTwo, compareType )
    if compareType == '>' then
        if numOne > numTwo then
            return true
        end
    elseif compareType == '<' then
        if numOne < numTwo then
            return true
        end
    elseif compareType == '>=' then
        if numOne >= numTwo then
            return true
        end
    elseif compareType == '<=' then
        if numOne <= numTwo then
            return true
        end
    else
        error('*AI ERROR: Invalid compare type: ' .. compareType)
        return false
    end
    return false
end