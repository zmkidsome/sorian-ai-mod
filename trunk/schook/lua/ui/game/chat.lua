do
local UiUtilsS = import('/lua/UiUtilsSorian.lua')

function CreateChatList(parent)
    local armies = GetArmiesTable()
    local container = Group(GUI.chatEdit)
    container:DisableHitTest()
    container.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
    container.entries = {}
    local function CreatePlayerEntry(data)
		if not data.human and not data.civilian then
			data.nickname = UiUtilsS.trim(string.gsub(data.nickname,'%b()', '' ))
		end
        local text = UIUtil.CreateText(container, data.nickname, 12, "Arial")
        text:SetColor('ffffffff')
        text:DisableHitTest()
        
        text.BG = Bitmap(text)
        text.BG:SetSolidColor('ff000000')
        text.BG.Depth:Set(function() return text.Depth() - 1 end)
        text.BG.Left:Set(function() return text.Left() - 6 end)
        text.BG.Top:Set(function() return text.Top() - 1 end)
        text.BG.Width:Set(function() return container.Width() + 8 end)
        text.BG.Bottom:Set(function() return text.Bottom() + 1 end)
        
        text.BG.HandleEvent = function(self, event)
            if event.Type == 'MouseEnter' then
                self:SetSolidColor('ff666666')
            elseif event.Type == 'MouseExit' then
                self:SetSolidColor('ff000000')
            elseif event.Type == 'ButtonPress' then
                ChatTo:Set(data.armyID)
                container:Destroy()
                parent.list = nil
                GUI.chatEdit.edit:Enable()
                GUI.chatEdit.edit:AcquireFocus()
            end
            GUI.bg.curTime = 0
        end
        return text
    end
    
    local entries = {
        {nickname = ToStrings.all.caps, armyID = 'all'},
        {nickname = ToStrings.allies.caps, armyID = 'allies'},
    }
    
    for armyID, armyData in armies.armiesTable do
        if armyID != armies.focusArmy and not armyData.civilian then
            table.insert(entries, {nickname = armyData.nickname, armyID = armyID})
        end
    end
    
    local maxWidth = 0
    local height = 0
    for index, data in entries do
        local i = index
        table.insert(container.entries, CreatePlayerEntry(data))
        if container.entries[i].Width() > maxWidth then
            maxWidth = container.entries[i].Width() + 8
        end
        height = height + container.entries[i].Height()
        if i > 1 then
            LayoutHelpers.Above(container.entries[i], container.entries[i-1])
        else
            LayoutHelpers.AtLeftIn(container.entries[i], container)
            LayoutHelpers.AtBottomIn(container.entries[i], container)
        end
    end
    container.Width:Set(maxWidth)
    container.Height:Set(height)
    
    container.LTBG = Bitmap(container, UIUtil.UIFile('/game/chat_brd/drop-box_brd_ul.dds'))
    container.LTBG:DisableHitTest()
    container.LTBG.Right:Set(container.Left)
    container.LTBG.Bottom:Set(container.Top)
    
    container.RTBG = Bitmap(container, UIUtil.UIFile('/game/chat_brd/drop-box_brd_ur.dds'))
    container.RTBG:DisableHitTest()
    container.RTBG.Left:Set(container.Right)
    container.RTBG.Bottom:Set(container.Top)
    
    container.RBBG = Bitmap(container, UIUtil.UIFile('/game/chat_brd/drop-box_brd_lr.dds'))
    container.RBBG:DisableHitTest()
    container.RBBG.Left:Set(container.Right)
    container.RBBG.Top:Set(container.Bottom)
    
    container.RLBG = Bitmap(container, UIUtil.UIFile('/game/chat_brd/drop-box_brd_ll.dds'))
    container.RLBG:DisableHitTest()
    container.RLBG.Right:Set(container.Left)
    container.RLBG.Top:Set(container.Bottom)
    
    container.LBG = Bitmap(container, UIUtil.UIFile('/game/chat_brd/drop-box_brd_vert_l.dds'))
    container.LBG:DisableHitTest()
    container.LBG.Right:Set(container.Left)
    container.LBG.Top:Set(container.Top)
    container.LBG.Bottom:Set(container.Bottom)
    
    container.RBG = Bitmap(container, UIUtil.UIFile('/game/chat_brd/drop-box_brd_vert_r.dds'))
    container.RBG:DisableHitTest()
    container.RBG.Left:Set(container.Right)
    container.RBG.Top:Set(container.Top)
    container.RBG.Bottom:Set(container.Bottom)
    
    container.TBG = Bitmap(container, UIUtil.UIFile('/game/chat_brd/drop-box_brd_horz_um.dds'))
    container.TBG:DisableHitTest()
    container.TBG.Left:Set(container.Left)
    container.TBG.Right:Set(container.Right)
    container.TBG.Bottom:Set(container.Top)
    
    container.BBG = Bitmap(container, UIUtil.UIFile('/game/chat_brd/drop-box_brd_lm.dds'))
    container.BBG:DisableHitTest()
    container.BBG.Left:Set(container.Left)
    container.BBG.Right:Set(container.Right)
    container.BBG.Top:Set(container.Bottom)
    
    function DestroySelf()
        parent:OnClick()
    end
    
    UIMain.AddOnMouseClickedFunc(DestroySelf)
    
    container.OnDestroy = function(self)
        UIMain.RemoveOnMouseClickedFunc(DestroySelf)
    end
    
    return container
