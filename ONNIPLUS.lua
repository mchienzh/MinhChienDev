-- ╔══════════════════════════════════════════════════════════════╗
-- ║      MINHCHIEN HUB v3.0 — UI MỚI (MinhChienUI)             ║
-- ╚══════════════════════════════════════════════════════════════╝

-- =====================================================================
-- PHẦN 1: MINHCHIEN UI LIBRARY (nhúng thẳng)
-- =====================================================================
local RedzUiEngine = {}
local openState    = true

function RedzUiEngine:CreateWindow()
    local Players   = game:GetService("Players")
    local player    = Players.LocalPlayer
    if not player then return end
    local playerGui = player:WaitForChild("PlayerGui")

    if playerGui:FindFirstChild("MinhChienDev") then
        playerGui:FindFirstChild("MinhChienDev"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name          = "MinhChienDev"
    ScreenGui.ResetOnSpawn  = false
    ScreenGui.DisplayOrder  = 999
    ScreenGui.Parent        = playerGui

    -- ── Main Frame ──
    local MainFrame = Instance.new("Frame")
    MainFrame.Name              = "MainFrame"
    MainFrame.Size              = UDim2.new(0, 540, 0, 380)
    MainFrame.Position          = UDim2.new(0.5, -270, 0.5, -190)
    MainFrame.BackgroundColor3  = Color3.fromRGB(15, 15, 15)
    MainFrame.BorderSizePixel   = 0
    MainFrame.Active            = true
    MainFrame.Draggable         = true
    MainFrame.Parent            = ScreenGui
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", MainFrame)
    MainStroke.Color     = Color3.fromRGB(255, 30, 60)
    MainStroke.Thickness = 1.5

    -- ── Top Bar ──
    local TopBar = Instance.new("Frame")
    TopBar.Name             = "TopBar"
    TopBar.Size             = UDim2.new(1, 0, 0, 35)
    TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    TopBar.BorderSizePixel  = 0
    TopBar.Parent           = MainFrame
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 8)

    -- patch bottom of TopBar corners
    local TPatch = Instance.new("Frame")
    TPatch.Size            = UDim2.new(1, 0, 0, 8)
    TPatch.Position        = UDim2.new(0, 0, 1, -8)
    TPatch.BackgroundColor3= Color3.fromRGB(20, 20, 20)
    TPatch.BorderSizePixel = 0
    TPatch.Parent          = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size               = UDim2.new(0.7, 0, 1, 0)
    Title.Position           = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text               = "✦ MINHCHIEN HUB v3.0 ✦"
    Title.TextColor3         = Color3.fromRGB(255, 255, 255)
    Title.TextSize           = 13
    Title.Font               = Enum.Font.GothamBold
    Title.TextXAlignment     = Enum.TextXAlignment.Left
    Title.Parent             = TopBar

    -- Min button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size            = UDim2.new(0, 28, 0, 22)
    MinBtn.Position        = UDim2.new(1, -68, 0.5, -11)
    MinBtn.BackgroundColor3= Color3.fromRGB(28, 28, 14)
    MinBtn.Text            = "—"
    MinBtn.TextColor3      = Color3.fromRGB(255, 210, 50)
    MinBtn.Font            = Enum.Font.GothamBold
    MinBtn.TextSize        = 13
    MinBtn.Parent          = TopBar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 4)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size            = UDim2.new(0, 28, 0, 22)
    CloseBtn.Position        = UDim2.new(1, -36, 0.5, -11)
    CloseBtn.BackgroundColor3= Color3.fromRGB(30, 20, 20)
    CloseBtn.Text            = "X"
    CloseBtn.TextColor3      = Color3.fromRGB(255, 50, 50)
    CloseBtn.Font            = Enum.Font.GothamBold
    CloseBtn.TextSize        = 12
    CloseBtn.Parent          = TopBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function()
        openState = not openState
        MainFrame.Visible = openState
    end)

    -- ── Sidebar ──
    local SideBar = Instance.new("ScrollingFrame")
    SideBar.Name                 = "SideBar"
    SideBar.Size                 = UDim2.new(0, 130, 1, -45)
    SideBar.Position             = UDim2.new(0, 5, 0, 40)
    SideBar.BackgroundColor3     = Color3.fromRGB(18, 18, 18)
    SideBar.BorderSizePixel      = 0
    SideBar.ScrollBarThickness   = 2
    SideBar.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
    SideBar.Parent               = MainFrame
    Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 6)

    local SidePad = Instance.new("UIPadding")
    SidePad.PaddingTop   = UDim.new(0, 5)
    SidePad.PaddingLeft  = UDim.new(0, 4)
    SidePad.PaddingRight = UDim.new(0, 4)
    SidePad.Parent       = SideBar

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0, 4)
    SideLayout.Parent  = SideBar

    -- ── Content ──
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name               = "ContentContainer"
    ContentContainer.Size               = UDim2.new(1, -145, 1, -45)
    ContentContainer.Position           = UDim2.new(0, 140, 0, 40)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent             = MainFrame

    -- ── Mobile toggle ──
    local MobileToggle = Instance.new("ImageButton")
    MobileToggle.Name            = "MinhChienDev"
    MobileToggle.Size            = UDim2.new(0, 50, 0, 50)
    MobileToggle.Position        = UDim2.new(0, 10, 0, 80)
    MobileToggle.BackgroundColor3= Color3.fromRGB(15, 15, 15)
    MobileToggle.Image           = "rbxassetid://74840524656036"
    MobileToggle.ImageColor3     = Color3.fromRGB(255, 255, 255)
    MobileToggle.ScaleType       = Enum.ScaleType.Stretch
    MobileToggle.Active          = true
    MobileToggle.Draggable       = true
    MobileToggle.Parent          = ScreenGui
    Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(0, 25)
    local MS2 = Instance.new("UIStroke", MobileToggle)
    MS2.Color = Color3.fromRGB(255, 30, 60); MS2.Thickness = 2

    MobileToggle.MouseButton1Click:Connect(function()
        openState = not openState
        MainFrame.Visible = openState
    end)

    -- ── Tab factory ──
    local tabs     = {}
    local firstTab = true

    function tabs:CreateTab(tabName)
        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name                 = tabName .. "Page"
        TabPage.Size                 = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible              = firstTab
        TabPage.ScrollBarThickness   = 3
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
        TabPage.CanvasSize           = UDim2.new(0, 0, 0, 0)
        TabPage.AutomaticCanvasSize  = Enum.AutomaticSize.Y
        TabPage.Parent               = ContentContainer

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop   = UDim.new(0, 4)
        PagePad.PaddingLeft  = UDim.new(0, 2)
        PagePad.PaddingRight = UDim.new(0, 4)
        PagePad.Parent       = TabPage

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 5)
        PageLayout.Parent  = TabPage

        local TabBtn = Instance.new("TextButton")
        TabBtn.Name             = tabName .. "Btn"
        TabBtn.Size             = UDim2.new(1, 0, 0, 32)
        TabBtn.BackgroundColor3 = firstTab and Color3.fromRGB(30, 15, 18) or Color3.fromRGB(22, 22, 22)
        TabBtn.Text             = tabName
        TabBtn.TextColor3       = firstTab and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(180, 180, 180)
        TabBtn.Font             = Enum.Font.GothamBold
        TabBtn.TextSize         = 11
        TabBtn.Parent           = SideBar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 5)

        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color     = firstTab and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(40, 40, 40)
        TabStroke.Thickness = 1
        TabStroke.Parent    = TabBtn

        TabBtn.MouseButton1Click:Connect(function()
            for _, pg in ipairs(ContentContainer:GetChildren()) do
                if pg:IsA("ScrollingFrame") then pg.Visible = false end
            end
            for _, btn in ipairs(SideBar:GetChildren()) do
                if btn:IsA("TextButton") then
                    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                    btn.TextColor3       = Color3.fromRGB(180, 180, 180)
                    local sk = btn:FindFirstChildOfClass("UIStroke")
                    if sk then sk.Color = Color3.fromRGB(40, 40, 40) end
                end
            end
            TabPage.Visible         = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 18)
            TabBtn.TextColor3       = Color3.fromRGB(255, 30, 60)
            TabStroke.Color         = Color3.fromRGB(255, 30, 60)
        end)

        firstTab = false

        local elements = {}

        -- Section
        function elements:CreateSection(txt)
            local SL = Instance.new("TextLabel")
            SL.Size               = UDim2.new(1, 0, 0, 18)
            SL.BackgroundTransparency = 1
            SL.Text               = "─── " .. txt .. " ───"
            SL.TextColor3         = Color3.fromRGB(255, 30, 60)
            SL.Font               = Enum.Font.GothamBold
            SL.TextSize           = 10
            SL.Parent             = TabPage
        end

        -- Button
        function elements:CreateButton(btnText, callback)
            local AB = Instance.new("TextButton")
            AB.Size             = UDim2.new(1, 0, 0, 34)
            AB.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            AB.Text             = "  " .. btnText
            AB.TextColor3       = Color3.fromRGB(230, 230, 230)
            AB.Font             = Enum.Font.GothamMedium
            AB.TextSize         = 12
            AB.TextXAlignment   = Enum.TextXAlignment.Left
            AB.Parent           = TabPage
            Instance.new("UICorner", AB).CornerRadius = UDim.new(0, 5)
            local ABS = Instance.new("UIStroke", AB)
            ABS.Color = Color3.fromRGB(35, 35, 35); ABS.Thickness = 1

            AB.MouseButton1Click:Connect(function()
                AB.BackgroundColor3 = Color3.fromRGB(40, 24, 26)
                task.wait(0.1)
                AB.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                pcall(callback)
            end)
            return AB
        end

        -- Toggle
        function elements:CreateToggle(toggleText, defaultState, callback)
            local toggled = defaultState

            local TF = Instance.new("TextButton")
            TF.Size             = UDim2.new(1, 0, 0, 38)
            TF.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            TF.Text             = ""
            TF.Parent           = TabPage
            Instance.new("UICorner", TF).CornerRadius = UDim.new(0, 5)
            local TFS = Instance.new("UIStroke", TF)
            TFS.Color = Color3.fromRGB(35, 35, 35); TFS.Thickness = 1

            local TLbl = Instance.new("TextLabel")
            TLbl.Size               = UDim2.new(0.7, 0, 1, 0)
            TLbl.Position           = UDim2.new(0, 10, 0, 0)
            TLbl.BackgroundTransparency = 1
            TLbl.Text               = toggleText
            TLbl.TextColor3         = toggled and Color3.fromRGB(255,255,255) or Color3.fromRGB(170,170,170)
            TLbl.Font               = Enum.Font.GothamMedium
            TLbl.TextSize           = 11
            TLbl.TextXAlignment     = Enum.TextXAlignment.Left
            TLbl.TextWrapped        = true
            TLbl.Parent             = TF

            local Sw = Instance.new("Frame")
            Sw.Size             = UDim2.new(0, 34, 0, 18)
            Sw.Position         = UDim2.new(1, -44, 0.5, -9)
            Sw.BackgroundColor3 = toggled and Color3.fromRGB(255,30,60) or Color3.fromRGB(45,45,45)
            Sw.Parent           = TF
            Instance.new("UICorner", Sw).CornerRadius = UDim.new(0, 9)

            local Knob = Instance.new("Frame")
            Knob.Size             = UDim2.new(0, 14, 0, 14)
            Knob.Position         = toggled and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
            Knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
            Knob.Parent           = Sw
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 7)

            local function upd()
                TLbl.TextColor3   = toggled and Color3.fromRGB(255,255,255) or Color3.fromRGB(170,170,170)
                Sw.BackgroundColor3 = toggled and Color3.fromRGB(255,30,60) or Color3.fromRGB(45,45,45)
                Knob.Position     = toggled and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
            end

            TF.MouseButton1Click:Connect(function()
                toggled = not toggled
                upd()
                pcall(callback, toggled)
            end)
        end

        -- Input
        function elements:CreateInput(labelText, placeholder, callback)
            local IF = Instance.new("Frame")
            IF.Size             = UDim2.new(1, 0, 0, 40)
            IF.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            IF.Parent           = TabPage
            Instance.new("UICorner", IF).CornerRadius = UDim.new(0, 5)

            local IL = Instance.new("TextLabel")
            IL.Size               = UDim2.new(0.5, 0, 1, 0)
            IL.Position           = UDim2.new(0, 10, 0, 0)
            IL.BackgroundTransparency = 1
            IL.Text               = labelText
            IL.TextColor3         = Color3.fromRGB(200,200,200)
            IL.Font               = Enum.Font.GothamMedium
            IL.TextSize           = 11
            IL.TextXAlignment     = Enum.TextXAlignment.Left
            IL.Parent             = IF

            local TB = Instance.new("TextBox")
            TB.Size             = UDim2.new(0.45, 0, 0, 26)
            TB.Position         = UDim2.new(1, -155, 0.5, -13)
            TB.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            TB.Text             = ""
            TB.PlaceholderText  = placeholder
            TB.TextColor3       = Color3.fromRGB(255,255,255)
            TB.PlaceholderColor3= Color3.fromRGB(80,80,80)
            TB.Font             = Enum.Font.Gotham
            TB.TextSize         = 11
            TB.ClipsDescendants = true
            TB.Parent           = IF
            Instance.new("UICorner", TB).CornerRadius = UDim.new(0, 4)
            local TBS = Instance.new("UIStroke", TB)
            TBS.Color = Color3.fromRGB(255,30,60); TBS.Thickness = 0.8

            TB.FocusLost:Connect(function() pcall(callback, TB.Text) end)
            return TB
        end

        -- Dropdown
        function elements:CreateDropdown(dropText, listData, callback)
            local expanded = false
            local DF = Instance.new("Frame")
            DF.Size             = UDim2.new(1, 0, 0, 36)
            DF.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            DF.ClipsDescendants = true
            DF.Parent           = TabPage
            Instance.new("UICorner", DF).CornerRadius = UDim.new(0, 5)
            local DFS = Instance.new("UIStroke", DF)
            DFS.Color = Color3.fromRGB(255,30,60); DFS.Thickness = 0.8

            local MBtn = Instance.new("TextButton")
            MBtn.Size               = UDim2.new(1, 0, 0, 36)
            MBtn.BackgroundTransparency = 1
            MBtn.Text               = "  " .. dropText .. ": " .. tostring(listData[1] or "—")
            MBtn.TextColor3         = Color3.fromRGB(255,30,60)
            MBtn.Font               = Enum.Font.GothamBold
            MBtn.TextSize           = 11
            MBtn.TextXAlignment     = Enum.TextXAlignment.Left
            MBtn.Parent             = DF

            local IS = Instance.new("ScrollingFrame")
            IS.Size                 = UDim2.new(1, -8, 0, 100)
            IS.Position             = UDim2.new(0, 4, 0, 38)
            IS.BackgroundColor3     = Color3.fromRGB(16, 16, 16)
            IS.BorderSizePixel      = 0
            IS.ScrollBarThickness   = 2
            IS.ScrollBarImageColor3 = Color3.fromRGB(255,30,60)
            IS.Parent               = DF
            Instance.new("UIListLayout", IS).Padding = UDim.new(0, 2)

            local function rebuild(data)
                for _, c in ipairs(IS:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                for _, v in ipairs(data) do
                    local IB = Instance.new("TextButton")
                    IB.Size             = UDim2.new(1, 0, 0, 26)
                    IB.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                    IB.Text             = tostring(v)
                    IB.TextColor3       = Color3.fromRGB(200,200,200)
                    IB.Font             = Enum.Font.Gotham
                    IB.TextSize         = 11
                    IB.Parent           = IS
                    Instance.new("UICorner", IB).CornerRadius = UDim.new(0, 4)
                    IB.MouseButton1Click:Connect(function()
                        MBtn.Text = "  " .. dropText .. ": " .. tostring(v)
                        expanded  = false
                        DF.Size   = UDim2.new(1, 0, 0, 36)
                        pcall(callback, v)
                    end)
                end
            end

            rebuild(listData)

            MBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                DF.Size  = expanded and UDim2.new(1, 0, 0, 142) or UDim2.new(1, 0, 0, 36)
            end)

            return {
                Refresh = function(_, newData)
                    rebuild(newData)
                    MBtn.Text = "  " .. dropText .. ": " .. tostring(newData[1] or "—")
                end,
                SetText = function(_, txt)
                    MBtn.Text = "  " .. dropText .. ": " .. txt
                end,
            }
        end

        -- Slider
        function elements:CreateSlider(sliderText, minV, maxV, defV, callback)
            local SF = Instance.new("Frame")
            SF.Size             = UDim2.new(1, 0, 0, 48)
            SF.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            SF.Parent           = TabPage
            Instance.new("UICorner", SF).CornerRadius = UDim.new(0, 5)

            local SLbl = Instance.new("TextLabel")
            SLbl.Size               = UDim2.new(0.65, 0, 0, 20)
            SLbl.Position           = UDim2.new(0, 10, 0, 3)
            SLbl.BackgroundTransparency = 1
            SLbl.Text               = sliderText .. ": " .. defV
            SLbl.TextColor3         = Color3.fromRGB(200,200,200)
            SLbl.Font               = Enum.Font.GothamMedium
            SLbl.TextSize           = 11
            SLbl.TextXAlignment     = Enum.TextXAlignment.Left
            SLbl.Parent             = SF

            local Bar = Instance.new("TextButton")
            Bar.Size             = UDim2.new(1, -20, 0, 6)
            Bar.Position         = UDim2.new(0, 10, 0, 30)
            Bar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Bar.Text             = ""
            Bar.Parent           = SF
            Instance.new("UICorner", Bar).CornerRadius = UDim.new(0, 3)

            local Fill = Instance.new("Frame")
            Fill.Size             = UDim2.new((defV-minV)/(maxV-minV), 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
            Fill.Parent           = Bar
            Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 3)

            local UIS2   = game:GetService("UserInputService")
            local curVal = defV
            local holding = false

            local function updateSlider(inp)
                local pos = math.clamp(
                    (inp.Position.X - Bar.AbsolutePosition.X) / Bar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                curVal    = math.floor(minV + (maxV - minV) * pos)
                SLbl.Text = sliderText .. ": " .. curVal
                pcall(callback, curVal)
            end

            Bar.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                    holding = true; updateSlider(i)
                end
            end)
            UIS2.InputChanged:Connect(function(i)
                if holding and (i.UserInputType == Enum.UserInputType.MouseMovement
                    or i.UserInputType == Enum.UserInputType.Touch) then
                    updateSlider(i)
                end
            end)
            UIS2.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1
                    or i.UserInputType == Enum.UserInputType.Touch then
                    holding = false
                end
            end)
        end

        return elements
    end
    return tabs
