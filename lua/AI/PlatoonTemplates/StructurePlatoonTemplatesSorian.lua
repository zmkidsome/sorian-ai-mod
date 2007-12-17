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