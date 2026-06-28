-- =====================================================================
-- ONNI HUB - SCRIPT V5 (MERGE V4 DI CHUYỂN NV + AUTO RAID + GHOST SERVER + PLAYER SELECT)
-- =====================================================================

-- =====================================================================
-- PHẦN 1: THƯ VIỆN GIAO DIỆN V4
-- =====================================================================
local RedzUiEngine = {}
local openState = true
local TweenService = game:GetService("TweenService")

function RedzUiEngine:CreateWindow()
    local Players = game:GetService("Players")
    local player = Players.LocalPlayer
    if not player then return end
    local playerGui = player:WaitForChild("PlayerGui")

    if playerGui:FindFirstChild("MinhChienDev") then
        playerGui:FindFirstChild("MinhChienDev"):Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "MinhChienDev"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = playerGui

    -- ── Main Frame ──
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 580, 0, 420)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -210)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    MainFrame.BorderSizePixel = 0
    MainFrame.Active = true
    MainFrame.Draggable = true
    MainFrame.Parent = ScreenGui

    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 30, 60)
    MainStroke.Thickness = 2
    MainStroke.Parent = MainFrame

    task.spawn(function()
        while MainFrame and MainFrame.Parent do
            TweenService:Create(MainStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0.65}):Play()
            task.wait(1.5)
            TweenService:Create(MainStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {Transparency = 0}):Play()
            task.wait(1.5)
        end
    end)

    -- ── Top Bar ──
    local TopBar = Instance.new("Frame")
    TopBar.Size = UDim2.new(1, 0, 0, 38)
    TopBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TopBar.BorderSizePixel = 0
    TopBar.Parent = MainFrame
    Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 10)

    local TopFill = Instance.new("Frame")
    TopFill.Size = UDim2.new(1, 0, 0, 10)
    TopFill.Position = UDim2.new(0, 0, 1, -10)
    TopFill.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
    TopFill.BorderSizePixel = 0
    TopFill.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(0.6, 0, 1, 0)
    Title.Position = UDim2.new(0, 14, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⚡ ONNI HUB  V5.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 30, 0, 24)
    MinBtn.Position = UDim2.new(1, -74, 0.5, -12)
    MinBtn.BackgroundColor3 = Color3.fromRGB(30, 28, 14)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = Color3.fromRGB(255, 210, 50)
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.Parent = TopBar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 24)
    CloseBtn.Position = UDim2.new(1, -40, 0.5, -12)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(35, 14, 14)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 55, 55)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 13
    CloseBtn.Parent = TopBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)

    for _, btn in ipairs({CloseBtn, MinBtn}) do
        local orig = btn.BackgroundColor3
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 30, 30)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.1), {BackgroundColor3 = orig}):Play()
        end)
    end

    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
    MinBtn.MouseButton1Click:Connect(function()
        openState = not openState
        MainFrame.Visible = openState
    end)

    -- ── Sidebar ──
    local SideBar = Instance.new("ScrollingFrame")
    SideBar.Name = "SideBar"
    SideBar.Size = UDim2.new(0, 135, 1, -48)
    SideBar.Position = UDim2.new(0, 5, 0, 43)
    SideBar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
    SideBar.BorderSizePixel = 0
    SideBar.ScrollBarThickness = 2
    SideBar.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
    SideBar.Parent = MainFrame
    Instance.new("UICorner", SideBar).CornerRadius = UDim.new(0, 8)

    local SidePad = Instance.new("UIPadding")
    SidePad.PaddingTop = UDim.new(0, 6)
    SidePad.PaddingLeft = UDim.new(0, 5)
    SidePad.PaddingRight = UDim.new(0, 5)
    SidePad.Parent = SideBar

    local SideLayout = Instance.new("UIListLayout")
    SideLayout.Padding = UDim.new(0, 5)
    SideLayout.Parent = SideBar

    -- ── Content Container ──
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -150, 1, -48)
    ContentContainer.Position = UDim2.new(0, 145, 0, 43)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    -- ── Mobile Toggle ──
    local MobileToggle = Instance.new("ImageButton")
    MobileToggle.Name = "MinhChienDev"
    MobileToggle.Size = UDim2.new(0, 52, 0, 52)
    MobileToggle.Position = UDim2.new(0, 10, 0, 80)
    MobileToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    MobileToggle.Image = "rbxassetid://74840524656036"
    MobileToggle.ImageColor3 = Color3.fromRGB(255, 255, 255)
    MobileToggle.ScaleType = Enum.ScaleType.Stretch
    MobileToggle.Active = true
    MobileToggle.Draggable = true
    MobileToggle.Parent = ScreenGui
    Instance.new("UICorner", MobileToggle).CornerRadius = UDim.new(0, 26)

    local MobileStroke = Instance.new("UIStroke")
    MobileStroke.Color = Color3.fromRGB(255, 30, 60)
    MobileStroke.Thickness = 2.5
    MobileStroke.Parent = MobileToggle

    task.spawn(function()
        while MobileToggle and MobileToggle.Parent do
            TweenService:Create(MobileStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0.7}):Play()
            task.wait(1)
            TweenService:Create(MobileStroke, TweenInfo.new(1, Enum.EasingStyle.Sine), {Transparency = 0}):Play()
            task.wait(1)
        end
    end)

    MobileToggle.MouseButton1Click:Connect(function()
        openState = not openState
        MainFrame.Visible = openState
    end)

    -- ── Tab System ──
    local tabs = {}
    local firstTab = true

    function tabs:CreateTab(tabName, tabIcon)
        local icon = tabIcon or "•"

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = tabName .. "Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = firstTab
        TabPage.ScrollBarThickness = 3
        TabPage.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
        TabPage.Parent = ContentContainer

        local PagePad = Instance.new("UIPadding")
        PagePad.PaddingTop = UDim.new(0, 5)
        PagePad.PaddingLeft = UDim.new(0, 4)
        PagePad.PaddingRight = UDim.new(0, 6)
        PagePad.Parent = TabPage

        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Padding = UDim.new(0, 6)
        PageLayout.Parent = TabPage

        -- Tab button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = tabName .. "Btn"
        TabBtn.Size = UDim2.new(1, 0, 0, 38)
        TabBtn.BackgroundColor3 = firstTab and Color3.fromRGB(35, 12, 18) or Color3.fromRGB(20, 20, 20)
        TabBtn.Text = icon .. "  " .. tabName
        TabBtn.TextColor3 = firstTab and Color3.fromRGB(255, 60, 80) or Color3.fromRGB(160, 160, 160)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 11
        TabBtn.Parent = SideBar
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = firstTab and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(38, 38, 38)
        TabStroke.Thickness = 1
        TabStroke.Parent = TabBtn

        local ActiveBar = Instance.new("Frame")
        ActiveBar.Size = UDim2.new(0, 3, 0.55, 0)
        ActiveBar.Position = UDim2.new(0, 1, 0.225, 0)
        ActiveBar.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
        ActiveBar.Visible = firstTab
        ActiveBar.BorderSizePixel = 0
        ActiveBar.Parent = TabBtn
        Instance.new("UICorner", ActiveBar).CornerRadius = UDim.new(0, 2)

        TabBtn.MouseButton1Click:Connect(function()
            for _, page in ipairs(ContentContainer:GetChildren()) do
                if page:IsA("ScrollingFrame") then page.Visible = false end
            end
            for _, btn in ipairs(SideBar:GetChildren()) do
                if btn:IsA("TextButton") then
                    TweenService:Create(btn, TweenInfo.new(0.18), {
                        BackgroundColor3 = Color3.fromRGB(20, 20, 20),
                        TextColor3 = Color3.fromRGB(160, 160, 160)
                    }):Play()
                    local s = btn:FindFirstChildOfClass("UIStroke")
                    if s then s.Color = Color3.fromRGB(38, 38, 38) end
                    local bar = btn:FindFirstChild("Frame")
                    if bar then bar.Visible = false end
                end
            end
            TabPage.Visible = true
            TweenService:Create(TabBtn, TweenInfo.new(0.18), {
                BackgroundColor3 = Color3.fromRGB(35, 12, 18),
                TextColor3 = Color3.fromRGB(255, 60, 80)
            }):Play()
            TabStroke.Color = Color3.fromRGB(255, 30, 60)
            ActiveBar.Visible = true
        end)

        firstTab = false
        local elements = {}

        -- ─ Section ─
        function elements:CreateSection(sectionText)
            local SecWrap = Instance.new("Frame")
            SecWrap.Size = UDim2.new(1, 0, 0, 24)
            SecWrap.BackgroundTransparency = 1
            SecWrap.Parent = TabPage

            local SecLbl = Instance.new("TextLabel")
            SecLbl.Size = UDim2.new(1, 0, 1, 0)
            SecLbl.BackgroundTransparency = 1
            SecLbl.Text = "▸ " .. sectionText
            SecLbl.TextColor3 = Color3.fromRGB(255, 50, 70)
            SecLbl.Font = Enum.Font.GothamBold
            SecLbl.TextSize = 11
            SecLbl.TextXAlignment = Enum.TextXAlignment.Left
            SecLbl.Parent = SecWrap

            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, 0, 0, 1)
            Line.Position = UDim2.new(0, 0, 1, -1)
            Line.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
            Line.BackgroundTransparency = 0.72
            Line.BorderSizePixel = 0
            Line.Parent = SecWrap
        end

        -- ─ Button ─
        function elements:CreateButton(btnText, callback)
            local ActionBtn = Instance.new("TextButton")
            ActionBtn.Size = UDim2.new(1, 0, 0, 38)
            ActionBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            ActionBtn.Text = "  ▶  " .. btnText
            ActionBtn.TextColor3 = Color3.fromRGB(215, 215, 215)
            ActionBtn.Font = Enum.Font.GothamMedium
            ActionBtn.TextSize = 12
            ActionBtn.TextXAlignment = Enum.TextXAlignment.Left
            ActionBtn.Parent = TabPage
            Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 6)

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Color3.fromRGB(40, 40, 40)
            BtnStroke.Thickness = 1
            BtnStroke.Parent = ActionBtn

            ActionBtn.MouseEnter:Connect(function()
                TweenService:Create(ActionBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
                TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(200, 30, 60), Transparency = 0.4}):Play()
            end)
            ActionBtn.MouseLeave:Connect(function()
                TweenService:Create(ActionBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
                TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(40, 40, 40), Transparency = 0}):Play()
            end)
            ActionBtn.MouseButton1Click:Connect(function()
                TweenService:Create(ActionBtn, TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(55, 18, 26)}):Play()
                task.wait(0.12)
                TweenService:Create(ActionBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
                pcall(callback)
            end)
        end

        -- ─ Toggle ─
        function elements:CreateToggle(toggleText, defaultState, callback)
            local toggled = defaultState

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 44)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            ToggleFrame.Text = ""
            ToggleFrame.Parent = TabPage
            Instance.new("UICorner", ToggleFrame).CornerRadius = UDim.new(0, 6)

            local TFStroke = Instance.new("UIStroke")
            TFStroke.Color = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(40, 40, 40)
            TFStroke.Thickness = 1
            TFStroke.Parent = ToggleFrame

            local StatusDot = Instance.new("Frame")
            StatusDot.Size = UDim2.new(0, 8, 0, 8)
            StatusDot.Position = UDim2.new(0, 10, 0.5, -4)
            StatusDot.BackgroundColor3 = toggled and Color3.fromRGB(50, 220, 100) or Color3.fromRGB(70, 70, 70)
            StatusDot.Parent = ToggleFrame
            Instance.new("UICorner", StatusDot).CornerRadius = UDim.new(0, 4)

            local Txt = Instance.new("TextLabel")
            Txt.Size = UDim2.new(0.6, 0, 1, 0)
            Txt.Position = UDim2.new(0, 24, 0, 0)
            Txt.BackgroundTransparency = 1
            Txt.Text = toggleText
            Txt.TextColor3 = toggled and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(155, 155, 155)
            Txt.Font = Enum.Font.GothamMedium
            Txt.TextSize = 12
            Txt.TextXAlignment = Enum.TextXAlignment.Left
            Txt.TextWrapped = true
            Txt.Parent = ToggleFrame

            local StatusLbl = Instance.new("TextLabel")
            StatusLbl.Size = UDim2.new(0, 36, 0, 18)
            StatusLbl.Position = UDim2.new(1, -84, 0.5, -9)
            StatusLbl.BackgroundTransparency = 1
            StatusLbl.Text = toggled and "BẬT" or "TẮT"
            StatusLbl.TextColor3 = toggled and Color3.fromRGB(50, 220, 100) or Color3.fromRGB(130, 130, 130)
            StatusLbl.Font = Enum.Font.GothamBold
            StatusLbl.TextSize = 10
            StatusLbl.Parent = ToggleFrame

            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 36, 0, 19)
            Switch.Position = UDim2.new(1, -46, 0.5, -9)
            Switch.BackgroundColor3 = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(48, 48, 48)
            Switch.Parent = ToggleFrame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 9)

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 15, 0, 15)
            Knob.Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.Parent = Switch
            Instance.new("UICorner", Knob).CornerRadius = UDim.new(0, 7)

            local function updateVisuals()
                TweenService:Create(Switch, TweenInfo.new(0.2), {
                    BackgroundColor3 = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(48, 48, 48)
                }):Play()
                TweenService:Create(Knob, TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Position = toggled and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                }):Play()
                TweenService:Create(TFStroke, TweenInfo.new(0.2), {
                    Color = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(40, 40, 40)
                }):Play()
                TweenService:Create(Txt, TweenInfo.new(0.2), {
                    TextColor3 = toggled and Color3.fromRGB(240, 240, 240) or Color3.fromRGB(155, 155, 155)
                }):Play()
                TweenService:Create(StatusDot, TweenInfo.new(0.2), {
                    BackgroundColor3 = toggled and Color3.fromRGB(50, 220, 100) or Color3.fromRGB(70, 70, 70)
                }):Play()
                StatusLbl.Text = toggled and "BẬT" or "TẮT"
                StatusLbl.TextColor3 = toggled and Color3.fromRGB(50, 220, 100) or Color3.fromRGB(130, 130, 130)
            end

            ToggleFrame.MouseEnter:Connect(function()
                TweenService:Create(ToggleFrame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(28, 28, 28)}):Play()
            end)
            ToggleFrame.MouseLeave:Connect(function()
                TweenService:Create(ToggleFrame, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
            end)
            ToggleFrame.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateVisuals()
                pcall(callback, toggled)
            end)
        end

        -- ─ Label ─ (MỚI: hiển thị thông tin trạng thái)
        function elements:CreateLabel(labelText, initialValue)
            local LblFrame = Instance.new("Frame")
            LblFrame.Size = UDim2.new(1, 0, 0, 30)
            LblFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
            LblFrame.Parent = TabPage
            Instance.new("UICorner", LblFrame).CornerRadius = UDim.new(0, 6)

            local KeyLbl = Instance.new("TextLabel")
            KeyLbl.Size = UDim2.new(0.45, 0, 1, 0)
            KeyLbl.Position = UDim2.new(0, 10, 0, 0)
            KeyLbl.BackgroundTransparency = 1
            KeyLbl.Text = labelText
            KeyLbl.TextColor3 = Color3.fromRGB(160, 160, 160)
            KeyLbl.Font = Enum.Font.GothamMedium
            KeyLbl.TextSize = 11
            KeyLbl.TextXAlignment = Enum.TextXAlignment.Left
            KeyLbl.Parent = LblFrame

            local ValLbl = Instance.new("TextLabel")
            ValLbl.Size = UDim2.new(0.5, 0, 1, 0)
            ValLbl.Position = UDim2.new(0.48, 0, 0, 0)
            ValLbl.BackgroundTransparency = 1
            ValLbl.Text = tostring(initialValue or "—")
            ValLbl.TextColor3 = Color3.fromRGB(255, 80, 100)
            ValLbl.Font = Enum.Font.GothamBold
            ValLbl.TextSize = 11
            ValLbl.TextXAlignment = Enum.TextXAlignment.Left
            ValLbl.Parent = LblFrame

            return {
                SetValue = function(_, v)
                    ValLbl.Text = tostring(v)
                end,
                GetLabel = function() return ValLbl end,
            }
        end

        -- ─ PlayerPicker (MỚI: chọn mục tiêu ném bom) ─
        function elements:CreatePlayerPicker(labelText, onSelect)
            local selected = "all"

            local WrapFrame = Instance.new("Frame")
            WrapFrame.Size = UDim2.new(1, 0, 0, 96)
            WrapFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
            WrapFrame.ClipsDescendants = false
            WrapFrame.Parent = TabPage
            Instance.new("UICorner", WrapFrame).CornerRadius = UDim.new(0, 6)

            local WStroke = Instance.new("UIStroke")
            WStroke.Color = Color3.fromRGB(50, 50, 50)
            WStroke.Thickness = 1
            WStroke.Parent = WrapFrame

            -- Header: tên + mục tiêu hiện tại
            local HeaderLbl = Instance.new("TextLabel")
            HeaderLbl.Size = UDim2.new(0.8, 0, 0, 24)
            HeaderLbl.Position = UDim2.new(0, 8, 0, 4)
            HeaderLbl.BackgroundTransparency = 1
            HeaderLbl.Text = labelText .. ":  🎯 Tất Cả"
            HeaderLbl.TextColor3 = Color3.fromRGB(255, 80, 100)
            HeaderLbl.Font = Enum.Font.GothamBold
            HeaderLbl.TextSize = 11
            HeaderLbl.TextXAlignment = Enum.TextXAlignment.Left
            HeaderLbl.Parent = WrapFrame

            -- Nút refresh
            local RefBtn = Instance.new("TextButton")
            RefBtn.Size = UDim2.new(0, 22, 0, 22)
            RefBtn.Position = UDim2.new(1, -26, 0, 3)
            RefBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
            RefBtn.Text = "⟳"
            RefBtn.TextColor3 = Color3.fromRGB(255, 30, 60)
            RefBtn.Font = Enum.Font.GothamBold
            RefBtn.TextSize = 13
            RefBtn.Parent = WrapFrame
            Instance.new("UICorner", RefBtn).CornerRadius = UDim.new(0, 4)

            -- Scroll ngang cho list nút player
            local ScrollList = Instance.new("ScrollingFrame")
            ScrollList.Size = UDim2.new(1, -10, 0, 58)
            ScrollList.Position = UDim2.new(0, 5, 0, 32)
            ScrollList.BackgroundTransparency = 1
            ScrollList.ScrollBarThickness = 2
            ScrollList.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
            ScrollList.ScrollingDirection = Enum.ScrollingDirection.X
            ScrollList.AutomaticCanvasSize = Enum.AutomaticSize.X
            ScrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
            ScrollList.Parent = WrapFrame

            local ListLayout = Instance.new("UIListLayout")
            ListLayout.FillDirection = Enum.FillDirection.Horizontal
            ListLayout.Padding = UDim.new(0, 5)
            ListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
            ListLayout.Parent = ScrollList

            local allButtons = {}

            local function setSelected(val, displayName)
                selected = val
                HeaderLbl.Text = labelText .. ":  🎯 " .. displayName
                for _, info in ipairs(allButtons) do
                    info.btn.BackgroundColor3 = (info.val == val)
                        and Color3.fromRGB(140, 20, 40)
                        or Color3.fromRGB(30, 30, 30)
                    info.btn.TextColor3 = (info.val == val)
                        and Color3.fromRGB(255, 200, 210)
                        or Color3.fromRGB(200, 200, 200)
                end
                pcall(onSelect, selected)
            end

            local function makeBtn(val, displayName, isAll)
                local w = isAll and 58 or math.max(64, #displayName * 7 + 16)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(0, w, 0, 32)
                Btn.BackgroundColor3 = (val == selected)
                    and Color3.fromRGB(140, 20, 40) or Color3.fromRGB(30, 30, 30)
                Btn.Text = displayName
                Btn.TextColor3 = (val == selected)
                    and Color3.fromRGB(255, 200, 210) or Color3.fromRGB(200, 200, 200)
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 11
                Btn.Parent = ScrollList
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 5)
                local bs = Instance.new("UIStroke")
                bs.Color = isAll and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(45, 45, 45)
                bs.Thickness = 1
                bs.Parent = Btn

                table.insert(allButtons, {btn = Btn, val = val})

                Btn.MouseButton1Click:Connect(function()
                    setSelected(val, displayName)
                end)
                return Btn
            end

            local function refresh()
                for _, c in ipairs(ScrollList:GetChildren()) do
                    if c:IsA("TextButton") then c:Destroy() end
                end
                allButtons = {}
                makeBtn("all", "Tất Cả", true)
                local plist = game:GetService("Players"):GetPlayers()
                for _, p in ipairs(plist) do
                    if p ~= game:GetService("Players").LocalPlayer then
                        makeBtn(p.Name, p.Name, false)
                    end
                end
                -- Nếu selected player rời đi → reset về all
                local stillValid = (selected == "all")
                if not stillValid then
                    for _, p in ipairs(plist) do
                        if p.Name == selected then stillValid = true; break end
                    end
                end
                if not stillValid then setSelected("all", "Tất Cả") end
            end

            refresh()
            RefBtn.MouseButton1Click:Connect(refresh)

            -- Auto refresh khi có người vào / rời
            game:GetService("Players").PlayerAdded:Connect(function() refresh() end)
            game:GetService("Players").PlayerRemoving:Connect(function() refresh() end)

            return {
                GetSelected = function() return selected end,
                Refresh = refresh,
            }
        end

        return elements
    end
    return tabs
