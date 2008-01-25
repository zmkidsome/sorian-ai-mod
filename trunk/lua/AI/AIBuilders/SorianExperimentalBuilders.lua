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
    BuilderGroupName = 'SorianMobileLandExperimentalEngineers',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T3 Land Exp1 Engineer 1',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 950,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.LAND }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
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
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.LAND }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
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
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.LAND }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
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
        PlatoonTemplate = 'T2EngineerAssist',
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
        Priority = 750,
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
        PlatoonAddPlans = {'NameUnits'},
        PlatoonTemplate = 'T4ExperimentalLandSorian',
        Priority = 10000,
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        #BuilderConditions = {
        #    { UCBC, 'HaveLessThanUnitsWithCategory', { 6, 'FACTORY TECH3'}},
        #},
        BuilderData = {
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
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.AIR }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2} },
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
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 800,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingGreater', { 'LocationType', 0, categories.EXPERIMENTAL * categories.AIR * categories.MOBILE}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
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
        Priority = 750,
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
        PlatoonAddPlans = {'NameUnits'},
        Priority = 800,
        InstanceCount = 50,
        FormRadius = 10000,
        BuilderType = 'Any',
        #BuilderConditions = {
        #    { UCBC, 'HaveLessThanUnitsWithCategory', { 6, 'FACTORY TECH3'}},
        #},
        BuilderData = {
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
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.NAVAL }},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, categories.ENERGYPRODUCTION * categories.TECH3}},
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENGINEER * categories.TECH3}},
            { MABC, 'MarkerLessThanDistance',  { 'Naval Area', 400}},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
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
        PlatoonTemplate = 'T2EngineerAssist',
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
        Priority = 750,
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
        PlatoonTemplate = 'T4ExperimentalSea',
        PlatoonAddBehaviors = { 'TempestBehaviorSorian' },
        PlatoonAddPlans = {'NameUnits'},
        PlatoonAIPlan = 'AttackForceAI',
        Priority = 1300,
        FormRadius = 10000,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderData = {
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
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.EXPERIMENTAL}},
            { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, categories.EXPERIMENTAL * categories.ORBITALSYSTEM }},
            { SIBC, 'GreaterThanEconEfficiencyOverTimeExp', { 0.9, 1.2 }},
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
        PlatoonTemplate = 'T2EngineerAssist',
        Priority = 800,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
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
        Priority = 750,
        InstanceCount = 5,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3}},
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
            PrioritizedCategories = { 'STRATEGIC STRUCTURE EXPERIMENTAL', 'TECH3 STRATEGIC STRUCTURE', 'ENERGYPRODUCTION', 'MASSFABRICATION', 'STRUCTURE' }, # list in order
        },
    },
}