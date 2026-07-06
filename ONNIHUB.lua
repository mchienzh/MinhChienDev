-- ================= KHỞI TẠO BẢO VỆ & AN TOÀN SERVICE =================
local function SafeGetService(serviceName)
    local success, service = pcall(game.GetService, game, serviceName)
    if success and service then
        if cloneref then return cloneref(service) end
        return service
    end
end

local RunService = SafeGetService("RunService")
local Players = SafeGetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = SafeGetService("UserInputService")
local TweenService = SafeGetService("TweenService")
local TeleportService = SafeGetService("TeleportService")
local HttpService = SafeGetService("HttpService")
local ReplicatedStorage = SafeGetService("ReplicatedStorage")

-- ================= ANTI BAN / KICK PLUS+ (CHẠY NGẦM) =================
pcall(function()
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local oldNamecall = gmt.__namecall
    gmt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then return nil end
        return oldNamecall(self, ...)
    end)
    setreadonly(gmt, true)
end)

local SpoofActive = true
pcall(function()
    if hookmetamethod then
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if SpoofActive and not checkcaller() and self:IsA("Humanoid") and LocalPlayer.Character and self:IsDescendantOf(LocalPlayer.Character) then
                if key == "WalkSpeed" then return 16 end
                if key == "PlatformStand" then return false end
                if key == "HipHeight" then return 0 end
            end
            return oldIndex(self, key)
        end))
    end
end)

local function AutoNukeAntiCheat()
    pcall(function()
        if getconnections then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid", 5) or char:FindFirstChildOfClass("Humanoid")
            if hum then
                for _, sigName in pairs({"Changed", "GetPropertyChangedSignal"}) do
                    local signal = (sigName == "Changed") and hum.Changed or hum:GetPropertyChangedSignal("WalkSpeed")
                    for _, connection in pairs(getconnections(signal)) do
                        connection:Disable()
                    end
                end
            end
        end
    end)
end
task.spawn(AutoNukeAntiCheat)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    AutoNukeAntiCheat()
end)

local BypassTP = true
local function SecureTween(targetCFrame, speed)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root then
        local distance = (root.Position - targetCFrame.Position).Magnitude
        if distance > 150 then
            root.CFrame = root.CFrame * CFrame.new(0, 80, 0)
            task.wait(0.06)
        end
        local duration = distance / speed
        local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
        return tween
    end
end
local function topos(targetPart) SecureTween(targetPart.CFrame * CFrame.new(0, 4, 0), 150) end
local function BTP(targetPart) SecureTween(targetPart.CFrame * CFrame.new(0, 4, 0), 55) end

-- ================= CẤU HÌNH THÔNG SỐ =================
local customSpeed = 130
local flySpeed = 120
local spinSpeed = 136
local currentLanguage = "VI"
local SelectedPlayer = nil

-- ================= NGÔN NGỮ =================
local LangConfig = {
    VI = {
        mainTab = "CHÍNH",
        toolTab = "CÔNG CỤ",
        settingsTab = "CÀI ĐẶT",
        animTab = "HOẠT ẢNH",
        selectTarget = "CHỌN MỤC TIÊU: KHÔNG CÓ",
        targetSelected = "MỤC TIÊU: ",
        speedHack = "TỐC ĐỘ CHẠY",
        noclip = "XUYÊN TƯỜNG",
        telePlayer = "TELE TO PLAYER",
        bringAll = "KÉO TẤT CẢ",
        esp = "HIỂN THỊ",
        fly = "BAY",
        autoWin = "TỰ ĐỘNG THẮNG",
        infJump = "NHẢY VÔ HẠN",
        autoParkour = "TỰ PARKOUR",
        spinBot = "XOAY",
        forceSit = "NGỒI CƯỠNG BỨC",
        fling = "ĐẨY TUNG",
        lay = "NẰM",
        cry = "KHÓC",
        aura = "AURA",
        waterWalk = "ĐI TRÊN NƯỚC",
        antiGrav = "KHÔNG TRỌNG LỰC",
        dance = "NHẢY DANCE",
        wave = "VẪY TAY",
        point = "CHỈ TAY",
        cheer = "CỔ VŨ",
        zombie = "ZOMBIE",
        runSpeedSlider = "TỐC ĐỘ CHẠY",
        flySpeedSlider = "TỐC ĐỘ BAY",
        changeLangBtn = "NGÔN NGỮ: TIẾNG VIỆT",
        serverHop = "ĐỔI SERVER",
        rejoinServer = "VÀO LẠI SERVER",
        tpToolBtn = "GẬY CLICK TP",
        petModeBtn = "BÁM LƯNG",
        copyToolsBtn = "COPY ĐỒ MỤC TIÊU",
        openSpyBtn = "MỞ REMOTE SPY"
    },
    EN = {
        mainTab = "MAIN",
        toolTab = "TOOLS",
        settingsTab = "SETTINGS",
        animTab = "ANIMATIONS",
        selectTarget = "SELECT TARGET: NONE",
        targetSelected = "TARGET: ",
        speedHack = "SPEED HACK",
        noclip = "NOCLIP",
        telePlayer = "TELE TO PLAYER",
        bringAll = "BRING ALL",
        esp = "ESP",
        fly = "FLY",
        autoWin = "AUTO WIN",
        infJump = "INF JUMP",
        autoParkour = "AUTO PARKOUR",
        spinBot = "SPIN",
        forceSit = "FORCE SIT",
        fling = "FLING",
        lay = "LAY DOWN",
        cry = "CRY",
        aura = "AURA",
        waterWalk = "WATER WALK",
        antiGrav = "ANTI GRAV",
        dance = "DANCE",
        wave = "WAVE",
        point = "POINT",
        cheer = "CHEER",
        zombie = "ZOMBIE",
        runSpeedSlider = "WALK SPEED",
        flySpeedSlider = "FLY SPEED",
        changeLangBtn = "LANGUAGE: ENGLISH",
        serverHop = "SERVER HOP",
        rejoinServer = "REJOIN",
        tpToolBtn = "CLICK TP TOOL",
        petModeBtn = "PIGGYBACK",
        copyToolsBtn = "COPY TOOLS",
        openSpyBtn = "OPEN SPY"
    }
}

