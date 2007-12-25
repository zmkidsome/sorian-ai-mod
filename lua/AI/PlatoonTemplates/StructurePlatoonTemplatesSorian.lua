#***************************************************************************
#*
#**  File     :  /lua/ai/StructurePlatoonTemplates.lua
#**
#**  Summary  : Global platoon templates
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

# ==== Missile systems ==== #
PlatoonTemplate {
    Name = 'T2TacticalLauncherSorian',
    Plan = 'TacticalAISorian',
    GlobalSquads = {
        { categories.STRUCTURE * categories.TACTICALMISSILEPLATFORM, 1, 1, 'attack', 'none' },
    }
}

# ==== Artillery platoons ==== #
PlatoonTemplate {
    Name = 'T2ArtilleryStructureSorian',
    Plan = 'ArtilleryAISorian',
    GlobalSquads = {
        { categories.ARTILLERY * categories.STRUCTURE * categories.TECH2, 1, 1, 'artillery', 'None' }
    }
}

PlatoonTemplate {
    Name = 'T3ArtilleryStructureSorian',
    Plan = 'ArtilleryAISorian',
    GlobalSquads = {
        { categories.ARTILLERY * categories.STRUCTURE * categories.TECH3, 1, 1, 'artillery', 'None' }
    }
}

PlatoonTemplate {
    Name = 'T4ArtilleryStructureSorian',
    Plan = 'ArtilleryAISorian',
    GlobalSquads = {
        { categories.ARTILLERY * categories.STRUCTURE * categories.EXPERIMENTAL, 1, 1, 'artillery', 'None' }
    }
}