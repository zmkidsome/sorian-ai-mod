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

function AirAttackCondition(aiBrain, locationType, targetNumber )
    local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')

    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager

    local position = engineerManager:GetLocationCoords()
    local radius = engineerManager:GetLocationRadius()
    
    local surfaceThreat = pool:GetPlatoonThreat( 'Surface', categories.MOBILE * categories.AIR - categories.SCOUT - categories.INTELLIGENCE, position, radius )
    local airThreat = pool:GetPlatoonThreat( 'Air', categories.MOBILE * categories.AIR - categories.SCOUT - categories.INTELLIGENCE, position, radius )
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
        Priority = 501,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T1Gunship',
        PlatoonTemplate = 'T1Gunship',
        Priority = 501,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
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
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
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
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T1 Interceptors - Two Factories',
        PlatoonTemplate = 'T1AirFighter',
        Priority = 505,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.AIR * categories.ANTIAIR * categories.TECH1 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
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
        Priority = 601,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
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
        },
    },
    Builder {
        BuilderName = 'Sorian T2 Torpedo Bomber',
        PlatoonTemplate = 'T2AirTorpedoBomber',
        Priority = 600,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 0, 'Naval' } },
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT2AntiAirBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T2AntiAirPlanes Initial Higher Pri',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 655,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AIR * categories.ANTIAIR * categories.TECH2 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T2AntiAirPlanes - Two Factories Higher Pri',
        PlatoonTemplate = 'T2FighterBomber',
        Priority = 605,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.AIR * categories.ANTIAIR * categories.TECH2 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
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
        Priority = 701,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Air Bomber',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 701,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
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
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3 Torpedo Bomber',
        PlatoonTemplate = 'T3TorpedoBomber',
        Priority = 700,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
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
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 2, categories.AIR * categories.ANTIAIR * categories.TECH3 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3AntiAirPlanes - Two Factories',
        PlatoonTemplate = 'T3AirFighter',
        Priority = 705,
        BuilderConditions = {
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.ANTIAIR * categories.AIR - categories.BOMBER } },
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 5, categories.AIR * categories.ANTIAIR * categories.TECH3 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
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
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH1} },
            { UCBC, 'HaveLessThanUnitsWithCategory', { 6, 'TRANSPORTFOCUS' } },
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
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.TECH1} },
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
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3} },
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
        BuilderName = 'Sorian T1 Air Transport Default',
        PlatoonTemplate = 'T1AirTransport',
        Priority = 500,
        BuilderConditions = {
            #{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH1} },
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS' } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
			#{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR } },
			#{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH2, FACTORY AIR TECH3' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T2 Air Transport Default',
        PlatoonTemplate = 'T2AirTransport',
        Priority = 600,
        BuilderConditions = {
            #{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.TECH1} },
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS' } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
			#{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, categories.FACTORY * categories.AIR } },
			#{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH3' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
        },
        BuilderType = 'Air',
    },
    Builder {
        BuilderName = 'Sorian T3 Air Transport Default',
        PlatoonTemplate = 'T3AirTransport',
        Priority = 700,
        BuilderConditions = {
            #{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 3, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 8, 'TRANSPORTFOCUS' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.MOBILE * categories.AIR * categories.ANTIAIR * categories.TECH3} },
            { MIBC, 'ArmyNeedsTransports', {} },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'TRANSPORTFOCUS' } },
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
        PlatoonTemplate = 'BomberAttack',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 1,
        InstanceCount = 10,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'UnitCapCheckGreater', { .90 } },
        },
        BuilderData = {
            PrioritizedCategories = {
                'MASSEXTRACTION',
                'ENERGYPRODUCTION',
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
    },
    Builder {
        BuilderName = 'Sorian GunshipAttackT1Cap',
        PlatoonTemplate = 'GunshipAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'UnitCapCheckGreater', { .90 } },
        },
    },
}


