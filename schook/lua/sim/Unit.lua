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
        if intel then
            self.IntelDisables[intel] = self.IntelDisables[intel] + 1
            if self.IntelDisables[intel] == 1 then
				#LOG('*DEBUG: Disabling Intel: ', repr(intel))
				#self:DisableIntel(intel)
				self:SetScriptBit(UTCCodes[intel], true)
				intDisabled = true
			end
        else
            for k, v in self.IntelDisables do
                self.IntelDisables[k] = v + 1
                if self.IntelDisables[k] == 1 then
                    #LOG('*DEBUG: Disabling Intel: ', repr(k))
					self:SetScriptBit(UTCCodes[k], true)
                    #self:DisableIntel(k)
                    intDisabled = true
                end
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
        if intel then
            if self.IntelDisables[intel] == 1 then
                #LOG('*DEBUG: Enabling Intel: ', repr(intel))
				#self:EnableIntel(intel)
				self:SetScriptBit(UTCCodes[intel], false)
                intEnabled = true
            end
            self.IntelDisables[intel] = self.IntelDisables[intel] - 1
        else
            for k, v in self.IntelDisables do
                if v == 1 then
                    #self:EnableIntel(k)
					self:SetScriptBit(UTCCodes[k], false)
                    #LOG('*DEBUG: Enabling Intel: ', repr(k))
                    if self:IsIntelEnabled(k) then
                        intEnabled = true
                    end
                end
                self.IntelDisables[k] = v - 1
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