local function getLangText(key)
    return LangConfig[currentLanguage][key] or key
end

-- ================= REDZ UI ENGINE (NHÚNG TRỰC TIẾP) =================
local RedzUiEngine = {}
local openState = true

function RedzUiEngine:CreateWindow()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if playerGui:FindFirstChild("MinhChienDev") then playerGui.MinhChienDev:Destroy() end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MinhChienDev"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = playerGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 540, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -270, 0.5, -200)
    MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 30, 60)
    MainStroke.Thickness = 1.5
    MainStroke.Parent = MainFrame

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame

    local TopCorner = Instance.new("UICorner")
    TopCorner.CornerRadius = UDim.new(0, 8)
    TopCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.7, 0, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "ONNI HUB"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 25)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -12)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 12
    CloseBtn.Parent = TopBar

    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 5)
    CloseCorner.Parent = CloseBtn

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local SideBar = Instance.new("ScrollingFrame")
    SideBar.Name = "SideBar"
    SideBar.Size = UDim2.new(0, 130, 1, -45)
    SideBar.Position = UDim2.new(0, 5, 0, 40)
    SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    SideBar.BorderSizePixel = 0
    SideBar.ScrollBarThickness = 2
    SideBar.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
    SideBar.Parent = MainFrame

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0, 4)
    SideLayout.Parent = SideBar

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -145, 1, -45)
    ContentContainer.Position = UDim2.new(0, 140, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    local MobileToggle = Instance.new("ImageButton")
    MobileToggle.Name = "MinhChienDev"
    MobileToggle.Size = UDim2.new(0, 50, 0, 50)
    MobileToggle.Position = UDim2.new(0, 10, 0, 80)
    MobileToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MobileToggle.Image = "rbxassetid://74840524656036"
    MobileToggle.ImageColor3 = Color3.fromRGB(255, 255, 255)
    MobileToggle.ScaleType = Enum.ScaleType.Stretch
    MobileToggle.Active = true
    MobileToggle.Draggable = true
    MobileToggle.Parent = ScreenGui

    local MobileCorner = Instance.new("UICorner")
    MobileCorner.CornerRadius = UDim.new(0, 25)
    MobileCorner.Parent = MobileToggle

    local MobileStroke = Instance.new("UIStroke")
    MobileStroke.Color = Color3.fromRGB(255, 30, 60)
    MobileStroke.Thickness = 2
    MobileStroke.Parent = MobileToggle

    MobileToggle.MouseButton1Click:Connect(function()
        openState = not openState
        MainFrame.Visible = openState
    end)

    local tabs = {}
    local firstTab = true

    function tabs:CreateTab(tabName)
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = tabName .. "Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = firstTab
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
        TabPage.Parent = ContentContainer

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.Parent = TabPage

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "Btn"
        TabBtn.Size = UDim2.new(1, -5, 0, 32)
        TabBtn.BackgroundColor3 = firstTab and Color3.fromRGB(30, 15, 18) or Color3.fromRGB(22, 22, 22)
        TabBtn.Text = tabName
        TabBtn.TextColor3 = firstTab and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(180, 180, 180)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 12
        TabBtn.Parent = SideBar

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 5)
        TabBtnCorner.Parent = TabBtn

        local TabBtnStroke = Instance.new("UIStroke")
        TabBtnStroke.Color = firstTab and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(40, 40, 40)
        TabBtnStroke.Thickness = 1
        TabBtnStroke.Parent = TabBtn

        TabBtn.MouseButton1Click:Connect(function()
            for _, page in ipairs(ContentContainer:GetChildren()) do
                if page:IsA("ScrollingFrame") then page.Visible = false end
            end
            for _, btn in ipairs(SideBar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                    local stroke = btn:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke.Color = Color3.fromRGB(40, 40, 40) end
                end
            end
            TabPage.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 18)
            TabBtn.TextColor3 = Color3.fromRGB(255, 30, 60)
            TabBtnStroke.Color = Color3.fromRGB(255, 30, 60)
        end)

        firstTab = false

        local elements = {}

        function elements:CreateSection(sectionText)
            local SecLabel = Instance.new("TextLabel")
            SecLabel.Size = UDim2.new(1, 0, 0, 20)
            SecLabel.BackgroundTransparency = 1
            SecLabel.Text = "—— " .. sectionText .. " ——"
            SecLabel.TextColor3 = Color3.fromRGB(255, 30, 60)
            SecLabel.Font = Enum.Font.GothamBold
            SecLabel.TextSize = 11
            SecLabel.Parent = TabPage
        end

        function elements:CreateButton(btnText, callback)
            local ActionBtn = Instance.new("TextButton")
            ActionBtn.Size = UDim2.new(1, -10, 0, 35)
            ActionBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            ActionBtn.Text = "  " .. btnText
            ActionBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
            ActionBtn.Font = Enum.Font.GothamMedium
            ActionBtn.TextSize = 12
            ActionBtn.TextXAlignment = Enum.TextXAlignment.Left
            ActionBtn.Parent = TabPage

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 5)
            BtnCorner.Parent = ActionBtn

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Color3.fromRGB(35, 35, 35)
            BtnStroke.Thickness = 1
            BtnStroke.Parent = ActionBtn

            ActionBtn.MouseButton1Click:Connect(function()
                ActionBtn.BackgroundColor3 = Color3.fromRGB(40, 24, 26)
                task.wait(0.1)
                ActionBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                pcall(callback)
            end)
        end

        function elements:CreateToggle(toggleText, defaultState, callback)
            local toggled = defaultState

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 38)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            ToggleFrame.Text = ""
            ToggleFrame.Parent = TabPage

            local TFCorner = Instance.new("UICorner")
            TFCorner.CornerRadius = UDim.new(0, 5)
            TFCorner.Parent = ToggleFrame

            local TFStroke = Instance.new("UIStroke")
            TFStroke.Color = Color3.fromRGB(35, 35, 35)
            TFStroke.Thickness = 1
            TFStroke.Parent = ToggleFrame

            local Txt = Instance.new("TextLabel")
            Txt.Size = UDim2.new(0.7, 0, 1, 0)
            Txt.Position = UDim2.new(0, 10, 0, 0)
            Txt.BackgroundTransparency = 1
            Txt.Text = toggleText
            Txt.TextColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
            Txt.Font = Enum.Font.GothamMedium
            Txt.TextSize = 12
            Txt.TextXAlignment = Enum.TextXAlignment.Left
            Txt.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 34, 0, 18)
            Switch.Position = UDim2.new(1, -45, 0.5, -9)
            Switch.BackgroundColor3 = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(45, 45, 45)
            Switch.Parent = ToggleFrame

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(0, 9)
            SwitchCorner.Parent = Switch

            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 14, 0, 14)
            Indicator.Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Indicator.Parent = Switch

            local IndCorner = Instance.new("UICorner")
            IndCorner.CornerRadius = UDim.new(0, 7)
            IndCorner.Parent = Indicator

            local function updateToggle()
                Txt.TextColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
                Switch.BackgroundColor3 = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(45, 45, 45)
                Indicator.Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            end

            ToggleFrame.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateToggle()
                pcall(callback, toggled)
            end)
        end

        function elements:CreateInput(inputText, placeholder, callback)
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, -10, 0, 42)
            InputFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            InputFrame.Parent = TabPage

            local IFCorner = Instance.new("UICorner")
            IFCorner.CornerRadius = UDim.new(0, 5)
            IFCorner.Parent = InputFrame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = inputText
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = InputFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0.45, 0, 0, 26)
            TextBox.Position = UDim2.new(1, -155, 0.5, -13)
            TextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            TextBox.Text = ""
            TextBox.PlaceholderText = placeholder
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 11
            TextBox.ClipsDescendants = true
            TextBox.Parent = InputFrame

            local TBCorner = Instance.new("UICorner")
            TBCorner.CornerRadius = UDim.new(0, 4)
            TBCorner.Parent = TextBox

            local TBStroke = Instance.new("UIStroke")
            TBStroke.Color = Color3.fromRGB(255, 30, 60)
            TBStroke.Thickness = 0.8
            TBStroke.Parent = TextBox

            TextBox.FocusLost:Connect(function() pcall(callback, TextBox.Text) end)
        end

        function elements:CreateDropdown(dropText, listData, callback)
            local expanded = false

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, -10, 0, 38)
            DropFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = TabPage

            local DFCorner = Instance.new("UICorner")
            DFCorner.CornerRadius = UDim.new(0, 5)
            DFCorner.Parent = DropFrame

            local MainBtn = Instance.new("TextButton")
            MainBtn.Size = UDim2.new(1, 0, 0, 38)
            MainBtn.BackgroundTransparency = 1
            MainBtn.Text = "  " .. dropText .. " : " .. tostring(listData[1] or "None")
            MainBtn.TextColor3 = Color3.fromRGB(255, 30, 60)
            MainBtn.Font = Enum.Font.GothamBold
            MainBtn.TextSize = 12
            MainBtn.TextXAlignment = Enum.TextXAlignment.Left
            MainBtn.Parent = DropFrame

            local ItemsScroll = Instance.new("ScrollingFrame")
            ItemsScroll.Size = UDim2.new(1, -10, 0, 100)
            ItemsScroll.Position = UDim2.new(0, 5, 0, 40)
            ItemsScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            ItemsScroll.BorderSizePixel = 0
            ItemsScroll.ScrollBarThickness = 2
            ItemsScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
            ItemsScroll.Parent = DropFrame

            local ScrollLayout = Instance.new("UIListLayout")
            ScrollLayout.Padding = UDim.new(0, 2)
            ScrollLayout.Parent = ItemsScroll

            for _, itemValue in ipairs(listData) do
                local ItemBtn = Instance.new("TextButton")
                ItemBtn.Size = UDim2.new(1, 0, 0, 25)
                ItemBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                ItemBtn.Text = tostring(itemValue)
                ItemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                ItemBtn.Font = Enum.Font.Gotham
                ItemBtn.TextSize = 11
                ItemBtn.Parent = ItemsScroll

                ItemBtn.MouseButton1Click:Connect(function()
                    MainBtn.Text = "  " .. dropText .. " : " .. tostring(itemValue)
                    expanded = false
                    DropFrame.Size = UDim2.new(1, -10, 0, 38)
                    pcall(callback, itemValue)
                end)
            end

            MainBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                DropFrame.Size = expanded and UDim2.new(1, -10, 0, 145) or UDim2.new(1, -10, 0, 38)
            end)
        end

        function elements:CreateSlider(sliderText, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -10, 0, 45)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            SliderFrame.Parent = TabPage

            local SFCorner = Instance.new("UICorner")
            SFCorner.CornerRadius = UDim.new(0, 5)
            SFCorner.Parent = SliderFrame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 2)
            Label.BackgroundTransparency = 1
            Label.Text = sliderText
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0.3, 0, 0, 20)
            ValLabel.Position = UDim2.new(1, -110, 0, 2)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(default)
            ValLabel.TextColor3 = Color3.fromRGB(255, 30, 60)
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 12
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = SliderFrame

            local SliderBar = Instance.new("TextButton")
            SliderBar.Size = UDim2.new(1, -20, 0, 6)
            SliderBar.Position = UDim2.new(0, 10, 0, 28)
            SliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            SliderBar.Text = ""
            SliderBar.Parent = SliderFrame

            local SBCorner = Instance.new("UICorner")
            SBCorner.CornerRadius = UDim.new(0, 3)
            SBCorner.Parent = SliderBar

            local Fill = Instance.new("Frame")
            local initPercent = (default - min) / (max - min)
            Fill.Size = UDim2.new(initPercent, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
            Fill.Parent = SliderBar

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 3)
            FillCorner.Parent = Fill

            local uis = game:GetService("UserInputService")
            local holding = false

            local function updateSliderInput(input)
                local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                local finalVal = math.floor(min + (max - min) * pos)
                ValLabel.Text = tostring(finalVal)
                pcall(callback, finalVal)
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    holding = true
                    updateSliderInput(input)
                end
            end)

            uis.InputChanged:Connect(function(input)
                if holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSliderInput(input)
                end
            end)

            uis.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    holding = false
                end
            end)
        end

        return elements
    end

    return tabs
