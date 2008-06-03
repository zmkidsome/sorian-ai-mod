#***************************************************************************
#*
#**  File     :  /lua/ai/SorianStrategyBuilders.lua
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
    BuilderGroupName = 'SorianBigAirGroup',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian Big Air Strategy',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ SBC, 'GreaterThanThreatAtEnemyBase', { 'AntiAir', 55 }},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 1, 'FACTORY AIR TECH3' }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 5, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER, 'Enemy'}},
        },
        BuilderType = 'Any',		
        RemoveBuilders = {
			FactoryManager = {
				'Sorian T1 Air Bomber',
				'Sorian T1 Air Bomber - Stomp Enemy',
				'Sorian T1Gunship',
				'Sorian T1 Air Bomber 2',
				'Sorian T1Gunship2',
				'Sorian T2 Air Gunship',
				'Sorian T2 Air Gunship - Anti Navy',
				'Sorian T2 Air Gunship - Stomp Enemy',
				'Sorian T2FighterBomber',
				'Sorian T2 Air Gunship2',
				'Sorian T2FighterBomber2',
				'Sorian T3 Air Gunship',
				'Sorian T3 Air Gunship - Anti Navy',
				'Sorian T3 Air Bomber',
				'Sorian T3 Air Bomber - Stomp Enemy',
				'Sorian T3 Air Gunship2',
				'Sorian T3 Air Bomber2',
			},
			PlatoonFormManager = {
				'Sorian BomberAttackT1Frequent',
				'Sorian BomberAttackT1Frequent - Anti-Land',
				'Sorian BomberAttackT1Frequent - Anti-Resource',
				'Sorian BomberAttackT2Frequent',
				'Sorian BomberAttackT2Frequent - Anti-Land',
				'Sorian BomberAttackT2Frequent - Anti-Resource',
				'Sorian BomberAttackT3Frequent',
				'Sorian BomberAttackT3Frequent - Anti-Land',
				'Sorian BomberAttackT3Frequent - Anti-Resource',
				'Sorian T1 Bomber Attack Weak Enemy Response',
				'Sorian BomberAttack Mass Hunter',
			}
		},
		AddBuilders = {
			FactoryManager = {
				'Sorian T2 Air Bomber - High Prio',
				'Sorian T3 Air Bomber Special - High Prio',
			},
			PlatoonFormManager = {
				'Sorian Bomber Attack - Big',
			}
		}
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianJesterRush',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian Jester Rush Strategy',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ MIBC, 'FactionIndex', {3, 3}},
			{ UCBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'FACTORY AIR' }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 1, categories.AIR * (categories.FACTORY + categories.MOBILE), 'Enemy'}},
        },
        BuilderType = 'Any',		
        RemoveBuilders = {
			FactoryManager = {
				'Sorian T1 Air Bomber',
				'Sorian T1 Air Bomber - Stomp Enemy',
				'Sorian T1Gunship',
				'Sorian T1 Air Fighter',
				'Sorian T1 Air Bomber 2',
				'Sorian T1Gunship2',
				'Sorian T1 Interceptors',
				'Sorian T1 Interceptors - Enemy Air',
				'Sorian T1 Interceptors - Enemy Air Extra',
				'Sorian T1 Interceptors - Enemy Air Extra 2',
				'Sorian T2 Air Gunship',
				'Sorian T2 Air Gunship - Anti Navy',
				'Sorian T2 Air Gunship - Stomp Enemy',
				'Sorian T2FighterBomber',
				'Sorian T1 Air Fighter - T2',
				'Sorian T2 Air Gunship2',
				'Sorian T2FighterBomber2',
				'Sorian T2AntiAirPlanes Initial Higher Pri',
				'Sorian T2AntiAirPlanes - Enemy Air',
				'Sorian T2AntiAirPlanes - Enemy Air Extra',
				'Sorian T2AntiAirPlanes - Enemy Air Extra 2',
				'Sorian T3 Air Gunship',
				'Sorian T3 Air Gunship - Anti Navy',
				'Sorian T3 Air Bomber',
				'Sorian T3 Air Bomber - Stomp Enemy',
				'Sorian T3 Air Gunship2',
				'Sorian T3 Air Bomber2',
			},
			PlatoonFormManager = {
				'Sorian BomberAttackT1Frequent',
				'Sorian BomberAttackT1Frequent - Anti-Land',
				'Sorian BomberAttackT1Frequent - Anti-Resource',
				'Sorian BomberAttackT2Frequent',
				'Sorian BomberAttackT2Frequent - Anti-Land',
				'Sorian BomberAttackT2Frequent - Anti-Resource',
				'Sorian BomberAttackT3Frequent',
				'Sorian BomberAttackT3Frequent - Anti-Land',
				'Sorian BomberAttackT3Frequent - Anti-Resource',
				'Sorian T1 Bomber Attack Weak Enemy Response',
				'Sorian BomberAttack Mass Hunter',
			}
		},
		AddBuilders = {
			FactoryManager = {
				'Sorian T1Gunship - High Prio',
			},
			PlatoonFormManager = {
				'Sorian GunShip Attack - Large',
			}
		}
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3ArtyRush',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian T3 Arty Rush Strategy',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 5, 'ENGINEER TECH3' }},
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ARTILLERY STRUCTURE TECH3' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 } },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 6, categories.SHIELD * categories.TECH3 * categories.STRUCTURE, 'Enemy'}},
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2}},
			{ EBC, 'GreaterThanEconIncome',  { 100, 3000}},
			{ SBC, 'MapGreaterThan', { 500, 500 }},
			{ SBC, 'EnemyInT3ArtilleryRange', { 'LocationType', true } },
        },
        BuilderType = 'Any',		
        RemoveBuilders = {},
		AddBuilders = {
			EngineerManager = {
				'Sorian T3 Arty Engineer - High Prio',
				'Sorian T3 Engineer Assist Build Arty - High Prio',
			}
		}
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3FBRush',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian T3 FB Rush Strategy',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 5, 'ENGINEER TECH3' }},
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ARTILLERY STRUCTURE TECH3' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 } },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 6, categories.SHIELD * categories.TECH3 * categories.STRUCTURE, 'Enemy'}},
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2}},
			{ EBC, 'GreaterThanEconIncome',  { 100, 3000}},
			{ SBC, 'MapGreaterThan', { 500, 500 }},
			{ SBC, 'EnemyInT3ArtilleryRange', { 'LocationType', false } },
        },
        BuilderType = 'Any',		
        RemoveBuilders = {},
		AddBuilders = {
			EngineerManager = {
				'Sorian T3 Expansion Area Firebase Engineer - Cybran - HP',
				'Sorian T3 Expansion Area Firebase Engineer - Aeon - HP',
				'Sorian T3 Expansion Area Firebase Engineer - UEF - HP',
				'Sorian T3 Expansion Area Firebase Engineer - Seraphim - HP',
				'Sorian T3 Expansion Area Firebase Engineer - Cybran - DP - HP',
				'Sorian T3 Expansion Area Firebase Engineer - Aeon - DP - HP',
				'Sorian T3 Expansion Area Firebase Engineer - UEF - DP - HP',
				'Sorian T3 Expansion Area Firebase Engineer - Seraphim - DP - HP',
			}
		}
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianNukeRush',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian Nuke Rush Strategy',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 5, 'ENGINEER TECH3' }},
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'NUKE SILO STRUCTURE TECH3' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 } },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 1, categories.ANTIMISSILE * categories.TECH3 * categories.STRUCTURE, 'Enemy'}},
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2}},
			{ EBC, 'GreaterThanEconIncome',  { 100, 3000}},
			{ SBC, 'MapGreaterThan', { 500, 500 }},
        },
        BuilderType = 'Any',		
        RemoveBuilders = {},
		AddBuilders = {
			EngineerManager = {
				'Sorian T3 Nuke Engineer - High Prio',
				'Sorian T3 Engineer Assist Build Nuke - High Prio',
				'Sorian T3 Engineer Assist Build Nuke Missile - High Prio',
			}
		}
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT2ACUSnipe',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian T2 ACU Snipe Strategy',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'ENGINEER TECH2' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH2 } },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 6, categories.ANTIMISSILE * categories.TECH2 * categories.STRUCTURE, 'Enemy'}},
			{ MABC, 'CanBuildFirebase', { 'LocationType', 256, 'Expansion Area', -1000, 5, 1, 'AntiSurface', 1, 'STRATEGIC', 20} },
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2}},
			{ SBC, 'MapGreaterThan', { 500, 500 }},
        },
        BuilderType = 'Any',		
        RemoveBuilders = {},
		AddBuilders = {
			EngineerManager = {
				'Sorian T2 Firebase Engineer - High Prio',
			}
		}
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianHeavyAirStrategy',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian T1 Heavy Air Strategy',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
            { SBC, 'LessThanThreatAtEnemyBase', { 'AntiAir', 7 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH3' }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 5, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER, 'Enemy'}},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY AIR TECH2, FACTORY AIR TECH3' }},
        },
        BuilderType = 'Any',		
        RemoveBuilders = {
			FactoryManager = {
				'Sorian T1 Air Bomber',
				'Sorian T1 Air Bomber - Stomp Enemy',
				'Sorian T1Gunship',
				'Sorian T1 Air Bomber 2',
				'Sorian T1Gunship2',
				'Sorian T2 Air Gunship',
				'Sorian T2 Air Gunship - Anti Navy',
				'Sorian T2 Air Gunship - Stomp Enemy',
				'Sorian T2FighterBomber',
				'Sorian T2 Air Gunship2',
				'Sorian T2FighterBomber2',
				'Sorian T3 Air Gunship',
				'Sorian T3 Air Gunship - Anti Navy',
				'Sorian T3 Air Bomber',
				'Sorian T3 Air Bomber - Stomp Enemy',
				'Sorian T3 Air Gunship2',
				'Sorian T3 Air Bomber2',
			},
			PlatoonFormManager = {
				'Sorian BomberAttackT1Frequent',
				'Sorian BomberAttackT1Frequent - Anti-Land',
				'Sorian BomberAttackT1Frequent - Anti-Resource',
				'Sorian BomberAttackT2Frequent',
				'Sorian BomberAttackT2Frequent - Anti-Land',
				'Sorian BomberAttackT2Frequent - Anti-Resource',
				'Sorian BomberAttackT3Frequent',
				'Sorian BomberAttackT3Frequent - Anti-Land',
				'Sorian BomberAttackT3Frequent - Anti-Resource',
				'Sorian T1 Bomber Attack Weak Enemy Response',
				'Sorian BomberAttack Mass Hunter',
			}
		},
		AddBuilders = {
			FactoryManager = {
				'Sorian T1 Air Bomber - High Prio',
				'Sorian T2 Air Bomber - High Prio',
				'Sorian T3 Air Bomber - High Prio',
			},
			PlatoonFormManager = {
				'Sorian Bomber Attack - Large',
			}
		}
    },
    Builder {
        BuilderName = 'Sorian T2 Heavy Air Strategy',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
            { SBC, 'LessThanThreatAtEnemyBase', { 'AntiAir', 19 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH3' }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 5, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER, 'Enemy'}},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Any',		
        RemoveBuilders = {
			FactoryManager = {
				'Sorian T1 Air Bomber',
				'Sorian T1 Air Bomber - Stomp Enemy',
				'Sorian T1Gunship',
				'Sorian T1 Air Bomber 2',
				'Sorian T1Gunship2',
				'Sorian T2 Air Gunship',
				'Sorian T2 Air Gunship - Anti Navy',
				'Sorian T2 Air Gunship - Stomp Enemy',
				'Sorian T2FighterBomber',
				'Sorian T2 Air Gunship2',
				'Sorian T2FighterBomber2',
				'Sorian T3 Air Gunship',
				'Sorian T3 Air Gunship - Anti Navy',
				'Sorian T3 Air Bomber',
				'Sorian T3 Air Bomber - Stomp Enemy',
				'Sorian T3 Air Gunship2',
				'Sorian T3 Air Bomber2',
			},
			PlatoonFormManager = {
				'Sorian BomberAttackT1Frequent',
				'Sorian BomberAttackT1Frequent - Anti-Land',
				'Sorian BomberAttackT1Frequent - Anti-Resource',
				'Sorian BomberAttackT2Frequent',
				'Sorian BomberAttackT2Frequent - Anti-Land',
				'Sorian BomberAttackT2Frequent - Anti-Resource',
				'Sorian BomberAttackT3Frequent',
				'Sorian BomberAttackT3Frequent - Anti-Land',
				'Sorian BomberAttackT3Frequent - Anti-Resource',
				'Sorian T2/T3 Bomber Attack Weak Enemy Response',
				'Sorian BomberAttack Mass Hunter',
			}
		},
		AddBuilders = {
			FactoryManager = {
				'Sorian T1 Air Bomber - High Prio',
				'Sorian T2 Air Bomber - High Prio',
				'Sorian T3 Air Bomber - High Prio',
			},
			PlatoonFormManager = {
				'Sorian Bomber Attack - Large',
			}
		}
    },
    Builder {
        BuilderName = 'Sorian T3 Heavy Air Strategy',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
            { SBC, 'LessThanThreatAtEnemyBase', { 'AntiAir', 55 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 5, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER, 'Enemy'}},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, 'FACTORY AIR TECH3' }},
        },
        BuilderType = 'Any',		
        RemoveBuilders = {
			FactoryManager = {
				'Sorian T1 Air Bomber',
				'Sorian T1 Air Bomber - Stomp Enemy',
				'Sorian T1Gunship',
				'Sorian T1 Air Bomber 2',
				'Sorian T1Gunship2',
				'Sorian T2 Air Gunship',
				'Sorian T2 Air Gunship - Anti Navy',
				'Sorian T2 Air Gunship - Stomp Enemy',
				'Sorian T2FighterBomber',
				'Sorian T2 Air Gunship2',
				'Sorian T2FighterBomber2',
				'Sorian T3 Air Gunship',
				'Sorian T3 Air Gunship - Anti Navy',
				'Sorian T3 Air Bomber',
				'Sorian T3 Air Bomber - Stomp Enemy',
				'Sorian T3 Air Gunship2',
				'Sorian T3 Air Bomber2',
			},
			PlatoonFormManager = {
				'Sorian BomberAttackT1Frequent',
				'Sorian BomberAttackT1Frequent - Anti-Land',
				'Sorian BomberAttackT1Frequent - Anti-Resource',
				'Sorian BomberAttackT2Frequent',
				'Sorian BomberAttackT2Frequent - Anti-Land',
				'Sorian BomberAttackT2Frequent - Anti-Resource',
				'Sorian BomberAttackT3Frequent',
				'Sorian BomberAttackT3Frequent - Anti-Land',
				'Sorian BomberAttackT3Frequent - Anti-Resource',
				'Sorian T2/T3 Bomber Attack Weak Enemy Response',
				'Sorian BomberAttack Mass Hunter',
			}
		},
		AddBuilders = {
			FactoryManager = {
				'Sorian T1 Air Bomber - High Prio',
				'Sorian T2 Air Bomber - High Prio',
				'Sorian T3 Air Bomber - High Prio',
			},
			PlatoonFormManager = {
				'Sorian Bomber Attack - Large',
			}
		}
    },
}