end

-- =====================================================================
-- PHẦN 2: SERVICES & ANTI-BAN
-- =====================================================================
local function SafeGetService(s)
    local ok, svc = pcall(game.GetService, game, s)
    if ok and svc then return (cloneref and cloneref(svc)) or svc end
end

local RunService      = SafeGetService("RunService")
local Players         = SafeGetService("Players")
local LocalPlayer     = Players.LocalPlayer
local UIS             = SafeGetService("UserInputService")
local TweenService    = SafeGetService("TweenService")
local TeleportService = SafeGetService("TeleportService")
local HttpService      = SafeGetService("HttpService")
local StarterGui       = SafeGetService("StarterGui")

-- Anti Kick
pcall(function()
    local gmt = getrawmetatable(game)
    setreadonly(gmt, false)
    local old = gmt.__namecall
    gmt.__namecall = newcclosure(function(self, ...)
        local m = getnamecallmethod()
        if m == "Kick" or m == "kick" then return nil end
        return old(self, ...)
    end)
    setreadonly(gmt, true)
end)

-- Speed spoof
local SpoofActive = true
pcall(function()
    if hookmetamethod then
        local oldIdx
        oldIdx = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if SpoofActive and not checkcaller() and self:IsA("Humanoid")
                and LocalPlayer.Character and self:IsDescendantOf(LocalPlayer.Character) then
                if key == "WalkSpeed"     then return 16    end
                if key == "PlatformStand" then return false end
                if key == "HipHeight"     then return 0     end
            end
            return oldIdx(self, key)
        end))
    end
