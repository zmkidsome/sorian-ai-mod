#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/SorianExpansionBalancedFull.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'SorianExpansionBalancedFull',
    Builders = {
        # ==== ECONOMY ==== #
        # Factory upgrades
        'SorianT1BalancedUpgradeBuildersExpansion',
        'SorianT2BalancedUpgradeBuildersExpansion',
        
        # Engineer Builders
        'SorianEngineerFactoryBuilders',
        'SorianT1EngineerBuilders',
        'SorianT2EngineerBuilders',
        'SorianT3EngineerBuilders',
        'SorianEngineerFactoryConstruction',
        'SorianLandInitialFactoryConstruction',
        
        # Build Mass low pri at this base
        'SorianEngineerMassBuildersLowerPri',
        
        # Build some power, but not much
        'SorianEngineerEnergyBuildersExpansions',
        
        # ==== EXPANSION ==== #
        'SorianEngineerExpansionBuildersFull',
        'SorianEngineerExpansionBuildersSmall',
        
        # ==== DEFENSES ==== #
        'SorianT1LightDefenses',
        'SorianT2LightDefenses',
        'SorianT3LightDefenses',

		'SorianT2ArtilleryFormBuilders',
		'SorianT3ArtilleryFormBuilders',
		'SorianT4ArtilleryFormBuilders',
        'SorianT2MissileDefenses',
        'SorianT3NukeDefenses',
        'SorianT3NukeDefenseBehaviors',
        
        # ==== NAVAL EXPANSION ==== #
        'SorianNavalExpansionBuilders',
        
        # ==== LAND UNIT BUILDERS ==== #
        'SorianT1LandFactoryBuilders',
        'SorianT2LandFactoryBuilders',
        'SorianT3LandFactoryBuilders',
        'SorianFrequentLandAttackFormBuilders',
        'SorianMassHunterLandFormBuilders',
        'SorianMiscLandFormBuilders',
        
        'SorianT1ReactionDF',
        'SorianT2ReactionDF',
        'SorianT3ReactionDF',

        # ==== AIR UNIT BUILDERS ==== #
        'SorianT1AirFactoryBuilders',
        'SorianT2AirFactoryBuilders',
        'SorianT3AirFactoryBuilders',
        'SorianFrequentAirAttackFormBuilders',
        'SorianMassHunterAirFormBuilders',
        
        'SorianACUHunterAirFormBuilders',
        
        'SorianTransportFactoryBuilders',
		
		'SorianExpResponseFormBuilders',
        
        'SorianT1AntiAirBuilders',
        'SorianT2AntiAirBuilders',
        'SorianT3AntiAirBuilders',
        'SorianBaseGuardAirFormBuilders',

        # ==== EXPERIMENTALS ==== #
        'SorianMobileLandExperimentalEngineers',
        'SorianMobileLandExperimentalForm',
        
        'SorianMobileAirExperimentalEngineers',
        'SorianMobileAirExperimentalForm',
    },
    NonCheatBuilders = {
        'SorianAirScoutFactoryBuilders',
        'SorianAirScoutFormBuilders',
        
        'SorianLandScoutFactoryBuilders',
        'SorianLandScoutFormBuilders',
        
        'SorianRadarEngineerBuilders',
        'SorianRadarUpgradeBuildersExpansion',
        
        'SorianCounterIntelBuilders',
    },
    BaseSettings = {
        EngineerCount = {
            Tech1 = 10,
            Tech2 = 15,
            Tech3 = 20,
            SCU = 2,
        },
        FactoryCount = {
            Land = 4,
            Air = 2,
            Sea = 0,
            Gate = 1,
        },
        MassToFactoryValues = {
            T1Value = 6,
            T2Value = 15,
            T3Value = 22.5
        },
    },
    ExpansionFunction = function(aiBrain, location, markerType)
        if markerType != 'Start Location' then
            return 0
        end
        
        local personality = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        if not personality == 'sorian' and not personality == 'sorianrush' then
            return 0
        end

        local threatCutoff = 10 # value of overall threat that determines where enemy bases are
        local distance = import('/lua/ai/AIUtilities.lua').GetThreatDistance( aiBrain, location, threatCutoff )
        if not distance or distance > 1000 then
            return 51
        elseif distance > 500 then
            return 76
        elseif distance > 250 then
            return 101
        else # within 250
            return 26
        end
        
        return 0
    end,
}