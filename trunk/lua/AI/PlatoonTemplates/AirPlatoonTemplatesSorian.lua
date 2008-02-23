PlatoonTemplate {
    Name = 'AirAttackSorian',
    Plan = 'StrikeForceAISorian',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS - categories.ANTINAVY, 1, 100, 'Attack', 'GrowthFormation' }
    },
}

PlatoonTemplate {
    Name = 'BomberAttackSorian',
    Plan = 'StrikeForceAISorian',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.BOMBER - categories.EXPERIMENTAL - categories.ANTINAVY, 1, 100, 'Attack', 'GrowthFormation' },
        #{ categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.EXPERIMENTAL - categories.BOMBER - categories.TRANSPORTFOCUS, 0, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'TorpedoBomberAttackSorian',
    Plan = 'AirHuntAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.ANTINAVY - categories.EXPERIMENTAL, 1, 100, 'Attack', 'GrowthFormation' },
        #{ categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.EXPERIMENTAL - categories.BOMBER - categories.TRANSPORTFOCUS, 0, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'GunshipAttackSorian',
    Plan = 'AirHuntAI',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS, 1, 100, 'Attack', 'GrowthFormation' },
        { categories.MOBILE * categories.AIR * categories.ANTIAIR - categories.EXPERIMENTAL - categories.BOMBER - categories.TRANSPORTFOCUS, 0, 10, 'Attack', 'GrowthFormation' },
    }
}

PlatoonTemplate {
    Name = 'GunshipSFSorian',
    Plan = 'StrikeForceAISorian',
    GlobalSquads = {
        { categories.MOBILE * categories.AIR * categories.GROUNDATTACK - categories.EXPERIMENTAL - categories.TRANSPORTFOCUS, 1, 100, 'Attack', 'GrowthFormation' },
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
    Plan = 'FighterHuntAI',
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
    Name = 'T4ExperimentalAirSorian',
    Plan = 'ExperimentalAIHubSorian', 
    GlobalSquads = {
        { categories.AIR * categories.EXPERIMENTAL * categories.MOBILE, 1, 1, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'T4ExperimentalAirLate',
    Plan = 'ExperimentalAIHubSorian', 
    GlobalSquads = {
        { categories.AIR * categories.EXPERIMENTAL * categories.MOBILE, 2, 3, 'attack', 'none' },
    },
}

PlatoonTemplate {
    Name = 'T2BomberSorian',
    FactionSquads = {
        UEF = {
            { 'dea0202', 1, 1, 'attack', 'None' },
        },
        Aeon = {
            { 'uaa0203', 1, 1, 'attack', 'None' },
        },
        Cybran = {
            { 'dra0202', 1, 1, 'attack', 'None' },
        },
        Seraphim = {
            { 'xsa0202', 1, 1, 'attack', 'None' },
        },
    },
}