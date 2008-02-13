#***************************************************************************
#*
#**  File     :  /lua/ai/SorianAirAttackBuilders.lua
#**
#**  Summary  : Default economic builders for skirmish
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local BBTmplFile = '/lua/basetemplates.lua'
local BuildingTmpl = 'BuildingTemplates'
local BaseTmpl = 'BaseTemplates'
local ExBaseTmpl = 'ExpansionBaseTemplates'
local Adj2x2Tmpl = 'Adjacency2x2'
local UCBC = '/lua/editor/UnitCountBuildConditions.lua'
local MIBC = '/lua/editor/MiscBuildConditions.lua'
local MABC = '/lua/editor/MarkerBuildConditions.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local OAUBC = '/lua/editor/OtherArmyUnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local PCBC = '/lua/editor/PlatoonCountBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local PlatoonFile = '/lua/platoon.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'

function AirAttackCondition(aiBrain, locationType, targetNumber )
    local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')

    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
	if not engineerManager then
        return false
    end

    local position = engineerManager:GetLocationCoords()
    local radius = engineerManager:GetLocationRadius()
    
    local surfaceThreat = pool:GetPlatoonThreat( 'AntiSurface', categories.MOBILE * categories.AIR - categories.SCOUT - categories.INTELLIGENCE, position, radius )
    local airThreat = pool:GetPlatoonThreat( 'AntiAir', categories.MOBILE * categories.AIR - categories.SCOUT - categories.INTELLIGENCE, position, radius )
    if ( surfaceThreat + airThreat ) > targetNumber then
        return true
    end
    return false
end

BuilderGroup {
    BuilderGroupName = 'SorianT1AirFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T1 Air Bomber',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 500,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
        },
    },
    Builder {
        BuilderName = 'Sorian T1 Air Bomber - Stomp Enemy',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 549,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 6, categories.MOBILE * categories.AIR - categories.SCOUT, 'Enemy'}},
			{ SBC, 'LessThanThreatAtEnemyBase', { 'AntiAir', 10 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
        },
    },
    Builder {
        BuilderName = 'Sorian T1Gunship',
        PlatoonTemplate = 'T1Gunship',
        Priority = 500,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
        },
    },
    Builder {
        BuilderName = 'Sorian T1 Air Fighter',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 10, categories.AIR * categories.ANTIAIR } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T1 Air Bomber 2',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 500,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
        },
    },
    Builder {
        BuilderName = 'Sorian T1Gunship2',
        PlatoonTemplate = 'T1Gunship',
        Priority = 500,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT1AntiAirBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T1 Interceptors',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 555,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AIR * categories.ANTIAIR * categories.TECH1 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY AIR TECH3' }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T1 Interceptors - Enemy Air',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 560,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.AIR * categories.ANTIAIR * categories.TECH1 } },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 4, categories.MOBILE * categories.AIR - categories.SCOUT, 'Enemy'}},
            #{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY AIR TECH3' }},
			#{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T1 Interceptors - Enemy Air Extra',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 560,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.AIR * categories.ANTIAIR * categories.TECH1 } },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 9, categories.MOBILE * categories.AIR - categories.SCOUT, 'Enemy'}},
            #{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY AIR TECH3' }},
			#{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T1 Interceptors - Two Factories',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.AIR * categories.ANTIAIR * categories.TECH1 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Air',
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT2AirFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T2 Air Gunship',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 600,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
    },
    Builder {
        BuilderName = 'Sorian T2 Air Gunship - Stomp Enemy',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 649,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 6, categories.MOBILE * categories.AIR - categories.SCOUT, 'Enemy'}},
			{ SBC, 'LessThanThreatAtEnemyBase', { 'AntiAir', 46 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
    },
    Builder {
        BuilderName = 'Sorian T2FighterBomber',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 600,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
    },
    Builder {
        BuilderName = 'Sorian T2 Air Gunship2',
        PlatoonTemplate = 'T2AirGunship',
        Priority = 600,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
    },
    Builder {
        BuilderName = 'Sorian T2FighterBomber2',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 600,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
    },
    Builder {
        BuilderName = 'Sorian T2FighterBomber2 - Exp Response',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 661,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.AIR * categories.BOMBER * categories.TECH2 } },
			{ MIBC, 'FactionIndex', {1, 3, 4}},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'EXPERIMENTAL LAND, EXPERIMENTAL NAVAL', 'Enemy'}},
        },
    },
    Builder {
        BuilderName = 'Sorian T2FighterBomber2 - Exp Response 2',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 661,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.AIR * categories.ANTIAIR * categories.TECH2 } },
			{ MIBC, 'FactionIndex', {2}},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'EXPERIMENTAL AIR', 'Enemy'}},
        },
    },
    Builder {
        BuilderName = 'Sorian T2 Torpedo Bomber',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 602,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.AIR * categories.ANTINAVY * categories.TECH2 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 0, 'Naval' } },
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT2AntiAirBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T2AntiAirPlanes Initial Higher Pri',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 655,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AIR * categories.ANTIAIR * categories.TECH1 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY AIR TECH3' }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T2AntiAirPlanes - Enemy Air',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 660,
        BuilderConditions = {
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 4, categories.MOBILE * categories.AIR - categories.SCOUT, 'Enemy'}},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.AIR * categories.ANTIAIR * categories.TECH1 } },
            #{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY AIR TECH3' }},
			#{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T2AntiAirPlanes - Enemy Air Extra',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 660,
        BuilderConditions = {
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 9, categories.MOBILE * categories.AIR - categories.SCOUT, 'Enemy'}},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.AIR * categories.ANTIAIR * categories.TECH1 } },
            #{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY AIR TECH3' }},
			#{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T2AntiAirPlanes - Two Factories Higher Pri',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 600,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.AIR * categories.ANTIAIR * categories.TECH1 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Air',
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3AirFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T3 Air Gunship',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 700,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Air Bomber',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 700,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.AIR * categories.BOMBER * categories.TECH3 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Air Bomber - Exp Response',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 761,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'EXPERIMENTAL LAND, EXPERIMENTAL NAVAL', 'Enemy'}},
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Air Bomber - Stomp Enemy',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 754,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 6, categories.MOBILE * categories.AIR - categories.SCOUT, 'Enemy'}},
			{ SBC, 'LessThanThreatAtEnemyBase', { 'AntiAir', 82 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Air Gunship2',
        PlatoonTemplate = 'T3AirGunship',
        Priority = 700,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Air Bomber2',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 700,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Air Fighter',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 700,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3 Torpedo Bomber',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 703,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 0, 'Naval' } },
        },
    }
}

