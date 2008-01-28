#***************************************************************************
#*
#**  File     :  /lua/ai/AIBaseTemplates/SorianMainBalanced.lua
#**
#**  Summary  : Manage engineers for a location
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

BaseBuilderTemplate {
    BaseTemplateName = 'SorianMainBalanced',
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
        'SorianEngineerFactoryConstruction Balance',
        'SorianEngineerFactoryConstruction',
        
        # Engineer Support buildings
        'SorianEngineeringSupportBuilder',
        
        # Build energy at this base
        'SorianEngineerEnergyBuilders',
        
        # Build Mass high pri at this base
        'SorianEngineerMassBuildersHighPri',
        
        # Extractors
        'SorianTime Exempt Extractor Upgrades',
        
        # ACU Builders
        'Sorian Initial ACU Builders',
        'SorianACUBuilders',
        'SorianACUUpgrades',
        
        # ACU Defense
        'SorianT1ACUDefenses',
        'SorianT2ACUDefenses',
        'SorianT2ACUShields',
        'SorianT3ACUShields',
        'SorianT3ACUNukeDefenses',
        
        # ==== EXPANSION ==== #
        'SorianEngineerExpansionBuildersFull',
        'SorianEngineerExpansionBuildersSmall',
		'SorianEngineerFirebaseBuilders',
        
        # ==== DEFENSES ==== #
		'SorianT1BaseDefenses',
		'SorianT2BaseDefenses',
		'SorianT3BaseDefenses',

		'SorianT2PerimeterDefenses',
		'SorianT3PerimeterDefenses',
		
        'SorianT1DefensivePoints',
        'SorianT2DefensivePoints',
        'SorianT3DefensivePoints',
		
		'SorianT2ArtilleryFormBuilders',
		'SorianT3ArtilleryFormBuilders',
		'SorianT4ArtilleryFormBuilders',
        'SorianT2MissileDefenses',
        'SorianT3NukeDefenses',
        'SorianT3NukeDefenseBehaviors',
		'SorianMiscDefensesEngineerBuilders',
        
        # ==== NAVAL EXPANSION ==== #
        'SorianNavalExpansionBuilders',
        
        # ==== LAND UNIT BUILDERS ==== #
        'SorianT1LandFactoryBuilders',
        'SorianT2LandFactoryBuilders',
        'SorianT3LandFactoryBuilders',
        
        'SorianFrequentLandAttackFormBuilders',
        'SorianMassHunterLandFormBuilders',
        'SorianMiscLandFormBuilders',
        'SorianUnitCapLandAttackFormBuilders',
        
        'SorianT1LandAA',
        'SorianT2LandAA',
		'SorianT3LandResponseBuilders',

        'SorianT1ReactionDF',
        'SorianT2ReactionDF',
        'SorianT3ReactionDF',
        
        'SorianT2Shields',
        'SorianShieldUpgrades',
        'SorianT3Shields',

        # ==== AIR UNIT BUILDERS ==== #
        'SorianT1AirFactoryBuilders',
        'SorianT2AirFactoryBuilders',
        'SorianT3AirFactoryBuilders',
        'SorianFrequentAirAttackFormBuilders',
        'SorianMassHunterAirFormBuilders',
        
        'SorianUnitCapAirAttackFormBuilders',
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
		
        'SorianMobileNavalExperimentalEngineers',
        'SorianMobileNavalExperimentalForm',
		
        # ==== ARTILLERY BUILDERS ==== #
        'SorianT3ArtilleryGroup',
        
        'SorianExperimentalArtillery',
        
        'SorianNukeBuildersEngineerBuilders',
        'SorianNukeFormBuilders',
        
        'SorianSatelliteExperimentalEngineers',
        'SorianSatelliteExperimentalForm',
    },
    NonCheatBuilders = {
        'SorianAirScoutFactoryBuilders',
        'SorianAirScoutFormBuilders',
        
        'SorianLandScoutFactoryBuilders',
        'SorianLandScoutFormBuilders',
        
        'SorianRadarEngineerBuilders',
        'SorianRadarUpgradeBuildersMain',
        
        'SorianCounterIntelBuilders',
    },
    BaseSettings = {
        EngineerCount = {
            Tech1 = 15,
            Tech2 = 10,
            Tech3 = 20,
            SCU = 4,
        },
        FactoryCount = {
            Land = 4,
            Air = 3,
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
        return 0
    end,
    FirstBaseFunction = function(aiBrain)
        local per = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
        if not per then 
            return 1, 'sorian'
        end
        
        if per != 'sorian' and per != 'bleh' and per != '' then
            return 1, 'sorian'
        end

        local mapSizeX, mapSizeZ = GetMapSize()
        local isIsland = false
        
        local startX, startZ = aiBrain:GetArmyStartPos()
        local islandMarker = import('/lua/AI/AIUtilities.lua').AIGetClosestMarkerLocation(aiBrain, 'Island', startX, startZ)
        if islandMarker then
            isIsland = true
        end
        
        if per == 'sorian' then
            return 1000, 'sorian'
        end
        
        #If we're playing on an island map, do not use this plan often
        if isIsland and mapSizeX > 1024 and mapSizeZ > 1024 then
            return Random(25, 50), 'sorian'

        elseif mapSizeX < 512 and mapSizeZ < 512 then
            return Random(98, 100), 'sorian'

        elseif mapSizeX >= 512 and mapSizeZ >= 512 and mapSizeX <= 1024 and mapSizeZ <= 1024 then
            return Random(50, 100), 'sorian'

        else
            return Random(25, 75), 'sorian'
        end
    end,
}