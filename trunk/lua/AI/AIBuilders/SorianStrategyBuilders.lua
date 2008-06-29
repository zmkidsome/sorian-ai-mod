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
		StrategyType = 'Intermediate',
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
		StrategyType = 'Intermediate',
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
    BuilderGroupName = 'SorianSmallMapRush',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian Small Map Rush Strategy',
		StrategyType = 'Overall',
        Priority = 105,
        InstanceCount = 1,
        BuilderConditions = {
			{ SBC, 'IsWaterMap', { false } },
			{ SBC, 'ClosestEnemyLessThan', { 750 } },
			{ SBC, 'EnemyToAllyRatioLessOrEqual', { 1 } },
			{ MIBC, 'LessThanGameTime', { 1200 } },
        },
        BuilderType = 'Any',		
        RemoveBuilders = {
			EngineerManager = {
				'Sorian T1VacantStartingAreaEngineer - Rush',
				'Sorian T1VacantStartingAreaEngineer',
				'Sorian T1 Vacant Expansion Area Engineer(Full Base)',
			},
		},
		AddBuilders = {
			EngineerManager = {
				'Sorian T1VacantStartingAreaEngineer - HP Strategy',
				'Sorian T1VacantStartingAreaEngineer Strategy',
				'Sorian T1 Vacant Expansion Area Engineer(Full Base) - Strategy',
			},
		}
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianT3ArtyRush',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian T3 Arty Rush Strategy',
		StrategyType = 'Intermediate',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'ENGINEER TECH3' }},
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ARTILLERY STRUCTURE TECH3' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 } },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 6, categories.SHIELD * categories.TECH3 * categories.STRUCTURE, 'Enemy'}},
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2}},
			{ SIBC, 'GreaterThanEconIncome',  { 100, 3000}},
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
		StrategyType = 'Intermediate',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'ENGINEER TECH3' }},
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'ARTILLERY STRUCTURE TECH3' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 } },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 6, categories.SHIELD * categories.TECH3 * categories.STRUCTURE, 'Enemy'}},
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2}},
			{ SIBC, 'GreaterThanEconIncome',  { 100, 3000}},
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
		StrategyType = 'Intermediate',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 3, 'ENGINEER TECH3' }},
			{ SIBC, 'HaveLessThanUnitsWithCategory', { 1, 'NUKE SILO STRUCTURE TECH3' }},
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, categories.ENERGYPRODUCTION * categories.TECH3 } },
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 1, categories.ANTIMISSILE * categories.TECH3 * categories.STRUCTURE, 'Enemy'}},
			{ SIBC, 'GreaterThanEconEfficiencyOverTime', { 0.9, 1.2}},
			{ SIBC, 'GreaterThanEconIncome',  { 100, 3000}},
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
		StrategyType = 'Intermediate',
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
		StrategyType = 'Intermediate',
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
				'Sorian Bomber Attack - Large T1',
			}
		}
    },
    Builder {
        BuilderName = 'Sorian T2 Heavy Air Strategy',
		StrategyType = 'Intermediate',
        Priority = 100,
        InstanceCount = 1,
		StrategyTime = 300,
        BuilderConditions = {
            { SBC, 'LessThanThreatAtEnemyBase', { 'AntiAir', 19 }},
			{ SBC, 'NoRushTimeCheck', { 600 }},
			{ UCBC, 'HaveLessThanUnitsWithCategory', { 1, 'FACTORY AIR TECH3' }},
			{ UCBC, 'HaveUnitsWithCategoryAndAlliance', { false, 5, categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.BOMBER, 'Enemy'}},
			{ UCBC, 'FactoryLessAtLocation', { 'LocationType', 1, 'FACTORY AIR TECH3' }},
			{ UCBC, 'FactoryGreaterAtLocation', { 'LocationType', 0, 'FACTORY AIR TECH2' }},
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
		StrategyType = 'Intermediate',
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

BuilderGroup {
    BuilderGroupName = 'SorianParagonStrategy',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian Paragon Strategy',
		StrategyType = 'Overall',
        Priority = 100,
        InstanceCount = 1,
        BuilderConditions = {
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION EXPERIMENTAL STRUCTURE' }},
        },
        BuilderType = 'Any',
        RemoveBuilders = {
			PlatoonFormManager = {
				'T1 Mass Extractor Upgrade Storage Based',
				'Sorian T1 Mass Extractor Upgrade Timeless Single',
				'Sorian T1 Mass Extractor Upgrade Timeless Two',
				'Sorian T1 Mass Extractor Upgrade Timeless LOTS',
				'Sorian T2 Mass Extractor Upgrade Timeless',
				'Sorian T2 Mass Extractor Upgrade Timeless Multiple',
				'Sorian Balanced T1 Land Factory Upgrade Initial',
				'Sorian BalancedT1AirFactoryUpgradeInitial',
				'Sorian Balanced T1 Land Factory Upgrade',
				'Sorian BalancedT1AirFactoryUpgrade',
				'Sorian Balanced T1 Sea Factory Upgrade',
				'Sorian Balanced T1 Land Factory Upgrade - T3',
				'Sorian BalancedT1AirFactoryUpgrade - T3',
				'Sorian Balanced T2 Land Factory Upgrade - initial',
				'Sorian Balanced T2 Air Factory Upgrade - initial',
				'Sorian Balanced T2 Land Factory Upgrade',
				'Sorian Balanced T2 Air Factory Upgrade',
				'Sorian Balanced T2 Sea Factory Upgrade',
				'Sorian Naval T1 Land Factory Upgrade Initial',
				'Sorian Naval T1 Air Factory Upgrade Initial',
				'Sorian Naval T1 Naval Factory Upgrade Initial',
				'Sorian Naval T1 Land Factory Upgrade',
				'Sorian Naval T1 AirFactory Upgrade',
				'Sorian Naval T1 Sea Factory Upgrade',
				'Sorian Naval T1 Land Factory Upgrade - T3',
				'Sorian Naval T1AirFactoryUpgrade - T3',
				'Sorian Naval T2 Land Factory Upgrade',
				'Sorian Naval T2 Air Factory Upgrade',
				'Sorian Naval T2 Sea Factory Upgrade',
			},
		},
		AddBuilders = {
			PlatoonFormManager = {
				'Sorian T1 Mass Extractor Upgrade Timeless Strategy',
				'Sorian T2 Mass Extractor Upgrade Timeless Strategy',
				'Sorian Balanced T1 Land Factory Upgrade Expansion Strategy',
				'Sorian BalancedT1AirFactoryUpgrade Expansion Strategy',
				'Sorian Balanced T1 Sea Factory Upgrade Expansion Strategy',
				'Sorian Balanced T2 Land Factory Upgrade Expansion Strategy',
				'Sorian Balanced T2 Air Factory Upgrade Expansion Strategy',
				'Sorian Balanced T2 Sea Factory Upgrade Expansion Strategy',
			},
		}
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianParagonStrategyExp',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian Paragon Strategy Expansion',
		StrategyType = 'Overall',
        Priority = 110,
        InstanceCount = 1,
        BuilderConditions = {
			{ SIBC, 'HaveGreaterThanUnitsWithCategory', { 0, 'ENERGYPRODUCTION EXPERIMENTAL STRUCTURE' }},
        },
        BuilderType = 'Any',
        RemoveBuilders = {
			PlatoonFormManager = {
				'Sorian Balanced T1 Land Factory Upgrade Expansion',
				'Sorian BalancedT1AirFactoryUpgrade Expansion',
				'Sorian Balanced T1 Sea Factory Upgrade Expansion',
				'Sorian Balanced T2 Land Factory Upgrade Expansion',
				'Sorian Balanced T2 Air Factory Upgrade Expansion',
				'Sorian Balanced T2 Sea Factory Upgrade Expansion',
				'Sorian Naval T1 Land Factory Upgrade Initial',
				'Sorian Naval T1 Air Factory Upgrade Initial',
				'Sorian Naval T1 Naval Factory Upgrade Initial',
				'Sorian Naval T1 Land Factory Upgrade',
				'Sorian Naval T1 AirFactory Upgrade',
				'Sorian Naval T1 Sea Factory Upgrade',
				'Sorian Naval T1 Land Factory Upgrade - T3',
				'Sorian Naval T1AirFactoryUpgrade - T3',
				'Sorian Naval T2 Land Factory Upgrade',
				'Sorian Naval T2 Air Factory Upgrade',
				'Sorian Naval T2 Sea Factory Upgrade',
			},
		},
		AddBuilders = {
			PlatoonFormManager = {
				'Sorian Balanced T1 Land Factory Upgrade Expansion Strategy',
				'Sorian BalancedT1AirFactoryUpgrade Expansion Strategy',
				'Sorian Balanced T1 Sea Factory Upgrade Expansion Strategy',
				'Sorian Balanced T2 Land Factory Upgrade Expansion Strategy',
				'Sorian Balanced T2 Air Factory Upgrade Expansion Strategy',
				'Sorian Balanced T2 Sea Factory Upgrade Expansion Strategy',
			},
		}
    },
}

BuilderGroup {
    BuilderGroupName = 'SorianTeamLevelAdjustment',
    BuildersType = 'StrategyBuilder',
    Builder {
        BuilderName = 'Sorian AI Outnumbered',
		StrategyType = 'Overall',
        Priority = 100,
        InstanceCount = 1,
        BuilderConditions = {
			{ SBC, 'MapGreaterThan', { 1000, 1000 }},
			{ SBC, 'AIOutnumbered', { true }},
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
				'Sorian T1 Bot - Early Game Rush',
				'Sorian T1 Bot - Early Game',
				'Sorian T1 Light Tank - Tech 1',
				'Sorian T1 Mortar',
				'Sorian T1 Mortar - tough def',
			},
			StrategyManager = {
				'Sorian T1 Heavy Air Strategy',
				'Sorian Jester Rush Strategy',
			}
		},
		AddBuilders = {}
    },
    Builder {
        BuilderName = 'Sorian AI Outnumbers Enemies',
		StrategyType = 'Overall',
        Priority = 100,
        InstanceCount = 1,
        BuilderConditions = {
			{ SBC, 'MapGreaterThan', { 1000, 1000 }},
			{ SBC, 'AIOutnumbered', { false }},
        },
        BuilderType = 'Any',
        RemoveBuilders = {
			EngineerManager = {
				'Sorian T1 Mass Adjacency Defense Engineer',
				'Sorian T1 Base D Engineer - Perimeter',
				'Sorian T1 Defensive Point Engineer',
			}
		},
		AddBuilders = {}
    },
}