BuilderGroup {
    BuilderGroupName = 'SorianT3AntiAirBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T3AntiAirPlanes Initial',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 755,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AIR * categories.ANTIAIR * categories.TECH3 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3AntiAirPlanes - Enemy Air',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 760,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 4, categories.MOBILE * categories.AIR - categories.SCOUT, 'Enemy'}},
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 10, categories.AIR * categories.ANTIAIR * categories.TECH3 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            #{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3AntiAirPlanes - Enemy Air Extra',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 760,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 9, categories.MOBILE * categories.AIR - categories.SCOUT, 'Enemy'}},
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.AIR * categories.ANTIAIR * categories.TECH3 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            #{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3AntiAirPlanes - Two Factories',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.AIR * categories.ANTIAIR * categories.TECH3 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3AntiAirPlanes - Exp Response',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 761,
        BuilderConditions = {
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'EXPERIMENTAL AIR', 'Enemy'}},
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 20, categories.AIR * categories.ANTIAIR * categories.TECH3 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
        BuilderType = 'Air',
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianTransportFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T1 Air Transport',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 550,
        BuilderConditions = {
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.AIR * categories.ANTIAIR } },
			#{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.AIR * categories.TECH1 * (categories.BOMBER + categories.GROUNDATTACK)} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'TRANSPORTFOCUS' } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'TRANSPORTFOCUS' } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
			#{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR } },
			#{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH2, FACTORY AIR TECH3' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T2 Air Transport',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 650,
        BuilderConditions = {
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.AIR * categories.ANTIAIR} },
			#{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.AIR * categories.TECH2 * (categories.BOMBER + categories.GROUNDATTACK)} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, 'TRANSPORTFOCUS' } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'TRANSPORTFOCUS' } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
			#{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR } },
			#{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH3' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3 Air Transport',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 750,
        BuilderConditions = {
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3} },
			#{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MOBILE * categories.AIR * categories.TECH3 * (categories.BOMBER + categories.GROUNDATTACK)} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 8, 'TRANSPORTFOCUS' } },
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'TRANSPORTFOCUS' } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
			#{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T1 Air Transport HighNeed',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 700,
        BuilderConditions = {
            { MIBC, 'TransportNeedGreater', { 7 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH2, FACTORY AIR TECH3' } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T2 Air Transport HighNeed',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 800,
        BuilderConditions = {
            { MIBC, 'TransportNeedGreater', { 7 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH3' } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3 Air Transport HighNeed',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 900,
        BuilderConditions = {
            { MIBC, 'TransportNeedGreater', { 7 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'TRANSPORTFOCUS' } },
        },
        BuilderType = 'Air',
    },
    
}

BuilderGroup {
    BuilderGroupName = 'SorianUnitCapAirAttackFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian Unit Cap Default Bomber Attack',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 1,
        InstanceCount = 10,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'UnitCapCheckGreater', { .90 } },
        },
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {                
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
				'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'COMMAND',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
    },
    Builder {
        BuilderName = 'Sorian GunshipAttackT1Cap',
        PlatoonTemplate = 'GunshipAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'UnitCapCheckGreater', { .90 } },
        },
		BuilderData = {
			DistressRange = 300,
		},
    },
}


BuilderGroup {
    BuilderGroupName = 'SorianFrequentAirAttackFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian BomberAttackT1Frequent',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {
                'MASSEXTRACTION',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'COMMAND',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, 'AIR MOBILE BOMBER' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH2, MOBILE AIR TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT1Frequent - Anti-Land',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {
				'ENGINEER',
				'MOBILE LAND',
                'MASSEXTRACTION',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'COMMAND',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, 'AIR MOBILE BOMBER' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH2, MOBILE AIR TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT1Frequent - Anti-Resource',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {
                'ENERGYPRODUCTION DRAGBUILD',
				'MASSEXTRACTION',
                'MASSFABRICATION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'COMMAND',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, 'AIR MOBILE BOMBER' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH2, MOBILE AIR TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian GunshipAttackT1Frequent',
        PlatoonTemplate = 'GunshipAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, 'AIR MOBILE GROUNDATTACK' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH2, AIR MOBILE TECH3' } },
        },
		BuilderData = {
			DistressRange = 300,
		},
    },
    Builder {
        BuilderName = 'Sorian Torpedo Bombers',
        PlatoonTemplate = 'TorpedoBomberAttackSorian',
        Priority = 100,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, 'ANTINAVY AIR MOBILE' } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT2Frequent',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {
                'MASSEXTRACTION',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'COMMAND',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, 'AIR MOBILE BOMBER' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT2Frequent - Anti-Land',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {
				'ENGINEER',
				'MOBILE LAND',
                'MASSEXTRACTION',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'COMMAND',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, 'AIR MOBILE BOMBER' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT2Frequent - Anti-Resource',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {                
                'ENERGYPRODUCTION DRAGBUILD',
				'MASSEXTRACTION',
                'MASSFABRICATION',
                'COMMAND',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, 'AIR MOBILE BOMBER' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian GunshipAttackT2Frequent',
        PlatoonTemplate = 'GunshipAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, 'AIR MOBILE GROUNDATTACK' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH3' } },
        },
		BuilderData = {
			DistressRange = 300,
		},
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT3Frequent',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {
                'COMMAND',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, 'AIR MOBILE BOMBER TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT3Frequent - Anti-Land',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {
				'ENGINEER',
				'MOBILE LAND',
                'COMMAND',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, 'AIR MOBILE BOMBER TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT3Frequent - Anti-Resource',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {                
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
				'COMMAND',
				'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, 'AIR MOBILE BOMBER TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian GunshipAttackT3Frequent',
        PlatoonTemplate = 'GunshipAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, 'AIR MOBILE GROUNDATTACK TECH3' } },
        },
		BuilderData = {
			DistressRange = 300,
		},
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianExpResponseFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian BomberAttackExpResponse',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 1000,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
                'EXPERIMENTAL LAND',
                'EXPERIMENTAL NAVAL',
            },
        },
        BuilderConditions = {
            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'EXPERIMENTAL LAND, EXPERIMENTAL NAVAL', 'Enemy'}},
        },
    },
    Builder {
        BuilderName = 'Sorian FighterAttackExpResponse',
        PlatoonTemplate = 'AirAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 1000,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
                'EXPERIMENTAL AIR',
            },
        },
        BuilderConditions = {
            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'EXPERIMENTAL AIR', 'Enemy'}},
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackThreatResponse',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 1000,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
                'STRUCTURE STRATEGIC EXPERIMENTAL',
				'EXPERIMENTAL ORBITALSYSTEM',
                'STRUCTURE STRATEGIC TECH3',
                'COMMAND',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'STRUCTURE STRATEGIC TECH3, STRUCTURE STRATEGIC EXPERIMENTAL', 'Enemy'}},
        },
    },
    Builder {
        BuilderName = 'Sorian T2/T3 Bomber Attack Weak Enemy Response',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 995,
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
				'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE',
                'STRUCTURE STRATEGIC EXPERIMENTAL',
				'EXPERIMENTAL ORBITALSYSTEM',
                'STRUCTURE STRATEGIC TECH3',
                'COMMAND',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { SBC, 'PoolThreatGreaterThanEnemyBase', {'LocationType', categories.MOBILE * categories.AIR - categories.SCOUT - categories.INTELLIGENCE, 'AntiAir', 'AntiSurface', 0.67}},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, 'FACTORY TECH2 AIR, FACTORY TECH3 AIR' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, 'AIR MOBILE BOMBER TECH2 TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian T1 Bomber Attack Weak Enemy Response',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 995,
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
				'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE',
                'STRUCTURE STRATEGIC EXPERIMENTAL',
				'EXPERIMENTAL ORBITALSYSTEM',
                'STRUCTURE STRATEGIC TECH3',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'COMMAND',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { SBC, 'PoolThreatGreaterThanEnemyBase', {'LocationType', categories.MOBILE * categories.AIR - categories.SCOUT - categories.INTELLIGENCE, 'AntiAir', 'AntiSurface', 0.67}},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY TECH2 AIR, FACTORY TECH3 AIR' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, 'AIR MOBILE BOMBER TECH1' } },
        },
    },
    Builder {
        BuilderName = 'Sorian T2/T3 GunShip Attack Weak Enemy Response',
        PlatoonTemplate = 'GunshipSFSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 995,
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
				'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE',
                'STRUCTURE STRATEGIC EXPERIMENTAL',
				'EXPERIMENTAL ORBITALSYSTEM',
                'STRUCTURE STRATEGIC TECH3',
                'COMMAND',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { SBC, 'PoolThreatGreaterThanEnemyBase', {'LocationType', categories.MOBILE * categories.AIR - categories.SCOUT - categories.INTELLIGENCE, 'AntiAir', 'AntiSurface', 0.67}},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, 'FACTORY TECH2 AIR, FACTORY TECH3 AIR' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, 'AIR MOBILE GROUNDATTACK TECH2 TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian T1 GunShip Attack Weak Enemy Response',
        PlatoonTemplate = 'GunshipSFSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 995,
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
				'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE',
                'STRUCTURE STRATEGIC EXPERIMENTAL',
				'EXPERIMENTAL ORBITALSYSTEM',
                'STRUCTURE STRATEGIC TECH3',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'COMMAND',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { SBC, 'PoolThreatGreaterThanEnemyBase', {'LocationType', categories.MOBILE * categories.AIR - categories.SCOUT - categories.INTELLIGENCE, 'AntiAir', 'AntiSurface', 0.67}},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY TECH2 AIR, FACTORY TECH3 AIR' }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, 'AIR MOBILE GROUNDATTACK TECH1' } },
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMassHunterAirFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian BomberAttack Mass Hunter',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
			DistressRange = 300,
            PrioritizedCategories = {
                'MASSEXTRACTION',
                'MOBILE LAND',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'COMMAND',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 3, 'AIR MOBILE BOMBER' } },
        },
    },
    Builder {
        BuilderName = 'Sorian Mass Hunter Gunships',
        PlatoonTemplate = 'GunshipMassHunterSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle', 'DistressResponseAISorian' },
        # Commented out as the platoon doesn't exist in AILandAttackBuilders.lua
        #PlatoonTemplate = 'EarlyGameMassHuntersCategory',
        Priority = 950,
        BuilderConditions = {  
                #{ MIBC, 'LessThanGameTime', { 600 } },      	
                #{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.TECH2 * categories.MOBILE * categories.LAND - categories.ENGINEER } },
            },
        BuilderData = {
            MarkerType = 'Mass',            
            MoveFirst = 'Threat', #'Random',
            MoveNext = 'Threat', #'Guard Base',
            ThreatType = 'Economy',			    # Type of threat to use for gauging attacks
            FindHighestThreat = false,			# Don't find high threat targets
            MaxThreatThreshold = 2900,			# If threat is higher than this, do not attack
            MinThreatThreshold = 1000,			# If threat is lower than this, do not attack
            AvoidBases = true,
            AvoidBasesRadius = 75,
            AggressiveMove = true,      
            AvoidClosestRadius = 50,  
            GuardRadius = 200,
			DistressRange = 300,
        },    
        InstanceCount = 2,
        BuilderType = 'Any',
    },      
}

BuilderGroup {
    BuilderGroupName = 'SorianBaseGuardAirFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian AntiAirHunt',
        PlatoonTemplate = 'AntiAirHuntSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 1,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
			Location = 'LocationType',
            NeverGuardEngineers = true,
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.AIR * categories.MOBILE * (categories.TECH1 + categories.TECH2 + categories.TECH3) * categories.ANTIAIR } },
        },
    },
    Builder {
        BuilderName = 'Sorian AntiAirBaseGuard',
        PlatoonTemplate = 'AntiAirBaseGuard',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 0, #1
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardEngineers = true,
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.AIR * categories.MOBILE * (categories.TECH1 + categories.TECH2) * categories.ANTIAIR } },
        },
    },
    Builder {
        BuilderName = 'Sorian GunshipBaseGuard',
        PlatoonTemplate = 'GunshipBaseGuard',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 0, #10
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardEngineers = true,
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 2, categories.AIR * categories.MOBILE * (categories.TECH1 + categories.TECH2) * categories.GROUNDATTACK } },
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianACUHunterAirFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
}