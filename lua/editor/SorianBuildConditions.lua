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
local SUtils = import('/lua/AI/sorianutilities.lua')

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

##############################################################################################################
# function: PoolThreatGreaterThanEnemyBase = BuildCondition
#
# parameter 0: string   aiBrain        = "default_brain"
# parameter 1: string	  locationType   = "loactionType"
# parameter 2: string   ucat            = "Unit Category"
# parameter 3: string   ttype           = "Enemy Threat Type"
# parameter 4: string   uttype          = "Unit Threat Type"
# parameter 5: integer divideby        = "Divide Unit Threat by"
#
##############################################################################################################
function PoolThreatGreaterThanEnemyBase(aiBrain, locationType, ucat, ttype, uttype, divideby)
    local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
	local divby = divideby or 1
    if not engineerManager then
        return false
    end
	
	if aiBrain:GetCurrentEnemy() then
		enemy = aiBrain:GetCurrentEnemy()
		enemyIndex = aiBrain:GetCurrentEnemy():GetArmyIndex()
	else
		return false
	end
	local StartX, StartZ = enemy:GetArmyStartPos()
    local position = engineerManager:GetLocationCoords()
    local radius = engineerManager:GetLocationRadius()
    
	local enemyThreat = aiBrain:GetThreatAtPosition( {StartX, 0, StartZ}, 1, true, ttype or 'Overall', enemyIndex )
    local Threat = pool:GetPlatoonThreat( uttype or 'Overall', ucat, position, radius )
    if SUtils.Round((Threat / divby), 1) > enemyThreat then
        return true
    end
    return false
end

##############################################################################################################
# function: LessThanThreatAtEnemyBase = BuildCondition
#
# parameter 0: string   aiBrain        = "default_brain"
# parameter 3: string   ttype          = "Enemy Threat Type"
# parameter 5: integer number         = "Threat Amount"
#
##############################################################################################################
function LessThanThreatAtEnemyBase(aiBrain, ttype, number)
	if aiBrain:GetCurrentEnemy() then
		enemy = aiBrain:GetCurrentEnemy()
		enemyIndex = aiBrain:GetCurrentEnemy():GetArmyIndex()
	else
		return false
	end
	
	local StartX, StartZ = enemy:GetArmyStartPos()
    
	local enemyThreat = aiBrain:GetThreatAtPosition( {StartX, 0, StartZ}, 1, true, ttype or 'Overall', enemyIndex )
    if number < enemyThreat then
        return true
    end
    return false
end

##############################################################################################################
# function: GreaterThanEnemyUnitsAroundBase = BuildCondition
#
# parameter 0: string   aiBrain         = "default_brain"
# parameter 1: integer  numUnits        = "Number of Units"
# parameter 2: integer  radius          = "radius"
# parameter 3: integer  unitCat         = "Unit Category"
#
##############################################################################################################
function GreaterThanEnemyUnitsAroundBase(aiBrain, locationtype, numUnits, unitCat, radius)
	local engineerManager = aiBrain.BuilderManagers[locationtype].EngineerManager
    if not engineerManager then
        return false
    end
    if type(unitCat) == 'string' then
        unitCat = ParseEntityCategory(unitCat)
    end
	local Units = aiBrain:GetNumUnitsAroundPoint(unitCat, engineerManager:GetLocationCoords(), radius, 'Enemy')
	if Units > numUnits then
		return true
    end
	return false
end

##############################################################################################################
# function: UnfinishedUnits = BuildCondition
#
# parameter 0: string   aiBrain         = "default_brain"
# parameter 1: integer  radius          = "radius"
# parameter 2: string   category        = "Unit category"
#
##############################################################################################################
function UnfinishedUnits(aiBrain, locationType, category)	
	local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    if not engineerManager then
        return false
    end
	local unfinished = aiBrain:GetUnitsAroundPoint( category, engineerManager:GetLocationCoords(), engineerManager:GetLocationRadius(), 'Ally' )
	for num, unit in unfinished do
		donePercent = unit:GetFractionComplete()
		if donePercent < 1 and SUtils.GetGuards(aiBrain, unit) < 1 then
			return true
		end
	end
	return false
end

##############################################################################################################
# function: ShieldDamaged = BuildCondition
#
# parameter 0: string   aiBrain         = "default_brain"
# parameter 1: integer  radius          = "radius"
#
##############################################################################################################
function ShieldDamaged(aiBrain, locationType)	
	local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
    if not engineerManager then
        return false
    end
	local shields = aiBrain:GetUnitsAroundPoint( categories.STRUCTURE * categories.SHIELD, engineerManager:GetLocationCoords(), engineerManager:GetLocationRadius(), 'Ally' )
	for num, unit in shields do
		if not unit:IsDead() and unit:ShieldIsOn() then
			shieldPercent = (unit.MyShield:GetHealth() / unit.MyShield:GetMaxHealth())
			if shieldPercent < 1 and SUtils.GetGuards(aiBrain, unit) < 3 then
				return true
			end
		end
	end
	return false
end

function NoRushTimeCheck(aiBrain, timeLeft)
	if ScenarioInfo.Options.NoRushOption and ScenarioInfo.Options.NoRushOption != 'Off' then
		if tonumber(ScenarioInfo.Options.NoRushOption) * 60 < GetGameTimeSeconds() + timeLeft then
			return true
		else
			return false
		end
	elseif ScenarioInfo.Options.NoRushOption and ScenarioInfo.Options.NoRushOption == 'Off' then
		return true
	end
	return true
end

function NoRush(aiBrain)
	if ScenarioInfo.Options.NoRushOption and ScenarioInfo.Options.NoRushOption != 'Off' then
		if tonumber(ScenarioInfo.Options.NoRushOption) * 60 > GetGameTimeSeconds() then
			return true
		else
			return false
		end
	elseif ScenarioInfo.Options.NoRushOption and ScenarioInfo.Options.NoRushOption == 'Off' then
		return false
	end
	return false
end

function HaveComparativeUnitsWithCategoryAndAlliance(aiBrain, greater, myCategory, eCategory, alliance)
    if type(eCategory) == 'string' then
        eCategory = ParseEntityCategory(eCategory)
    end
    if type(myCategory) == 'string' then
        myCategory = ParseEntityCategory(myCategory)
    end
	local myUnits = aiBrain:GetCurrentUnits(myCategory)
    local numUnits = aiBrain:GetNumUnitsAroundPoint( eCategory, Vector(0,0,0), 100000, alliance )
	if alliance == 'Ally' then
		numUnits = numUnits - aiBrain:GetCurrentUnits(myCategory)
	end
    if numUnits > myUnits and greater then
        return true
    elseif numUnits < myUnits and not greater then
        return true
    end
    return false
end