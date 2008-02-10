#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/SorianNavalExpansionSmall.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'SorianNavalExpansionSmall',
    Builders = {
        # ==== ECONOMY ==== #
        # Factory upgrades
        'SorianT1BalancedUpgradeBuilders',
        'SorianT2BalancedUpgradeBuilders',
        
        # Engineer Builders
        'SorianEngineerFactoryBuilders',
        'SorianT1EngineerBuilders',
        'SorianT2EngineerBuilders',
        'SorianT3EngineerBuilders',
        'SorianEngineerNavalFactoryBuilder',
        
        # Mass
        'SorianEngineerMassBuildersLowerPri',
        
        # ==== EXPANSION ==== #
        'SorianEngineerExpansionBuildersFull',
        
        # ==== DEFENSES ==== #
        'SorianT1NavalDefenses',
        'SorianT2NavalDefenses',
        'SorianT3NavalDefenses',
        
        # ==== ATTACKS ==== #
        'SorianT1SeaFactoryBuilders',
        'SorianT2SeaFactoryBuilders',
        'SorianT3SeaFactoryBuilders',
        'SorianFrequentSeaAttackFormBuilders',
        'SorianMassHunterSeaFormBuilders',
        
        # ==== NAVAL EXPANSION ==== #
        'SorianNavalExpansionBuilders',
    },
    NonCheatBuilders = {
        'SorianSonarEngineerBuilders',
        'SorianSonarUpgradeBuildersSmall',
    },
    BaseSettings = {
        EngineerCount = {
            Tech1 = 5,
            Tech2 = 5,
            Tech3 = 5,
            SCU = 0,
        },
        FactoryCount = {
            Land = 0,
            Air = 0,
            Sea = 3,
            Gate = 0,
        },
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 15,
            T3Value = 22.5
        },
    },
    ExpansionFunction = function(aiBrain, location, markerType)
        if markerType != 'Naval Area' then
            return 0
        end
        
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        if personality == 'sorian' or personality == 'sorianrush' or personality == 'sorianair' or personality == 'sorianwater' then
            return 200 #50
        end
        
        return 0
    end,
}