#***************************************************************************
#*
#**  File     :  /lua/ai/AIEconomicBuilders.lua
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
local SAI = '/lua/ScenarioPlatoonAI.lua'
local TBC = '/lua/editor/ThreatBuildConditions.lua'
local PlatoonFile = '/lua/platoon.lua'
local SIBC = '/lua/editor/SorianInstantBuildConditions.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'

BuilderGroup {
    BuilderGroupName = 'SorianEngineerFactoryBuilders',
    BuildersType = 'FactoryBuilder',
    # ============
    #    TECH 1
    # ============
    Builder {
        BuilderName = 'Sorian T1 Engineer Disband - Init Small',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 4, 'ENGINEER TECH1' }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY TECH3' }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH1' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech1' } },
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'Sorian T1 Engineer Disband - Filler 1',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 800,
        BuilderConditions = {
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 8, 'ENGINEER TECH1' }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY TECH3' }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'MOBILE LAND DIRECTFIRE' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH1' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech1' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'Sorian T1 Engineer Disband - Filler 2',
        PlatoonTemplate = 'T1BuildEngineer',
        Priority = 700,
        BuilderConditions = {
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 } },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY TECH3' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 4, 'FACTORY TECH3' }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'MOBILE LAND DIRECTFIRE' } },
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH1' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech1' } },
            { IBC, 'BrainNotLowMassMode', {} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
        },
        BuilderType = 'All',
    },
    
    # ============
    #    TECH 2
    # ============
    Builder {
        BuilderName = 'Sorian T2 Engineer Disband - Init',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 925,
        BuilderConditions = {
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH2' }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, 'FACTORY TECH3' }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH2' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech2' } },
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Disband - Filler 1',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 800,
        BuilderConditions = {
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 6, 'ENGINEER TECH2' }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, 'FACTORY TECH3' }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH2' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech2' } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Disband - Filler 2',
        PlatoonTemplate = 'T2BuildEngineer',
        Priority = 700,
        BuilderConditions = {
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 } },
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 4, 'FACTORY TECH3' }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH2' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech2' } },
            #{ IBC, 'BrainNotLowMassMode', {} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
        },
        BuilderType = 'All',
    },
    
    # ============
    #    TECH 3
    # ============
    Builder {
        BuilderName = 'Sorian T3 Engineer Disband - Init',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 950,
        BuilderConditions = {
            { UCBC,'EngineerLessAtLocation', { 'LocationType', 6, 'ENGINEER TECH3' }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH3' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech3' } },
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Disband - Filler',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 925,
        BuilderConditions = {
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 9, 'ENGINEER TECH3' }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH3' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech3' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Disband - Filler 2',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 12, 'ENGINEER TECH3' }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH3' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech3' } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 } },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            #{ IBC, 'BrainNotLowMassMode', {} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Disband - Filler 3',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 900,
        BuilderConditions = {
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 } },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH3' } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech3' } },
            #{ IBC, 'BrainNotLowMassMode', {} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
        },
        BuilderType = 'All',
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Disband - Filler 3 Econ',
        PlatoonTemplate = 'T3BuildEngineer',
        Priority = 950,
        BuilderConditions = {
            { EBC, 'GreaterThanEconStorageRatio', { 0.85, 0.85 } },
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 1.2, 1.2 } },
			{ SBC, 'NoRushTimeCheck', { 600 }},
            { UCBC, 'LocationFactoriesBuildingLess', { 'LocationType', 1, 'ENGINEER TECH3' } },
            #{ UCBC, 'EngineerCapCheck', { 'LocationType', 'Tech3' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
        },
        BuilderType = 'All',
    },

    # ====================
    #    SUB COMMANDERS
    # ====================
    Builder {
        BuilderName = 'Sorian T3 Sub Commander',
        PlatoonTemplate = 'T3LandSubCommander',
        Priority = 950,
        BuilderConditions = {
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 } },
            { UCBC, 'EngineerCapCheck', { 'LocationType', 'SCU' } },
            #{ IBC, 'BrainNotLowMassMode', {} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
        },
        BuilderType = 'Gate',
    },
}