end

-- =====================================================================
-- PHẦN 2: BIẾN & HÀM TIỆN ÍCH
-- =====================================================================

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players           = game:GetService("Players")
local TeleportService   = game:GetService("TeleportService")
local HttpService        = game:GetService("HttpService")
local StarterGui        = game:GetService("StarterGui")
local LocalPlayer       = Players.LocalPlayer

local function SendNotify(title, text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title, Text = text, Duration = duration or 3
        })
    end)
end

SendNotify("⚡ ONNI HUB V5", "Script đã tải thành công! (Merge V4)", 3)

_G.AutoMerge    = false
_G.AutoRaid     = false
_G.AutoLockBase = false
_G.AutoUpgrade  = false
_G.AutoRebirth  = false
_G.AntiStranger = false
_G.RaidTarget   = "all"   -- "all" hoặc tên player cụ thể

-- ─── Tìm RemoteEvent/RemoteFunction ───
local function findRemote(names)
    if type(names) == "string" then names = {names} end
    -- Pass 1: tìm chính xác
    for _, name in ipairs(names) do
        local found = ReplicatedStorage:FindFirstChild(name, true)
        if found then return found end
    end
    -- Pass 2: lowercase fallback
    for _, name in ipairs(names) do
        local lower = name:lower()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction"))
                and obj.Name:lower() == lower then
                return obj
            end
        end
    end
    return nil