end

-- ================= TẠO UI MỚI =================
local tabs = RedzUiEngine:CreateWindow()

-- Lưu các toggle state cho animation
local animStates = {
    lay = false,
    cry = false,
    dance = false,
    wave = false,
    point = false,
    cheer = false,
    zombie = false
}

-- Bảng lưu animation tracks
local animTracks = {}

local function playAnimation(animId, loop, callback)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local anim = Instance.new("Animation")
    anim.AnimationId = "rbxassetid://" .. animId
    local track = hum:LoadAnimation(anim)
    track:Play()
    if loop then track:AdjustSpeed(1) track.Looped = true else track.Looped = false end
    if callback then callback(track) end
    return track
end

local function stopAnimation(track)
    if track then
        track:Stop()
        track:Destroy()
    end
end

-- ================= TẠO CÁC TAB =================

-- 1. TAB MAIN
local mainTab = tabs:CreateTab(getLangText("mainTab"))
local mainElems = mainTab

-- Dropdown chọn target
mainElems:CreateSection(getLangText("selectTarget"))
local playerNames = {}
local function updatePlayerList()
    playerNames = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(playerNames, p.Name) end
    end
end
updatePlayerList()
Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

mainElems:CreateDropdown(getLangText("selectTarget"), playerNames, function(value)
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name == value then SelectedPlayer = p break end
    end
end)

