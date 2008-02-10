#***************************************************************************
#*
#**  File     :  /lua/ai/SorianLandAttackBuilders.lua
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
local PCBC = '/lua/editor/PlatoonCountBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local PlatoonFile = '/lua/platoon.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'

function LandAttackCondition(aiBrain, locationType, targetNumber)
    local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
	if not engineerManager then
        return false
    end

    local position = engineerManager:GetLocationCoords()
    local radius = engineerManager:GetLocationRadius()
    
    local surThreat = pool:GetPlatoonThreat( 'AntiSurface', categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, position, radius )
	local airThreat = pool:GetPlatoonThreat( 'AntiAir', categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, position, radius )
    if (surThreat + airThreat) > targetNumber then
        return true
    end
    return false
end

BuilderGroup {
    BuilderGroupName = 'SorianT1LandFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    # Initial bots, built during early game for harrassment
    Builder {
        BuilderName = 'Sorian T1 Bot - Early Game',
        PlatoonTemplate = 'T1LandDFBot',
        Priority = 825,
		#Priority = 0,
        BuilderConditions = {
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY LAND TECH2, FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH1 } },
            { MIBC, 'LessThanGameTime', { 300 } },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            #{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'MOBILE LAND DIRECTFIRE' } },
            #{ EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
            #{ IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Land',
    },
    # Priority of tanks at tech 1
    # Won't build if economy is hurting
    Builder {
        BuilderName = 'Sorian T1 Light Tank - Tech 1',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 825,
        #Priority = 950,
        BuilderConditions = {
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY LAND TECH2, FACTORY LAND TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH1 } },
            #{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'MOBILE LAND DIRECTFIRE' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Land',
    },
    # Priority of tanks at tech 2
    # Won't build if economy is hurting
    Builder {
        BuilderName = 'Sorian T1 Light Tank - Tech 2',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 500,
        BuilderConditions = {
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY LAND TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH1 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
        },
        BuilderType = 'Land',
    },
    # Priority of tanks at tech 3
    # Won't build if economy is hurting
    Builder {
        BuilderName = 'Sorian T1 Light Tank - Tech 3',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 0,
        BuilderConditions = {
            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, 'FACTORY LAND TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH1 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
        },
        BuilderType = 'Land',
    },    
    # T1 Artillery, built in a ratio to tanks before tech 3
    Builder {
        BuilderName = 'Sorian T1 Mortar',
        PlatoonTemplate = 'T1LandArtillery',
        Priority = 830,
        BuilderConditions = {
            #{ UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'INDIRECTFIRE LAND MOBILE' } },
            { UCBC, 'HaveUnitRatio', { 0.3, categories.LAND * categories.INDIRECTFIRE * categories.MOBILE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY LAND TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY - categories.TECH3 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
        },
        BuilderType = 'Land',
    },
}

#----------------------------------------
# T1 Mobile AA
#----------------------------------------
BuilderGroup {
    BuilderGroupName = 'SorianT1LandAA',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T1 Mobile AA',
        PlatoonTemplate = 'T1LandAA',
        Priority = 830,
        BuilderConditions = {
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY LAND TECH2, FACTORY LAND TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH1 } },
            { UCBC, 'HaveUnitRatio', { 0.15, categories.LAND * categories.ANTIAIR * categories.MOBILE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'LAND ANTIAIR MOBILE' } },
            #{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'ANTIAIR' } },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'Sorian T1 Mobile AA - Response',
        PlatoonTemplate = 'T1LandAA',
        PlatoonAddBehaviors = { 'AirLandToggle' },
        Priority = 900,
        BuilderConditions = {
            { TBC, 'HaveLessThreatThanNearby', { 'LocationType', 'AntiAir', 'Air' } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH1 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'LAND ANTIAIR MOBILE' } },
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY LAND TECH2, FACTORY LAND TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
        BuilderType = 'Land',
    },
}

#----------------------------------------
# T1 Response Builder
# Used to respond to the sight of tanks nearby
#----------------------------------------
BuilderGroup {
    BuilderGroupName = 'SorianT1ReactionDF',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T1 Tank Enemy Nearby',
        PlatoonTemplate = 'T1LandDFTank',
        Priority = 900,
        BuilderConditions = {
            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 0, 'Land', 10 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH1 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY LAND TECH2, FACTORY LAND TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH1 } },
        },
        BuilderType = 'Land',
    },
}