end)

local function NukeAntiCheat()
    pcall(function()
        if not getconnections then return end
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        local hum  = char:WaitForChild("Humanoid", 5)
        if not hum then return end
        for _, sig in pairs({hum.Changed, hum:GetPropertyChangedSignal("WalkSpeed")}) do
            for _, c in pairs(getconnections(sig)) do c:Disable() end
        end
    end)
end
task.spawn(NukeAntiCheat)
LocalPlayer.CharacterAdded:Connect(function() task.wait(1) NukeAntiCheat() end)

local BypassTP = true

-- =====================================================================
-- PHẦN 3: CONFIG
-- =====================================================================
local customSpeed = 130
local flySpeed    = 120
local spinSpeed   = 55
local hitboxSize  = 8

-- =====================================================================
-- PHẦN 4: TWEEN HELPER
-- =====================================================================
local function SecureTween(cf, spd)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local dist = (root.Position - cf.Position).Magnitude
    if dist > 150 then root.CFrame = root.CFrame * CFrame.new(0, 80, 0); task.wait(0.06) end
    local tw = TweenService:Create(root,
        TweenInfo.new(dist / spd, Enum.EasingStyle.Linear), {CFrame = cf})
    tw:Play(); return tw
end
local function topos(p) SecureTween(p.CFrame * CFrame.new(0, 4, 0), 150) end
local function BTP(p)   SecureTween(p.CFrame * CFrame.new(0, 4, 0), 55)  end