BuilderGroup {
    BuilderGroupName = 'Sorian Initial ACU Builders',
    BuildersType = 'EngineerBuilder',
    
    # Initial builder
    Builder {
        BuilderName = 'Sorian CDR Initial Balanced',
        PlatoonAddBehaviors = { 'CommanderBehaviorSorian', },
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
                { IBC, 'NotPreBuilt', {}},
            },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
					'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1Resource',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1EnergyProduction',
					'T1EnergyProduction',
                    'T1AirFactory',					
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian CDR Initial PreBuilt Balanced',
        PlatoonAddBehaviors = { 'CommanderBehaviorSorian', },
		PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
                { IBC, 'PreBuiltBase', {}},
            },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
                    'T1AirFactory',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1EnergyProduction',
                    'T1AirFactory',
                    'T1LandFactory',
                    'T1LandFactory',
                    'T1LandFactory',
                }
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'Sorian Air Initial ACU Builders',
    BuildersType = 'EngineerBuilder',
    
    # Initial builder
    Builder {
        BuilderName = 'Sorian CDR Initial Air',
        PlatoonAddBehaviors = { 'CommanderBehaviorSorian', },
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
                { IBC, 'NotPreBuilt', {}},
            },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1AirFactory',
					'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1Resource',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1EnergyProduction',
					'T1EnergyProduction',
                    'T1AirFactory',					
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian CDR Initial PreBuilt Air',
        PlatoonAddBehaviors = { 'CommanderBehaviorSorian', },
		PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
                { IBC, 'PreBuiltBase', {}},
            },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1AirFactory',
                    'T1AirFactory',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1EnergyProduction',
                    'T1AirFactory',
                    'T1AirFactory',
                    'T1AirFactory',
                    'T1LandFactory',
                }
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'Sorian Naval Initial ACU Builders',
    BuildersType = 'EngineerBuilder',
    
    # Initial builder
    Builder {
        BuilderName = 'Sorian CDR Initial Naval',
        PlatoonAddBehaviors = { 'CommanderBehaviorSorian', },
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
                { IBC, 'NotPreBuilt', {}},
            },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
					'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1Resource',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1EnergyProduction',
					'T1EnergyProduction',
                    'T1AirFactory',					
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian CDR Initial PreBuilt Naval',
        PlatoonAddBehaviors = { 'CommanderBehaviorSorian', },
		PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
                { IBC, 'PreBuiltBase', {}},
            },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1AirFactory',
                    'T1AirFactory',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1EnergyProduction',
                    'T1AirFactory',
                    'T1AirFactory',
                    'T1AirFactory',
                }
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'Sorian Rush Initial ACU Builders',
    BuildersType = 'EngineerBuilder',
    
    # Initial builder
    Builder {
        BuilderName = 'Sorian CDR Initial Land Rush',
        PlatoonAddBehaviors = { 'CommanderBehaviorSorian', },
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
                { IBC, 'NotPreBuilt', {}},
            },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
			Delay = 165,
			Mult = 2,
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
					'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1Resource',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
					'T1EnergyProduction',
					'T1EnergyProduction',
                    'T1LandFactory',  
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian CDR Initial PreBuilt Land Rush',
        PlatoonAddBehaviors = { 'CommanderBehaviorSorian', },
		PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
                { IBC, 'PreBuiltBase', {}},
            },
        InstantCheck = true,
        BuilderType = 'Any',
        PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
			Delay = 165,
			Mult = 2,
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
                    'T1AirFactory',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1AirFactory',
                    'T1LandFactory',
                    'T1LandFactory',
                    'T1LandFactory',
                }
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianACUBuilders',
    BuildersType = 'EngineerBuilder',
    
    # After initial
    # Build on nearby mass locations
    Builder {
        BuilderName = 'Sorian CDR Single T1Resource',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 0, #950, Probably uneeded, removed for testing
        BuilderConditions = {
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 40, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1Resource',
                },
            }
        }
    },
    Builder {    	
        BuilderName = 'Sorian CDR T1 Power',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 875,
        BuilderConditions = {            
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.5 }},
            { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.4 }},
            #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 1, 'ENGINEER TECH2, ENGINEER TECH3' } },
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH2, ENERGYPRODUCTION TECH3'}},
        },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                #AdjacencyCategory = 'FACTORY',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    
    Builder {
        BuilderName = 'Sorian CDR Base D',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 925,
        BuilderConditions = {
            { UCBC, 'HaveLessThanUnitsWithCategory', { 0, 'DEFENSE TECH1' }},
            { MABC, 'MarkerLessThanDistance',  { 'Rally Point', 50 }},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.95, 1.2 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BaseTemplate = ExBaseTmpl,
                BuildClose = false,
                NearMarkerType = 'Rally Point',
                ThreatMin = -5,
                ThreatMax = 5,
                ThreatRings = 0,
                BuildStructures = {
                    'T1GroundDefense',
                    'T1AADefense',
                }
            }
        }
    },
    
    # CDR Assisting
    Builder {
        BuilderName = 'Sorian CDR Assist T2/T3 Power',
        PlatoonTemplate = 'CommanderAssistSorian',
        Priority = 700,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'ENERGYPRODUCTION TECH2, ENERGYPRODUCTION TECH3' }},
            { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.3 }},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 0.5 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssisteeType = 'Engineer',
                AssistLocation = 'LocationType',
				AssistRange = 100,
                BeingBuiltCategories = {'ENERGYPRODUCTION TECH3', 'ENERGYPRODUCTION TECH2'},
                Time = 20,
            },
        }
    },
    # CDR Assisting
    Builder {
        BuilderName = 'Sorian CDR Assist T4',
        PlatoonTemplate = 'CommanderAssistSorian',
        Priority = 750,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'EXPERIMENTAL' }},
			{ IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 1.2, 1.2 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssisteeType = 'Engineer',
                AssistLocation = 'LocationType',
				AssistRange = 100,
                BeingBuiltCategories = {'EXPERIMENTAL'},
                Time = 60,
            },
        }
    },
    #Builder {
    #    BuilderName = 'Sorian CDR Assist Factory',
    #    PlatoonTemplate = 'CommanderAssistSorian',
    #    Priority = 500,
    #    BuilderConditions = {
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1} },
    #        { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'MOBILE' }},
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #    },
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            AssisteeType = 'Factory',
    #            BuilderCategories = {'FACTORY',},
    #            PermanentAssist = true,
    #            Time = 20,
    #        },
    #    }
    #},
    #Builder {
    #    BuilderName = 'Sorian CDR Assist Factory Upgrade Tech 2',
    #    PlatoonTemplate = 'CommanderAssistSorian',
    #    Priority = 800,
    #    BuilderConditions = {
    #        { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'TECH2 FACTORY' } },
    #        { UCBC, 'HaveLessThanUnitsWithCategory', { 2, 'FACTORY TECH2, FACTORY TECH3' } },
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 } },
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #    },
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            AssisteeType = 'Factory',
    #            PermanentAssist = true,
    #            BeingBuiltCategories = {'FACTORY TECH2',},
    #            Time = 40,
    #        },
    #    }
    #},
    #Builder {
    #    BuilderName = 'Sorian CDR Assist Factory Upgrade Tech 3',
    #    PlatoonTemplate = 'CommanderAssistSorian',
    #    Priority = 800,
    #    BuilderConditions = {
    #        { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'TECH3 FACTORY' } },
    #        { UCBC, 'HaveLessThanUnitsWithCategory', { 2, 'TECH3 FACTORY' } },
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 } },
    #    },
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            AssisteeType = 'Factory',
    #            PermanentAssist = true,
    #            BeingBuiltCategories = {'FACTORY TECH3',},
    #            Time = 40,
    #        },
    #    }
    #},
    #Builder {
    #    BuilderName = 'Sorian CDR Assist Mass Extractor Upgrade',
    #    PlatoonTemplate = 'CommanderAssistSorian',
    #    Priority = 0,
    #    BuilderConditions = {
    #        { UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, 'TECH2 MASSEXTRACTION' } },
    #        { UCBC, 'HaveLessThanUnitsWithCategory', { 2, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3' } },
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #    },
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssisteeType = 'Structure',
    #            AssistLocation = 'LocationType',
    #            BeingBuiltCategories = {'MASSEXTRACTION'},
    #            Time = 30,
    #        },
    #    }
    #},
}

