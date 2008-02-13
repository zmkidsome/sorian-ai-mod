#***************************************************************************
#*
#**  File     :  /lua/ai/SeaPlatoonTemplates.lua
#**
#**  Summary  : Global platoon templates
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

# ==== Global Form platoons ==== #
PlatoonTemplate {
    Name = 'SeaAttackSorian',
    Plan = 'NavalForceAISorian',
    GlobalSquads = {
        { categories.MOBILE * categories.NAVAL - categories.EXPERIMENTAL - categories.CARRIER, 1, 100, 'Attack', 'GrowthFormation' }
    },
}

PlatoonTemplate {
    Name = 'T4ExperimentalSeaSorian',
    Plan = 'NavalForceAISorian',
    FactionSquads = {
        UEF = {
            { 'ues0401', 1, 1, 'attack', 'None' }
        },
        Aeon = {
            { 'uas0401', 1, 1, 'attack', 'None' }
        },
    }
}