-- =====================================================================
-- PHẦN 5: THÔNG BÁO
-- =====================================================================
local function Notify(title, text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text or "", Duration = dur or 3
        })
    end)
end

-- =====================================================================
-- PHẦN 6: TRẠNG THÁI TOGGLE
-- =====================================================================
local SelectedPlayer = nil
local speedToggle    = false
local noclipToggle   = false
local espToggle      = false
local flyToggle      = false
local winToggle      = false
local ijToggle       = false
local parkourToggle  = false
local spinToggle     = false
local sitToggle      = false
local flingToggle    = false
local freezeToggle   = false
local antiVoidToggle = false
local godmodeToggle  = false
local hitboxToggle   = false
local petToggle      = false

local flyBV, flyBG, winBV = nil, nil, nil
local frozenCF = nil
local FD = {f=false, b=false, l=false, r=false, u=false, d=false}

-- =====================================================================
-- PHẦN 7: FLY D-PAD MOBILE
-- =====================================================================
local tempGui = LocalPlayer:WaitForChild("PlayerGui")
if tempGui:FindFirstChild("MinhChien") then tempGui.MinhChien:Destroy() end

local FlyDpad = Instance.new("ScreenGui")
FlyDpad.Name = "MinhChien"; FlyDpad.ResetOnSpawn = false
FlyDpad.DisplayOrder = 1000; FlyDpad.Parent = tempGui

local DpadFrame = Instance.new("Frame", FlyDpad)
DpadFrame.Size               = UDim2.new(0, 175, 0, 175)
DpadFrame.Position           = UDim2.new(0, 8, 1, -190)
DpadFrame.BackgroundTransparency = 1
DpadFrame.Visible            = false

local DpadFrame2 = Instance.new("Frame", FlyDpad)
DpadFrame2.Size              = UDim2.new(0, 58, 0, 120)
DpadFrame2.Position          = UDim2.new(1, -75, 1, -175)
DpadFrame2.BackgroundTransparency = 1
DpadFrame2.Visible           = false

local function MkDBtn(parent, icon, pos, sz, key)
    local fr = Instance.new("Frame", parent)
    fr.Size = sz; fr.Position = pos
    fr.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    fr.BackgroundTransparency = 0.4
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 8)
    local sk = Instance.new("UIStroke", fr)
    sk.Color = Color3.fromRGB(0, 200, 255); sk.Thickness = 1.5
    local lbl = Instance.new("TextLabel", fr)
    lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
    lbl.Text = icon; lbl.TextColor3 = Color3.fromRGB(0,230,255)
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 17
    local btn = Instance.new("TextButton", fr)
    btn.Size = UDim2.new(1,0,1,0); btn.BackgroundTransparency = 1; btn.Text = ""
    btn.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
            FD[key] = true; fr.BackgroundTransparency = 0.1
        end
    end)
    btn.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.Touch
            or i.UserInputType == Enum.UserInputType.MouseButton1 then
            FD[key] = false; fr.BackgroundTransparency = 0.4
        end
    end)
end