-- Các toggle
mainElems:CreateSection("⚙️ Toggles")
local speedToggle = false
mainElems:CreateToggle(getLangText("speedHack"), false, function(state) speedToggle = state end)

local noclipToggle = false
mainElems:CreateToggle(getLangText("noclip"), false, function(state) noclipToggle = state end)

local tpPlayerToggle = false
mainElems:CreateToggle(getLangText("telePlayer"), false, function(state) tpPlayerToggle = state end)

local bringAllToggle = false
mainElems:CreateToggle(getLangText("bringAll"), false, function(state) bringAllToggle = state end)

local espToggle = false
mainElems:CreateToggle(getLangText("esp"), false, function(state) espToggle = state end)

local flyToggle = false
mainElems:CreateToggle(getLangText("fly"), false, function(state) flyToggle = state end)

local winToggle = false
mainElems:CreateToggle(getLangText("autoWin"), false, function(state) winToggle = state end)

local infJumpToggle = false
mainElems:CreateToggle(getLangText("infJump"), false, function(state) infJumpToggle = state end)

local parkourToggle = false
mainElems:CreateToggle(getLangText("autoParkour"), false, function(state) parkourToggle = state end)

local spinToggle = false
mainElems:CreateToggle(getLangText("spinBot"), false, function(state) spinToggle = state end)

