#***************************************************************************
#*
#**  File     :  /lua/ai/SorianStrategyPlatoonBuilders.lua
#**
#**  Summary  : Default Naval structure builders for skirmish
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
local PlatoonFile = '/lua/platoon.lua'
local SBC = '/lua/editor/SorianBuildConditions.lua'
local SIBC = '/lua/editor/SorianInstantBuildConditions.lua'


BuilderGroup {
    BuilderGroupName = 'SorianT1BomberHighPrio',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T1 Air Bomber - High Prio',
        PlatoonTemplate = 'T1AirBomber',
        Priority = 0.1,
		ActivePriority = 549,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 2, 'FACTORY AIR TECH3' }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT2BomberHighPrio',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T2 Air Bomber - High Prio',
        PlatoonTemplate = 'T2BomberSorian',
        Priority = 0.1,
		ActivePriority = 649,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH2 } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 2, 'FACTORY AIR TECH3' }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH3' }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3BomberHighPrio',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T3 Air Bomber - High Prio',
        PlatoonTemplate = 'T3AirBomber',
        Priority = 0.1,
		ActivePriority = 754,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3BomberSpecialHighPrio',
    BuildersType = 'FactoryBuilder',
    Builder {
        BuilderName = 'Sorian T3 Air Bomber Special - High Prio',
        PlatoonTemplate = 'T3AirBomberSpecialSorian',
        Priority = 0.1,
		ActivePriority = 754,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH3 } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT1GunshipHighPrio',
    BuildersType = 'FactoryBuilder',
	Builder {
        BuilderName = 'Sorian T1Gunship - High Prio',
        PlatoonTemplate = 'T1Gunship',
        Priority = 0.1,
		ActivePriority = 549,
        BuilderType = 'Air',
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, categories.FACTORY * categories.AIR * categories.TECH1 } },
            { SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.05 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 2, 'FACTORY AIR TECH3' }},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 2, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianBomberLarge',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian Bomber Attack - Large',
        PlatoonTemplate = 'BomberAttackSorian',
		PlatoonAddBehaviors = { 'AirUnitRefitSorian' },
		PlatoonAddPlans = { 'AirIntelToggle' },
        Priority = 0.1,
		ActivePriority = 995,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'COMMAND',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 9, 'AIR MOBILE BOMBER' } },
			{ SBC, 'NoRushTimeCheck', { 0 }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianBomberBig',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian Bomber Attack - Big',
        PlatoonTemplate = 'BomberAttackSorianBig',
		PlatoonAddBehaviors = { 'AirUnitRefitSorian' },
		PlatoonAddPlans = { 'AirIntelToggle' },
        Priority = 0.1,
		ActivePriority = 995,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
                'COMMAND',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 19, 'AIR MOBILE BOMBER' } },
			{ SBC, 'NoRushTimeCheck', { 0 }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianGunShipLarge',
    BuildersType = 'PlatoonFormBuilder',
    Builder {
        BuilderName = 'Sorian GunShip Attack - Large',
        PlatoonTemplate = 'GunshipSFSorian',
		PlatoonAddBehaviors = { 'AirUnitRefitSorian' },
		PlatoonAddPlans = { 'AirIntelToggle' },
        Priority = 0.1,
		ActivePriority = 995,
        InstanceCount = 5,
        BuilderType = 'Any',
        BuilderData = {
			SearchRadius = 6000,
            PrioritizedCategories = {
                'COMMAND',
                'ENERGYPRODUCTION DRAGBUILD',
                'MASSFABRICATION',
                'MASSEXTRACTION',
                'SHIELD',
                'ANTIAIR STRUCTURE',
                'DEFENSE STRUCTURE',
                'STRUCTURE',
                'MOBILE ANTIAIR',
                'ALLUNITS',
            },
        },
        BuilderConditions = {
			{ UCBC, 'PoolGreaterAtLocation', { 'LocationType', 9, 'AIR MOBILE GROUNDATTACK' } },
			{ SBC, 'NoRushTimeCheck', { 0 }},
        },
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3ArtyBuildersHighPrio',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T3 Arty Engineer - High Prio',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 3,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T3Artillery',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Build Arty - High Prio',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 3,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
				AssistUntilFinished = true,
                AssistRange = 150,
                BeingBuiltCategories = {'STRUCTURE ARTILLERY TECH3'},
                Time = 120,
            },
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3FBBuildersHighPrio',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T3 Expansion Area Firebase Engineer - Cybran - HP',
        PlatoonTemplate = 'CybranT3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 1,
        BuilderConditions = {
            { SBC, 'CanBuildFirebase', { 'LocationType', 700, 'Expansion Area', -10000, 5, 1, 'AntiSurface', 1, 'STRUCTURE ARTILLERY TECH3', 20} },
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = ExBaseTmpl,
                FireBase = true,
                FireBaseRange = 700,
                NearMarkerType = 'Expansion Area',
                LocationType = 'LocationType',
                ThreatMin = -10000,
                ThreatMax = 5,
                ThreatRings = 1,
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRUCTURE ARTILLERY TECH3',
                MarkerRadius = 20,
                BuildStructures = {
					'T2RadarJammer',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2Radar',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2StrategicMissileDefense',
					'T2ShieldDefense',
					'T2EngineerSupport',
					'T2ShieldDefense',
					'T3Artillery',
                    'T2Artillery',
                    'T2StrategicMissile',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Expansion Area Firebase Engineer - Aeon - HP',
        PlatoonTemplate = 'AeonT3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 1,
        BuilderConditions = {
            { SBC, 'CanBuildFirebase', { 'LocationType', 900, 'Expansion Area', -10000, 5, 1, 'AntiSurface', 1, 'STRUCTURE ARTILLERY TECH3', 20} },
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = ExBaseTmpl,
                FireBase = true,
                FireBaseRange = 900,
                NearMarkerType = 'Expansion Area',
                LocationType = 'LocationType',
                ThreatMin = -10000,
                ThreatMax = 5,
                ThreatRings = 1,
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRUCTURE ARTILLERY TECH3',
                MarkerRadius = 20,
                BuildStructures = {
					'T2RadarJammer',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2Radar',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2StrategicMissileDefense',
					'T3ShieldDefense',
					'T3ShieldDefense',
					'T3Artillery',
                    'T2Artillery',
                    'T2StrategicMissile',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Expansion Area Firebase Engineer - UEF - HP',
        PlatoonTemplate = 'UEFT3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 1,
        BuilderConditions = {
            { SBC, 'CanBuildFirebase', { 'LocationType', 750, 'Expansion Area', -10000, 5, 1, 'AntiSurface', 1, 'STRUCTURE ARTILLERY TECH3', 20} },
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = ExBaseTmpl,
                FireBase = true,
                FireBaseRange = 750,
                NearMarkerType = 'Expansion Area',
                LocationType = 'LocationType',
                ThreatMin = -10000,
                ThreatMax = 5,
                ThreatRings = 1,
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRUCTURE ARTILLERY TECH3',
                MarkerRadius = 20,
                BuildStructures = {
					'T2RadarJammer',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2Radar',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2StrategicMissileDefense',
					'T3ShieldDefense',
					'T2EngineerSupport',
					'T3ShieldDefense',
					'T3Artillery',
                    'T2Artillery',
                    'T2StrategicMissile',
				}
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Expansion Area Firebase Engineer - Seraphim - HP',
        PlatoonTemplate = 'SeraphimT3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 1,
        BuilderConditions = {
            { SBC, 'CanBuildFirebase', { 'LocationType', 825, 'Expansion Area', -10000, 5, 1, 'AntiSurface', 1, 'STRUCTURE ARTILLERY TECH3', 20} },
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = ExBaseTmpl,
                FireBase = true,
                FireBaseRange = 825,
                NearMarkerType = 'Expansion Area',
                LocationType = 'LocationType',
                ThreatMin = -10000,
                ThreatMax = 5,
                ThreatRings = 1,
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRUCTURE ARTILLERY TECH3',
                MarkerRadius = 20,
                BuildStructures = {
					'T2RadarJammer',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2Radar',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2StrategicMissileDefense',
					'T3ShieldDefense',
					'T3ShieldDefense',
					'T3Artillery',
                    'T2Artillery',
                    'T2StrategicMissile',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Expansion Area Firebase Engineer - Cybran - DP - HP',
        PlatoonTemplate = 'CybranT3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 1,
        BuilderConditions = {
            { SBC, 'CanBuildFirebase', { 'LocationType', 700, 'Defensive Point', -10000, 5, 1, 'AntiSurface', 1, 'STRUCTURE ARTILLERY TECH3', 20} },
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = ExBaseTmpl,
                FireBase = true,
                FireBaseRange = 700,
                NearMarkerType = 'Defensive Point',
                LocationType = 'LocationType',
                ThreatMin = -10000,
                ThreatMax = 5,
                ThreatRings = 1,
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRUCTURE ARTILLERY TECH3',
                MarkerRadius = 20,
                BuildStructures = {
					'T2RadarJammer',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2Radar',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2StrategicMissileDefense',
					'T3ShieldDefense',
					'T3ShieldDefense',
					'T3Artillery',
                    'T2Artillery',
                    'T2StrategicMissile',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Expansion Area Firebase Engineer - Aeon - DP - HP',
        PlatoonTemplate = 'AeonT3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 1,
        BuilderConditions = {
            { SBC, 'CanBuildFirebase', { 'LocationType', 900, 'Defensive Point', -10000, 5, 1, 'AntiSurface', 1, 'STRUCTURE ARTILLERY TECH3', 20} },
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = ExBaseTmpl,
                FireBase = true,
                FireBaseRange = 900,
                NearMarkerType = 'Defensive Point',
                LocationType = 'LocationType',
                ThreatMin = -10000,
                ThreatMax = 5,
                ThreatRings = 1,
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRUCTURE ARTILLERY TECH3',
                MarkerRadius = 20,
                BuildStructures = {
					'T2RadarJammer',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2Radar',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2StrategicMissileDefense',
					'T3ShieldDefense',
					'T3ShieldDefense',
					'T3Artillery',
                    'T2Artillery',
                    'T2StrategicMissile',
                }
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Expansion Area Firebase Engineer - UEF - DP - HP',
        PlatoonTemplate = 'UEFT3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 1,
        BuilderConditions = {
            { SBC, 'CanBuildFirebase', { 'LocationType', 750, 'Defensive Point', -10000, 5, 1, 'AntiSurface', 1, 'STRUCTURE ARTILLERY TECH3', 20} },
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = ExBaseTmpl,
                FireBase = true,
                FireBaseRange = 750,
                NearMarkerType = 'Defensive Point',
                LocationType = 'LocationType',
                ThreatMin = -10000,
                ThreatMax = 5,
                ThreatRings = 1,
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRUCTURE ARTILLERY TECH3',
                MarkerRadius = 20,
                BuildStructures = {
					'T2RadarJammer',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2Radar',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2StrategicMissileDefense',
					'T3ShieldDefense',
					'T3ShieldDefense',
					'T3Artillery',
                    'T2Artillery',
                    'T2StrategicMissile',
				}
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Expansion Area Firebase Engineer - Seraphim - DP - HP',
        PlatoonTemplate = 'SeraphimT3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 1,
        BuilderConditions = {
            { SBC, 'CanBuildFirebase', { 'LocationType', 825, 'Defensive Point', -10000, 5, 1, 'AntiSurface', 1, 'STRUCTURE ARTILLERY TECH3', 20} },
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = ExBaseTmpl,
                FireBase = true,
                FireBaseRange = 825,
                NearMarkerType = 'Defensive Point',
                LocationType = 'LocationType',
                ThreatMin = -10000,
                ThreatMax = 5,
                ThreatRings = 1,
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRUCTURE ARTILLERY TECH3',
                MarkerRadius = 20,
                BuildStructures = {
					'T2RadarJammer',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2Radar',
                    'T3AADefense',
                    'T2GroundDefense',
					'T2StrategicMissileDefense',
					'T3ShieldDefense',
					'T3ShieldDefense',
					'T3Artillery',
                    'T2Artillery',
                    'T2StrategicMissile',
                }
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT2FirebaseBuildersHighPrio',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T2 Firebase Engineer - High Prio',
        PlatoonTemplate = 'T2EngineerBuilderSorian',
		Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 1,
        BuilderConditions = {
			{ IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			RequireTransport = true,
            Construction = {
                BuildClose = false,
                BaseTemplate = ExBaseTmpl,
                FireBase = true,
                FireBaseRange = 256,
                NearMarkerType = 'Expansion Area',
                LocationType = 'LocationType',
                ThreatMin = -1000,
                ThreatMax = 5,
                ThreatRings = 1,
                ThreatType = 'AntiSurface',
                MarkerUnitCount = 1,
                MarkerUnitCategory = 'STRATEGIC',
                MarkerRadius = 20,
                BuildStructures = {
                    'T2StrategicMissile',
                    'T2AADefense',
                    'T2GroundDefense',
					'T2Radar',
                    'T2Artillery',
                    'T2StrategicMissileDefense',
                    'T2AADefense',
                    'T2GroundDefense',
                    'T2StrategicMissile',
                    'T2Artillery',       
					'T2ShieldDefense',
                }
            }
        }
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianNukeBuildersHighPrio',
    BuildersType = 'EngineerBuilder',
    Builder {
        BuilderName = 'Sorian T3 Nuke Engineer - High Prio',
        PlatoonTemplate = 'T3EngineerBuilderSorian',
        Priority = 0.1,
        ActivePriority = 980,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
			NumAssistees = 3,
            Construction = {
                BuildClose = true,
                BuildStructures = {
                    'T3StrategicMissile',
                },
                Location = 'LocationType',
            }
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Build Nuke - High Prio',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 3,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'Engineer',
				AssistUntilFinished = true,
                AssistRange = 150,
                BeingBuiltCategories = {'STRUCTURE NUKE'},
                Time = 120,
            },
        }
    },
    Builder {
        BuilderName = 'Sorian T3 Engineer Assist Build Nuke Missile - High Prio',
        PlatoonTemplate = 'T3EngineerAssistSorian',
        Priority = 0.1,
        ActivePriority = 980,
        InstanceCount = 3,
        BuilderConditions = {
            { IBC, 'BrainNotLowPowerMode', {} },
        },
        BuilderType = 'Any',
        BuilderData = {
            Assist = {
                AssistLocation = 'LocationType',
                AssisteeType = 'NonUnitBuildingStructure',
				AssistUntilFinished = true,
                AssistRange = 150,
                AssisteeCategory = 'STRUCTURE NUKE',
                Time = 120,
            },
        }
    },
}