local S = UDim2.new(0, 52, 0, 52)
MkDBtn(DpadFrame, "↑", UDim2.new(0,62,0,0),   S, "f")
MkDBtn(DpadFrame, "↓", UDim2.new(0,62,0,120), S, "b")
MkDBtn(DpadFrame, "←", UDim2.new(0,0,0,60),   S, "l")
MkDBtn(DpadFrame, "→", UDim2.new(0,124,0,60), S, "r")
MkDBtn(DpadFrame2, "⬆", UDim2.new(0,0,0,0),   UDim2.new(1,0,0,52), "u")
MkDBtn(DpadFrame2, "⬇", UDim2.new(0,0,0,64),  UDim2.new(1,0,0,52), "d")

-- =====================================================================
-- PHẦN 8: HÀM FLY
-- =====================================================================
local function EnableFly()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end
    hum.PlatformStand = true
    if flyBG then flyBG:Destroy() end
    if flyBV then flyBV:Destroy() end
    flyBG = Instance.new("BodyGyro", root)
    flyBG.MaxTorque = Vector3.new(9e9,9e9,9e9); flyBG.P = 9e4
    flyBG.CFrame = root.CFrame
    flyBV = Instance.new("BodyVelocity", root)
    flyBV.MaxForce = Vector3.new(9e9,9e9,9e9); flyBV.Velocity = Vector3.zero
    DpadFrame.Visible = true; DpadFrame2.Visible = true
end

local function DisableFly()
    DpadFrame.Visible = false; DpadFrame2.Visible = false
    if flyBG then flyBG:Destroy(); flyBG = nil end
    if flyBV then flyBV:Destroy(); flyBV = nil end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = false end
    for k in pairs(FD) do FD[k] = false end
end

RunService.Heartbeat:Connect(function()
    if not flyToggle or not flyBV or not flyBG then return end
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local camCF = workspace.CurrentCamera.CFrame
        local look  = Vector3.new(camCF.LookVector.X,  0, camCF.LookVector.Z)
        local right = Vector3.new(camCF.RightVector.X, 0, camCF.RightVector.Z)
        if look.Magnitude  > 0.001 then look  = look.Unit  end
        if right.Magnitude > 0.001 then right = right.Unit end
        local vel = Vector3.zero
        if FD.f or UIS:IsKeyDown(Enum.KeyCode.W) then vel += look  * flySpeed end
        if FD.b or UIS:IsKeyDown(Enum.KeyCode.S) then vel -= look  * flySpeed end
        if FD.l or UIS:IsKeyDown(Enum.KeyCode.A) then vel -= right * flySpeed end
        if FD.r or UIS:IsKeyDown(Enum.KeyCode.D) then vel += right * flySpeed end
        if FD.u or UIS:IsKeyDown(Enum.KeyCode.Space) or UIS:IsKeyDown(Enum.KeyCode.E) then
            vel += Vector3.new(0, flySpeed * 0.7, 0)
        end
        if FD.d or UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.Q) then
            vel -= Vector3.new(0, flySpeed * 0.7, 0)
        end
        flyBV.Velocity = vel
        flyBG.CFrame   = camCF
    end)
end)

-- =====================================================================
-- PHẦN 9: AUTO WIN+
-- =====================================================================
local function findWinTarget()
    local kws = {"win","finish","end","đích","reward","goal","stage","complete","checkpoint","flag"}
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("SpawnLocation") or v:IsA("Model") then
            local n = v.Name:lower()
            for _, kw in pairs(kws) do if n:find(kw) then return v end end
        end
    end
end

task.spawn(function()
    while task.wait(0.05) do
        if not winToggle then continue end
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum  = char and char:FindFirstChildOfClass("Humanoid")
            if not root then return end
            for _, p in pairs(char:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
            local target = findWinTarget()
            if not target then return end
            local tPos = target:IsA("Model")
                and (target.PrimaryPart or target:FindFirstChildOfClass("BasePart")) or target
            if not tPos then return end
            local dist = (root.Position - tPos.Position).Magnitude
            if dist < 5 then
                root.CFrame = CFrame.new(tPos.Position + Vector3.new(0,3.5,0))
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                if hum then hum.WalkSpeed = 0 end
                task.wait(0.4)
                if winToggle and hum then hum.WalkSpeed = customSpeed end
            elseif dist < 350 then
                local tw = TweenService:Create(root,
                    TweenInfo.new(math.min(dist/220, 1.8), Enum.EasingStyle.Linear),
                    {CFrame = CFrame.new(tPos.Position + Vector3.new(0,3.5,0))})
                tw:Play()
                task.spawn(function()
                    for _ = 1, 18 do
                        if not winToggle then break end
                        root.AssemblyLinearVelocity = Vector3.zero; task.wait(0.03)
                    end
                end)
                if not winBV then
                    winBV = Instance.new("BodyVelocity", root)
                    winBV.MaxForce = Vector3.new(9e9,9e9,9e9)
                end
                local dir = (tPos.Position - root.Position + Vector3.new(0,3,0))
                if dir.Magnitude > 0 then dir = dir.Unit end
                winBV.Velocity = dir * 90; task.wait(0.35)
                if winBV then winBV.Velocity = Vector3.zero end
            else
                if BypassTP then BTP(tPos) else topos(tPos) end
            end
        end)
    end
end)

-- =====================================================================
-- PHẦN 10: HEARTBEAT LOOPS
-- =====================================================================
-- Speed
RunService.Heartbeat:Connect(function()
    if not speedToggle then return end
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = customSpeed end
    end)
end)

-- Noclip
RunService.Stepped:Connect(function()
    if not noclipToggle then return end
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)
end)

-- Spin
RunService.Heartbeat:Connect(function()
    if not spinToggle then return end
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(spinSpeed), 0) end
    end)
end)

-- Force Sit
RunService.Heartbeat:Connect(function()
    if not sitToggle then return end
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and not hum.Sit then hum.Sit = true end
    end)
end)

-- Parkour
RunService.Heartbeat:Connect(function()
    if not parkourToggle then return end
    pcall(function()
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not hum or not root or hum.MoveDirection.Magnitude == 0 then return end
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {char}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local dropHit  = workspace:Raycast(root.Position + hum.MoveDirection*4.5, Vector3.new(0,-7,0), rp)
        local blockHit = workspace:Raycast(root.Position, hum.MoveDirection*3.5, rp)
        if not dropHit or blockHit then
            if hum.FloorMaterial ~= Enum.Material.Air then
                hum:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end)
end)

