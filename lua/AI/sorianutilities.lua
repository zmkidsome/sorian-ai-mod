local AIUtils = import('/lua/ai/aiutilities.lua')

function Nuke(aiBrain)
    local atkPri = { 'STRUCTURE ARTILLERY EXPERIMENTAL', 'STRUCTURE NUKE EXPERIMENTAL', 'STRUCTURE ARTILLERY TECH3', 'STRUCTURE NUKE TECH3', 'EXPERIMENTAL ENERGYPRODUCTION STRUCTURE', 'COMMAND', 'TECH3 MASSFABRICATION', 'TECH3 ENERGYPRODUCTION', 'STRUCTURE STRATEGIC', 'STRUCTURE DEFENSE TECH3', 'STRUCTURE DEFENSE TECH2', 'STRUCTURE FACTORY', 'STRUCTURE', 'SPECIALLOWPRI', 'ALLUNITS' }
	local maxFire = false
	local Nukes = aiBrain:GetListOfUnits( categories.NUKE * categories.SILO * categories.STRUCTURE, true )
	local nukeCount = 0
	local launcher
	local bp
	local weapon
	local maxRadius
	local fired = {}
    for k, v in Nukes do
		if not maxFire then
			bp = v:GetBlueprint()
			weapon = bp.Weapon[1]
			maxRadius = weapon.MaxRadius
			launcher = v
			maxFire = true
		end
		fired[k] = false
        if v:GetNukeSiloAmmoCount() > 0 then
			nukeCount = nukeCount + 1
        end            
    end
	if nukeCount > 0 then
		local oldTarget = {}
		local target
		local fireCount = 0
		local aitarget
		local tarPosition
		repeat
			target, tarPosition = AIUtils.AIFindBrainNukeTargetInRangeSorian( aiBrain, launcher, maxRadius, atkPri, nukeCount, oldTarget )
			if target then
				aitarget = target:GetAIBrain():GetArmyIndex()
				#AISendChat('allies', ArmyBrains[aiBrain:GetArmyIndex()].Nickname, 'nukechat', ArmyBrains[aitarget].Nickname)
				#AISendPing(tarPosition, 'attack', aiBrain:GetArmyIndex())
				local antiNukes = aiBrain:GetNumUnitsAroundPoint( categories.ANTIMISSILE * categories.TECH3 * categories.STRUCTURE, tarPosition, 80, 'Enemy' )
				for k, v in Nukes do
					if v:GetNukeSiloAmmoCount() > 0 and not fired[k] then
						IssueNuke( {v}, tarPosition )
						nukeCount = nukeCount - 1
						fireCount = fireCount + 1
						fired[k] = true
					end
					if fireCount > (antiNukes + 1) or nukeCount == 0 or (fireCount > 0 and antiNukes == 0) then
						break
					end
				end
			end
			table.insert( oldTarget, target )
			fireCount = 0
			#WaitSeconds(15)
		until nukeCount <= 0 or target == false
	end
end