BuilderGroup {
    BuilderGroupName = 'SorianFrequentAirAttackFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian BomberAttackT1Frequent',
        PlatoonTemplate = 'BomberAttack',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
            PrioritizedCategories = {
				'ENGINEER',
                'MASSEXTRACTION',
                'ENERGYPRODUCTION',
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
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, 'AIR MOBILE BOMBER' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH2, MOBILE AIR TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian GunshipAttackT1Frequent',
        PlatoonTemplate = 'GunshipAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, 'AIR MOBILE GROUNDATTACK' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH2, AIR MOBILE TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT2Frequent',
        PlatoonTemplate = 'BomberAttack',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
            PrioritizedCategories = {
                'MASSEXTRACTION',
                'ENERGYPRODUCTION',
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
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 6, 'AIR MOBILE BOMBER' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian GunshipAttackT2Frequent',
        PlatoonTemplate = 'GunshipAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 5, 'AIR MOBILE GROUNDATTACK' } },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'AIR MOBILE TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackT3Frequent',
        PlatoonTemplate = 'BomberAttack',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
            PrioritizedCategories = {
                'COMMAND',
                'MASSEXTRACTION',
                'ENERGYPRODUCTION',
                'MASSFABRICATION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, 'AIR MOBILE BOMBER TECH3' } },
        },
    },
    Builder {
        BuilderName = 'Sorian GunshipAttackT3Frequent',
        PlatoonTemplate = 'GunshipAttackSorian',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 100,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 4, 'AIR MOBILE GROUNDATTACK TECH3' } },
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianExpResponseFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian BomberAttackExpResponse',
        PlatoonTemplate = 'BomberAttack',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 1000,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
            PrioritizedCategories = {
                'EXPERIMENTAL LAND',
                'EXPERIMENTAL NAVAL',
                'COMMAND',
                'MASSEXTRACTION',
                'ENERGYPRODUCTION',
                'MASSFABRICATION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'EXPERIMENTAL LAND, EXPERIMENTAL NAVAL', 'Enemy'}},
        },
    },
    Builder {
        BuilderName = 'Sorian FighterAttackExpResponse',
        PlatoonTemplate = 'AirAttack',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 1000,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
            PrioritizedCategories = {
                'EXPERIMENTAL AIR',
                'MOBILE AIR BOMBER',
                'MOBILE AIR',
            },
        },
        BuilderConditions = {
            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'EXPERIMENTAL AIR', 'Enemy'}},
        },
    },
    Builder {
        BuilderName = 'Sorian BomberAttackThreatResponse',
        PlatoonTemplate = 'BomberAttack',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 1000,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
            PrioritizedCategories = {
                'STRUCTURE STRATEGIC EXPERIMENTAL',
                'STRUCTURE STRATEGIC TECH3',
                'COMMAND',
                'MASSEXTRACTION',
                'ENERGYPRODUCTION',
                'MASSFABRICATION',
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
}

BuilderGroup {
    BuilderGroupName = 'SorianMassHunterAirFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian BomberAttack Mass Hunter',
        PlatoonTemplate = 'BomberAttack',
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        Priority = 100,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            PrioritizedCategories = {
                'MASSEXTRACTION',
                'MOBILE LAND',
                'ENERGYPRODUCTION',
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
		PlatoonAddPlans = { 'AirUnitRefit', 'AirIntelToggle' },
        # Commented out as the platoon doesn't exist in AILandAttackBuilders.lua
        #PlatoonTemplate = 'EarlyGameMassHuntersCategory',
        Priority = 950,
        BuilderConditions = {  
                #{ MIBC, 'LessThanGameTime', { 600 } },      	
                #{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.TECH2 * categories.MOBILE * categories.LAND - categories.ENGINEER } },
            },
        BuilderData = {
            MarkerType = 'Mass',            
            MoveFirst = 'Random',
            MoveNext = 'Guard Base',
            ThreatType = 'Economy',			    # Type of threat to use for gauging attacks
            FindHighestThreat = false,			# Don't find high threat targets
            MaxThreatThreshold = 2900,			# If threat is higher than this, do not attack
            MinThreatThreshold = 1000,			# If threat is lower than this, do not attack
            AvoidBases = true,
            AvoidBasesRadius = 75,
            AggressiveMove = true,      
            AvoidClosestRadius = 50,  
            GuardRadius = 200,
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
        Priority = 1,
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
        Priority = 10,
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