-- Fling
task.spawn(function()
    while task.wait(0.04) do
        if not flingToggle or not SelectedPlayer then continue end
        pcall(function()
            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local tRoot  = SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot or not tRoot then return end
            tRoot.CFrame = myRoot.CFrame * CFrame.new(0, 0, -1)
            tRoot.AssemblyLinearVelocity = Vector3.new(
                math.random(-180,180), math.random(200,450), math.random(-180,180))
            myRoot.AssemblyLinearVelocity = Vector3.new(
                math.random(-250,250), math.random(250,600), math.random(-250,250))
        end)
    end
end)

-- Freeze Target
task.spawn(function()
    while task.wait(0.03) do
        if not freezeToggle or not SelectedPlayer then continue end
        pcall(function()
            local tRoot = SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not tRoot then return end
            if not frozenCF then frozenCF = tRoot.CFrame end
            tRoot.CFrame = frozenCF
            tRoot.AssemblyLinearVelocity  = Vector3.zero
            tRoot.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end)

-- Anti Void
RunService.Heartbeat:Connect(function()
    if not antiVoidToggle then return end
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root and root.Position.Y < -80 then
            root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
        end
    end)
end)

-- Godmode
RunService.Heartbeat:Connect(function()
    if not godmodeToggle then return end
    pcall(function()
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.Health = hum.MaxHealth end
    end)
end)

-- Hitbox
RunService.Heartbeat:Connect(function()
    if not hitboxToggle then return end
    pcall(function()
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then root.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize) end
            end
        end
    end)
end)

-- Pet Mode (bám lưng)
local petBV, petBG = nil, nil
RunService.Heartbeat:Connect(function()
    if not petToggle or not SelectedPlayer then return end
    pcall(function()
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local tRoot  = SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myRoot or not tRoot then return end
        if not petBV then
            petBV = Instance.new("BodyVelocity", myRoot)
            petBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        end
        if not petBG then
            petBG = Instance.new("BodyGyro", myRoot)
            petBG.MaxTorque = Vector3.new(9e9,9e9,9e9); petBG.P = 9e4
        end
        local offset = tRoot.CFrame * CFrame.new(0, 0.5, -2)
        petBV.Velocity = (offset.Position - myRoot.Position) * 18
        petBG.CFrame   = tRoot.CFrame
    end)
end)

-- Inf Jump
UIS.JumpRequest:Connect(function()
    if not ijToggle then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
end)

-- Anti AFK
local vu = game:GetService("VirtualUser")
LocalPlayer.Idled:Connect(function()
    pcall(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
end)

-- =====================================================================
-- PHẦN 11: EMOTE & AURA
-- =====================================================================
local ANIM = {
    lie      = "rbxassetid://2506281703", cry   = "rbxassetid://5915770496",
    wave     = "rbxassetid://507770239",  point = "rbxassetid://507770453",
    cheer    = "rbxassetid://507770677",  laugh = "rbxassetid://3576719377",
    dance1   = "rbxassetid://507771019",  dance2= "rbxassetid://507776043",
    dance3   = "rbxassetid://507777826",  sleep = "rbxassetid://2506281703",
    salute   = "rbxassetid://3360689775", headbang="rbxassetid://2319064687",
    think    = "rbxassetid://3576720568", dab   = "rbxassetid://3360693915",
    shrug    = "rbxassetid://3003769597", workout="rbxassetid://3917532562",
    twerk    = "rbxassetid://3360686498", spin  = "rbxassetid://3161891786",
}

local curTrack, auraAttach = nil, nil
local auraOn, auraRgbOn   = false, false

local function StopAnim()
    if curTrack then pcall(function() curTrack:Stop() end); curTrack = nil end
end

local function PlayEmote(id)
    pcall(function()
        StopAnim()
        local char = LocalPlayer.Character
        local hum  = char and char:FindFirstChildOfClass("Humanoid")
        if not hum then return end
        local anim = Instance.new("Animation"); anim.AnimationId = id
        local animator = hum:FindFirstChildOfClass("Animator")
        if not animator then return end
        curTrack = animator:LoadAnimation(anim); curTrack:Play()
    end)
end

local function RemoveAura()
    if auraAttach then pcall(function() auraAttach:Destroy() end); auraAttach = nil end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if root and root:FindFirstChild("_AuraLight") then root._AuraLight:Destroy() end
end

local function CreateAura(r, g, b, rainbow)
    RemoveAura()
    pcall(function()
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return end
        local att = Instance.new("Attachment", root); att.Name = "_AuraAttach"; auraAttach = att
        local pe  = Instance.new("ParticleEmitter", att)
        pe.Size         = NumberSequence.new({
            NumberSequenceKeypoint.new(0,4,0), NumberSequenceKeypoint.new(0.5,2.5,0), NumberSequenceKeypoint.new(1,0,0)})
        pe.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0,0.1,0), NumberSequenceKeypoint.new(0.6,0.4,0), NumberSequenceKeypoint.new(1,1,0)})
        pe.Lifetime = NumberRange.new(0.8,2); pe.Rate = 65; pe.Speed = NumberRange.new(2,7)
        pe.SpreadAngle = Vector2.new(180,180); pe.LightEmission = 1; pe.LightInfluence = 0
        pe.Rotation = NumberRange.new(0,360); pe.RotSpeed = NumberRange.new(-180,180)
        local light = Instance.new("PointLight", root)
        light.Name = "_AuraLight"; light.Brightness = 3.5; light.Range = 16
        light.Color = Color3.fromRGB(r,g,b)
        if rainbow then
            local hue = 0
            task.spawn(function()
                while att and att.Parent do
                    hue = (hue + 0.013) % 1
                    local c1 = Color3.fromHSV(hue, 1, 1); local c2 = Color3.fromHSV((hue+0.4)%1,1,1)
                    pe.Color = ColorSequence.new(c1, c2); light.Color = c1; task.wait(0.05)
                end
            end)
        else
            pe.Color = ColorSequence.new(Color3.fromRGB(r,g,b), Color3.fromRGB(r/2,g/2,b/2))
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    auraAttach = nil; curTrack  = nil
    auraOn = false;   auraRgbOn = false
    task.wait(1)
    if flyToggle then EnableFly() end
    NukeAntiCheat()
end)

-- =====================================================================
-- PHẦN 12: PLAYER LIST HELPER
-- =====================================================================
local function getPlayerNames()
    local names = {"Không có"}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(names, p.Name) end
    end
    return names