end

-- =====================================================================
-- PHẦN 3: GHÉP BOM V4 (DI CHUYỂN NHÂN VẬT - FIX THẬT SỰ)
-- Cơ chế: Teleport nhân vật → cầm bom A → chạy đến bom B → chạm = ghép
-- =====================================================================

local MERGE_EVENTS = {
    "MergeEvent","Merge","MergeNuke","MergeNukes","MergeBombs",
    "CombineNukes","CombineEvent","NukeMerge","BombMerge",
    "Combine","MergeItems","FuseNukes","FuseBombs","Fuse",
}

local PICKUP_EVENTS = {
    "PickupEvent","Pickup","GrabEvent","Grab","HoldBomb","HoldItem",
    "PickBomb","GetBomb","TakeBomb","CollectBomb","PickupItem",
    "GrabItem","CarryEvent","Carry","PickItem","EquipBomb",
}

local UPGRADE_EVENTS = {
    "UpgradeEvent","Upgrade","UpgradeBomb","UpgradeNuke",
    "BuyUpgrade","PurchaseUpgrade","UpgradeBase","LevelUp",
    "UpgradeItem","Buy","Purchase",
}

-- Cache merge event (30 giây)
local _mergeEvCache, _mergeEvTime = nil, 0
local function getCachedMergeEvent()
    if _mergeEvCache and (tick() - _mergeEvTime) < 30 then
        return _mergeEvCache
    end
    local ev = findRemote(MERGE_EVENTS)
    if not ev then
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("merge") or n:find("combine") or n:find("fuse") then
                    ev = obj; break
                end
            end
        end
    end
    _mergeEvCache = ev
    _mergeEvTime  = tick()
    return ev