#----------------------------------------
# T2 Factories
#----------------------------------------
BuilderGroup {
    BuilderGroupName = 'SorianT2LandFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    # Tech 2 Priority
    Builder {
        BuilderName = 'Sorian T2 Tank - Tech 2',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 600,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
    # Tech 3 Priority
    Builder {
        BuilderName = 'Sorian T2 Tank 2 - Tech 3',
        PlatoonTemplate = 'T2LandDFTank',
        Priority = 550,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 3, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
    # MML's, built in a ratio to directfire units
    Builder {
        BuilderName = 'Sorian T2 MML',
        PlatoonTemplate = 'T2LandArtillery',
        Priority = 600,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, 'FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { UCBC, 'HaveUnitRatio', { 0.35, categories.LAND * categories.INDIRECTFIRE * categories.MOBILE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, categories.INDIRECTFIRE * categories.LAND * categories.TECH2 * categories.MOBILE } },            
        },
    },
    # Tech 2 priority
    Builder {
        BuilderName = 'Sorian T2AttackTank - Tech 2',
        PlatoonTemplate = 'T2AttackTankSorian',
        Priority = 600,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
    # Tech 3 priority
    Builder {
        BuilderName = 'Sorian T2AttackTank2 - Tech 3',
        PlatoonTemplate = 'T2AttackTankSorian',
        Priority = 550,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 3, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
    # Tech 2 priority
    Builder {
        BuilderName = 'Sorian T2 Amphibious Tank - Tech 2',
        PlatoonTemplate = 'T2LandAmphibious',
        Priority = 0,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
    # Tech 3 priority
    Builder {
        BuilderName = 'Sorian T2 Amphibious Tank',
        PlatoonTemplate = 'T2LandAmphibious',
        Priority = 0,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },    
    Builder {
        BuilderName = 'Sorian T2MobileShields',
        PlatoonTemplate = 'T2MobileShields',
        Priority = 600,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { UCBC, 'HaveUnitRatio', { 0.1, categories.LAND * categories.MOBILE * ( categories.COUNTERINTELLIGENCE + (categories.SHIELD * categories.DEFENSE) ) - categories.DIRECTFIRE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
        },
    },
    Builder {
        BuilderName = 'Sorian T2MobileShields - T3 Factories',
        PlatoonTemplate = 'T2MobileShields',
        Priority = 0,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
            { UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 3, 'FACTORY LAND TECH3' }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { UCBC, 'HaveUnitRatio', { 0.05, categories.LAND * categories.MOBILE * ( categories.COUNTERINTELLIGENCE + (categories.SHIELD * categories.DEFENSE) ) - categories.DIRECTFIRE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
        },
    },
    Builder {
        BuilderName = 'Sorian T2MobileBombs',
        PlatoonTemplate = 'T2MobileBombs',
        Priority = 0,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.05 }},
            { UCBC, 'HaveUnitRatio', { 0.2, categories.LAND * categories.INDIRECTFIRE * categories.MOBILE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
        },
    },
}

#----------------------------------------
# T2 Response Builder
# Used to respond to the sight of tanks nearby
#----------------------------------------
BuilderGroup {
    BuilderGroupName = 'SorianT2ReactionDF',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T2 Tank Enemy Nearby',
        PlatoonTemplate = 'T2AttackTankSorian',
        Priority = 925,
        BuilderConditions = {
            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 0, 'Land', 2 } },
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.DIRECTFIRE * categories.LAND * categories.MOBILE - categories.TECH1 } },
        },
        BuilderType = 'Land',
    },
}