end

function CreateChat()
    if GUI.bg then
        GUI.bg.OnClose()
    end
    GUI.bg = CreateChatBackground()
    GUI.chatEdit = CreateChatEdit()
    GUI.bg.OnResize = function(self, x, y, firstFrame)
        if firstFrame then
            self:SetNeedsFrameUpdate(false)
        end
        CreateChatLines()
        GUI.chatContainer:CalcVisible()
    end
    GUI.bg.OnResizeSet = function(self)
        if not self:IsPinned() then
            self:SetNeedsFrameUpdate(true)
        end
        RewrapLog()
        CreateChatLines()
        GUI.chatContainer:CalcVisible()
        GUI.chatEdit.edit:AcquireFocus()
    end
    GUI.bg.OnMove = function(self, x, y, firstFrame)
        if firstFrame then
            self:SetNeedsFrameUpdate(false)
        end
    end
    GUI.bg.OnMoveSet = function(self)
        GUI.chatEdit.edit:AcquireFocus()
        if not self:IsPinned() then
            self:SetNeedsFrameUpdate(true)
        end
    end
    GUI.bg.OnMouseWheel = function(self, rotation)
        local newTop = GUI.chatContainer.top - math.floor(rotation / 100)
        GUI.chatContainer:ScrollSetTop(nil, newTop)
    end
    GUI.bg.OnClose = function(self)
        ToggleChat()
    end
    GUI.bg.OnOptionsSet = function(self)
        GUI.chatContainer:Destroy()
        GUI.chatContainer = false
        for i, v in GUI.chatLines do
            v:Destroy()
        end
        GUI.bg:SetAlpha(ChatOptions.win_alpha, true)
        GUI.chatLines = {}
        CreateChatLines()
        RewrapLog()
        GUI.chatContainer:CalcVisible()
        GUI.chatEdit.edit:AcquireFocus()
        if not GUI.bg.pinned then
            GUI.bg.curTime = 0
            GUI.bg:SetNeedsFrameUpdate(true)
        end
    end
    GUI.bg.OnHideWindow = function(self, hidden)
        if not hidden then
            for i, v in GUI.chatLines do
                v:SetNeedsFrameUpdate(false)
            end
        end
    end
    GUI.bg.curTime = 0
    GUI.bg.pinned = false
    GUI.bg.OnFrame = function(self, delta)
        self.curTime = self.curTime + delta
        if self.curTime > ChatOptions.fade_time then
            ToggleChat()
        end
    end
    GUI.bg.OnPinCheck = function(self, checked)
        GUI.bg.pinned = checked
        GUI.bg:SetNeedsFrameUpdate(not checked)
        GUI.bg.curTime = 0
        GUI.chatEdit.edit:AcquireFocus()
        if checked then
            Tooltip.AddCheckboxTooltip(GUI.bg._pinBtn, 'chat_pinned')
        else
            Tooltip.AddCheckboxTooltip(GUI.bg._pinBtn, 'chat_pin')
        end
    end
    GUI.bg.OnConfigClick = function(self, checked)
        if GUI.config then GUI.config:Destroy() GUI.config = false return end
        CreateConfigWindow()
        GUI.bg:SetNeedsFrameUpdate(false)
        
    end
    for i, v in GetArmiesTable().armiesTable do
        if not v.civilian then
            ChatOptions[i] = true
        end
    end
    GUI.bg:SetAlpha(ChatOptions.win_alpha, true)
    Tooltip.AddButtonTooltip(GUI.bg._closeBtn, 'chat_close')
    GUI.bg.OldHandleEvent = GUI.bg.HandleEvent
    GUI.bg.HandleEvent = function(self, event)
        if event.Type == "WheelRotation" and self:IsHidden() then
            import('/lua/ui/game/worldview.lua').ForwardMouseWheelInput(event)
            return true
        else
            return GUI.bg.OldHandleEvent(self, event)
        end
    end
    
    Tooltip.AddCheckboxTooltip(GUI.bg._pinBtn, 'chat_pin')
    Tooltip.AddControlTooltip(GUI.bg._configBtn, 'chat_config')
    Tooltip.AddControlTooltip(GUI.bg._closeBtn, 'chat_close')
    Tooltip.AddCheckboxTooltip(GUI.chatEdit.camData, 'chat_camera')
    
    ChatOptions['links'] = ChatOptions.links or true
    CreateChatLines()
    RewrapLog()
    GUI.chatContainer:CalcVisible()
    ToggleChat()