end

-- Lấy vị trí của object (hỗ trợ Model + BasePart)
local function getObjPosition(obj)
    if obj:IsA("Model") then
        local ok, pos = pcall(function() return obj:GetPivot().Position end)
        if ok and pos then return pos end
        if obj.PrimaryPart then return obj.PrimaryPart.Position end
        for _, v in ipairs(obj:GetDescendants()) do
            if v:IsA("BasePart") then return v.Position end
        end
    elseif obj:IsA("BasePart") then
        return obj.Position
    end
    return nil
end

-- Lấy level bom
local function getObjectLevel(obj)
    for _, attr in ipairs({"Level","Tier","Grade","Power","Rank","Merge","Stage","Value"}) do
        local v = obj:GetAttribute(attr)
        if v and type(v) == "number" then return v end
    end
    for _, child in ipairs(obj:GetChildren()) do
        if child:IsA("IntValue") or child:IsA("NumberValue") then
            local n = child.Name:lower()
            if n=="level" or n=="tier" or n=="grade" or n=="value"
            or n=="rank" or n=="merge" or n=="stage" then
                return child.Value
            end
        end
    end
    local num = obj.Name:match("(%d+)$")
            or obj.Name:match("_(%d+)")
            or obj.Name:match("(%d+)")
    return num and tonumber(num) or 1