#----------------------------------------
# T2 AA
#----------------------------------------
BuilderGroup {
    BuilderGroupName = 'SorianT2LandAA',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T2 Mobile Flak',
        PlatoonTemplate = 'T2LandAA',
        Priority = 600,
        BuilderConditions = {
            #{ TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 10, 'Air' } },
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
			{ UCBC, 'HaveUnitRatio', { 0.15, categories.LAND * categories.ANTIAIR * categories.MOBILE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'LAND ANTIAIR MOBILE' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'Sorian T2 Mobile Flak Response',
        PlatoonTemplate = 'T2LandAA',
        Priority = 900,
        BuilderConditions = {
            #{ TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 10, 'Air' } },
			{ TBC, 'HaveLessThreatThanNearby', { 'LocationType', 'AntiAir', 'Air' } },
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY LAND TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH2 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'LAND ANTIAIR MOBILE' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
        BuilderType = 'Land',
    },
}

#----------------------------------------
# T3 Land
#----------------------------------------
BuilderGroup {
    BuilderGroupName = 'SorianT3LandFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    # T3 Tank
    Builder {
        BuilderName = 'Sorian T3 Siege Assault Bot',
        PlatoonTemplate = 'T3LandBot',
        Priority = 700,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
    # T3 Artilery
    Builder {
        BuilderName = 'Sorian T3 Mobile Heavy Artillery',
        PlatoonTemplate = 'T3LandArtillery',
        Priority = 700,
        BuilderType = 'Land',
        BuilderConditions = {
            #{ TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 5, 'AntiSurface' } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { UCBC, 'HaveUnitRatio', { 0.2, categories.LAND * categories.INDIRECTFIRE * categories.MOBILE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Mobile Flak',
        PlatoonTemplate = 'T3LandAA',
        Priority = 700,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { UCBC, 'HaveUnitRatio', { 0.15, categories.LAND * categories.ANTIAIR * categories.MOBILE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'LAND ANTIAIR MOBILE' } },
            #{ TBC, 'HaveLessThreatThanNearby', { 'LocationType', 'AntiAir', 'Air' } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'Sorian T3SniperBots',
        PlatoonTemplate = 'T3SniperBots',
        Priority = 700,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3ArmoredAssault',
        PlatoonTemplate = 'T3ArmoredAssaultSorian',
        Priority = 700,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3MobileMissile',
        PlatoonTemplate = 'T3MobileMissile',
        Priority = 700,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { UCBC, 'HaveUnitRatio', { 0.25, categories.LAND * categories.INDIRECTFIRE * categories.MOBILE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
            #{ TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 5, 'AntiSurface' } },
        },
    },
    Builder {
        BuilderName = 'Sorian T3MobileShields',
        PlatoonTemplate = 'T3MobileShields',
        Priority = 700,
        BuilderType = 'Land',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { UCBC, 'HaveUnitRatio', { 0.1, categories.LAND * categories.MOBILE * ( categories.COUNTERINTELLIGENCE + (categories.SHIELD * categories.DEFENSE) ) - categories.DIRECTFIRE, '<=', categories.LAND * categories.DIRECTFIRE * categories.MOBILE}},
        },
    },
}

#----------------------------------------
# T3 AA
#---------------------------------------    
BuilderGroup {
    BuilderGroupName = 'SorianT3LandResponseBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T3 Mobile AA Response',
        PlatoonTemplate = 'T3LandAA',
        Priority = 900,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'LAND ANTIAIR MOBILE' } },
            { TBC, 'HaveLessThreatThanNearby', { 'LocationType', 'AntiAir', 'Air' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
        BuilderType = 'Land',
    },
}

#----------------------------------------
# T3 Response
#--------------------------------------- 
BuilderGroup {
    BuilderGroupName = 'SorianT3ReactionDF',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T3 Assault Enemy Nearby',
        PlatoonTemplate = 'T3ArmoredAssaultSorian',
        Priority = 950,
        BuilderConditions = {
            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 0, 'Land', 2 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH3 } },
        },
        BuilderType = 'Land',
    },
    Builder {
        BuilderName = 'Sorian T3 SiegeBot Enemy Nearby',
        PlatoonTemplate = 'T3LandBot',
        Priority = 945,
        BuilderConditions = {
            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 0, 'Land', 2 } },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.LAND * categories.FACTORY * categories.TECH3 } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 1.05 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 2, categories.DIRECTFIRE * categories.LAND * categories.MOBILE * categories.TECH3 } },
        },
        BuilderType = 'Land',
    },
}

# ===================== #
#     Form Builders
# ===================== #
BuilderGroup {
    BuilderGroupName = 'SorianUnitCapLandAttackFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian Unit Cap Default Land Attack',
        PlatoonTemplate = 'LandAttackSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 1,
        InstanceCount = 10,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'UnitCapCheckGreater', { .90 } },
        },
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
            ThreatWeights = {
                IgnoreStrongerTargetsRatio = 100.0,
            },
        },
    },
    Builder {
        BuilderName = 'Sorian De-clutter Land Attack T1',
        PlatoonTemplate = 'LandAttackMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 0,
        InstanceCount = 10,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 34, categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.SCOUT - categories.ENGINEER } },
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND - categories.ENGINEER - categories.TECH1 } },
			{ MIBC, 'GreaterThanGameTime', { 720 } },
        },
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
        },
    },
    Builder {
        BuilderName = 'Sorian De-clutter Land Attack T2',
        PlatoonTemplate = 'LandAttackMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 0,
        InstanceCount = 10,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 44, categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.SCOUT - categories.ENGINEER } },
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND - categories.ENGINEER - categories.TECH1 - categories.TECH2 } },
			{ MIBC, 'GreaterThanGameTime', { 720 } },
        },
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
        },
    },
    Builder {
        BuilderName = 'Sorian De-clutter Land Attack T3',
        PlatoonTemplate = 'LandAttackMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 0,
        InstanceCount = 10,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'PoolGreaterAtLocation', { 'LocationType', 54, categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.SCOUT - categories.ENGINEER } },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER } },
			{ MIBC, 'GreaterThanGameTime', { 720 } },
        },
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
        },
    },
}


