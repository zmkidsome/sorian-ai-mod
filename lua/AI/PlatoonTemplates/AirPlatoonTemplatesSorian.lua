PlatoonTemplate {
    Name = 'GunshipAttackSorian',
    Plan = 'AirHuntAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS, 1, 100, 'Attack', 'GrowthFormation' },
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.EXPERIMENTAL - categories.BOMBER - categories.TRANSPORTFOCUS, 0, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'GunshipMassHunterSorian',
    Plan = 'GuardMarkerSorian',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS, 1, 5, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'T1AirScoutFormSorian',
    Plan = 'ScoutingAISorian',
    GlobalSquads = {
        { categories.AIR * categories.SCOUT * categories.TECH1, 1, 1, 'scout', 'None' },
    }
}

PlatoonTemplate {
    Name = 'AntiAirHuntSorian',
    Plan = 'AirHuntAI',
    GlobalSquads = {
        { categories.AIR * categories.MOBILE * categories.ANTIAIR * ( categories.TECH1 + categories.TECH2 + categories.TECH3 ) - categories.BOMBER - categories.TRANSPORTFOCUS - categories.EXPERIMENTAL, 1, 100, 'attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'T3AirScoutFormSorian',
    Plan = 'ScoutingAISorian',
    GlobalSquads = {
        { categories.AIR * categories.INTELLIGENCE * categories.TECH3, 1, 1, 'scout', 'None' },
    }
}

PlatoonTemplate {
    Name = 'T4ExperimentalAirLate',
    Plan = 'ExperimentalAIHub', 
    GlobalSquads = {
        { categories.AIR * categories.EXPERIMENTAL * categories.MOBILE, 2, 3, 'attack', 'none' },
    },
}