end

-- Tìm tất cả bom trong workspace (V4: quét rộng hơn)
local function findAllNukes()
    local nukes = {}
    local seen  = {}
    local BOMB_KW = {"nuke","bomb","missile","rocket","warhead","grenade","mine","weapon","bom"}
    local CONT_KW = {"nuke","bomb","missile","rocket","mine","weapon","bom","merge","item","tile","field","board","grid"}

    local function checkObj(obj)
        if seen[obj] then return end
        seen[obj] = true
        if not (obj:IsA("Model") or obj:IsA("BasePart")) then return end

        -- Bỏ qua nếu parent model đã đăng ký rồi (tránh đếm 2 lần)
        if obj:IsA("BasePart") and obj.Parent and obj.Parent:IsA("Model") then
            if seen[obj.Parent] then return end
        end

        local isNuke = false

        -- 1. Attribute đặc biệt → chắc chắn là bom
        if obj:GetAttribute("CanMerge") == true
        or obj:GetAttribute("Mergeable") == true
        or obj:GetAttribute("IsBomb") == true
        or obj:GetAttribute("IsNuke") == true then
            isNuke = true
        end

        -- 2. Tên object chứa keyword bom
        if not isNuke then
            local nl = obj.Name:lower()
            for _, kw in ipairs(BOMB_KW) do
                if nl:find(kw) then isNuke = true; break end
            end
        end

        -- 3. Tên container (folder/model cha) chứa keyword
        if not isNuke and obj.Parent then
            local pnl = obj.Parent.Name:lower()
            for _, kw in ipairs(CONT_KW) do
                if pnl:find(kw) then isNuke = true; break end
            end
        end

        if isNuke then
            local level = getObjectLevel(obj)
            if not nukes[level] then nukes[level] = {} end
            table.insert(nukes[level], obj)
        end
    end

    -- Quét toàn workspace + Backpack
    for _, obj in ipairs(workspace:GetDescendants()) do checkObj(obj) end
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, obj in ipairs(bp:GetDescendants()) do checkObj(obj) end
    end

    return nukes
end

-- Teleport nhân vật đến vị trí (đứng ngay trên bom)
local function teleportCharTo(pos)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    -- Đứng ngay trên bom (offset Y để không bị ngập vào trong)
    hrp.CFrame = CFrame.new(pos + Vector3.new(0, 3.5, 0))
end

