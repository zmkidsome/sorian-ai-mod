do

function ExecutePlan(aiBrain)
    aiBrain:SetConstantEvaluate(false)
	local behaviors = import('/lua/ai/AIBehaviors.lua')
    WaitSeconds(1)
    if not aiBrain.BuilderManagers.MAIN.FactoryManager:HasBuilderList() then
        aiBrain:SetResourceSharing(true)
		
		local per = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
		
		if string.find(per, 'sorian') then
			aiBrain:SetupUnderEnergyStatTriggerSorian(0.1)
			aiBrain:SetupUnderMassStatTriggerSorian(0.1)		
		else        
			aiBrain:SetupUnderEnergyStatTrigger(0.1)
			aiBrain:SetupUnderMassStatTrigger(0.1)
		end
        
        SetupMainBase(aiBrain)
        
        # Get units out of pool and assign them to the managers
        local mainManagers = aiBrain.BuilderManagers.MAIN
        
        local pool = aiBrain:GetPlatoonUniquelyNamed('ArmyPool')
        for k,v in pool:GetPlatoonUnits() do
            if EntityCategoryContains( categories.ENGINEER, v ) then
                mainManagers.EngineerManager:AddUnit(v)
            elseif EntityCategoryContains( categories.FACTORY * categories.STRUCTURE, v ) then
                mainManagers.FactoryManager:AddFactory( v )
            end
        end

		if string.find(per, 'sorian') then
			ForkThread(UnitCapWatchThreadSorian, aiBrain)
			ForkThread(behaviors.NukeCheck, aiBrain)
		else
			ForkThread(UnitCapWatchThread, aiBrain)
		end
    end
    if aiBrain.PBM then
        aiBrain:PBMSetEnabled(false)
    end
end

function SetupMainBase(aiBrain)
    local base, returnVal, baseType = GetHighestBuilder(aiBrain)

    local per = ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality
    if per != 'adaptive' then
        ScenarioInfo.ArmySetup[aiBrain.Name].AIPersonality = baseType
    end

    LOG('*AI DEBUG: ARMY ', repr(aiBrain:GetArmyIndex()), ': Initiating Archetype using ' .. base)
    AIAddBuilderTable.AddGlobalBaseTemplate(aiBrain, 'MAIN', base)
    aiBrain:ForceManagerSort()
end

function UnitCapWatchThreadSorian(aiBrain)
	#LOG('*AI DEBUG: UnitCapWatchThreadSorian started')
    KillPD = false
	KillDF = false
	KillEng = false	
	KillT1Land = false
	KillT1Air = false
	Reset = false
    while true do
        WaitSeconds(60)
		local Scouts = aiBrain:GetListOfUnits( categories.SCOUT + categories.MOBILE * categories.INTELLIGENCE * categories.AIR, true )
		for k, v in Scouts do
			if not v:IsDead() and EntityCategoryContains( categories.AIR, v ) and not v.HasFuel then
				v:Kill()
			end
		end
        while GetArmyUnitCostTotal(aiBrain:GetArmyIndex()) > (GetArmyUnitCap(aiBrain:GetArmyIndex()) - 20) and not Reset do
            if not KillPD and aiBrain:GetCurrentUnits(categories.TECH3 * categories.ENERGYPRODUCTION) > 3 then
				local units = aiBrain:GetListOfUnits(categories.TECH1 * categories.ENERGYPRODUCTION * categories.STRUCTURE, true)
				for k, v in units do
					v:Kill()
				end
                KillPD = true
				#LOG('*AI DEBUG: UnitCapWatchThreadSorian Killed T1 Pgens')
            elseif not KillDF and aiBrain:GetCurrentUnits(categories.TECH3 * categories.DEFENSE * categories.STRUCTURE) > 15 then            
                local units = aiBrain:GetListOfUnits(categories.TECH1 * categories.DEFENSE * categories.STRUCTURE, true)
                for k, v in units do
                    v:Kill()
                end
				KillDF = true
				#LOG('*AI DEBUG: UnitCapWatchThreadSorian Killed T1 Defenses')
			elseif not KillEng and (aiBrain:GetCurrentUnits(categories.TECH2 * categories.ENGINEER) > 6 or aiBrain:GetCurrentUnits(categories.TECH3 * categories.ENGINEER) > 6) then
				if aiBrain:GetCurrentUnits(categories.TECH2 * categories.ENGINEER) > 1 or aiBrain:GetCurrentUnits(categories.TECH3 * categories.ENGINEER) > 1 then
					local units = aiBrain:GetListOfUnits(categories.TECH1 * categories.ENGINEER, true)
					for k, v in units do
						v:Kill()						
					end
				end
				if aiBrain:GetCurrentUnits(categories.TECH3 * categories.ENGINEER) > 6 then
					local units = aiBrain:GetListOfUnits(categories.TECH2 * categories.ENGINEER - categories.ENGINEERSTATION, true)
					for k, v in units do
						v:Kill()
					end
				end				
				KillEng = true
				#LOG('*AI DEBUG: UnitCapWatchThreadSorian Killed Engies')
			elseif not KillT1Land and aiBrain:GetCurrentUnits(categories.TECH3 * categories.MOBILE * categories.LAND - categories.ENGINEER) > 50 then
				local units = aiBrain:GetListOfUnits(categories.TECH1 * categories.MOBILE * categories.LAND, true)
				for k, v in units do
					v:Kill()
				end				
				KillT1Land = true
				#LOG('*AI DEBUG: UnitCapWatchThreadSorian Killed T1 Land')
			elseif not KillT1Air and aiBrain:GetCurrentUnits(categories.TECH3 * categories.MOBILE * categories.AIR - categories.INTELLIGENCE) > 10 then
				local units = aiBrain:GetListOfUnits(categories.TECH1 * categories.MOBILE * categories.AIR - categories.SCOUT, true)
				for k, v in units do
					v:Kill()
				end				
				KillT1Air = true
				#LOG('*AI DEBUG: UnitCapWatchThreadSorian Killed T1 Air')
            else        
				if aiBrain:GetCurrentUnits(categories.TECH3 * categories.DEFENSE * categories.ANTIAIR) > 10 then
					local units = aiBrain:GetListOfUnits(categories.TECH2 * categories.DEFENSE * categories.ANTIAIR, true)
					for k, v in units do
						v:Kill()
					end
				end
				KillPD = false
				KillDF = false
				KillEng = false
				KillT1Land = false
				KillT1Air = false
				Reset = true
				#LOG('*AI DEBUG: UnitCapWatchThreadSorian Reset')
            end
        end
		Reset = false
    end
end

end