local sitToggle = false
mainElems:CreateToggle(getLangText("forceSit"), false, function(state) sitToggle = state end)

local waterToggle = false
mainElems:CreateToggle(getLangText("waterWalk"), false, function(state) waterToggle = state end)

local gravToggle = false
mainElems:CreateToggle(getLangText("antiGrav"), false, function(state) gravToggle = state end)

-- Nút Fling
mainElems:CreateSection("💥 Action")
mainElems:CreateButton(getLangText("fling"), function()
    if not SelectedPlayer then
        print("Chọn mục tiêu trước!")
        return
    end
    pcall(function()
        local root = SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = Instance.new("BodyVelocity", root)
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.new(math.random(-600, 600), math.random(200, 600), math.random(-600, 600))
            task.wait(0.8)
            bv:Destroy()
            root.AssemblyLinearVelocity = root.AssemblyLinearVelocity * 0.1
        end
    end)
end)

-- 2. TAB TOOLS
local toolTab = tabs:CreateTab(getLangText("toolTab"))
local toolElems = toolTab

toolElems:CreateSection("🛠 Tools")
toolElems:CreateButton(getLangText("tpToolBtn"), function()
    pcall(function()
        local tool = Instance.new("Tool")
        tool.Name = "Click TP Tool"
        tool.RequiresHandle = false
        tool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root and mouse.Target then root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
        end)
        tool.Parent = LocalPlayer.Backpack
    end)
end)

local petToggle = false
toolElems:CreateToggle(getLangText("petModeBtn"), false, function(state)
    petToggle = state
    if petToggle and not SelectedPlayer then
        print("Chọn mục tiêu trước!")
        petToggle = false
        return
    end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Sit = petToggle end
end)

toolElems:CreateButton(getLangText("copyToolsBtn"), function()
    if not SelectedPlayer then
        print("Chọn mục tiêu trước!")
        return
    end
    pcall(function()
        local copiedCount = 0
        for _, container in pairs({SelectedPlayer.Backpack, SelectedPlayer.Character}) do
            if container then
                for _, item in pairs(container:GetChildren()) do
                    if item:IsA("Tool") then
                        local clonedTool = item:Clone()
                        clonedTool.Parent = LocalPlayer.Backpack
                        copiedCount = copiedCount + 1
                    end
                end
            end
        end
        print("Đã copy " .. copiedCount .. " items!")
    end)
end)

toolElems:CreateButton(getLangText("openSpyBtn"), function()
    pcall(function()
        loadstring(game:HttpGet("https://pastefy.app/6nDkQPNr/raw"))()
    end)
end)

-- 3. TAB SETTINGS
local settingsTab = tabs:CreateTab(getLangText("settingsTab"))
local settingsElems = settingsTab

settingsElems:CreateSection("🌐 Language")
settingsElems:CreateButton(getLangText("changeLangBtn"), function()
    if currentLanguage == "VI" then currentLanguage = "EN" else currentLanguage = "VI" end
    -- Cần refresh UI? Đơn giản chỉ thay đổi biến, các button text sẽ không tự động thay đổi.
    -- Có thể yêu cầu người dùng khởi động lại UI, nhưng tạm thời chấp nhận.
    print("Ngôn ngữ: " .. currentLanguage)
end)

settingsElems:CreateSection("🌐 Server")
settingsElems:CreateButton(getLangText("serverHop"), function()
    local placeId = game.PlaceId
    local httprequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    if httprequest then
        local response = httprequest({
            Url = string.format("https://games.roblox.com/v1/places/%d/servers/Public?sortOrder=Desc&limit=100", placeId),
            Method = "GET"
        })
        if response and response.StatusCode == 200 then
            local body = HttpService:JSONDecode(response.Body)
            if body and body.data then
                for _, v in pairs(body.data) do
                    if v.playing < v.maxPlayers and v.id ~= game.JobId then
                        TeleportService:TeleportToPlaceInstance(placeId, v.id, LocalPlayer)
                        break
                    end
                end
            end
        end
    else
        TeleportService:Teleport(placeId, LocalPlayer)
    end
end)

settingsElems:CreateButton(getLangText("rejoinServer"), function()
    TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
end)

settingsElems:CreateSection("📊 Sliders")
settingsElems:CreateSlider(getLangText("runSpeedSlider"), 16, 300, customSpeed, function(value)
    customSpeed = value
end)