-- Tương tác với bom: thử mọi cơ chế có thể (pickup/touch)
local function interactWithBomb(obj)
    if not (obj and obj.Parent) then return end

    -- 1. ProximityPrompt (phổ biến nhất trong game mới)
    for _, v in ipairs(obj:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            pcall(function() fireproximityprompt(v) end)
        end
    end

    -- 2. ClickDetector
    for _, v in ipairs(obj:GetDescendants()) do
        if v:IsA("ClickDetector") then
            pcall(function() fireclickdetector(v) end)
        end
    end

    -- 3. firetouchinterest: giả lập nhân vật chạm vào bom
    local char = LocalPlayer.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        local targetPart = nil
        if obj:IsA("BasePart") then
            targetPart = obj
        elseif obj:IsA("Model") then
            targetPart = obj.PrimaryPart or obj:FindFirstChildOfClass("BasePart")
        end
        if hrp and targetPart then
            pcall(function() firetouchinterest(hrp, targetPart, 0) end)
            task.wait(0.04)
            pcall(function() firetouchinterest(targetPart, hrp, 0) end)
        end
    end

    -- 4. Pickup RemoteEvent (nếu game dùng event riêng để cầm bom)
    local pickEv = findRemote(PICKUP_EVENTS)
    if pickEv then
        pcall(function() pickEv:FireServer(obj) end)
        task.wait(0.02)
        pcall(function() pickEv:FireServer(obj.Name) end)
    end
end

-- ─── performMerge V4: Di chuyển nhân vật để ghép bom ───
-- Luồng: teleport đến bom A → tương tác (cầm) → teleport đến bom B → chạm = ghép
local function performMerge()
    local char = LocalPlayer.Character
    if not char then return false, 0 end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false, 0 end

    local mergeEvent = getCachedMergeEvent()
    local nukes      = findAllNukes()
    local total      = 0
    local merged     = 0

    for _, list in pairs(nukes) do total = total + #list end
    if total == 0 then return false, 0 end

    -- Lưu vị trí gốc để trả về sau khi ghép xong
    local savedCF = hrp.CFrame

    for level, list in pairs(nukes) do
        local i = 1
        while i + 1 <= #list do
            if not _G.AutoMerge then break end

            local a, b = list[i], list[i + 1]
            if not (a and a.Parent) or not (b and b.Parent) then
                i = i + 1
                continue
            end

            local posA = getObjPosition(a)
            local posB = getObjPosition(b)

            if posA and posB then
                -- ══ BƯỚC 1: Đến bom A → cầm lên ══
                teleportCharTo(posA)
                task.wait(0.3)           -- chờ server nhận vị trí
                interactWithBomb(a)
                task.wait(0.2)

                -- ══ BƯỚC 2: Đến bom B → chạm để ghép ══
                teleportCharTo(posB)
                task.wait(0.3)
                interactWithBomb(b)
                task.wait(0.2)

                -- ══ BƯỚC 3: Gửi RemoteEvent backup (nếu game có) ══
                if mergeEvent then
                    if mergeEvent:IsA("RemoteFunction") then
                        pcall(function() mergeEvent:InvokeServer(a, b) end)
                        task.wait(0.03)
                        pcall(function() mergeEvent:InvokeServer(a, b, level) end)
                    else
                        pcall(function() mergeEvent:FireServer(a, b) end)
                        task.wait(0.03)
                        pcall(function() mergeEvent:FireServer(a, b, level) end)
                        task.wait(0.03)
                        pcall(function() mergeEvent:FireServer({a, b}) end)
                        task.wait(0.03)
                        pcall(function() mergeEvent:FireServer(a.Name, b.Name) end)
                    end
                end

                merged = merged + 1
            end

            i = i + 2
            task.wait(0.15)  -- delay giữa mỗi cặp bom
        end
    end

    -- Trả nhân vật về vị trí ban đầu
    pcall(function()
        if hrp and hrp.Parent then
            hrp.CFrame = savedCF
        end
    end)

    return merged > 0, total
end

-- =====================================================================
-- PHẦN 4: GHOST HOP V3 (FIX 0 NGƯỜI + GHOST SERVER THẬT)
-- =====================================================================

-- ─── Ghost Server Thật: tạo server riêng, người khác KHÔNG vào được ───
local function CreateGhostServer()
    SendNotify("👻 Ghost Server", "Đang tạo server ma riêng...", 4)
    task.spawn(function()
        -- ReserveServer tạo private server chỉ bạn vào được
        local ok, accessCode = pcall(function()
            return TeleportService:ReserveServer(game.PlaceId)
        end)

        if ok and accessCode and accessCode ~= "" then
            _G.GhostAccessCode = accessCode
            SendNotify("✅ Server Ma!", "Đã tạo! Người khác KHÔNG thể thấy/vào.\nĐang teleport...", 5)
            task.wait(1.2)
            local tok, terr = pcall(function()
                TeleportService:TeleportToPrivateServer(game.PlaceId, accessCode, {LocalPlayer})
            end)
            if not tok then
                SendNotify("❌ Teleport lỗi", tostring(terr):sub(1, 60), 4)
            end
        else
            local errMsg = not ok and tostring(accessCode):sub(1, 50) or "Game không cho tạo server riêng."
            SendNotify("❌ Lỗi Ghost", errMsg .. "\nĐang hop server ít người nhất...", 4)
            task.wait(1)
            -- Fallback: hop server ít người nhất
            _G._hopFallback = true
        end
    end)
end

-- ─── GhostHopV3: tìm server ít người, FIX 0 người (dùng ReserveServer) ───
local function GhostHopV2(maxAllowed)
    maxAllowed = maxAllowed or 1

    -- FIX: server 0 người không xuất hiện trong API Roblox
    -- → dùng ReserveServer để tạo server hoàn toàn trống
    if maxAllowed == 0 then
        CreateGhostServer()
        return
    end

    local label = "phòng ≤" .. maxAllowed .. " người"
    SendNotify("👻 Ghost Hop V3", "Đang quét " .. label .. "...", 4)

    local placeId    = game.PlaceId
    local cursor     = ""
    local bestServer = nil
    local scanned    = 0
    local MAX_PAGES  = 15 -- tăng lên 15 trang

    task.spawn(function()
        for page = 1, MAX_PAGES do
            local url = "https://games.roblox.com/v1/games/"
                .. placeId
                .. "/servers/Public?sortOrder=Asc&limit=100"
            if cursor ~= "" then url = url .. "&cursor=" .. cursor end

            local ok, raw = pcall(function() return game:HttpGet(url) end)
            if not ok or not raw or raw == "" then break end

            local jok, json = pcall(function() return HttpService:JSONDecode(raw) end)
            if not jok or not json or not json.data then break end

            scanned = scanned + #json.data

            for _, srv in ipairs(json.data) do
                -- Bỏ qua server hiện tại
                if srv.id == game.JobId then continue end
                local playing = srv.playing or 0
                local maxP    = srv.maxPlayers or 999
                -- Server phải không đầy và đủ điều kiện
                if playing <= maxAllowed and playing < maxP then
                    if bestServer == nil or playing < (bestServer.playing or 999) then
                        bestServer = srv
                    end
                end
            end

            -- Tìm thấy server hoàn hảo (playing = 1) thì dừng sớm
            if bestServer and (bestServer.playing or 0) <= 1 then break end

            if json.nextPageCursor and json.nextPageCursor ~= "" then
                cursor = json.nextPageCursor
            else
                break
            end

            task.wait(0.1)
        end

        SendNotify("📊 Đã quét", scanned .. " servers.", 2)

        if bestServer then
            local p = bestServer.playing or 0
            SendNotify("✅ Tìm thấy!", "Server có " .. p .. " người. Đang teleport...", 5)
            task.wait(1.2)
            pcall(function()
                TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
            end)
        else
            -- Không tìm được → tạo ghost server thay thế
            SendNotify("⚠️ Không tìm được", "Đang tạo server ma thay thế...", 3)
            task.wait(0.8)
            CreateGhostServer()
        end
    end)
end

-- =====================================================================
-- PHẦN 5: XÂY DỰNG GIAO DIỆN
-- =====================================================================

local Window     = RedzUiEngine:CreateWindow()
local FarmTab    = Window:CreateTab("Auto Farm",  "⚡")
local UpgradeTab = Window:CreateTab("Nâng Cấp",   "🔧")
local DefenseTab = Window:CreateTab("Phòng Thủ",  "🛡")
local ServerTab  = Window:CreateTab("Hop Server", "🌐")

-- ═══════════════════════ TAB 1: AUTO FARM ═══════════════════════════

FarmTab:CreateSection("Ghép Bom (Merge V4 - Di Chuyển Nhân Vật)")

FarmTab:CreateToggle("⚡ Tự Động Gộp Bom (Merge V4)", false, function(state)
    _G.AutoMerge = state
    -- Reset cache khi bật lại để tìm event mới
    _mergeEvCache = nil
    if state then
        SendNotify("Auto Merge V4", "Đã bật! NV sẽ tự di chuyển ghép bom.", 3)
        task.spawn(function()
            local noNukeCount = 0
            while _G.AutoMerge do
                local ok, total = performMerge()

                if total == 0 then
                    noNukeCount = noNukeCount + 1
                    if noNukeCount >= 20 then
                        SendNotify("⚠️ Merge", "Không tìm thấy bom!\nKiểm tra object trong game.", 5)
                        noNukeCount = 0
                        task.wait(8)
                    end
                else
                    noNukeCount = 0
                end
                -- FIX LAG: giảm từ 0.3 xuống 0.15
                task.wait(0.15)
            end
        end)
    else
        SendNotify("Auto Merge", "Đã tắt.", 2)
    end
end)

FarmTab:CreateButton("🔍 Quét & Debug Bom (Xem Vị Trí)", function()
    local nukes = findAllNukes()
    local total = 0
    local parts = {}
    for level, list in pairs(nukes) do
        total = total + #list
        table.insert(parts, "Lv" .. level .. ": " .. #list .. " quả")
    end
    if total == 0 then
        -- Debug: liệt kê tất cả object trong workspace con
        local wsChildren = {}
        for _, obj in ipairs(workspace:GetChildren()) do
            if obj:IsA("Model") or obj:IsA("Folder") then
                table.insert(wsChildren, obj.Name)
            end
        end
        local wsInfo = #wsChildren > 0 and ("WS: " .. table.concat(wsChildren, ", "):sub(1, 80)) or "Workspace trống"
        SendNotify("❌ Không Tìm Thấy Bom", wsInfo, 6)
    else
        table.sort(parts)
        SendNotify("✅ Tìm thấy " .. total .. " quả bom!", table.concat(parts, " | "), 5)
    end
end)

FarmTab:CreateSection("Ném Bom Người Chơi (Auto Raid)")

-- ─── PLAYER PICKER: chọn mục tiêu ném bom ───
local raidPicker = FarmTab:CreatePlayerPicker("Mục tiêu", function(sel)
    _G.RaidTarget = sel
    if sel == "all" then
        SendNotify("🎯 Mục tiêu", "Ném tất cả người chơi", 2)
    else
        SendNotify("🎯 Mục tiêu", "Sẽ ném: " .. sel, 2)
    end
end)

FarmTab:CreateToggle("💣 Tự Động Ném Bom (Auto Raid)", false, function(state)
    _G.AutoRaid = state
    if state then
        SendNotify("Auto Raid", "Đã bật! Đang tìm mục tiêu...", 2)
        task.spawn(function()
            local launchNames = {
                "LaunchNukeEvent","LaunchBomb","RaidEvent","AttackEvent",
                "LaunchEvent","FireNuke","SendNuke","NukePlayer","BombPlayer",
                "LaunchAttack","Attack","SendBomb","FireBomb","ThrowBomb",
            }

            while _G.AutoRaid do
                task.wait(1.2)

                local launchEvent = findRemote(launchNames)
                if not launchEvent then
                    -- Tìm thêm qua keyword
                    for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                            local n = obj.Name:lower()
                            if n:find("launch") or n:find("attack") or n:find("raid")
                                or n:find("bomb") or n:find("nuke") or n:find("fire") then
                                launchEvent = obj; break
                            end
                        end
                    end
                end

                if launchEvent then
                    local targets = {}
                    for _, p in ipairs(Players:GetPlayers()) do
                        if p ~= LocalPlayer and p:GetAttribute("BaseLocked") ~= true then
                            -- FIX: lọc theo _G.RaidTarget
                            if _G.RaidTarget == "all" or p.Name == _G.RaidTarget then
                                table.insert(targets, p)
                            end
                        end
                    end

                    -- FIX: thử nhiều format với từng target
                    for _, target in ipairs(targets) do
                        if not _G.AutoRaid then break end
                        -- Format 1: object Player
                        pcall(function() launchEvent:FireServer(target) end)
                        task.wait(0.08)
                        -- Format 2: tên string
                        pcall(function() launchEvent:FireServer(target.Name) end)
                        task.wait(0.08)
                        -- Format 3: UserId
                        pcall(function() launchEvent:FireServer(target.UserId) end)
                        task.wait(0.08)
                        -- Format 4: Character
                        if target.Character then
                            pcall(function() launchEvent:FireServer(target.Character) end)
                            task.wait(0.08)
                        end
                        -- Format 5: Table
                        pcall(function() launchEvent:FireServer({target}) end)
                        task.wait(0.08)

                        -- Nếu chọn cụ thể 1 người, không cần loop
                        if _G.RaidTarget ~= "all" then break end
                        task.wait(0.5) -- delay giữa các target
                    end
                end
            end
        end)
    else
        SendNotify("Auto Raid", "Đã tắt.", 2)
    end
end)

FarmTab:CreateButton("💣 Ném Bom Ngay (1 Lần)", function()
    local launchNames = {
        "LaunchNukeEvent","LaunchBomb","RaidEvent","AttackEvent",
        "LaunchEvent","FireNuke","SendNuke","NukePlayer","BombPlayer",
    }
    local launchEvent = findRemote(launchNames)
    if not launchEvent then
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("launch") or n:find("attack") or n:find("raid") or n:find("bomb") then
                    launchEvent = obj; break
                end
            end
        end
    end

    if launchEvent then
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                if _G.RaidTarget == "all" or p.Name == _G.RaidTarget then
                    pcall(function() launchEvent:FireServer(p) end)
                    pcall(function() launchEvent:FireServer(p.Name) end)
                    count = count + 1
                end
            end
        end
        SendNotify("💣 Đã Ném!", "Đã gửi tới " .. count .. " người chơi.", 2)
    else
        SendNotify("❌ Lỗi", "Không tìm thấy LaunchEvent trong game.", 3)
    end
end)

-- ═══════════════════════ TAB 2: NÂNG CẤP ═══════════════════════════

UpgradeTab:CreateSection("Tự Động Nâng Cấp")

UpgradeTab:CreateToggle("🔧 Auto Nâng Cấp Liên Tục", false, function(state)
    _G.AutoUpgrade = state
    if state then
        SendNotify("Auto Upgrade", "Đã bật! Đang nâng cấp...", 2)
        task.spawn(function()
            while _G.AutoUpgrade do
                task.wait(0.5)
                local ev = findRemote(UPGRADE_EVENTS)
                if ev then
                    pcall(function() ev:FireServer() end)
                    pcall(function() ev:FireServer("all") end)
                    pcall(function() ev:FireServer(true) end)
                end
            end
        end)
    else
        SendNotify("Auto Upgrade", "Đã tắt.", 2)
    end
end)

UpgradeTab:CreateButton("⚡ Nâng Cấp Ngay 1 Lần", function()
    local ev = findRemote(UPGRADE_EVENTS)
    if ev then
        pcall(function() ev:FireServer() end)
        pcall(function() ev:FireServer("all") end)
        SendNotify("Nâng Cấp", "Đã gửi lệnh nâng cấp!", 2)
    else
        SendNotify("Lỗi", "Không tìm thấy Upgrade Event.", 3)
    end
end)

UpgradeTab:CreateSection("Hồi Sinh (Rebirth / Prestige)")

UpgradeTab:CreateToggle("🔄 Auto Rebirth Khi Đủ Điều Kiện", false, function(state)
    _G.AutoRebirth = state
    if state then
        SendNotify("Auto Rebirth", "Đã bật! Tự rebirth khi có thể.", 2)
        task.spawn(function()
            local rebirthNames = {"RebirthEvent","Rebirth","Prestige","PrestigeEvent","RebirthRemote"}
            while _G.AutoRebirth do
                task.wait(2)
                local ev = findRemote(rebirthNames)
                if ev then pcall(function() ev:FireServer() end) end
            end
        end)
    else
        SendNotify("Auto Rebirth", "Đã tắt.", 2)
    end
end)

UpgradeTab:CreateButton("🔄 Rebirth Ngay (Thủ Công)", function()
    local ev = findRemote({"RebirthEvent","Rebirth","Prestige","PrestigeEvent","RebirthRemote"})
    if ev then
        pcall(function() ev:FireServer() end)
        SendNotify("Rebirth", "Đã gửi lệnh Rebirth!", 2)
    else
        SendNotify("Lỗi", "Không tìm thấy Rebirth Event.", 3)
    end
end)

-- ═══════════════════════ TAB 3: PHÒNG THỦ ═══════════════════════════

DefenseTab:CreateSection("Bảo Vệ Căn Cứ")

DefenseTab:CreateToggle("🛡 Auto Khiên Bất Tử (Lock Base)", false, function(state)
    _G.AutoLockBase = state
    if state then
        SendNotify("Phòng Thủ", "Đã bật khiên! Duy trì liên tục.", 3)
        task.spawn(function()
            local lockNames = {"LockBaseEvent","LockBase","ShieldEvent","ActivateShield","BaseShield","DefenseEvent"}
            while _G.AutoLockBase do
                task.wait(2.5)
                local ev = findRemote(lockNames)
                if ev then pcall(function() ev:FireServer() end) end
            end
        end)
    else
        SendNotify("Phòng Thủ", "Đã tắt khiên.", 2)
    end
end)

DefenseTab:CreateButton("🛡 Kích Hoạt Khiên 1 Lần", function()
    local ev = findRemote({"LockBaseEvent","LockBase","ShieldEvent","ActivateShield","BaseShield"})
    if ev then
        pcall(function() ev:FireServer() end)
        SendNotify("Thành Công", "Đã kích hoạt Khiên!", 2)
    else
        SendNotify("Lỗi", "Không tìm thấy Lock Base Event.", 3)
    end
end)

-- ═══════════════════════ TAB 4: HOP SERVER ═══════════════════════════

ServerTab:CreateSection("👻 Ghost Server (Server Ma - Chỉ Mình Bạn)")

ServerTab:CreateButton("👻 Tạo Server Ma (Không Ai Vào Được)", function()
    -- Dùng ReserveServer thật sự - người khác không thể thấy/tìm/vào
    CreateGhostServer()
end)

ServerTab:CreateSection("🔍 Hop Server Thường (Quét 15 Trang)")

ServerTab:CreateButton("👥 Vào Server Có ≤1 Người", function()
    GhostHopV2(1)
end)

ServerTab:CreateButton("👥 Vào Server Có ≤2 Người", function()
    GhostHopV2(2)
end)

ServerTab:CreateButton("👥 Vào Server Có ≤3 Người", function()
    GhostHopV2(3)
end)

ServerTab:CreateSection("🚨 Bảo Vệ Tự Động")

-- Status label
local strangerStatus = ServerTab:CreateLabel("Trạng thái", "Chưa bật")

ServerTab:CreateToggle("🚨 Auto Chuồn Khi Có Người Lạ Vào", false, function(state)
    _G.AntiStranger = state
    if state then
        strangerStatus:SetValue("Đang bảo vệ ✅")
        SendNotify("Bảo Vệ VIP", "Đã bật! Tự thoát khi có người vào.", 3)
        -- Nếu phòng đang có người rồi → thoát ngay
        if #Players:GetPlayers() > 1 then
            SendNotify("🚨 Phòng Có Người", "Đang tự động chuồn...", 3)
            task.wait(0.8)
            GhostHopV2(1)
        end
    else
        strangerStatus:SetValue("Tắt ❌")
        SendNotify("Bảo Vệ VIP", "Đã tắt tự động thoát.", 2)
    end
end)

ServerTab:CreateButton("📋 Xem Người Trong Phòng", function()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(list, (p == LocalPlayer and "★ " or "  ") .. p.Name)
    end
    SendNotify("Phòng Hiện Tại (" .. #list .. " người)", table.concat(list, "\n"), 5)
end)

-- ─── Lắng nghe người lạ vào phòng (FIX: dùng biến local để tránh closure bug) ───
Players.PlayerAdded:Connect(function(newcomer)
    -- FIX: check _G.AntiStranger tại thời điểm event xảy ra
    if not _G.AntiStranger then return end
    if newcomer == LocalPlayer then return end

    SendNotify("🚨 CẢNH BÁO!", newcomer.Name .. " vừa vào! Đang chuồn...", 4)
    task.wait(0.4)
    GhostHopV2(1)
end)