end

function ReceiveChat(sender, msg)
	if msg.aisender then
		sender = msg.aisender
	else
		sender = sender or "nil sender"
	end
    if msg.ConsoleOutput then
        print(LOCF("%s %s", sender, msg.ConsoleOutput))
        return
    end
    if not msg.Chat then return end
    if type(msg) == 'string' then
        msg = { text = msg }
    elseif type(msg) != 'table' then
        msg = { text = repr(msg) }
    end
    local armyData = GetArmyData(sender)
    local towho = LOC(ToStrings[msg.to].text) or LOC(ToStrings['private'].text)
    local tokey = ToStrings[msg.to].colorkey or ToStrings['private'].colorkey
	if msg.aisender then
		sender = UiUtilsS.trim(string.gsub(sender,'%b()', '' ))
	end
    local name = sender .. ' ' .. towho
    if msg.echo then
        name = string.format("%s %s:", LOC(ToStrings.to.caps), sender)
    end
    local tempText = WrapText({text = msg.text, name = name})
    -- if text wrap produces no lines (ie text is all white space) then add a blank line
    if table.getn(tempText) == 0 then
        tempText = {""}
    end
	if not msg.aisender then
		UiUtilsS.ProcessAIChat(msg.to, armyData.ArmyID, msg.text)
	end
    local entry = {name = name,
        tokey = tokey,
        color = armyData.color,
        armyID = armyData.ArmyID,
        faction = (armyData.faction or 0)+1,
        text = msg.text,
        wrappedtext = tempText,
        new = true}
    if msg.camera then
        entry.camera = msg.camera
    end
    table.insert(chatHistory, entry)
    if ChatOptions[entry.armyID] then
        if table.getsize(chatHistory) == 1 then
            GUI.chatContainer:CalcVisible()
        else
            GUI.chatContainer:ScrollToBottom()
        end
    end
end