settingsElems:CreateSlider(getLangText("flySpeedSlider"), 20, 300, flySpeed, function(value)
    flySpeed = value
end)

-- 4. TAB ANIMATIONS
local animTab = tabs:CreateTab(getLangText("animTab"))
local animElems = animTab

animElems:CreateSection("💃 Animations")

-- Lay
animElems:CreateToggle(getLangText("lay"), false, function(state)
    animStates.lay = state
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hum and root then
            if state then
                hum.PlatformStand = true
                hum.Sit = true
                root.CFrame = root.CFrame * CFrame.Angles(math.rad(90), 0, 0)
                root.AssemblyLinearVelocity = Vector3.new(0,0,0)
            else
                hum.PlatformStand = false
                hum.Sit = false
                root.CFrame = root.CFrame * CFrame.Angles(math.rad(-90), 0, 0)
            end
        end
    end)
end)

-- Cry
animElems:CreateToggle(getLangText("cry"), false, function(state)
    animStates.cry = state
    pcall(function()
        local head = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Head")
        if head then
            if state then
                if head:FindFirstChild("CryBill") then head.CryBill:Destroy() end
                local bill = Instance.new("BillboardGui", head)
                bill.Name = "CryBill"
                bill.Size = UDim2.new(0, 60, 0, 60)
                bill.AlwaysOnTop = true
                local lbl = Instance.new("TextLabel", bill)
                lbl.Size = UDim2.new(1,0,1,0)
                lbl.BackgroundTransparency = 1
                lbl.Text = "😭"
                lbl.TextSize = 40
                lbl.TextColor3 = Color3.new(1,1,1)
            else
                if head:FindFirstChild("CryBill") then head.CryBill:Destroy() end
            end
        end
    end)
end)

-- Dance
animElems:CreateToggle(getLangText("dance"), false, function(state)
    animStates.dance = state
    if state then
        if animTracks.dance then stopAnimation(animTracks.dance) end
        animTracks.dance = playAnimation("507768788", true)
    else
        if animTracks.dance then stopAnimation(animTracks.dance) animTracks.dance = nil end
    end
end)

-- Wave
animElems:CreateToggle(getLangText("wave"), false, function(state)
    animStates.wave = state
    if state then
        if animTracks.wave then stopAnimation(animTracks.wave) end
        animTracks.wave = playAnimation("507769975", true)
    else
        if animTracks.wave then stopAnimation(animTracks.wave) animTracks.wave = nil end
    end
end)

-- Point
animElems:CreateToggle(getLangText("point"), false, function(state)
    animStates.point = state
    if state then
        if animTracks.point then stopAnimation(animTracks.point) end
        animTracks.point = playAnimation("507770238", true)
    else
        if animTracks.point then stopAnimation(animTracks.point) animTracks.point = nil end
    end
end)

-- Cheer
animElems:CreateToggle(getLangText("cheer"), false, function(state)
    animStates.cheer = state
    if state then
        if animTracks.cheer then stopAnimation(animTracks.cheer) end
        animTracks.cheer = playAnimation("507771411", true)
    else
        if animTracks.cheer then stopAnimation(animTracks.cheer) animTracks.cheer = nil end
    end
end)

-- Zombie
animElems:CreateToggle(getLangText("zombie"), false, function(state)
    animStates.zombie = state
    if state then
        if animTracks.zombie then stopAnimation(animTracks.zombie) end
        animTracks.zombie = playAnimation("507771977", true)
    else
        if animTracks.zombie then stopAnimation(animTracks.zombie) animTracks.zombie = nil end
    end
end)

-- Aura
animElems:CreateToggle(getLangText("aura"), false, function(state)
    if state then
        if not animTracks.aura then
            local auraParts = {}
            local function createAura()
                for _, v in pairs(auraParts) do if v and v.Parent then v:Destroy() end end
                auraParts = {}
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    for i = 1, 24 do
                        local part = Instance.new("Part")
                        part.Size = Vector3.new(0.5, 0.5, 0.5)
                        part.Anchored = true
                        part.CanCollide = false
                        part.Material = Enum.Material.Neon
                        part.Color = Color3.fromHSV(math.random(), 1, 1)
                        part.Parent = workspace
                        table.insert(auraParts, part)
                    end
                end
                return auraParts
            end
            animTracks.aura = {
                parts = createAura(),
                running = true
            }
        end
    else
        if animTracks.aura then
            for _, v in pairs(animTracks.aura.parts) do if v and v.Parent then v:Destroy() end end
            animTracks.aura = nil
        end
    end
end)

-- ================= VÒNG LẶP CHỨC NĂNG CHÍNH =================

-- Speed hack
RunService.Heartbeat:Connect(function()
    if speedToggle then
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum and hum.MoveDirection.Magnitude > 0 then
                local moveDir = hum.MoveDirection
                root.AssemblyLinearVelocity = Vector3.new(moveDir.X * customSpeed, root.AssemblyLinearVelocity.Y, moveDir.Z * customSpeed)
            end
        end)
    end
end)