BuilderGroup {
    BuilderGroupName = 'SorianFrequentLandAttackFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian Frequent Land Attack T1',
        PlatoonTemplate = 'LandAttackMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 1,
        InstanceCount = 12,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
        },        
        BuilderConditions = {
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND - categories.ENGINEER - categories.TECH1 } },
            { LandAttackCondition, { 'LocationType', 10 } },
        },
    },
    Builder {
        BuilderName = 'Sorian Frequent Land Attack T2',
        PlatoonTemplate = 'LandAttackMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 1,
        InstanceCount = 13,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
        },
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.TECH2 - categories.ENGINEER} },
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER} },
            { LandAttackCondition, { 'LocationType', 50 } },
        },
    },
    Builder {
        BuilderName = 'Sorian Frequent Land Attack T3',
        PlatoonTemplate = 'LandAttackMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 1,
        InstanceCount = 13,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
            ThreatWeights = {
                IgnoreStrongerTargetsRatio = 2.0,
            },
        },
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.MOBILE * categories.LAND * categories.TECH3 - categories.ENGINEER} },
            { LandAttackCondition, { 'LocationType', 150 } },
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMassHunterLandFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    
    # Hunts for mass locations with Economic threat value of no more than 2 mass extractors    
    Builder {
        BuilderName = 'Sorian Mass Hunter Early Game',
        PlatoonTemplate = 'T1MassHuntersCategorySorian',
        # Commented out as the platoon doesn't exist in AILandAttackBuilders.lua
        #PlatoonTemplate = 'EarlyGameMassHuntersCategory',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 950,
        BuilderConditions = {  
                { MIBC, 'LessThanGameTime', { 600 } },      	
                #{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.TECH2 * categories.MOBILE * categories.LAND - categories.ENGINEER } },
            },
        BuilderData = {
            MarkerType = 'Mass',            
            MoveFirst = 'Random',
            MoveNext = 'Threat',
            ThreatType = 'Economy',			    # Type of threat to use for gauging attacks
            FindHighestThreat = false,			# Don't find high threat targets
            MaxThreatThreshold = 2900,			# If threat is higher than this, do not attack
            MinThreatThreshold = 1000,			# If threat is lower than this, do not attack
            AvoidBases = true,
            AvoidBasesRadius = 75,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
            AvoidClosestRadius = 50,  
        },    
        InstanceCount = 2,
        BuilderType = 'Any',
    },      
        
    # Mid Game Mass Hunter
    # Used after 10, goes after mass locations of no max threat
    Builder {
        BuilderName = 'Sorian Mass Hunter Mid Game',
        PlatoonTemplate = 'T2MassHuntersCategorySorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 950,
        BuilderConditions = {  
        		{ MIBC, 'GreaterThanGameTime', { 600 } },      	
                #{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.TECH2 * categories.MOBILE * categories.LAND - categories.ENGINEER } },
            },
        BuilderData = {
            MarkerType = 'Mass',            
            MoveFirst = 'Random',
            MoveNext = 'Threat',
            ThreatType = 'Economy',			    # Type of threat to use for gauging attacks
            FindHighestThreat = false,			# Don't find high threat targets
            MaxThreatThreshold = 9999999,		# If threat is higher than this, do not attack
            MinThreatThreshold = 1000,			# If threat is lower than this, do not attack
            AvoidBases = true,
            AvoidBasesRadius = 75,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
            AvoidClosestRadius = 50,  
        },    
        InstanceCount = 2,
        BuilderType = 'Any',
    },
      
    
    # Early Game Start Location Attack
    # Used in the first 12 minutes to attack starting location areas
    # The platoon then stays at that location and disbands after a certain amount of time
    # Also the platoon carries an engineer with it
    Builder {
        BuilderName = 'Sorian Start Location Attack',
        PlatoonTemplate = 'StartLocationAttackSorian',
		PlatoonAddPlans = {'PlatoonCallForHelpAISorian'},
        Priority = 960,
        BuilderConditions = { 
                #{ UCBC, 'ExpansionAreaNeedsEngineer', { 'LocationType', 350, -1000, 0, 2, 'StructuresNotMex' } },     
        		{ MIBC, 'LessThanGameTime', { 720 } },  	
				{ SBC, 'MapGreaterThan', {1000, 1000}},
                #{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.TECH2 * categories.MOBILE * categories.LAND - categories.ENGINEER } },
            },
        BuilderData = {
            MarkerType = 'Start Location',            
            MoveFirst = 'Closest',
            MoveNext = 'Guard Base',
            #ThreatType = '',
            #SelfThreat = '',
            #FindHighestThreat ='',
            #ThreatThreshold = '',
            AvoidBases = true,
            AvoidBasesRadius = 100,
            AggressiveMove = true,      
            AvoidClosestRadius = 50,
            GuardTimer = 30,              
            UseFormation = 'AttackFormation',
        },    
        InstanceCount = 2,
        BuilderType = 'Any',
    }, 
    
    Builder {
        BuilderName = 'Sorian Base Location Guard Small',
        PlatoonTemplate = 'BaseGuardSmallSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        #Priority = 1000,
		Priority = 0,
        BuilderConditions = { 
                #{ UCBC, 'ExpansionAreaNeedsEngineer', { 'LocationType', 350, -1000, 0, 2, 'StructuresNotMex' } },     
        		#{ MIBC, 'LessThanGameTime', { 720 } },  	
                #{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.TECH2 * categories.MOBILE * categories.LAND - categories.ENGINEER } },
				{ UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, categories.STRUCTURE * categories.DEFENSE - categories.TECH1 } },
            },
        BuilderData = {
            LocationType = 'LocationType',
        },    
        InstanceCount = 1,
        BuilderType = 'Any',
    }, 

    Builder {
        BuilderName = 'Sorian Base Location Guard Medium',
        PlatoonTemplate = 'BaseGuardMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        #Priority = 1000,
		Priority = 0,
        BuilderConditions = { 
                #{ UCBC, 'ExpansionAreaNeedsEngineer', { 'LocationType', 350, -1000, 0, 2, 'StructuresNotMex' } },     
        		{ MIBC, 'GreaterThanGameTime', { 720 } },  	
                #{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.TECH2 * categories.MOBILE * categories.LAND - categories.ENGINEER } },
            },
        BuilderData = {
            LocationType = 'LocationType',
        },    
        InstanceCount = 1,
        BuilderType = 'Any',
    }, 
	
    Builder {
        BuilderName = 'Sorian Threat Response Strikeforce',
        PlatoonTemplate = 'StrikeForceMediumSorian',
        Priority = 1500,
        BuilderConditions = { 
            { UCBC, 'HaveUnitsWithCategoryAndAlliance', { true, 0, 'STRUCTURE STRATEGIC TECH3, STRUCTURE STRATEGIC EXPERIMENTAL', 'Enemy'}},
        },
        BuilderData = {
            PrioritizedCategories = {
                'STRUCTURE STRATEGIC EXPERIMENTAL',
                'STRUCTURE STRATEGIC TECH3',
                'COMMAND',
                'MASSEXTRACTION',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },    
        InstanceCount = 1,
        BuilderType = 'Any',
    },
	
    Builder {
        BuilderName = 'Sorian T2/T3 Land Weak Enemy Response',
        #PlatoonTemplate = 'StrikeForceMediumSorian',
		PlatoonTemplate = 'LandAttackMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 1400,
        BuilderConditions = { 
            { SBC, 'PoolThreatGreaterThanEnemyBase', {'LocationType', categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, 'AntiSurface', 'AntiSurface', 1}},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, 'FACTORY TECH2 LAND, FACTORY TECH3 LAND' }},
			{ MIBC, 'GreaterThanGameTime', { 720 } },
			{ LandAttackCondition, { 'LocationType', 50 } },
        },
        BuilderData = {
			SearchRadius = 6000,
            NeverGuardBases = true,
            NeverGuardEngineers = true,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
            PrioritizedCategories = {
                'STRUCTURE STRATEGIC EXPERIMENTAL',
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
        InstanceCount = 1,
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T1 Land Weak Enemy Response',
        #PlatoonTemplate = 'StrikeForceMediumSorian',
		PlatoonTemplate = 'LandAttackMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 1400,
        BuilderConditions = { 
            { SBC, 'PoolThreatGreaterThanEnemyBase', {'LocationType', categories.MOBILE * categories.LAND - categories.SCOUT - categories.ENGINEER, 'AntiSurface', 'AntiSurface', 1}},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY TECH2 LAND, FACTORY TECH3 LAND' }},
			{ MIBC, 'GreaterThanGameTime', { 720 } },
			{ LandAttackCondition, { 'LocationType', 10 } },
        },
        BuilderData = {
			SearchRadius = 6000,
            NeverGuardBases = true,
            NeverGuardEngineers = true,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
            PrioritizedCategories = {
                'STRUCTURE STRATEGIC EXPERIMENTAL',
                'STRUCTURE STRATEGIC TECH3',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'COMMAND',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },    
        InstanceCount = 1,
        BuilderType = 'Any',
    },
            
    # Small patrol that goes to expansion areas and attacks
    Builder {
        BuilderName = 'Sorian Expansion Area Patrol',
        PlatoonTemplate = 'StartLocationAttack2Sorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 925,
        BuilderConditions = {        
        		{ MIBC, 'LessThanGameTime', { 300 } },	
				{ SBC, 'MapGreaterThan', {1000, 1000}},
                #{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.TECH2 * categories.MOBILE * categories.LAND - categories.ENGINEER } },
            },
        BuilderData = {
            MarkerType = 'Expansion Area',            
            MoveFirst = 'Random',
            MoveNext = 'Random',
            #ThreatType = '',
            #SelfThreat = '',
            #FindHighestThreat ='',
            #ThreatThreshold = '',
            AvoidBases = true,
            AvoidBasesRadius = 75,
			UseFormation = 'AttackFormation',
			AggressiveMove = true,
            AvoidClosestRadius = 50,  
        },    
        InstanceCount = 2,
        BuilderType = 'Any',
    },           
    
    # Seek and destroy
    Builder {
        BuilderName = 'Sorian T1 Hunters',
        PlatoonTemplate = 'HuntAttackSmallSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 990,
		#Priority = 0,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'AttackFormation',
            ThreatWeights = {
                IgnoreStrongerTargetsRatio = 100.0,
            }, 
        },      
        BuilderConditions = {	
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND - categories.ENGINEER - categories.TECH1 } },
            { LandAttackCondition, { 'LocationType', 10 } },
        },    
    },     
    
    # Seek and destroy
    Builder {
        BuilderName = 'Sorian T2 Hunters',
        PlatoonTemplate = 'HuntAttackMediumSorian',
		PlatoonAddPlans = {'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 990,
		#Priority = 0,
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            NeverGuardBases = true,
            NeverGuardEngineers = true,
            UseFormation = 'AttackFormation',
            ThreatWeights = {
                IgnoreStrongerTargetsRatio = 100.0,
            },   
        },    
        BuilderConditions = {	
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND - categories.ENGINEER - categories.TECH1 - categories.TECH2 } },
            { LandAttackCondition, { 'LocationType', 10 } },
        },    
    },              
}

