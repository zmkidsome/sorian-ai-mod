#***************************************************************************
#*
#**  File     :  /lua/ai/SorianExperimentalBuilders.lua
#**
#**  Summary  : Default experimental builders for skirmish
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
local OAUBC = '/lua/editor/OtherArmyUnitCountBuildConditions.lua'
local EBC = '/lua/editor/EconomyBuildConditions.lua'
local PCBC = '/lua/editor/PlatoonCountBuildConditions.lua'
local SAI = '/lua/ScenarioPlatoonAI.lua'
local IBC = '/lua/editor/InstantBuildConditions.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local PlatoonFile = '/lua/platoon.lua'
local SIBC = '/lua/editor/SorianInstantBuildConditions.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'

local AIAddBuilderTable = import('/lua/ai/AIAddBuilderTable.lua')

BuilderGroup {
    BuilderGroupName = 'SorianMobileExperimentalEngineersGroup',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T3 Land Exp1 Engineer 1 Group',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 951,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'EXPERIMENTAL MOBILE LAND, EXPERIMENTAL MOBILE AIR'}},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.LAND } },
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
				T4 = true,
                BaseTemplate = ExBaseTmpl,
                NearMarkerType = 'Rally Point',
                BuildStructures = {
                    'T4LandExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Land Exp2 Engineer 1 Group',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 951,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.LAND } },
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'EXPERIMENTAL MOBILE LAND, EXPERIMENTAL MOBILE AIR'}},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
				T4 = true,
                BaseTemplate = ExBaseTmpl,
                NearMarkerType = 'Rally Point',
                BuildStructures = {
                    'T4LandExperimental2',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Air Exp1 Engineer 1 Group',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 951,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 0, categories.EXPERIMENTAL * categories.AIR } },
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'EXPERIMENTAL MOBILE LAND, EXPERIMENTAL MOBILE AIR'}},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
				T4 = true,
                NearMarkerType = 'Protected Experimental Construction',
                BuildStructures = {
                    'T4AirExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMobileLandExperimentalEngineers',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T3 Land Exp1 Engineer 1',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
				T4 = true,
                BaseTemplate = ExBaseTmpl,
                NearMarkerType = 'Rally Point',
                BuildStructures = {
                    'T4LandExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Land Exp2 Engineer 1',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
				T4 = true,
                BaseTemplate = ExBaseTmpl,
                NearMarkerType = 'Rally Point',
                BuildStructures = {
                    'T4LandExperimental2',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Land Exp3 Engineer 1',
        PlatoonTemplate = 'CybranT3EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
				T4 = true,
                BaseTemplate = ExBaseTmpl,
                NearMarkerType = 'Rally Point',
                BuildStructures = {
                    'T4LandExperimental3',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Experimental Mobile Land',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 800,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.LAND * categories.MOBILE}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 150,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE LAND'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Mobile Land',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 851,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.LAND * categories.MOBILE}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 150,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE LAND'},
                Time = 60,
            },
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMobileLandExperimentalForm',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian T4 Exp Land',
        PlatoonAddPlans = {'NameUnitsSorian', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        PlatoonTemplate = 'T4ExperimentalLandSorian',
        Priority = 10000,
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderConditions = {
            { SIBC, 'HaveLessThanUnitsWithCategory', { 3, 'EXPERIMENTAL MOBILE LAND, EXPERIMENTAL MOBILE AIR'}},
			#{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, 'FACTORY TECH1, FACTORY TECH2' } },
			{ SBC, 'NoRushTimeCheck', { 0 }},
        },
        BuilderData = {
			ThreatSupport = 100,
            ThreatWeights = {
                TargetThreatType = 'Commander',
            },
            UseMoveOrder = true,
            PrioritizedCategories = { 'EXPERIMENTAL LAND', 'COMMAND', 'STRUCTURE ARTILLERY EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'MASSFABRICATION', 'ENERGYPRODUCTION', 'STRUCTURE STRATEGIC', 'STRUCTURE DEFENSE ANTIAIR', 'STRUCTURE DEFENSE DIRECTFIRE', 'FACTORY AIR', 'FACTORY LAND' }, # list in order
        },
    },
    Builder {
        BuilderName = 'Sorian T4 Exp Land Late Game',
        PlatoonAddPlans = {'NameUnitsSorian', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        PlatoonTemplate = 'T4ExperimentalLandLate',
        Priority = 10000,
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'EXPERIMENTAL MOBILE LAND, EXPERIMENTAL MOBILE AIR'}},
			#{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY TECH1' } },
			{ SBC, 'NoRushTimeCheck', { 0 }},
        },
        BuilderData = {
			ThreatSupport = 100,
            ThreatWeights = {
                TargetThreatType = 'Commander',
            },
            UseMoveOrder = true,
            PrioritizedCategories = { 'EXPERIMENTAL LAND', 'COMMAND', 'STRUCTURE ARTILLERY EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'MASSFABRICATION', 'ENERGYPRODUCTION', 'STRUCTURE STRATEGIC', 'STRUCTURE DEFENSE ANTIAIR', 'STRUCTURE DEFENSE DIRECTFIRE', 'FACTORY AIR', 'FACTORY LAND' }, # list in order
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMobileAirExperimentalEngineers',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T3 Air Exp1 Engineer 1',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
				T4 = true,
                NearMarkerType = 'Protected Experimental Construction',
                BuildStructures = {
                    'T4AirExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Experimental Mobile Air',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 800,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.AIR * categories.MOBILE}},
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 150,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE AIR'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Mobile Air',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 851,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.AIR * categories.MOBILE}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 150,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE AIR'},
                Time = 60,
            },
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMobileAirExperimentalForm',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian T4 Exp Air',
        PlatoonTemplate = 'T4ExperimentalAirSorian',
        PlatoonAddPlans = {'NameUnitsSorian', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 800,
        InstanceCount = 50,
        FormRadius = 10000,
        BuilderType = 'Any',
        BuilderConditions = {
            { SIBC, 'HaveLessThanUnitsWithCategory', { 3, 'EXPERIMENTAL MOBILE LAND, EXPERIMENTAL MOBILE AIR'}},
			#{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 1, 'FACTORY TECH1, FACTORY TECH2' } },
			{ SBC, 'NoRushTimeCheck', { 0 }},
        },
        BuilderData = {
			ThreatSupport = 100,
            ThreatWeights = {
                TargetThreatType = 'Commander',
            },
            UseMoveOrder = true,
            PrioritizedCategories = { 'EXPERIMENTAL', 'COMMAND', 'STRUCTURE ARTILLERY EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'ENERGYPRODUCTION', 'MASSFABRICATION', 'STRUCTURE' }, # list in order
        },
    },
    Builder {
        BuilderName = 'Sorian T4 Exp Air Late Game',
        PlatoonTemplate = 'T4ExperimentalAirLate',
        PlatoonAddPlans = {'NameUnitsSorian', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 800,
        InstanceCount = 50,
        FormRadius = 10000,
        BuilderType = 'Any',
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'EXPERIMENTAL MOBILE LAND, EXPERIMENTAL MOBILE AIR'}},
			#{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY TECH1' } },
			{ SBC, 'NoRushTimeCheck', { 0 }},
        },
        BuilderData = {
			ThreatSupport = 100,
            ThreatWeights = {
                TargetThreatType = 'Commander',
            },
            UseMoveOrder = true,
            PrioritizedCategories = { 'EXPERIMENTAL', 'COMMAND', 'STRUCTURE ARTILLERY EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'ENERGYPRODUCTION', 'MASSFABRICATION', 'STRUCTURE' }, # list in order
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMobileNavalExperimentalEngineers',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T4 Sea Exp1 Engineer',
        PlatoonTemplate = 'T3EngineerBuilder',
        Priority = 950,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENGINEER * categories.TECH3}},
            { MABC, 'MarkerLessThanDistance',  { 'Naval Area', 400}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
				T4 = true,
                NearMarkerType = 'Naval Area',
                BuildStructures = {
                    'T4SeaExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Experimental Mobile Naval',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 800,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 150,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE NAVAL'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Mobile Naval',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 851,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 150,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE NAVAL'},
                Time = 60,
            },
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMobileNavalExperimentalForm',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian T4 Exp Sea',
        PlatoonTemplate = 'T4ExperimentalSeaSorian',
        #PlatoonAddBehaviors = { 'TempestBehaviorSorian' },
        PlatoonAddPlans = {'NameUnitsSorian', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        #PlatoonAIPlan = 'AttackForceAI',
        Priority = 1300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 0 }},
        },
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderData = {
			ThreatSupport = 100,
            ThreatWeights = {
                TargetThreatType = 'Commander',
            },
            PrioritizedCategories = { 'COMMAND', 'FACTORY -NAVAL','EXPERIMENTAL', 'MASSPRODUCTION', 'STRUCTURE' }, # list in order
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianSatelliteExperimentalEngineers',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T3 Satellite Exp Engineer',
        PlatoonTemplate = 'UEFT3EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENGINEER * categories.TECH3}},
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.ORBITALSYSTEM }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 3, categories.EXPERIMENTAL * categories.ORBITALSYSTEM }},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = true,
				T4 = true,
                BuildStructures = {
                    'T4SatelliteExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Experimental Satellite',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 800,
        InstanceCount = 5,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ORBITALSYSTEM }},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                BeingBuiltCategories = {'EXPERIMENTAL ORBITALSYSTEM'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Satellite',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 851,
        InstanceCount = 5,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ORBITALSYSTEM }},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                BeingBuiltCategories = {'EXPERIMENTAL ORBITALSYSTEM'},
                Time = 60,
            },
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianSatelliteExperimentalForm',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian T4 Exp Satellite',
        PlatoonTemplate = 'T4SatelliteExperimental',
        PlatoonAddPlans = {'NameUnitsSorian'},
        PlatoonAIPlan = 'StrikeForceAI',
        Priority = 800,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 0 }},
        },
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = { 'COMMAND', 'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE', 'STRATEGIC STRUCTURE EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'ENERGYPRODUCTION', 'MASSFABRICATION', 'STRUCTURE' }, # list in order
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEconomicExperimentalEngineers',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian Econ Exper Engineer',
        PlatoonTemplate = 'AeonT3EngineerBuilder',
        Priority = 950,
		InstanceCount = 1,
        BuilderConditions = {
		{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
		{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSPRODUCTION * categories.TECH3}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.ECONOMIC }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.EXPERIMENTAL * categories.ECONOMIC}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2}},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
			{ IBC, 'BrainNotLowPowerMode', {} },
			{ SIBC, 'T4BuildingCheck', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
				T4 = true,
                BuildStructures = {
                    'T4EconExperimental',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Experimental Economic',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 800,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ECONOMIC}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 150,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Economic',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 851,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ECONOMIC }},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 150,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},
                Time = 60,
            },
        }
    },
}