-- Noclip
RunService.Stepped:Connect(function()
    if noclipToggle then
        pcall(function()
            if LocalPlayer.Character then
                for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then part.CanCollide = false end
                end
            end
        end)
    end
end)

-- Tele to player
task.spawn(function()
    while task.wait(0.1) do
        if tpPlayerToggle and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
            pcall(function()
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                local targetRoot = SelectedPlayer.Character.HumanoidRootPart
                if myRoot and targetRoot then
                    local targetPos = targetRoot.Position + Vector3.new(0, 3, 0)
                    local currentPos = myRoot.Position
                    local distance = (targetPos - currentPos).Magnitude
                    if distance > 12 then
                        local steps = math.ceil(distance / 12)
                        for step = 1, steps do
                            if not tpPlayerToggle then break end
                            myRoot.CFrame = CFrame.new(currentPos:Lerp(targetPos, step / steps))
                            myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                            RunService.Heartbeat:Wait()
                        end
                    else
                        myRoot.CFrame = CFrame.new(targetPos)
                        myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    end
                end
            end)
        end
    end
end)

-- Bring all
task.spawn(function()
    while task.wait(0.1) do
        if bringAllToggle then
            pcall(function()
                local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if not myRoot then return end
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        local targetRoot = p.Character.HumanoidRootPart
                        targetRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -3)
                        targetRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                    end
                end
            end)
        end
    end
end)

-- ESP
RunService.RenderStepped:Connect(function()
    if espToggle then
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChildOfClass("Humanoid") then
                    local char = p.Character
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if not char:FindFirstChild("ESPHighlight") then
                        local hl = Instance.new("Highlight", char)
                        hl.Name = "ESPHighlight"
                        hl.FillColor = Color3.fromRGB(255, 0, 100)
                        hl.FillTransparency = 0.5
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    end
                    if char:FindFirstChild("Head") and not char.Head:FindFirstChild("ESPBillboard") then
                        local bill = Instance.new("BillboardGui", char.Head)
                        bill.Name = "ESPBillboard"
                        bill.Size = UDim2.new(0, 150, 0, 40)
                        bill.AlwaysOnTop = true
                        bill.StudsOffset = Vector3.new(0, 3, 0)
                        local lbl = Instance.new("TextLabel", bill)
                        lbl.Name = "InfoLabel"
                        lbl.Size = UDim2.new(1, 0, 1, 0)
                        lbl.BackgroundTransparency = 1
                        lbl.TextColor3 = Color3.fromRGB(0, 255, 255)
                        lbl.Font = Enum.Font.GothamBold
                        lbl.TextSize = 10
                    end
                    if char:FindFirstChild("Head") and char.Head:FindFirstChild("ESPBillboard") then
                        char.Head.ESPBillboard.InfoLabel.Text = string.format("%s\n[HP: %d/%d]", p.Name, math.floor(hum.Health), math.floor(hum.MaxHealth))
                    end
                end
            end
        end)
    else
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("ESPHighlight") then p.Character.ESPHighlight:Destroy() end
                if p.Character:FindFirstChild("Head") and p.Character.Head:FindFirstChild("ESPBillboard") then p.Character.Head.ESPBillboard:Destroy() end
            end
        end
    end
end)

-- Fly (nâng cấp)
local bvFly, bgFly
flyToggle = false -- override để tránh xung đột
local function enableFly(state)
    if state then
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if root and hum then
            hum.PlatformStand = true
            bgFly = Instance.new("BodyGyro", root)
            bgFly.maxTorque = Vector3.new(9e9, 9e9, 9e9)
            bgFly.P = 9e4
            bgFly.cframe = root.CFrame
            bvFly = Instance.new("BodyVelocity", root)
            bvFly.maxForce = Vector3.new(9e9, 9e9, 9e9)
            bvFly.velocity = Vector3.new(0,0,0)
            task.spawn(function()
                local camera = workspace.CurrentCamera
                while flyToggle and root and hum.Parent do
                    RunService.Heartbeat:Wait()
                    bgFly.cframe = camera.CFrame
                    local moveDir = hum.MoveDirection
                    local targetVel = Vector3.new(0,0,0)
                    if moveDir.Magnitude > 0.1 then
                        local forward = camera.CFrame.LookVector
                        forward = Vector3.new(forward.X, 0, forward.Z).Unit
                        local right = camera.CFrame.RightVector
                        right = Vector3.new(right.X, 0, right.Z).Unit
                        targetVel = (forward * moveDir.Z + right * moveDir.X) * flySpeed
                        targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)
                    end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                        targetVel = targetVel + Vector3.new(0, flySpeed * 0.8, 0)
                    elseif UserInputService:IsKeyDown(Enum.KeyCode.C) then
                        targetVel = targetVel - Vector3.new(0, flySpeed * 0.8, 0)
                    end
                    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) and not UserInputService:IsKeyDown(Enum.KeyCode.C) then
                        targetVel = Vector3.new(targetVel.X, 0, targetVel.Z)
                    end
                    bvFly.velocity = targetVel
                end
                if bgFly then bgFly:Destroy() end
                if bvFly then bvFly:Destroy() end
                if hum then hum.PlatformStand = false end
            end)
        end
    else
        if bgFly then bgFly:Destroy() end
        if bvFly then bvFly:Destroy() end
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