BuilderGroup {
    BuilderGroupName = 'SorianACUUpgrades',
    BuildersType = 'EngineerBuilder', #'PlatoonFormBuilder',
    # UEF
    Builder {
        BuilderName = 'Sorian UEF CDR Upgrade AdvEng - Pods',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'FACTORY TECH2, FACTORY TECH3' }},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3' }},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION TECH3' }},
                #{ EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}},
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
				{ SBC, 'CmdrHasUpgrade', { 'AdvancedEngineering', false }},
				{ SBC, 'CmdrHasUpgrade', { 'Shield', false }},
                { MIBC, 'FactionIndex', {1, 1}},
            },
        Priority = 900,
        BuilderType = 'Any',
		PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'LeftPod', 'RightPod', 'ResourceAllocation', 'AdvancedEngineering' },
        },
    },
    Builder {
        BuilderName = 'Sorian UEF CDR Upgrade T3 Eng - Shields',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'FACTORY TECH2, FACTORY TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3'}},
                #{ EBC, 'GreaterThanEconStorageRatio', { 0.5, 0.5}},
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
				{ SBC, 'CmdrHasUpgrade', { 'AdvancedEngineering', true }},
				{ SBC, 'CmdrHasUpgrade', { 'T3Engineering', false }},
                { MIBC, 'FactionIndex', {1, 1}},
            },
        Priority = 900,
        BuilderType = 'Any',
		PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'RightPodRemove', 'Shield', 'T3Engineering' },
        },
    },

    # Aeon
    Builder {
        BuilderName = 'Sorian Aeon CDR Upgrade AdvEng - Resource - Crysalis',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'FACTORY TECH2, FACTORY TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION TECH3' }},
                #{ EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}},
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
				{ SBC, 'CmdrHasUpgrade', { 'HeatSink', false }},
				{ SBC, 'CmdrHasUpgrade', { 'T3Engineering', false }},
                { MIBC, 'FactionIndex', {2, 2}},
            },
        Priority = 900,
        BuilderType = 'Any',
		PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'AdvancedEngineering', 'Shield', 'HeatSink' },
        },
    },
    Builder {
        BuilderName = 'Sorian Aeon CDR Upgrade T3 Eng - ResourceAdv - EnhSensor',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'FACTORY TECH2, FACTORY TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3'}},
                #{ EBC, 'GreaterThanEconStorageRatio', { 0.5, 0.5}},
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
				{ SBC, 'CmdrHasUpgrade', { 'HeatSink', true }},
				{ SBC, 'CmdrHasUpgrade', { 'T3Engineering', false }},
                { MIBC, 'FactionIndex', {2, 2}},
            },
        Priority = 900,
        BuilderType = 'Any',
		PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'T3Engineering' },
        },
    },
    
    # Cybran
    Builder {
        BuilderName = 'Sorian Cybran CDR Upgrade AdvEng - Laser Gen',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'FACTORY TECH2, FACTORY TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION TECH3' }},
                #{ EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}},
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
				{ SBC, 'CmdrHasUpgrade', { 'AdvancedEngineering', false }},
				{ SBC, 'CmdrHasUpgrade', { 'T3Engineering', false }},
                { MIBC, 'FactionIndex', {3, 3}},
            },
        Priority = 900,
        BuilderType = 'Any',
		PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'StealthGenerator', 'AdvancedEngineering' },
        },
    },
    Builder {
        BuilderName = 'Sorian Cybran CDR Upgrade T3 Eng - Resource',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'FACTORY TECH2, FACTORY TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3'}},
                #{ EBC, 'GreaterThanEconStorageRatio', { 0.5, 0.5}},
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
				{ SBC, 'CmdrHasUpgrade', { 'AdvancedEngineering', true }},
				{ SBC, 'CmdrHasUpgrade', { 'T3Engineering', false }},
                { MIBC, 'FactionIndex', {3, 3}},
            },
        Priority = 900,
        BuilderType = 'Any',
		PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'T3Engineering' },
        },
    },
	
    # Seraphim
    Builder {
        BuilderName = 'Sorian Seraphim CDR Upgrade AdvEng - Resource - Crysalis',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'FACTORY TECH2, FACTORY TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION TECH3' }},
                #{ EBC, 'GreaterThanEconStorageRatio', { 0.25, 0.25}},
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
				{ SBC, 'CmdrHasUpgrade', { 'DamageStabilization', false }},
				{ SBC, 'CmdrHasUpgrade', { 'T3Engineering', false }},
                { MIBC, 'FactionIndex', {4, 4}},
            },
        Priority = 900,
        BuilderType = 'Any',
		PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'AdvancedEngineering', 'DamageStabilization' },
        },
    },
    Builder {
        BuilderName = 'Sorian Seraphim CDR Upgrade T3 Eng - ResourceAdv - EnhSensor',
        PlatoonTemplate = 'CommanderEnhance',
        BuilderConditions = {
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 4, 'FACTORY TECH2, FACTORY TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3'}},
                #{ EBC, 'GreaterThanEconStorageRatio', { 0.5, 0.5}},
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
				{ SBC, 'CmdrHasUpgrade', { 'DamageStabilization', true }},
				{ SBC, 'CmdrHasUpgrade', { 'T3Engineering', false }},
                { MIBC, 'FactionIndex', {4, 4}},
            },
        Priority = 900,
        BuilderType = 'Any',
		PlatoonAddFunctions = { {SAI, 'BuildOnce'}, },
        BuilderData = {
            Enhancement = { 'T3Engineering' },
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT1EngineerBuilders',
    BuildersType = 'EngineerBuilder',
    # =====================================
    #     T1 Engineer Resource Builders
    # =====================================
    Builder {
        BuilderName = 'Sorian T1 Hydrocarbon Engineer - init',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 0, #1002, #980
        BuilderConditions = {
                { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENGINEER * ( categories.TECH2 + categories.TECH3 ) } },
				{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.MASSEXTRACTION } },
                { SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'HYDROCARBON'}},
				{ SBC, 'CanBuildOnHydroLessThanDistance', { 'LocationType', 200, -500, 1, 0, 'AntiSurface', 1 }},
                #{ SBC, 'MarkerLessThanDistance',  { 'Hydrocarbon', 200}},
            },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1HydroCarbon',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1 Hydrocarbon Engineer',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 980,
        BuilderConditions = {
                { UCBC, 'HaveLessThanUnitsWithCategory', { 1, categories.ENGINEER * ( categories.TECH2 + categories.TECH3 ) } },
				{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 4, categories.MASSEXTRACTION } },
                #{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'HYDROCARBON'}},
				{ SBC, 'CanBuildOnHydroLessThanDistance', { 'LocationType', 200, -500, 1, 0, 'AntiSurface', 1 }},
                #{ SBC, 'MarkerLessThanDistance',  { 'Hydrocarbon', 200}},
            },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1HydroCarbon',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1 Engineer Reclaim',
        PlatoonTemplate = 'EngineerBuilderSorian',
        PlatoonAIPlan = 'ReclaimAISorian',
        Priority = 900,
        InstanceCount = 3,
        BuilderConditions = {
                { SBC, 'ReclaimablesInArea', { 'LocationType', }},
            },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T1 Engineer Reclaim Old Pgens',
        PlatoonTemplate = 'EngineerBuilderSorian',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
                { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
				{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH1 * categories.ENERGYPRODUCTION * categories.DRAGBUILD }},
            },
        BuilderData = {
			Location = 'LocationType',
			Reclaim = {'STRUCTURE ENERGYPRODUCTION TECH1 DRAGBUILD'},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T1 Engineer Find Unfinished',
        PlatoonTemplate = 'EngineerBuilderSorian',
        PlatoonAIPlan = 'ManagerEngineerFindUnfinished',
        Priority = 1800,
        InstanceCount = 1,
        BuilderConditions = {
                { SBC, 'UnfinishedUnits', { 'LocationType', categories.STRUCTURE}},
            },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE STRATEGIC, STRUCTURE ECONOMIC, STRUCTURE'},
                Time = 20,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T1 Engineer Find Low Shield',
        PlatoonTemplate = 'EngineerBuilderSorian',
        PlatoonAIPlan = 'ManagerEngineerFindLowShield',
        Priority = 1801,
        InstanceCount = 3,
        BuilderConditions = {
                { SBC, 'ShieldDamaged', { 'LocationType'}},
            },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE SHIELD TECH2, STRUCTURE SHIELD TECH3'},
                Time = 20,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T1 Engineer Repair',
        PlatoonTemplate = 'EngineerRepairSorian',
        PlatoonAIPlan = 'RepairAI',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
                { SBC, 'DamagedStructuresInArea', { 'LocationType', }},
            },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T1 Engineer Reclaim Excess',
        PlatoonTemplate = 'EngineerBuilderSorian',
        PlatoonAIPlan = 'ReclaimAISorian',
        Priority = 1,
        InstanceCount = 50,
        BuilderConditions = {
                { SBC, 'ReclaimablesInArea', { 'LocationType', }},
            },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 120,
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T1 Mass Adjacency Engineer',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 925,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            { MABC, 'MarkerLessThanDistance',  { 'Mass', 250, -3, 0, 0}},
            #{ IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { UCBC, 'AdjacencyCheck', { 'LocationType', 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3', 250, 'ueb1106' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION TECH3, MASSEXTRACTION TECH2',
                AdjacencyDistance = 250,
                BuildClose = false,
                ThreatMin = -3,
                ThreatMax = 0,
                ThreatRings = 0,
                BuildStructures = {
                    'MassStorage',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1 Energy Storage Engineer - T3 Energy Production',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 825,
        BuilderConditions = {
            { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, 'ENERGYPRODUCTION TECH3' }},
            { UCBC, 'UnitCapCheckLess', { .7 } },
            { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.3 }},
            { UCBC, 'AdjacencyCheck', { 'LocationType', 'ENERGYPRODUCTION TECH3', 100, 'ueb1105' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'ENERGYPRODUCTION TECH3',
                AdjacencyDistance = 100,
                BuildClose = false,
                BuildStructures = {
                    'EnergyStorage',
                    'EnergyStorage',
                    'EnergyStorage',
                    'EnergyStorage',
                },
            }
        }
    },
    
    # =========================
    #     T1 ENGINEER ASSIST
    # =========================
    #Builder {
    #    BuilderName = 'Sorian T1 Engineer Assist Factory',
    #    PlatoonTemplate = 'EngineerAssistSorian',
    #    Priority = 600,
    #    BuilderConditions = {
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #        { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'MOBILE' } },
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
    #    },
    #    InstanceCount = 5,
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            PermanentAssist = true,
    #            AssisteeType = 'Factory',
    #            Time = 30,
    #        },
    #    }
    #},
    #Builder {
    #    BuilderName = 'Sorian T1 Engineer Assist FactoryLowerPri',
    #    PlatoonTemplate = 'EngineerAssistSorian',
    #    Priority = 500,
    #    InstanceCount = 50,
    #    BuilderConditions = {
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #        { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'MOBILE' } },
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
    #    },
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            PermanentAssist = true,
    #            AssisteeType = 'Factory',
    #            Time = 30,
    #        },
    #    }
    #},
    Builder {
        BuilderName = 'Sorian T1 Engineer Assist Engineer',
        PlatoonTemplate = 'EngineerAssistSorian',
        Priority = 500,
        InstanceCount = 50,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'ALLUNITS' } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = true,
                AssisteeType = 'Engineer',
                Time = 30,
            },
        }
    },
    #Builder {
    #    BuilderName = 'Sorian T1 Engineer Assist Shield',
    #    PlatoonTemplate = 'EngineerAssistSorian',
    #    Priority = 825,
    #    BuilderConditions = {
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #        { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'STRUCTURE SHIELD' }},
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
    #    },
    #    InstanceCount = 2,
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            AssisteeType = 'Engineer',
    #            BeingBuiltCategories = {'SHIELD STRUCTURE'},
    #            Time = 60,
    #        },
    #    }
    #},
    #Builder {
    #    BuilderName = 'Sorian T1 Engineer Assist Mass Upgrade',
    #    PlatoonTemplate = 'EngineerAssistSorian',
    #    Priority = 850,
    #    BuilderConditions = {
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #        { UCBC, 'BuildingGreaterAtLocation', { 'LocationType', 0, 'MASSEXTRACTION TECH2'}},
    #        { UCBC, 'HaveLessThanUnitsWithCategory', { 5, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3' } },
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
    #        { SIBC, 'LessThanEconEfficiencyOverTime', { 1.5, 2.0 }},
    #    },
    #    InstanceCount = 2,            
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssisteeType = 'Structure',
    #            AssistLocation = 'LocationType',
    #            BeingBuiltCategories = {'MASSEXTRACTION TECH2'},
    #            Time = 60,
    #        },
    #    }
    #},
    #Builder {
    #    BuilderName = 'Sorian T1 Engineer Assist Power',
    #    PlatoonTemplate = 'EngineerAssistSorian',
    #    Priority = 900,
    #    BuilderConditions = {
    #        { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'ENERGYPRODUCTION' }},
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 0.8 }},
    #        { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.4 }},
    #    },
    #    InstanceCount = 2,
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            PermanentAssist = true,
    #            BeingBuiltCategories = {'ENERGYPRODUCTION TECH3', 'ENERGYPRODUCTION TECH2', 'ENERGYPRODUCTION'},
    #            AssisteeType = 'Engineer',
    #            Time = 60,
    #        },
    #    }
    #},
    #Builder {
    #    BuilderName = 'Sorian T1 Engineer Assist Transport',
    #    PlatoonTemplate = 'EngineerAssistSorian',
    #    Priority = 875,
    #    BuilderConditions = {
    #        { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'TRANSPORTFOCUS' } },
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
    #    },
    #    InstanceCount = 2,
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            PermanentAssist = false,
    #            BeingBuiltCategories = {'TRANSPORTFOCUS'},
    #            AssisteeType = 'Factory',
    #            Time = 60,
    #        },
    #    },
    #},
    #Builder {
    #    BuilderName = 'Sorian T1 Engineer Assist T2 Factory Upgrade',
    #    PlatoonTemplate = 'EngineerAssistSorian',
    #    Priority = 875,
    #    BuilderConditions = {
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #        { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENGINEER TECH1'}},
    #        { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'FACTORY TECH2' }},
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
    #    },
    #    InstanceCount = 4,
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            PermanentAssist = true,
    #            BeingBuiltCategories = {'FACTORY TECH2'},
    #            AssisteeType = 'Factory',
    #            Time = 60,
    #        },
    #    }
    #},
    #Builder {
    #    BuilderName = 'Sorian T1 Engineer Assist T3 Factory Upgrade',
    #    PlatoonTemplate = 'EngineerAssistSorian',
    #    Priority = 900,
    #    BuilderConditions = {
    #        { IBC, 'BrainNotLowPowerMode', {} },
    #        { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENGINEER TECH1'}},
    #        { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'FACTORY TECH3' }},
    #        { UCBC, 'HaveLessThanUnitsWithCategory', { 3, 'TECH3 FACTORY' } },
    #        { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
    #    },
    #    InstanceCount = 8,
    #    BuilderType = 'Any',
    #    BuilderData = {
    #        Assist = {
    #            AssistLocation = 'LocationType',
    #            PermanentAssist = true,
    #            BeingBuiltCategories = {'FACTORY TECH3'},
    #            AssisteeType = 'Factory',
    #            Time = 60,
    #        },
    #    }
    #},    
}