end

-- =====================================================================
-- PHẦN 13: XÂY DỰNG UI VỚI MINHCHIENUI
-- =====================================================================
local Window    = RedzUiEngine:CreateWindow()
local MainTab   = Window:CreateTab("⚔ MAIN")
local ToolTab   = Window:CreateTab("🔧 CÔNG CỤ")
local EmoteTab  = Window:CreateTab("💃 HOẠT ẢNH")
local SetTab    = Window:CreateTab("⚙ CÀI ĐẶT")

-- ═══════════════════════ TAB MAIN ═══════════════════════════════════

MainTab:CreateSection("Chọn Mục Tiêu")

-- Dropdown chọn player
local playerDrop = MainTab:CreateDropdown("Mục tiêu", getPlayerNames(), function(val)
    if val == "Không có" then
        SelectedPlayer = nil
    else
        SelectedPlayer = Players:FindFirstChild(val)
    end
    Notify("🎯 Mục tiêu", val, 2)
end)

-- Refresh dropdown khi player thay đổi
local function refreshDrop()
    task.wait(0.5)
    playerDrop:Refresh(getPlayerNames())
end
Players.PlayerAdded:Connect(function() refreshDrop() end)
Players.PlayerRemoving:Connect(function() refreshDrop() end)

MainTab:CreateSection("Di Chuyển")

MainTab:CreateToggle("🏃 Tốc Độ Chạy (Speed Hack)", false, function(on)
    speedToggle = on
    if not on then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = 16 end
    end
end)

MainTab:CreateToggle("👻 Xuyên Tường (Noclip)", false, function(on)
    noclipToggle = on
end)

MainTab:CreateToggle("🪂 Bay (Fly++)", false, function(on)
    flyToggle = on
    if on then EnableFly() else DisableFly() end
end)

MainTab:CreateToggle("♾ Nhảy Vô Hạn", false, function(on)
    ijToggle = on
end)

MainTab:CreateToggle("🅿 Tự Động Parkour", false, function(on)
    parkourToggle = on
end)

MainTab:CreateToggle("🌀 Xoay Vòng (Spin Bot)", false, function(on)
    spinToggle = on
end)

MainTab:CreateToggle("🪑 Tự Động Ngồi", false, function(on)
    sitToggle = on
end)

MainTab:CreateSection("Thắng & Mục Tiêu")

MainTab:CreateToggle("🏆 Auto Win+", false, function(on)
    winToggle = on
    if not on and winBV then winBV:Destroy(); winBV = nil end
end)

MainTab:CreateButton("📡 Tele Đến Mục Tiêu", function()
    if not SelectedPlayer then Notify("⚠️ Chưa chọn target!", "", 2); return end
    local tRoot = SelectedPlayer.Character and SelectedPlayer.Character:FindFirstChild("HumanoidRootPart")
    if tRoot then BTP(tRoot) else Notify("❌ Target không có Character", "", 2) end
end)

MainTab:CreateButton("🧲 Kéo Tất Cả Về Chỗ Mình", function()
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local tRoot = p.Character:FindFirstChild("HumanoidRootPart")
            if tRoot then
                tRoot.CFrame = myRoot.CFrame * CFrame.new(math.random(-3,3), 0, math.random(-3,3))
            end
        end
    end
    Notify("✅ Đã kéo " .. (#Players:GetPlayers()-1) .. " người!", "", 2)
end)

MainTab:CreateToggle("💥 Tung Bay Mục Tiêu (Fling)", false, function(on)
    if on and not SelectedPlayer then
        Notify("⚠️ Chọn target trước!", "", 2)
        return
    end
    flingToggle = on
end)

MainTab:CreateToggle("🧊 Đóng Băng Mục Tiêu (Freeze)", false, function(on)
    if on and not SelectedPlayer then
        Notify("⚠️ Chọn target trước!", "", 2)
        return
    end
    freezeToggle = on
    if not on then frozenCF = nil end
end)

MainTab:CreateSection("Phòng Thủ & Khác")

MainTab:CreateToggle("👁 ESP Hiện Tên Người Chơi", false, function(on)
    espToggle = on
    if not on then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("_ESPBillboard")
                if hl then hl:Destroy() end
            end
        end
    else
        task.spawn(function()
            while espToggle do
                for _, p in pairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        local root = p.Character:FindFirstChild("HumanoidRootPart")
                        if root and not root:FindFirstChild("_ESPBillboard") then
                            local bb = Instance.new("BillboardGui", root)
                            bb.Name = "_ESPBillboard"
                            bb.Size = UDim2.new(0,120,0,30)
                            bb.AlwaysOnTop = true; bb.StudsOffset = Vector3.new(0,3,0)
                            local lbl = Instance.new("TextLabel", bb)
                            lbl.Size = UDim2.new(1,0,1,0); lbl.BackgroundTransparency = 1
                            lbl.Text = p.Name; lbl.TextColor3 = Color3.fromRGB(255,30,60)
                            lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 13
                        end
                    end
                end
                task.wait(1)
            end
        end)
    end
end)

MainTab:CreateToggle("🛡 Godmode (Thử Nghiệm)", false, function(on) godmodeToggle = on end)
MainTab:CreateToggle("⚠️ Chống Rơi Đáy Map (Anti Void)", false, function(on) antiVoidToggle = on end)
MainTab:CreateToggle("📦 Mở Rộng Hitbox", false, function(on)
    hitboxToggle = on
    if not on then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local root = p.Character:FindFirstChild("HumanoidRootPart")
                if root then root.Size = Vector3.new(2,2,1) end
            end
        end
    end
end)

-- ═══════════════════════ TAB CÔNG CỤ ════════════════════════════════

ToolTab:CreateSection("Công Cụ Di Chuyển")

ToolTab:CreateButton("🪄 Nhận Gậy Click TP", function()
    local tool = Instance.new("Tool")
    tool.Name     = "Click TP"
    tool.RequiresHandle = false
    tool.Parent   = LocalPlayer.Backpack
    local clickPart = Instance.new("Part", tool)
    clickPart.Transparency = 1; clickPart.CanCollide = false; clickPart.Size = Vector3.new(1,1,1)
    tool.Activated:Connect(function()
        local ray    = workspace.CurrentCamera:ScreenPointToRay(
            UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y)
        local result = workspace:Raycast(ray.Origin, ray.Direction * 500)
        if result then
            local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if root then root.CFrame = CFrame.new(result.Position + Vector3.new(0,3,0)) end
        end
    end)
    Notify("✅ Đã tạo gậy Click TP!", "Equip trong Backpack.", 3)
end)

ToolTab:CreateToggle("🎒 Bám Lưng Mục Tiêu (Pet Mode)", false, function(on)
    if on and not SelectedPlayer then
        Notify("⚠️ Chọn target trước!", "", 2); return
    end
    petToggle = on
    if not on then
        if petBV then petBV:Destroy(); petBV = nil end
        if petBG then petBG:Destroy(); petBG = nil end
    end
end)

ToolTab:CreateSection("Tiện Ích")

ToolTab:CreateButton("📋 Sao Chép Đồ Của Mục Tiêu", function()
    if not SelectedPlayer then Notify("⚠️ Chọn target trước!", "", 2); return end
    local tBack = SelectedPlayer:FindFirstChildOfClass("Backpack")
    if tBack then
        local count = 0
        for _, tool in pairs(tBack:GetChildren()) do
            if tool:IsA("Tool") then
                local clone = tool:Clone()
                clone.Parent = LocalPlayer.Backpack
                count = count + 1
            end
        end
        Notify("✅ Đã copy " .. count .. " đồ!", "", 3)
    else
        Notify("❌ Target không có Backpack", "", 2)
    end
end)

ToolTab:CreateButton("🕵 Mở Remote Spy", function()
    Notify("⏳ Đang tải Remote Spy...", "", 3)
    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://pastefy.app/6nDkQPNr/raw"))()
        end)
        if not ok then Notify("❌ Lỗi tải Spy", tostring(err):sub(1,40), 4) end
    end)
end)