-- Toggle fly từ UI sẽ gọi enableFly
flyToggle = false

-- Auto Win (nâng cấp)
local winNoclipCache = false
task.spawn(function()
    while task.wait(0.5) do
        if winToggle then
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local target = nil
                    for _, v in pairs(workspace:GetDescendants()) do
                        if v:IsA("BasePart") or v:IsA("SpawnLocation") then
                            local n = v.Name:lower()
                            if n:find("win") or n:find("finish") or n:find("end") or n:find("đích") or n:find("reward") then
                                target = v
                                break
                            end
                        end
                    end
                    if target then
                        -- Bật noclip tạm thời
                        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                            if part:IsA("BasePart") then part.CanCollide = false end
                        end
                        local targetPos = target.CFrame * CFrame.new(0, 5, 0)
                        local tween = TweenService:Create(root, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {CFrame = targetPos})
                        tween:Play()
                        tween.Completed:Wait()
                        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
                        root.AssemblyAngularVelocity = Vector3.new(0,0,0)
                        root.CFrame = targetPos
                    end
                end
            end)
        end
    end
end)

-- Inf Jump
UserInputService.JumpRequest:Connect(function()
    if infJumpToggle and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Anti AFK
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    pcall(function() vu:CaptureController() vu:ClickButton2(Vector2.new()) end)
end)

-- Auto Parkour
RunService.Heartbeat:Connect(function()
    if parkourToggle then
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.MoveDirection.Magnitude > 0 then
                local lookVec = hum.MoveDirection
                local rayParams = RaycastParams.new()
                rayParams.FilterDescendantsInstances = {char}
                rayParams.FilterType = Enum.RaycastFilterType.Exclude
                local checkDropPos = root.Position + (lookVec * 4.5)
                local dropHit = workspace:Raycast(checkDropPos, Vector3.new(0, -7, 0), rayParams)
                local blockHit = workspace:Raycast(root.Position, lookVec * 3.5, rayParams)
                if not dropHit or blockHit then
                    if hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
                end
            end
        end)
    end
end)

-- Spin
RunService.Heartbeat:Connect(function()
    if spinToggle then
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end
        end)
    end
end)

-- Force Sit
RunService.Heartbeat:Connect(function()
    if sitToggle then
        pcall(function()
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum and not hum.Sit then hum.Sit = true end
        end)
    end
end)

-- Water Walk
RunService.Heartbeat:Connect(function()
    if waterToggle then
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local ray = workspace:Raycast(root.Position, Vector3.new(0, -5, 0), RaycastParams.new())
                if ray and ray.Instance and ray.Instance.Material == Enum.Material.Water then
                    local waterPos = ray.Position + Vector3.new(0, 1.5, 0)
                    root.CFrame = CFrame.new(root.Position.X, waterPos.Y, root.Position.Z)
                    root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
                    if hum.MoveDirection.Magnitude > 0 then hum:ChangeState(Enum.HumanoidStateType.Running) end
                end
            end
        end)
    end
end)

-- Anti Gravity
local gravBV = nil
RunService.Heartbeat:Connect(function()
    if gravToggle then
        pcall(function()
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then
                if not gravBV or gravBV.Parent ~= root then
                    gravBV = Instance.new("BodyVelocity", root)
                    gravBV.MaxForce = Vector3.new(0, 9e9, 0)
                    gravBV.Velocity = Vector3.new(0,0,0)
                end
                gravBV.Velocity = Vector3.new(0,0,0)
            end
        end)
    else
        if gravBV then gravBV:Destroy() end
    end
end)

-- Piggyback (pet)
RunService.Heartbeat:Connect(function()
    if petToggle and SelectedPlayer and SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart") then
        pcall(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local targetRoot = SelectedPlayer.Character.HumanoidRootPart
            if myRoot and targetRoot then
                myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 1.5, 1)
                myRoot.AssemblyLinearVelocity = Vector3.new(0,0,0)
                myRoot.AssemblyAngularVelocity = Vector3.new(0,0,0)
            end
        end)
    end
end)

-- Aura loop (nếu có)
task.spawn(function()
    while task.wait(0.1) do
        if animTracks.aura and animTracks.aura.running then
            pcall(function()
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root and animTracks.aura.parts then
                    local parts = animTracks.aura.parts
                    local angleStep = (math.pi * 2) / #parts
                    local radius = 3 + math.sin(tick() * 2) * 0.5
                    for i, part in pairs(parts) do
                        if part and part.Parent then
                            local angle = (i * angleStep) + tick()
                            local x = math.cos(angle) * radius
                            local z = math.sin(angle) * radius
                            local y = math.sin(angle * 0.5 + tick()) * 1.5
                            part.CFrame = root.CFrame * CFrame.new(x, y + 1, z)
                            part.Color = Color3.fromHSV((tick() * 0.1 + i * 0.05) % 1, 1, 1)
                            part.Transparency = 0.1
                        end
                    end
                end
            end)
        end
    end
end)

-- set fps cap
setfpscap(60)