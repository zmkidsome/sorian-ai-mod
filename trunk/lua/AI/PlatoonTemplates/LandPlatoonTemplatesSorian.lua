PlatoonTemplate {
    Name = 'BaseGuardSmallSorian',
    Plan = 'GuardBaseSorian',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER, 5, 15, 'Attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'BaseGuardMediumSorian',
    Plan = 'GuardBaseSorian',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER, 15, 25, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'StartLocationAttackSorian',
    Plan = 'GuardMarkerSorian',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER, 15, 25, 'Attack', 'none' },
        { categories.ENGINEER, 1, 1, 'Attack', 'none' },
    },
}
PlatoonTemplate {
    Name = 'StartLocationAttack2Sorian',
    Plan = 'GuardMarkerSorian',
    GlobalSquads = {
        { categories.MOBILE * categories.LAND - categories.EXPERIMENTAL - categories.ENGINEER, 15, 25, 'Attack', 'none' }
    },
}
PlatoonTemplate {
    Name = 'T1LandScoutFormSorian',
    Plan = 'ScoutingAISorian',
    GlobalSquads = {
        { categories.MOBILE * categories.SCOUT * categories.TECH1, 1, 1, 'scout', 'none' }
    }
}

PlatoonTemplate {
    Name = 'T2EngineerGuard',
    Plan = 'None',
    GlobalSquads = {
        { categories.DIRECTFIRE * categories.TECH2 * categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER, 1, 3, 'guard', 'None' }
    },
}

PlatoonTemplate {
    Name = 'T3EngineerGuard',
    Plan = 'None',
    GlobalSquads = {
        { categories.DIRECTFIRE * categories.TECH3 * categories.LAND * categories.MOBILE - categories.SCOUT - categories.ENGINEER, 1, 3, 'guard', 'None' }
    },
}

PlatoonTemplate {
    Name = 'T1MassHuntersCategorySorian',
    #Plan = 'AttackForceAI',    
    Plan = 'GuardMarkerSorian',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.BOT - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 3, 15, 'attack', 'none' },
        { categories.LAND * categories.SCOUT, 0, 1, 'attack', 'none' },
    }
}

PlatoonTemplate {
    Name = 'T2MassHuntersCategorySorian',
    #Plan = 'AttackForceAI',    
    Plan = 'GuardMarkerSorian',    
    GlobalSquads = {
        { categories.TECH1 * categories.LAND * categories.MOBILE * categories.DIRECTFIRE * categories.BOT - categories.SCOUT - categories.ENGINEER - categories.EXPERIMENTAL, 10, 25, 'attack', 'none' },
        { categories.LAND * categories.SCOUT, 0, 1, 'attack', 'none' },
    }
}
PlatoonTemplate {
    Name = 'T4ExperimentalLandLate',
    Plan = 'ExperimentalAIHub',   
    GlobalSquads = {
        { categories.EXPERIMENTAL * categories.LAND * categories.MOBILE, 2, 3, 'attack', 'none' }
    },
}

PlatoonTemplate {
    Name = 'T2AttackTankSorian',
    FactionSquads = {
        UEF = {
            { 'del0204', 1, 1, 'attack', 'None' },
        },
        Aeon = {
            { 'xal0203', 1, 1, 'attack', 'None' },
        },
        Cybran = {
            { 'drl0204', 1, 1, 'attack', 'None' },
        },
    },
}