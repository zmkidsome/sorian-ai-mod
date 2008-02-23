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
    BuilderGroupName = 'SorianMobileAirExperimentalEngineersHigh',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T3 Air Exp1 Engineer 1 High',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 951,
		InstanceCount = 1,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
                NearMarkerType = 'Protected Experimental Construction',
                BuildStructures = {
                    'T4AirExperimental1',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Experimental Mobile Air High',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 800,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.AIR * categories.MOBILE}},
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE AIR'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Mobile Air High',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 950,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.AIR * categories.MOBILE}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE AIR'},
                Time = 60,
            },
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
        InstanceCount = 1,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
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
		InstanceCount = 1,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
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
		InstanceCount = 1,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
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
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE LAND'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Mobile Land',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 950,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.LAND * categories.MOBILE}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
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
        PlatoonAddPlans = {'NameUnits', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        PlatoonTemplate = 'T4ExperimentalLandSorian',
        Priority = 10000,
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderConditions = {
            #{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, 'FACTORY TECH3'}},
        },
        BuilderData = {
			ThreatSupport = 200,
            ThreatWeights = {
                TargetThreatType = 'Commander',
            },
            UseMoveOrder = true,
            PrioritizedCategories = { 'EXPERIMENTAL LAND', 'COMMAND', 'STRUCTURE ARTILLERY EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'MASSFABRICATION', 'ENERGYPRODUCTION', 'STRUCTURE STRATEGIC', 'STRUCTURE DEFENSE ANTIAIR', 'STRUCTURE DEFENSE DIRECTFIRE', 'FACTORY AIR', 'FACTORY LAND' }, # list in order
        },
    },
    Builder {
        BuilderName = 'Sorian T4 Exp Land Late Game 1',
        PlatoonAddPlans = {'NameUnits', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        PlatoonTemplate = 'T4ExperimentalLandLate',
        Priority = 0,
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, 'FACTORY TECH3'}},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.LAND * categories.EXPERIMENTAL - categories.url0401}},
        },
        BuilderData = {
			ThreatSupport = 200,
            ThreatWeights = {
                TargetThreatType = 'Commander',
            },
            UseMoveOrder = true,
            PrioritizedCategories = { 'EXPERIMENTAL LAND', 'COMMAND', 'STRUCTURE ARTILLERY EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'MASSFABRICATION', 'ENERGYPRODUCTION', 'STRUCTURE STRATEGIC', 'STRUCTURE DEFENSE ANTIAIR', 'STRUCTURE DEFENSE DIRECTFIRE', 'FACTORY AIR', 'FACTORY LAND' }, # list in order
        },
    },
    Builder {
        BuilderName = 'Sorian T4 Exp Land Late Game 2',
        PlatoonAddPlans = {'NameUnits', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        PlatoonTemplate = 'T4ExperimentalLandLate',
        Priority = 0,
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, 'FACTORY TECH3'}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.LAND * categories.EXPERIMENTAL - categories.url0401}},
        },
        BuilderData = {
			ThreatSupport = 200,
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
		InstanceCount = 1,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
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
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE AIR'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Mobile Air',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 950,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.AIR * categories.MOBILE}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
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
        PlatoonAddPlans = {'NameUnits', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 800,
        InstanceCount = 50,
        FormRadius = 10000,
        BuilderType = 'Any',
        BuilderConditions = {
            #{ UCBC, 'HaveLessThanUnitsWithCategory', { 6, 'FACTORY TECH3'}},
        },
        BuilderData = {
			ThreatSupport = 200,
            ThreatWeights = {
                TargetThreatType = 'Commander',
            },
            UseMoveOrder = true,
            PrioritizedCategories = { 'EXPERIMENTAL', 'COMMAND', 'STRUCTURE ARTILLERY EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'ENERGYPRODUCTION', 'MASSFABRICATION', 'STRUCTURE' }, # list in order
        },
    },
    Builder {
        BuilderName = 'Sorian T4 Exp Air Late Game 1',
        PlatoonTemplate = 'T4ExperimentalAirLate',
        PlatoonAddPlans = {'NameUnits', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 0,
        InstanceCount = 50,
        FormRadius = 10000,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, 'FACTORY TECH3'}},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.AIR * categories.EXPERIMENTAL}},
        },
        BuilderData = {
			ThreatSupport = 200,
            ThreatWeights = {
                TargetThreatType = 'Commander',
            },
            UseMoveOrder = true,
            PrioritizedCategories = { 'EXPERIMENTAL', 'COMMAND', 'STRUCTURE ARTILLERY EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'ENERGYPRODUCTION', 'MASSFABRICATION', 'STRUCTURE' }, # list in order
        },
    },
    Builder {
        BuilderName = 'Sorian T4 Exp Air Late Game 2',
        PlatoonTemplate = 'T4ExperimentalAirLate',
        PlatoonAddPlans = {'NameUnits', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        Priority = 0,
        InstanceCount = 50,
        FormRadius = 10000,
        BuilderType = 'Any',
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 5, 'FACTORY TECH3'}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.AIR * categories.EXPERIMENTAL}},
        },
        BuilderData = {
			ThreatSupport = 200,
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
		InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENGINEER * categories.TECH3}},
            { MABC, 'MarkerLessThanDistance',  { 'Naval Area', 400}},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
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
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL MOBILE NAVAL'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Mobile Naval',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 950,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.NAVAL * categories.MOBILE}},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
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
        PlatoonAddBehaviors = { 'TempestBehaviorSorian' },
        PlatoonAddPlans = {'NameUnits', 'DistressResponseAISorian', 'PlatoonCallForHelpAISorian'},
        PlatoonAIPlan = 'AttackForceAI',
        Priority = 1300,
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderData = {
			ThreatSupport = 200,
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
		InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENGINEER * categories.TECH3}},
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.ORBITALSYSTEM }},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = true,
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
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ORBITALSYSTEM }},
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
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
        Priority = 950,
        InstanceCount = 5,
        BuilderConditions = {
            { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ORBITALSYSTEM }},
            { IBC, 'BrainNotLowPowerMode', {} },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
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
        PlatoonAddPlans = {'NameUnits'},
        PlatoonAIPlan = 'StrikeForceAI',
        Priority = 800,
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
        BuilderConditions = {
		{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.ECONOMIC }},
            { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.EXPERIMENTAL * categories.ECONOMIC}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2}},
			{ SIBC, 'EngineerNeedsAssistance', { false, 'LocationType', 'EXPERIMENTAL' }},
			{ IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 2,
            Construction = {
                BuildClose = false,
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
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Experimental Mobile Economic',
        PlatoonTemplate = 'T3EngineerAssist',
        Priority = 950,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.ECONOMIC }},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
                AssistRange = 80,
                BeingBuiltCategories = {'EXPERIMENTAL ECONOMIC'},
                Time = 60,
            },
        }
    },
}