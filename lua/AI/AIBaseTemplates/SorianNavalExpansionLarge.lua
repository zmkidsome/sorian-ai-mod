#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/SorianNavalExpansionSmall.lua
#**  Author(s): Michael Robbins aka Sorian
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'SorianNavalExpansionLarge',
    Builders = {
        # ==== ECONOMY ==== #
        # Factory upgrades
        'SorianT1NavalUpgradeBuilders',
        'SorianT2NavalUpgradeBuilders',
		
        # Pass engineers to main as needed
        'Engineer Transfers',
        
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
		
        # ==== EXPERIMENTALS ==== #
        'SorianMobileNavalExperimentalEngineers',
        'SorianMobileNavalExperimentalForm',
    },
    NonCheatBuilders = {
        'SorianSonarEngineerBuilders',
        'SorianSonarUpgradeBuildersSmall',
    },
    BaseSettings = {
        EngineerCount = {
            Tech1 = 1,
            Tech2 = 1,
            Tech3 = 1,
            SCU = 0,
        },
        FactoryCount = {
            Land = 0,
            Air = 0,
            Sea = 4,
            Gate = 0,
        },
        MassToFactoryValues = {
            T1Value = 6, #6
            T2Value = 15, #15
            T3Value = 22.5, #22.5 
        },
    },
    ExpansionFunction = function(aiBrain, location, markerType)
        if markerType != 'Naval Area' then
            return 0
        end
		
		local isIsland = false
        local startX, startZ = aiBrain:GetArmyStartPos()
        local islandMarker = import('/lua/AI/AIUtilities.lua').AIGetClosestMarkerLocation(aiBrain, 'Island', startX, startZ)
        if islandMarker then
            isIsland = true
        end
        
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
		local base = ScenarioInfo.ArmySetup[aiBrain.Name].AIBase
		
		if personality == 'sorianadaptive' and base == 'SorianMainWater' then
			return 250
		end
		
        if personality == 'sorianwater' then
            return 200
        end
        
        return 0
    end,
}