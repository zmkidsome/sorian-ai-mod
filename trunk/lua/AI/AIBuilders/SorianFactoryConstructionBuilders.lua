#***************************************************************************
#*
#**  File     :  /lua/ai/SorianFactoryConstructionBuilders.lua
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

local ExtractorToFactoryRatio = 2.2

BuilderGroup {
    BuilderGroupName = 'SorianLandInitialFactoryConstruction',
    BuildersType = 'EngineerBuilder',
    # =======================================
    #     Land Factory Builders - Initial
    # =======================================
    Builder {        
        BuilderName = 'Sorian T1 Land Factory Builder - Initial',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 1000,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                Location = 'LocationType',
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineerFactoryConstructionLandHigherPriority',
    BuildersType = 'EngineerBuilder',
    Builder {        
        BuilderName = 'SorianT2 Land Factory Builder Higher Pri',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
        Priority = 750,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 1, 'ENGINEER TECH3' } },
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, 'LAND' } },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
                },
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
            }
        }
    },
    Builder {        
        BuilderName = 'SorianT3 Land Factory Builder Higher Pri',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 750,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, 'LAND' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
                },
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
            }
        }
    },
    Builder {
        BuilderName = 'SorianCDR T1 Land Factory Higher Pri - Init',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 905,
        BuilderConditions = {                        
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 3, 'LAND FACTORY'}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1 Land Factory Higher Pri - Init',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 1001,
        BuilderConditions = {                        
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 3, 'LAND FACTORY'}},
			{ MIBC, 'GreaterThanGameTime', { 165 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1 Land Factory Higher Pri',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 1001,
        BuilderConditions = {                        
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'LAND FACTORY'}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'AIR FACTORY'}},
			{ MIBC, 'GreaterThanGameTime', { 165 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T1 Air Factory Higher Pri',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 1001,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Air' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'LAND FACTORY'}},
			{ MIBC, 'GreaterThanGameTime', { 165 } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'SorianCDR T1 Land Factory Higher Pri',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 905,
        BuilderConditions = {                        
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'LAND FACTORY'}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'AIR FACTORY'}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    Builder {
        BuilderName = 'SorianCDR T1 Air Factory Higher Pri',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 905,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Air' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 2, 'LAND FACTORY'}},
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineerFactoryConstruction Balance',
    BuildersType = 'EngineerBuilder',
    # =============================
    #     Land Factory Builders
    # =============================
    Builder {        
        BuilderName = 'Sorian T1 Land Factory Builder Balance',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 905,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
            #{ UCBC, 'FactoryRatioLessAtLocation', { 'LocationType', 'LAND', 'AIR' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
                },
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian CDR T1 Land Factory Balance',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 905,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
            #{ UCBC, 'FactoryRatioLessAtLocation', { 'LocationType', 'LAND', 'AIR' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    
    # ============================
    #     Air Factory Builders
    # ============================
    Builder {        
        BuilderName = 'Sorian T1 Air Factory Builder Balance',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 906,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Air' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
            { UCBC, 'FactoryRatioLessAtLocation', { 'LocationType', 'AIR', 'LAND' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1AirFactory',
                },
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
            }
        }
    },

    Builder {
        BuilderName = 'Sorian CDR T1 Air Factory Balance',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 906,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Air' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
            { UCBC, 'FactoryRatioLessAtLocation', { 'LocationType', 'AIR', 'LAND' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianEngineerFactoryConstruction',
    BuildersType = 'EngineerBuilder',
    # =============================
    #     Land Factory Builders
    # =============================
    Builder {        
        BuilderName = 'Sorian T1 Land Factory Builder',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 900,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1LandFactory',
                },
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
            }
        },
    },
    Builder {
        BuilderName = 'Sorian CDR T1 Land Factory',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 900,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Land' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1LandFactory',
                },
            }
        }
    },
    
    # ============================
    #     Air Factory Builders
    # ============================
    Builder {        
        BuilderName = 'Sorian T1 Air Factory Builder',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 900,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Air' } },
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 1.0, 1.1} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1AirFactory',
                },
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
            }
        }
    },

    Builder {
        BuilderName = 'Sorian CDR T1 Air Factory',
        PlatoonTemplate = 'CommanderBuilderSorian',
        Priority = 900,
        BuilderConditions = {
            { EBC, 'GreaterThanEconEfficiencyOverTime', { 0.8, 1.1} },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Air' } },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T1AirFactory',
                },
            }
        }
    },

    # ====================================== #
    #     Air Factories + Transport Need
    # ====================================== #
    Builder {
        BuilderName = 'Sorian T1 Air Factory Transport Needed',
        PlatoonTemplate = 'EngineerBuilderSorian',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'EngineerLessAtLocation', { 'LocationType', 1, 'ENGINEER TECH3, ENGINEER TECH2' } },
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Air' } },
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 3, 'AIR FACTORY' } },
            { MIBC, 'ArmyNeedsTransports', {} },
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { UCBC, 'HaveUnitRatio', { ExtractorToFactoryRatio, 'MASSEXTRACTION', '>=','FACTORY' } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T1AirFactory',
                },
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
            }
        }
    },

    # =============================
    #     Quantum Gate Builders
    # =============================
    Builder {
        BuilderName = 'Sorian T3 Gate Engineer',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 900,
        BuilderConditions = {
            { UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION TECH3' }},
            { UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'GATE TECH3 STRUCTURE' }},
            { UCBC, 'FactoryCapCheck', { 'LocationType', 'Gate' } },
            { IBC, 'BrainNotLowPowerMode', {} },
            { UCBC, 'UnitCapCheckLess', { .8 } },
            { EBC, 'MassToFactoryRatioBaseCheck', { 'LocationType' } },
        },
        BuilderType = 'Any',
        BuilderData = {
            Construction = {
                BuildStructures = {
                    'T3QuantumGate',
                },
                Location = 'LocationType',
                AdjacencyCategory = 'ENERGYPRODUCTION',
            }
        }
    },
}