BuilderGroup {
    BuilderGroupName = 'SorianT2EngineerBuilders',
    BuildersType = 'EngineerBuilder',
    # =====================================
    #     T2 Engineer Resource Builders
    # =====================================
    Builder {
        BuilderName = 'Sorian T2 Mass Adjacency Engineer',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 850,
        BuilderConditions = {
			#{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 1, 'ENGINEER TECH1' }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3'}},
            { MABC, 'MarkerLessThanDistance',  { 'Mass', 250, -3, 0, 0}},
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { UCBC, 'AdjacencyCheck', { 'LocationType', 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3', 250, 'ueb1106' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'MASSEXTRACTION TECH2, MASSEXTRACTION TECH3',
                AdjacencyDistance = 250,
                BuildClose = false,
                ThreatMin = -3,
                ThreatMax = 0,
                ThreatRings = 0,
                BuildStructures = {
                    'MassStorage',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Reclaim',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        PlatoonAIPlan = 'ReclaimAISorian',
        Priority = 0,
        InstanceCount = 3,
        BuilderConditions = {
				{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'TECH2 ENERGYPRODUCTION'}},
                { SBC, 'ReclaimablesInArea', { 'LocationType', }},
            },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Reclaim Old Pgens',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        PlatoonAIPlan = 'ReclaimStructuresAI',
        Priority = 900,
        InstanceCount = 1,
        BuilderConditions = {
                { UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH3 * categories.ENERGYPRODUCTION}},
				{ UCBC, 'UnitsGreaterAtLocation', { 'LocationType', 0, categories.TECH1 * categories.ENERGYPRODUCTION * categories.DRAGBUILD }},
            },
        BuilderData = {
			Location = 'LocationType',
			Reclaim = {'STRUCTURE ENERGYPRODUCTION TECH1 DRAGBUILD'},
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Find Unfinished',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        PlatoonAIPlan = 'ManagerEngineerFindUnfinished',
        Priority = 1800,
        InstanceCount = 1,
        BuilderConditions = {
                { SBC, 'UnfinishedUnits', { 'LocationType', categories.STRUCTURE}},
            },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE STRATEGIC, STRUCTURE ECONOMIC, STRUCTURE'},
                Time = 20,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Find Low Shield',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        PlatoonAIPlan = 'ManagerEngineerFindLowShield',
        Priority = 1801,
        InstanceCount = 3,
        BuilderConditions = {
                { SBC, 'ShieldDamaged', { 'LocationType'}},
            },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE SHIELD TECH2, STRUCTURE SHIELD TECH3'},
                Time = 20,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Repair',
        PlatoonTemplate = 'T2EngineerRepairSorian',
        PlatoonAIPlan = 'RepairAI',
        Priority = 925,
        InstanceCount = 1,
        BuilderConditions = {
                { SBC, 'DamagedStructuresInArea', { 'LocationType', }},
            },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Reclaim Excess',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        PlatoonAIPlan = 'ReclaimAISorian',
        Priority = 1,
        InstanceCount = 50,
        BuilderConditions = {
                { SBC, 'ReclaimablesInArea', { 'LocationType', }},
            },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 120,
        },
        BuilderType = 'Any',
    },

    # =========================
    #     T2 ENGINEER ASSIST
    # =========================
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Energy',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 900,
        InstanceCount = 3,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'ENERGYPRODUCTION TECH2, ENERGYPRODUCTION TECH3' } },
            { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.5 }},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 0.5 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = true,
                BeingBuiltCategories = { 'ENERGYPRODUCTION TECH3', 'ENERGYPRODUCTION TECH2', },
                AssisteeType = 'Engineer',
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Factory',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 500,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'MOBILE' } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
        },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = true,
                BeingBuiltCategories = { 'MOBILE',},
                AssisteeType = 'Factory',
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Transport',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 875,
        BuilderConditions = {
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'TRANSPORTFOCUS' } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
        },
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = false,
                BeingBuiltCategories = {'TRANSPORTFOCUS'},
                AssisteeType = 'Factory',
                Time = 60,
            },
        },
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist Engineer',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 500,
        InstanceCount = 50,
        BuilderType = 'Any',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'ALLUNITS' } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
        },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = true,
                BeingBuiltCategories = { 'ALLUNITS' },
                AssisteeType = 'Engineer',
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineer Assist T3 Factory Upgrade',
        PlatoonTemplate = 'T2EngineerAssistSorian',
        Priority = 975,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENGINEER TECH1'}},
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'FACTORY TECH3' }},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 1.1 }},
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = true,
                BeingBuiltCategories = {'FACTORY TECH3'},
                AssisteeType = 'Factory',
                Time = 60,
            },
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3EngineerBuilders',
    BuildersType = 'EngineerBuilder',
    # =========================
    #     T3 ENGINEER BUILD
    # =========================
    Builder {
        BuilderName = 'Sorian T3 Engineer Reclaim',
        PlatoonTemplate = 'T3EngineerBuilderOnlySorian',
        PlatoonAIPlan = 'ReclaimAISorian',
        Priority = 0,
        InstanceCount = 3,
        BuilderConditions = {
				{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'TECH3 ENERGYPRODUCTION'}},
                { SBC, 'ReclaimablesInArea', { 'LocationType', }},
            },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Find Unfinished',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        PlatoonAIPlan = 'ManagerEngineerFindUnfinished',
        Priority = 1800,
        InstanceCount = 1,
        BuilderConditions = {
                { SBC, 'UnfinishedUnits', { 'LocationType', categories.STRUCTURE}},
            },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'EXPERIMENTAL, STRUCTURE STRATEGIC, STRUCTURE ECONOMIC, STRUCTURE'},
                Time = 20,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Find Low Shield',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        PlatoonAIPlan = 'ManagerEngineerFindLowShield',
        Priority = 1801,
        InstanceCount = 3,
        BuilderConditions = {
                { SBC, 'ShieldDamaged', { 'LocationType'}},
            },
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = {'STRUCTURE SHIELD TECH2, STRUCTURE SHIELD TECH3'},
                Time = 20,
            },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Repair',
        PlatoonTemplate = 'T3EngineerRepairSorian',
        PlatoonAIPlan = 'RepairAI',
        Priority = 925,
        InstanceCount = 1,
        BuilderConditions = {
                { SBC, 'DamagedStructuresInArea', { 'LocationType', }},
            },
        BuilderData = {
            LocationType = 'LocationType',
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Reclaim Excess',
        PlatoonTemplate = 'T3EngineerBuilderOnlySorian',
        PlatoonAIPlan = 'ReclaimAISorian',
        Priority = 1,
        InstanceCount = 50,
        BuilderConditions = {
                { SBC, 'ReclaimablesInArea', { 'LocationType', }},
            },
        BuilderData = {
            LocationType = 'LocationType',
            ReclaimTime = 120,
        },
        BuilderType = 'Any',
    },
    # =========================
    #     T3 ENGINEER ASSIST
    # =========================
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist T3 Energy Production',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 947, #950,
        InstanceCount = 3,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'ENERGYPRODUCTION TECH3' }},
            { SIBC, 'LessThanEconEfficiencyOverTime', { 2, 1.3}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.7, 0.5 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = true,
                BeingBuiltCategories = {'ENERGYPRODUCTION TECH3'},
                AssisteeType = 'Engineer',
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Transport',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'TRANSPORTFOCUS' } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.1 }},
        },
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = false,
                BeingBuiltCategories = {'TRANSPORTFOCUS'},
                AssisteeType = 'Factory',
                Time = 60,
            },
        },
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Mass Fab',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 800,
        InstanceCount = 1,
        BuilderConditions = {
                { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 1, 'ENGINEER TECH3' }},
                { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'MASSPRODUCTION TECH3' }},
                { SIBC, 'LessThanEconEfficiencyOverTime', { 0.9, 2.0}},
                { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.6, 1.1}},
                { IBC, 'BrainNotLowPowerMode', {} },
            },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = { 'MASSPRODUCTION TECH3', },
                AssisteeType = 'Engineer',
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Defenses',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 750,
        InstanceCount = 1,
        BuilderConditions = {
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 1, 'ENGINEER TECH3' }},
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'STRUCTURE DEFENSE' }},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = { 'STRUCTURE DEFENSE', },
                AssisteeType = 'Engineer',
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Shields',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 750,
        InstanceCount = 2,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'STRUCTURE SHIELD' }},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                BeingBuiltCategories = { 'STRUCTURE SHIELD', },
                AssisteeType = 'Engineer',
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Factory',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 700,
        InstanceCount = 20,
        BuilderConditions = {
            { UCBC, 'LocationFactoriesBuildingGreater', { 'LocationType', 0, 'MOBILE' }},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = true,
                AssisteeType = 'Factory',
                Time = 60,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Engineer',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 700,
        InstanceCount = 20,
        BuilderConditions = {
            { UCBC, 'LocationEngineersBuildingAssistanceGreater', { 'LocationType', 0, 'STRUCTURE, EXPERIMENTAL' }},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                PermanentAssist = true,
                BeingBuiltCategories = { 'SHIELD STRUCTURE', 'DEFENSE ANTIAIR', 'DEFENSE DIRECTFIRE', 'DEFENSE ANTINAVY', 'ENERGYPRODUCTION',
                                        'EXPERIMENTAL', 'ALLUNITS', },
                AssisteeType = 'Engineer',
                Time = 60,
            },
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineerMassBuilders - Naval',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 150 - Naval', #150
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 1000,
        InstanceCount = 4,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 100, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 250 - Naval',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 980,
        InstanceCount = 4,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 250, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },  
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 450 - Naval',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 970,
        InstanceCount = 4,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 450, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },       
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 1500 - Naval',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 850,
        InstanceCount = 1,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            #NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 T2Resource Engineer 250 - Naval',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 975,
        InstanceCount = 1,
        BuilderConditions = {
                { UCBC, 'EngineerLessAtLocation', { 'LocationType', 6, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 250, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 T2Resource Engineer 1500 - Naval',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 0, #875,
        InstanceCount = 1,
        BuilderConditions = {
                { UCBC, 'EngineerLessAtLocation', { 'LocationType', 6, 'ENGINEER TECH3'}},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T2Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 T3Resource Engineer 250 range - Naval',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 975,
        BuilderConditions = {
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 250, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 T3Resource Engineer 1500 range - Naval',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 0, #850,
        BuilderConditions = {
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T2Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Mass Fab Engineer - Naval',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 1200,
        BuilderConditions = {
                { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'MASSFABRICATION' } },
                { SIBC, 'LessThanEconEfficiencyOverTime', { 0.95, 2.0}},
                { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.4, 1.25}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3' } },
				{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'MASSPRODUCTION TECH3' } },
                { IBC, 'BrainNotLowPowerMode', {} },
            },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                BuildClose = true,
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineerMassBuilders - Rush',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 100 - Rush', #150
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 1000,
        InstanceCount = 4,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 100, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 250 - Rush',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 970,
        InstanceCount = 4,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 250, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },  
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 450 - Rush',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 910,
        InstanceCount = 4,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 450, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },       
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 1500 - Rush',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 850,
        InstanceCount = 1,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            #NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 T2Resource Engineer 250 - Rush',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 975,
        InstanceCount = 1,
        BuilderConditions = {
                { UCBC, 'EngineerLessAtLocation', { 'LocationType', 6, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 250, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 T2Resource Engineer 1500 - Rush',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 0, #875,
        InstanceCount = 1,
        BuilderConditions = {
                { UCBC, 'EngineerLessAtLocation', { 'LocationType', 6, 'ENGINEER TECH3'}},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T2Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 T3Resource Engineer 250 range - Rush',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 975,
        BuilderConditions = {
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 250, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 T3Resource Engineer 1500 range - Rush',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 0, #850,
        BuilderConditions = {
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T2Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Mass Fab Engineer - Rush',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 1200,
        BuilderConditions = {
                { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'MASSFABRICATION' } },
                { SIBC, 'LessThanEconEfficiencyOverTime', { 0.95, 2.0}},
                { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.4, 1.25}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3' } },
				{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'MASSPRODUCTION TECH3' } },
                { IBC, 'BrainNotLowPowerMode', {} },
            },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                BuildClose = true,
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineerMassBuildersHighPri',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 150', #150
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 1000,
        InstanceCount = 4,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 150, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 250',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 970,
        InstanceCount = 4,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 250, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },  
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 450',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 910,
        InstanceCount = 4,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 450, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },       
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 1500',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 850,
        InstanceCount = 1,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            #NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 T2Resource Engineer 250',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 975,
        InstanceCount = 1,
        BuilderConditions = {
                { UCBC, 'EngineerLessAtLocation', { 'LocationType', 6, 'ENGINEER TECH3' }},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 250, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 T2Resource Engineer 1500',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 0, #875,
        InstanceCount = 1,
        BuilderConditions = {
                { UCBC, 'EngineerLessAtLocation', { 'LocationType', 6, 'ENGINEER TECH3'}},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T2Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 T3Resource Engineer 250 range',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 975,
        BuilderConditions = {
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 250, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 T3Resource Engineer 1500 range',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 0, #850,
        BuilderConditions = {
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T2Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Mass Fab Engineer',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 1200,
        BuilderConditions = {
                { UCBC, 'HaveLessThanUnitsInCategoryBeingBuilt', { 1, 'MASSFABRICATION' } },
                { SIBC, 'LessThanEconEfficiencyOverTime', { 0.95, 2.0}},
                { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.4, 1.25}},
                { SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3' } },
				{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'MASSPRODUCTION TECH3' } },
                { IBC, 'BrainNotLowPowerMode', {} },
            },
        BuilderType = 'Any',
        BuilderData = {
            NumAssistees = 2,
            Construction = {
                BuildClose = true,
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildStructures = {
                    'T3MassCreation',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineerMassBuildersLowerPri',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 150 Low',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 1000,
        InstanceCount = 2,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 4, 'ENGINEER TECH2, ENGINEER TECH3'}},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 150, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 350 Low',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 700,
        InstanceCount = 2,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 4, 'ENGINEER TECH2, ENGINEER TECH3'}},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 350, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1ResourceEngineer 1500 Low',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 650,
        InstanceCount = 2,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 4, 'ENGINEER TECH2, ENGINEER TECH3'}},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            #NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2ResourceEngineer 150 Low',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 1000,
        InstanceCount = 2,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 4, 'ENGINEER TECH3'}},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 150, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            NeedGuard = true,
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },    
    Builder {
        BuilderName = 'Sorian T2 T2Resource Engineer 350 Low',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 850,
        InstanceCount = 1,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 4, 'ENGINEER TECH3'}},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 350, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 T2Resource Engineer 1500 Low',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 750,
        InstanceCount = 1,
        BuilderConditions = {
                #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 4, 'ENGINEER TECH3'}},
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 T3Resource Engineer 350 range Low',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 850,
        BuilderConditions = {
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 350, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 T3Resource Engineer 1500 range Low',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 750,
        BuilderConditions = {
                { MABC, 'CanBuildOnMassLessThanDistance', { 'LocationType', 1500, -500, 1, 0, 'AntiSurface', 1 }},
            },
        BuilderType = 'Any',
        BuilderData = {
            DesiresAssist = false,
            Construction = {
                BuildStructures = {
                    'T1Resource',
                }
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineerEnergyBuilders',
    BuildersType = 'EngineerBuilder',
    # =====================================
    #     T2 Engineer Resource Builders
    # =====================================
    Builder {
        BuilderName = 'Sorian T1 Power Engineer',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
            #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH2, ENGINEER TECH3' } },
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH2, ENERGYPRODUCTION TECH3'}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 0.5 }},
            { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.4 }},
			#{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'HYDROCARBON'}},
        },
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                #AdjacencyCategory = 'FACTORY',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1 Power Engineer No Hydro',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 0, #1000,
        BuilderConditions = {
            #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'ENGINEER TECH2, ENGINEER TECH3' } },
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH2, ENERGYPRODUCTION TECH3'}},
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 0.5 }},
            { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.4 }},
			{ SBC, 'NoMarkerLessThanDistance',  { 'Hydrocarbon', 200}},
        },
        InstanceCount = 2,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                #AdjacencyCategory = 'FACTORY',
                BuildStructures = {
                    'T1EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Power Engineer',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
            #{ UCBC, 'EngineerLessAtLocation', { 'LocationType', 3, 'TECH3 ENGINEER' }},
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3'}},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION TECH2' } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.1 }},
            { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.6 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T2EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Power Engineer',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 1000,
        BuilderType = 'Any',
        BuilderConditions = {
		{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION TECH3' } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.1 }},
			{ SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.6 }},
        },
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Power Engineer - init',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 1500,
        BuilderConditions = {
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH2'}},
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.1 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T2EnergyProduction',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Power Engineer - init',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 1500,
        BuilderType = 'Any',
        BuilderConditions = {
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ENERGYPRODUCTION TECH3'}},
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.1 }},
        },
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T3EnergyProduction',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineerEnergyBuildersExpansions',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T1 Power Engineer Expansions',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
                { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, 'ENERGYPRODUCTION' } },
                { UCBC, 'EngineerLessAtLocation', { 'LocationType', 1, 'ENGINEER TECH2, ENGINEER TECH3' } },
                { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.2}},
            },
        InstanceCount = 1,
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                    'T1EnergyProduction',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Power Engineer Expansions',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
                { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'ENERGYPRODUCTION TECH2' } },
                { UCBC, 'EngineerLessAtLocation', { 'LocationType', 1, 'TECH3 ENGINEER' }},
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.1 }},
                { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.2}},
            },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T2EnergyProduction',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Power Engineer Expansions',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 1000,
        BuilderType = 'Any',
        BuilderConditions = {
                { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'ENERGYPRODUCTION TECH3' } },
				{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.5, 0.1 }},
                { SIBC, 'LessThanEconEfficiencyOverTime', { 2.0, 1.2}},
            },
        BuilderData = {
            Construction = {
                BuildStructures = {
                   'T3EnergyProduction',
                },
                Location = 'LocationType',
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineeringSupportBuilder',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T2 Engineering Support UEF',
        PlatoonTemplate = 'UEFT2EngineerBuilderSorian',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'ENGINEERSTATION' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 3, 'ENGINEER TECH2, ENGINEER TECH3' } },
            { SIBC, 'GreaterThanEconIncome',  { 10, 100}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildClose = true,
                FactionIndex = 1,
                BuildStructures = {
                    'T2EngineerSupport',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineering Support UEF',
        PlatoonTemplate = 'UEFT3EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, 'ENGINEERSTATION' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 3, 'ENGINEER TECH2, ENGINEER TECH3' } },
            { SIBC, 'GreaterThanEconIncome',  { 10, 100}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildClose = true,
                FactionIndex = 1,
                BuildStructures = {
                    'T2EngineerSupport',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T2 Engineering Support Cybran',
        PlatoonTemplate = 'CybranT2EngineerBuilderSorian',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 2, 'ENGINEERSTATION' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 3, 'ENGINEER TECH2, ENGINEER TECH3' } },
            { SIBC, 'GreaterThanEconIncome',  { 10, 100}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildClose = true,
                FactionIndex = 3,
                BuildStructures = {
                    'T2EngineerSupport',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineering Support Cybran',
        PlatoonTemplate = 'CybranT3EngineerBuilderSorian',
        Priority = 950,
        BuilderConditions = {
            { UCBC, 'UnitsLessAtLocation', { 'LocationType', 4, 'ENGINEERSTATION' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 } },
            { UCBC, 'EngineerGreaterAtLocation', { 'LocationType', 3, 'ENGINEER TECH2, ENGINEER TECH3' } },
            { SIBC, 'GreaterThanEconIncome',  { 10, 100}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                AdjacencyCategory = 'ENERGYPRODUCTION',
                BuildClose = true,
                FactionIndex = 3,
                BuildStructures = {
                    'T2EngineerSupport',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineeringUpgrades',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian T2 Engineeering Support Upgrade 1',
        PlatoonTemplate = 'T2Engineering1',
        Priority = 5,
        InstanceCount = 1,
        BuilderConditions = {
            { SIBC, 'GreaterThanEconIncome',  { 10, 100}},
            { MIBC, 'FactionIndex', {3, 3}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T2 Engineeering Support Upgrade 2',
        PlatoonTemplate = 'T2Engineering2',
        Priority = 5,
        InstanceCount = 1,
        BuilderConditions = {
            { SIBC, 'GreaterThanEconIncome',  { 10, 100}},
            { MIBC, 'FactionIndex', {3, 3}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 } },
        },
        BuilderType = 'Any',
    },
    Builder {
        BuilderName = 'Sorian T2 Engineeering Support Upgrade',
        PlatoonTemplate = 'T2Engineering',
        Priority = 5,
        InstanceCount = 1,
        BuilderConditions = {
            { SIBC, 'GreaterThanEconIncome',  { 10, 100}},
            { MIBC, 'FactionIndex', {1, 1}},
            { IBC, 'BrainNotLowPowerMode', {} },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 } },
        },
        BuilderType = 'Any',
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianMassFabPause',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Mass Fabricator Pause',
        PlatoonTemplate = 'MassFabsSorian',
        Priority = 300,
        InstanceCount = 3,
        BuildConditions = {
                { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.MASSFABRICATION}},
                { EBC, 'LessThanEconStorageRatio',  { 1.1, 0.6}},
            },
        BuilderType = 'Any',
		FormRadius = 10000,
    },
}