BuilderGroup {
    BuilderGroupName = 'SorianMiscLandFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian T1 Tanks - Engineer Guard',
        PlatoonTemplate = 'T1EngineerGuard',
        PlatoonAIPlan = 'GuardEngineer',
        Priority = 750,
        InstanceCount = 3,
        BuilderData = {
            NeverGuardBases = true,
        },
        BuilderConditions = {
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND - categories.ENGINEER - categories.TECH1 } },
            { UCBC, 'EngineersNeedGuard', { 'LocationType' } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T2 Tanks - Engineer Guard',
        PlatoonTemplate = 'T2EngineerGuard',
        PlatoonAIPlan = 'GuardEngineer',
        Priority = 750,
        InstanceCount = 3,
        BuilderData = {
            NeverGuardBases = true,
        },
        BuilderConditions = {
			{ UCBC, 'PoolLessAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND - categories.ENGINEER - categories.TECH1 - categories.TECH2} },
            { UCBC, 'EngineersNeedGuard', { 'LocationType' } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T3 Tanks - Engineer Guard',
        PlatoonTemplate = 'T3EngineerGuard',
        PlatoonAIPlan = 'GuardEngineer',
        Priority = 750,
        InstanceCount = 3,
        BuilderData = {
            NeverGuardBases = true,
        },
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 1, categories.MOBILE * categories.LAND - categories.ENGINEER * categories.TECH3} },
            { UCBC, 'EngineersNeedGuard', { 'LocationType' } },
        },
        BuilderType = 'Any',
    },
}