-- ═══════════════════════ TAB HOẠT ẢNH ═══════════════════════════════

EmoteTab:CreateSection("Emote")

local emoteList = {
    {"😴 Nằm Xuống", ANIM.lie},   {"😭 Khóc", ANIM.cry},
    {"👋 Vẫy Tay", ANIM.wave},    {"👆 Chỉ Tay", ANIM.point},
    {"🎉 Hò Réo", ANIM.cheer},    {"😂 Cười", ANIM.laugh},
    {"💃 Nhảy 1", ANIM.dance1},   {"💃 Nhảy 2", ANIM.dance2},
    {"💃 Nhảy 3", ANIM.dance3},   {"💤 Ngủ Gà", ANIM.sleep},
    {"🫡 Chào", ANIM.salute},     {"🤘 Lắc Đầu", ANIM.headbang},
    {"🤔 Suy Nghĩ", ANIM.think},  {"😎 Dab", ANIM.dab},
    {"🤷 Nhún Vai", ANIM.shrug},  {"💪 Tập Gym", ANIM.workout},
    {"🍑 Twerk", ANIM.twerk},     {"🌀 Xoay", ANIM.spin},
}
for _, e in ipairs(emoteList) do
    local name, id = e[1], e[2]
    EmoteTab:CreateButton(name, function() PlayEmote(id) end)
end

EmoteTab:CreateSection("Hiệu Ứng Aura")

EmoteTab:CreateButton("✨ Aura Vàng", function()
    auraOn = not auraOn; auraRgbOn = false
    if auraOn then CreateAura(255,200,50,false) else RemoveAura() end
end)

EmoteTab:CreateButton("🌈 Aura Du Màu (RGB)", function()
    auraRgbOn = not auraRgbOn; auraOn = false
    if auraRgbOn then CreateAura(255,100,200,true) else RemoveAura() end
end)

EmoteTab:CreateButton("💙 Aura Xanh Dương", function()
    auraOn = false; auraRgbOn = false; CreateAura(80,180,255,false)
end)

EmoteTab:CreateButton("💜 Aura Tím", function()
    auraOn = false; auraRgbOn = false; CreateAura(180,80,255,false)
end)

EmoteTab:CreateButton("⏹ Dừng Tất Cả", function()
    StopAnim(); RemoveAura(); auraOn = false; auraRgbOn = false
    Notify("⏹ Đã dừng", "Emote & Aura đã tắt.", 2)
end)

-- ═══════════════════════ TAB CÀI ĐẶT ═══════════════════════════════

SetTab:CreateSection("Tốc Độ")
SetTab:CreateSlider("🏃 Tốc Độ Chạy", 16, 500, customSpeed, function(v) customSpeed = v end)
SetTab:CreateSlider("🪂 Tốc Độ Bay", 20, 400, flySpeed, function(v) flySpeed = v end)
SetTab:CreateSlider("📦 Kích Thước Hitbox", 3, 30, hitboxSize, function(v) hitboxSize = v end)

SetTab:CreateSection("Server")

SetTab:CreateButton("🌐 Đổi Server Ngẫu Nhiên", function()
    Notify("🔍 Đang tìm server...", "", 3)
    local placeId = game.PlaceId
    task.spawn(function()
        local done = false
        pcall(function()
            local raw = game:HttpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Desc&limit=100"):format(placeId))
            local body = HttpService:JSONDecode(raw)
            local svrs = {}
            if body and body.data then
                for _, v in pairs(body.data) do
                    if type(v)=="table" and tonumber(v.playing) and tonumber(v.maxPlayers)
                        and v.playing < v.maxPlayers and v.id ~= game.JobId then
                        table.insert(svrs, v.id)
                    end
                end
            end
            if #svrs > 0 then
                TeleportService:TeleportToPlaceInstance(placeId, svrs[math.random(1,#svrs)], LocalPlayer)
                done = true
            end
        end)
        if not done then
            pcall(function() TeleportService:Teleport(placeId, LocalPlayer) end)
        end
    end)
end)

SetTab:CreateButton("🔄 Vào Lại Server Cũ", function()
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end)
end)

SetTab:CreateSection("Khác")

SetTab:CreateButton("ℹ️ Thông Tin Script", function()
    Notify("MINHCHIEN HUB v3.0", "UI: MinhChienUI v2\nFly++ | Fling | Emotes | Aura", 5)
end)

-- =====================================================================
-- XONG — Thông báo load
-- =====================================================================
task.delay(0.6, function()
    Notify("✦ MINHCHIEN HUB v3 ✦", "Đã tải thành công!", 4)
end)
