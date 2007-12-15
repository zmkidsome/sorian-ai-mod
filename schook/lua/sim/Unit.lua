do
oldUnit = Unit
Unit = Class(oldUnit) {

    DisableUnitIntel = function(self, intel)
        local UTCCodes = {
            Radar = "RULEUTC_IntelToggle",
            Sonar = "RULEUTC_IntelToggle",
            Omni = "RULEUTC_IntelToggle",
            RadarStealth = "RULEUTC_StealthToggle",
            SonarStealth = "RULEUTC_StealthToggle",
            RadarStealthField = "RULEUTC_StealthToggle",
            SonarStealthField = "RULEUTC_StealthToggle",
            Cloak = "RULEUTC_CloakToggle",
            CloakField = "RULEUTC_CloakToggle",
            Spoof = "RULEUTC_JammingToggle",
            Jammer = "RULEUTC_JammingToggle",
        }
		local intDisabled = false
        if not self.IntelDisables then return end
		local toggle1 = false
		local toggle2 = false
        if intel then
            self.IntelDisables[intel] = self.IntelDisables[intel] + 1
            if self.IntelDisables[intel] == 1 then
                if self:TestToggleCaps(UTCCodes[intel]) and (UTCCodes[intel] == "RULEUTC_StealthToggle" or UTCCodes[intel] == "RULEUTC_CloakToggle") and not toggle1 then
					self:SetScriptBit(UTCCodes[intel], true)
					toggle1 = true
				elseif self:TestToggleCaps(UTCCodes[intel]) and UTCCodes[intel] == "RULEUTC_IntelToggle" and not toggle2 then
					self:SetScriptBit(UTCCodes[intel], true)
					toggle2 = true
				else
					self:DisableIntel(intel)
				end
				intDisabled = true
			end
			if self.IntelDisables[intel] > 1 then self.IntelDisables[intel] = 1 end
        else
            for k, v in self.IntelDisables do
                self.IntelDisables[k] = v + 1
                if self.IntelDisables[k] == 1 then
					if self:TestToggleCaps(UTCCodes[k]) and (UTCCodes[k] == "RULEUTC_StealthToggle" or UTCCodes[k] == "RULEUTC_CloakToggle") and not toggle1 then
						self:SetScriptBit(UTCCodes[k], true)
						toggle1 = true
					elseif self:TestToggleCaps(UTCCodes[k]) and UTCCodes[k] == "RULEUTC_IntelToggle" and not toggle2 then
						self:SetScriptBit(UTCCodes[k], true)
						toggle2 = true
					else
						self:DisableIntel(k)
					end
					intDisabled = true
                end
				if self.IntelDisables[k] > 1 then self.IntelDisables[k] = 1 end
            end
        end       
        if intDisabled then
			self:OnIntelDisabled()
		end
    end,

    EnableUnitIntel = function(self, intel)
        local UTCCodes = {
            Radar = "RULEUTC_IntelToggle",
            Sonar = "RULEUTC_IntelToggle",
            Omni = "RULEUTC_IntelToggle",
            RadarStealth = "RULEUTC_StealthToggle",
            SonarStealth = "RULEUTC_StealthToggle",
            RadarStealthField = "RULEUTC_StealthToggle",
            SonarStealthField = "RULEUTC_StealthToggle",
            Cloak = "RULEUTC_CloakToggle",
            CloakField = "RULEUTC_CloakToggle",
            Spoof = "RULEUTC_JammingToggle",
            Jammer = "RULEUTC_JammingToggle",
        }
        local layer = self:GetCurrentLayer()
        local bp = self:GetBlueprint()
        local intEnabled = false
        if layer == 'Seabed' or layer == 'Sub' or layer == 'Water' then
            self:EnableIntel('WaterVision')
        end
		local toggle1 = false
		local toggle2 = false
        if intel then
            if self.IntelDisables[intel] == 1 then
                if self:TestToggleCaps(UTCCodes[intel]) and (UTCCodes[intel] == "RULEUTC_StealthToggle" or UTCCodes[intel] == "RULEUTC_CloakToggle") and not toggle1 then
					self:SetScriptBit(UTCCodes[intel], false)
					toggle1 = true
				elseif self:TestToggleCaps(UTCCodes[intel]) and UTCCodes[intel] == "RULEUTC_IntelToggle" and not toggle2 then
					self:SetScriptBit(UTCCodes[intel], false)
					toggle2 = true
				else
					self:EnableIntel(intel)
				end
                intEnabled = true
				self.IntelDisables[intel] = 0
            end
			if self.IntelDisables[intel] < 0 then self.IntelDisables[intel] = 0 end
        else
            for k, v in self.IntelDisables do
                if v == 1 then
                    if self:TestToggleCaps(UTCCodes[k]) and (UTCCodes[k] == "RULEUTC_StealthToggle" or UTCCodes[k] == "RULEUTC_CloakToggle") and not toggle1 then
						self:SetScriptBit(UTCCodes[k], false)
						toggle1 = true
					elseif self:TestToggleCaps(UTCCodes[k]) and UTCCodes[k] == "RULEUTC_IntelToggle" and not toggle2 then
						self:SetScriptBit(UTCCodes[k], false)
						toggle2 = true
					else
						self:EnableIntel(k)
					end
                    if self:IsIntelEnabled(k) then
                        intEnabled = true
                    end
					self.IntelDisables[k] = 0
                end
				if self.IntelDisables[k] < 0 then self.IntelDisables[k] = 0 end
            end
        end

        if not self.IntelThread then
            self.IntelThread = self:ForkThread(self.IntelWatchThread)
        end  
      
        if intEnabled then
            self:OnIntelEnabled()
        end
    end,
	
}

end