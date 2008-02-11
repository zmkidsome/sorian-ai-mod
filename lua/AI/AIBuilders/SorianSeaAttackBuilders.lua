#***************************************************************************
#*
#**  File     :  /lua/ai/AISeaAttackBuilders.lua
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

function SeaAttackCondition(aiBrain, locationType, targetNumber)
    local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')

    local engineerManager = aiBrain.BuilderManagers[locationType].EngineerManager
	if not engineerManager then
        return false
    end

    local position = engineerManager:GetLocationCoords()
    local radius = engineerManager:GetLocationRadius()
    
    local surfaceThreat = pool:GetPlatoonThreat( 'AntiSurface', categories.MOBILE * categories.NAVAL, position, radius )
    local subThreat = pool:GetPlatoonThreat( 'AntiSub', categories.MOBILE * categories.NAVAL, position, radius )
    if ( surfaceThreat + subThreat ) > targetNumber then
        return true
    end
    return false
end

BuilderGroup {
    BuilderGroupName = 'SorianT1SeaFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T1 Sea Sub',
        PlatoonTemplate = 'T1SeaSub',
        Priority = 500,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'Sorian T1 Sea Frigate',
        PlatoonTemplate = 'T1SeaFrigate',
        Priority = 500,
        BuilderType = 'Sea',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T1 Naval Anti-Air',
        PlatoonTemplate = 'T1SeaAntiAir',
        Priority = 0,
        BuilderConditions = {
            { TBC, 'EnemyThreatGreaterThanValueAtBase', { 'LocationType', 10, 'Air' } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH1 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
        BuilderType = 'Sea',
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT2SeaFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T2 Naval Destroyer',
        PlatoonTemplate = 'T2SeaDestroyer',
        Priority = 600,
        BuilderType = 'Sea',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T2 Naval Cruiser',
        PlatoonTemplate = 'T2SeaCruiser',
        PlatoonAddBehaviors = { 'AirLandToggle' },
        Priority = 600,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'Sorian T2SubKiller',
        PlatoonTemplate = 'T2SubKiller',
        Priority = 600,
        BuilderType = 'Sea',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T2ShieldBoat',
        PlatoonTemplate = 'T2ShieldBoat',
        Priority = 600,
        BuilderType = 'Sea',
        BuilderConditions = {
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'SHIELD NAVAL MOBILE' } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T2CounterIntelBoat',
        PlatoonTemplate = 'T2CounterIntelBoat',
        Priority = 600,
        BuilderType = 'Sea',
        BuilderConditions = {
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'COUNTERINTELLIGENCE NAVAL MOBILE' } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH2 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3SeaFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T3 Naval Battleship',
        PlatoonTemplate = 'T3SeaBattleship',
        Priority = 700,
        BuilderType = 'Sea',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Naval Nuke Sub',
        PlatoonTemplate = 'T3SeaNukeSub',
        Priority = 0,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
        BuilderType = 'Sea',
    },
    Builder {
        BuilderName = 'Sorian T3MissileBoat',
        PlatoonTemplate = 'T3MissileBoat',
        Priority = 700,
        BuilderType = 'Sea',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
    },
    Builder {
        BuilderName = 'Sorian T3Battlecruiser',
        PlatoonTemplate = 'T3Battlecruiser',
        Priority = 700,
        BuilderType = 'Sea',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.NAVAL * categories.FACTORY * categories.TECH3 } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.75, 1.05 }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianFrequentSeaAttackFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian Frequent Sea Attack T1',
        PlatoonTemplate = 'SeaAttack',
        Priority = 1,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
		UseFormation = 'AttackFormation',
            ThreatWeights = {
                #IgnoreStrongerTargetsRatio = 100.0,
                PrimaryThreatTargetType = 'Naval',
                SecondaryThreatTargetType = 'Economic',
                SecondaryThreatWeight = 0.1,
                WeakAttackThreatWeight = 1,
                VeryNearThreatWeight = 10,
                NearThreatWeight = 5,
                MidThreatWeight = 1,                
                FarThreatWeight = 1,            
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'MOBILE TECH2 NAVAL, MOBILE TECH3 NAVAL' } },
            { SeaAttackCondition, { 'LocationType', 20 } },
        },
    },
    Builder {
        BuilderName = 'Sorian Frequent Sea Attack T2',
        PlatoonTemplate = 'SeaAttack',
        Priority = 1,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
		UseFormation = 'AttackFormation',
            ThreatWeights = {
                #IgnoreStrongerTargetsRatio = 100.0,
                PrimaryThreatTargetType = 'Naval',
                SecondaryThreatTargetType = 'Economic',
                SecondaryThreatWeight = 0.1,
                WeakAttackThreatWeight = 1,
                VeryNearThreatWeight = 10,
                NearThreatWeight = 5,
                MidThreatWeight = 1,                
                FarThreatWeight = 1,            
            },
        },
        BuilderConditions = {
            { UCBC, 'PoolLessAtLocation', { 'LocationType', 1, 'MOBILE TECH3 NAVAL' } },
            { SeaAttackCondition, { 'LocationType', 60 } },
        },
    },
    Builder {
        BuilderName = 'Sorian Frequent Sea Attack T3',
        PlatoonTemplate = 'SeaAttack',
        Priority = 1,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
		UseFormation = 'AttackFormation',
            ThreatWeights = {
                #IgnoreStrongerTargetsRatio = 100.0,
                PrimaryThreatTargetType = 'Naval',
                SecondaryThreatTargetType = 'Economic',
                SecondaryThreatWeight = 0.1,
                WeakAttackThreatWeight = 1,
                VeryNearThreatWeight = 10,
                NearThreatWeight = 5,
                MidThreatWeight = 1,                
                FarThreatWeight = 1,            
            },
        },
        BuilderConditions = {
            { SeaAttackCondition, { 'LocationType', 180 } },
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMassHunterSeaFormBuilders',
    BuildersType = 'PlatoonFormBuilder',
}