function CreateConfigWindow()
    import('/lua/ui/game/multifunction.lua').CloseMapDialog()
    local windowTextures = {
        tl = UIUtil.SkinnableFile('/game/panel/panel_brd_ul.dds'),
        tr = UIUtil.SkinnableFile('/game/panel/panel_brd_ur.dds'),
        tm = UIUtil.SkinnableFile('/game/panel/panel_brd_horz_um.dds'),
        ml = UIUtil.SkinnableFile('/game/panel/panel_brd_vert_l.dds'),
        m = UIUtil.SkinnableFile('/game/panel/panel_brd_m.dds'),
        mr = UIUtil.SkinnableFile('/game/panel/panel_brd_vert_r.dds'),
        bl = UIUtil.SkinnableFile('/game/panel/panel_brd_ll.dds'),
        bm = UIUtil.SkinnableFile('/game/panel/panel_brd_lm.dds'),
        br = UIUtil.SkinnableFile('/game/panel/panel_brd_lr.dds'),
        borderColor = 'ff415055',
    }
    GUI.config = Window(GetFrame(0), '<LOC chat_0008>Chat Options', nil, nil, nil, true, true, 'chat_config', nil, windowTextures)
    GUI.config.Depth:Set(GetFrame(0):GetTopmostDepth() + 1)
    Tooltip.AddButtonTooltip(GUI.config._closeBtn, 'chat_close')
    GUI.config.Top:Set(function() return GetFrame(0).Bottom() - 700 end)
    GUI.config.Width:Set(300)
    LayoutHelpers.AtHorizontalCenterIn(GUI.config, GetFrame(0))
    LayoutHelpers.ResetRight(GUI.config)
    
    GUI.config.DragTL = Bitmap(GUI.config, UIUtil.SkinnableFile('/game/drag-handle/drag-handle-ul_btn_up.dds'))
    GUI.config.DragTR = Bitmap(GUI.config, UIUtil.SkinnableFile('/game/drag-handle/drag-handle-ur_btn_up.dds'))
    GUI.config.DragBL = Bitmap(GUI.config, UIUtil.SkinnableFile('/game/drag-handle/drag-handle-ll_btn_up.dds'))
    GUI.config.DragBR = Bitmap(GUI.config, UIUtil.SkinnableFile('/game/drag-handle/drag-handle-lr_btn_up.dds'))
    
    LayoutHelpers.AtLeftTopIn(GUI.config.DragTL, GUI.config, -24, -8)
    
    LayoutHelpers.AtRightTopIn(GUI.config.DragTR, GUI.config, -22, -8)
    
    LayoutHelpers.AtLeftIn(GUI.config.DragBL, GUI.config, -24)
    LayoutHelpers.AtBottomIn(GUI.config.DragBL, GUI.config, -8)
    
    LayoutHelpers.AtRightIn(GUI.config.DragBR, GUI.config, -22)
    LayoutHelpers.AtBottomIn(GUI.config.DragBR, GUI.config, -8)
    
    GUI.config.DragTL.Depth:Set(function() return GUI.config.Depth() + 10 end)
    GUI.config.DragTR.Depth:Set(GUI.config.DragTL.Depth)
    GUI.config.DragBL.Depth:Set(GUI.config.DragTL.Depth)
    GUI.config.DragBR.Depth:Set(GUI.config.DragTL.Depth)
    
    GUI.config.DragTL:DisableHitTest()
    GUI.config.DragTR:DisableHitTest()
    GUI.config.DragBL:DisableHitTest()
    GUI.config.DragBR:DisableHitTest()
    
    GUI.config.OnClose = function(self)
        GUI.config:Destroy()
        GUI.config = false
    end
    
    local options = {
        filters = {{type = 'filter', name = '<LOC _Links>Links', key = 'links', tooltip = 'chat_filter'}},
        winOptions = {
                {type = 'color', name = '<LOC _All>', key = 'all_color', tooltip = 'chat_color'},
                {type = 'color', name = '<LOC _Allies>', key = 'allies_color', tooltip = 'chat_color'},
                {type = 'color', name = '<LOC _Private>', key = 'priv_color', tooltip = 'chat_color'},
                {type = 'color', name = '<LOC _Links>', key = 'link_color', tooltip = 'chat_color'},
                {type = 'splitter'},
                {type = 'slider', name = '<LOC chat_0009>Chat Font Size', key = 'font_size', tooltip = 'chat_fontsize', min = 12, max = 18, inc = 2},
                {type = 'slider', name = '<LOC chat_0010>Window Fade Time', key = 'fade_time', tooltip = 'chat_fadetime', min = 5, max = 30, inc = 1},
                {type = 'slider', name = '<LOC chat_0011>Window Alpha', key = 'win_alpha', tooltip = 'chat_alpha', min = 20, max = 100, inc = 1},
        },
    }
        
    local optionGroup = Group(GUI.config:GetClientGroup())
    LayoutHelpers.FillParent(optionGroup, GUI.config:GetClientGroup())
    optionGroup.options = {}
    local tempOptions = {}
    
    local function UpdateOption(key, value)
        if key == 'win_alpha' then
            value = value / 100
        end
        tempOptions[key] = value
    end
    
    local function CreateSplitter()
        local splitter = Bitmap(optionGroup)
        splitter:SetSolidColor('ff000000')
        splitter.Left:Set(optionGroup.Left)
        splitter.Right:Set(optionGroup.Right)
        splitter.Height:Set(2)
        return splitter
    end
    
    local function CreateEntry(data)
        local group = Group(optionGroup)
        if data.type == 'filter' then
            group.name = UIUtil.CreateText(group, data.name, 14, "Arial")
            group.check = UIUtil.CreateCheckboxStd(group, '/dialogs/check-box_btn/radio')
            LayoutHelpers.AtLeftTopIn(group.check, group)
            LayoutHelpers.RightOf(group.name, group.check)
            LayoutHelpers.AtVerticalCenterIn(group.name, group.check)
            group.check.key = data.key
            group.Height:Set(group.check.Height)
            group.Width:Set(function() return group.check.Width() + group.name.Width() end)
            group.check.OnCheck = function(self, checked)
                UpdateOption(self.key, checked)
            end
            if ChatOptions[data.key] then
                group.check:SetCheck(ChatOptions[data.key], true)
            end
        elseif data.type == 'color' then
            group.name = UIUtil.CreateText(group, data.name, 14, "Arial")
            local defValue = ChatOptions[data.key] or 1
            group.color = BitmapCombo(group, chatColors, defValue, true, nil, "UI_Tab_Rollover_01", "UI_Tab_Click_01")
            LayoutHelpers.AtLeftTopIn(group.color, group)
            LayoutHelpers.RightOf(group.name, group.color, 5)
            LayoutHelpers.AtVerticalCenterIn(group.name, group.color)
            group.color.Width:Set(55)
            group.color.key = data.key
            group.Height:Set(group.color.Height)
            group.Width:Set(group.color.Width)
            group.color.OnClick = function(self, index)
                UpdateOption(self.key, index)
            end
        elseif data.type == 'slider' then
            group.name = UIUtil.CreateText(group, data.name, 14, "Arial")
            LayoutHelpers.AtLeftTopIn(group.name, group)
            group.slider = IntegerSlider(group, false, 
                data.min, data.max, 
                data.inc, UIUtil.SkinnableFile('/slider02/slider_btn_up.dds'), 
                UIUtil.SkinnableFile('/slider02/slider_btn_over.dds'), UIUtil.SkinnableFile('/slider02/slider_btn_down.dds'), 
                UIUtil.SkinnableFile('/dialogs/options-02/slider-back_bmp.dds'))
            LayoutHelpers.Below(group.slider, group.name)
            group.slider.key = data.key
            group.Height:Set(function() return group.name.Height() + group.slider.Height() end)
            group.slider.OnValueSet = function(self, newValue)
                UpdateOption(self.key, newValue)
            end
            group.value = UIUtil.CreateText(group, '', 14, "Arial")
            LayoutHelpers.RightOf(group.value, group.slider)
            group.slider.OnValueChanged = function(self, newValue)
                group.value:SetText(string.format('%3d', newValue))
            end
            local defValue = ChatOptions[data.key] or 1
            if data.key == 'win_alpha' then
                defValue = defValue * 100
            end
            group.slider:SetValue(defValue)
            group.Width:Set(200)
        elseif data.type == 'splitter' then
            group.split = CreateSplitter()
            LayoutHelpers.AtTopIn(group.split, group)
            group.Width:Set(group.split.Width)
            group.Height:Set(group.split.Height)
        end
        if data.type != 'splitter' then
            Tooltip.AddControlTooltip(group, data.tooltip or 'chat_filter')
        end
        return group
    end
    
    local armyData = GetArmiesTable()
    for i, v in armyData.armiesTable do
        if not v.civilian then
            table.insert(options.filters, {type = 'filter', name = v.nickname, key = i})
        end
    end
    
    local filterTitle = UIUtil.CreateText(optionGroup, '<LOC chat_0012>Message Filters', 14, "Arial Bold")
    LayoutHelpers.AtLeftTopIn(filterTitle, optionGroup, 5, 5)
    Tooltip.AddControlTooltip(filterTitle, 'chat_filter')
    local index = 1
    for i, v in options.filters do
        optionGroup.options[index] = CreateEntry(v)
        optionGroup.options[index].Left:Set(filterTitle.Left)
        optionGroup.options[index].Right:Set(optionGroup.Right)
        if index == 1 then
            LayoutHelpers.Below(optionGroup.options[index], filterTitle, 5)
        else
            LayoutHelpers.Below(optionGroup.options[index], optionGroup.options[index-1], -2)
        end
        index = index + 1
    end
    local splitIndex = index
    local splitter = CreateSplitter()
    splitter.Top:Set(function() return optionGroup.options[splitIndex-1].Bottom() + 5 end)
    
    local WindowTitle = UIUtil.CreateText(optionGroup, '<LOC chat_0013>Message Colors', 14, "Arial Bold")
    LayoutHelpers.Below(WindowTitle, splitter, 5)
    WindowTitle.Left:Set(filterTitle.Left)
    Tooltip.AddControlTooltip(WindowTitle, 'chat_color')
    
    local firstOption = true
    local optionIndex = 1
    for i, v in options.winOptions do
        optionGroup.options[index] = CreateEntry(v)
        optionGroup.options[index].Data = v
        if firstOption then
            LayoutHelpers.Below(optionGroup.options[index], WindowTitle, 5)
            optionGroup.options[index].Right:Set(function() return filterTitle.Left() + (optionGroup.Width() / 2) end)
            firstOption = false
        elseif v.type == 'color' then
            optionGroup.options[index].Right:Set(function() return filterTitle.Left() + (optionGroup.Width() / 2) end)
            if math.mod(optionIndex, 2) == 1 then
                LayoutHelpers.Below(optionGroup.options[index], optionGroup.options[index-2], 2)
            else
                LayoutHelpers.RightOf(optionGroup.options[index], optionGroup.options[index-1])
            end
        else
            LayoutHelpers.Below(optionGroup.options[index], optionGroup.options[index-1], 4)
            LayoutHelpers.AtHorizontalCenterIn(optionGroup.options[index], optionGroup)
        end
        optionIndex = optionIndex + 1
        index = index + 1
    end
    
    local resetBtn = UIUtil.CreateButtonStd(optionGroup, '/widgets02/small', '<LOC _Reset>', 16)
    LayoutHelpers.Below(resetBtn, optionGroup.options[index-1], 4)
    LayoutHelpers.AtHorizontalCenterIn(resetBtn, optionGroup)
    resetBtn.OnClick = function(self)
        for option, value in defOptions do
            for i, control in optionGroup.options do
                if control.Data.key == option then
                    if control.Data.type == 'slider' then
                        if control.Data.key == 'win_alpha' then
                            value = value * 100
                        end
                        control.slider:SetValue(value)
                    elseif control.Data.type == 'color' then
                        control.color:SetItem(value)
                    end
                    UpdateOption(option, value)
                    break
                end
            end
        end
    end
    
    local okBtn = UIUtil.CreateButtonStd(optionGroup, '/widgets02/small', '<LOC _Ok>', 16)
    LayoutHelpers.Below(okBtn, resetBtn, 4)
    LayoutHelpers.AtLeftIn(okBtn, optionGroup)
    okBtn.OnClick = function(self)
        ChatOptions = table.merged(ChatOptions, tempOptions)
        Prefs.SetToCurrentProfile("chatoptions", ChatOptions)
        GUI.bg:OnOptionsSet()
        GUI.config:Destroy()
        GUI.config = false
    end
    
    local cancelBtn = UIUtil.CreateButtonStd(optionGroup, '/widgets02/small', '<LOC _Cancel>', 16)
    LayoutHelpers.Below(cancelBtn, resetBtn, 4)
    LayoutHelpers.AtRightIn(cancelBtn, optionGroup)
    LayoutHelpers.ResetLeft(cancelBtn)
    cancelBtn.OnClick = function(self)
        GUI.config:Destroy()
        GUI.config = false
    end
    
    
    GUI.config.Bottom:Set(function() return okBtn.Bottom() + 5 end)
end

end