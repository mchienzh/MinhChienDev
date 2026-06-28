-- =====================================================================
-- ONNI HUB - SCRIPT V3 (FIX MERGE + UI NÂNG CẤP + GHOST HOP V2)
-- =====================================================================

-- =====================================================================
-- PHẦN 1: THƯ VIỆN GIAO DIỆN V3 (TweenService + Hiệu Ứng Đầy Đủ)
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
    MainFrame.Size = UDim2.new(0, 580, 0, 400)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -200)
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

    -- Hiệu ứng đường viền nhấp nháy
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

    -- Lấp góc dưới của TopBar
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
    Title.Text = "⚡ ONNI HUB  V3.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar

    -- Nút thu nhỏ (—)
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

    -- Nút đóng (✕)
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

    -- Hover cho nút đóng / thu nhỏ
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

    -- ── Mobile Toggle Button ──
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

        -- Tab button ở sidebar
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

        -- Thanh chỉ báo active (bên trái tab)
        local ActiveBar = Instance.new("Frame")
        ActiveBar.Size = UDim2.new(0, 3, 0.55, 0)
        ActiveBar.Position = UDim2.new(0, 1, 0.225, 0)
        ActiveBar.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
        ActiveBar.Visible = firstTab
        ActiveBar.BorderSizePixel = 0
        ActiveBar.Parent = TabBtn
        Instance.new("UICorner", ActiveBar).CornerRadius = UDim.new(0, 2)

        TabBtn.MouseButton1Click:Connect(function()
            -- Ẩn tất cả trang
            for _, page in ipairs(ContentContainer:GetChildren()) do
                if page:IsA("ScrollingFrame") then page.Visible = false end
            end
            -- Reset tất cả tab buttons
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
            -- Kích hoạt tab này
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

        -- ─ Section Header ─
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

        -- ─ Button với hover effect ─
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

            -- Hover effect
            ActionBtn.MouseEnter:Connect(function()
                TweenService:Create(ActionBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 30)}):Play()
                TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(200, 30, 60), Transparency = 0.4}):Play()
            end)
            ActionBtn.MouseLeave:Connect(function()
                TweenService:Create(ActionBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
                TweenService:Create(BtnStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(40, 40, 40), Transparency = 0}):Play()
            end)
            -- Click flash
            ActionBtn.MouseButton1Click:Connect(function()
                TweenService:Create(ActionBtn, TweenInfo.new(0.07), {BackgroundColor3 = Color3.fromRGB(55, 18, 26)}):Play()
                task.wait(0.12)
                TweenService:Create(ActionBtn, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
                pcall(callback)
            end)
        end

        -- ─ Toggle với status dot + label BẬT/TẮT ─
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

            -- Đèn trạng thái (chấm tròn)
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

            -- Label BẬT / TẮT
            local StatusLbl = Instance.new("TextLabel")
            StatusLbl.Size = UDim2.new(0, 36, 0, 18)
            StatusLbl.Position = UDim2.new(1, -84, 0.5, -9)
            StatusLbl.BackgroundTransparency = 1
            StatusLbl.Text = toggled and "BẬT" or "TẮT"
            StatusLbl.TextColor3 = toggled and Color3.fromRGB(50, 220, 100) or Color3.fromRGB(130, 130, 130)
            StatusLbl.Font = Enum.Font.GothamBold
            StatusLbl.TextSize = 10
            StatusLbl.Parent = ToggleFrame

            -- Switch track
            local Switch = Instance.new("Frame")
            Switch.Size = UDim2.new(0, 36, 0, 19)
            Switch.Position = UDim2.new(1, -46, 0.5, -9)
            Switch.BackgroundColor3 = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(48, 48, 48)
            Switch.Parent = ToggleFrame
            Instance.new("UICorner", Switch).CornerRadius = UDim.new(0, 9)

            -- Switch knob
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

        return elements
    end
    return tabs
end

-- =====================================================================
-- PHẦN 2: CÁC BIẾN VÀ HÀM TIỆN ÍCH
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

SendNotify("⚡ ONNI HUB V3", "Script đã tải thành công!", 3)

_G.AutoMerge    = false
_G.AutoRaid     = false
_G.AutoLockBase = false
_G.AutoUpgrade  = false
_G.AutoRebirth  = false
_G.AntiStranger = false

-- Tìm RemoteEvent/RemoteFunction theo danh sách tên (tìm sâu)
local function findRemote(names)
    if type(names) == "string" then names = {names} end
    for _, name in ipairs(names) do
        local found = ReplicatedStorage:FindFirstChild(name, true)
        if found then return found end
    end
    -- Phương án dự phòng: duyệt toàn bộ và so tên lowercase
    for _, name in ipairs(names) do
        local lower = name:lower()
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if (obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction")) and obj.Name:lower() == lower then
                return obj
            end
        end
    end
    return nil
end

-- =====================================================================
-- PHẦN 3: LOGIC GHÉP BOM V2 (ĐA TẦNG - FIX HOÀN TOÀN)
-- =====================================================================

-- Tên RemoteEvent có thể dùng để merge
local MERGE_EVENTS = {
    "MergeEvent","Merge","MergeNuke","MergeNukes","MergeBombs",
    "CombineNukes","CombineEvent","NukeMerge","BombMerge",
    "Combine","MergeItems","FuseNukes","FuseBombs","Fuse",
}

-- Tên RemoteEvent có thể dùng để upgrade
local UPGRADE_EVENTS = {
    "UpgradeEvent","Upgrade","UpgradeBomb","UpgradeNuke",
    "BuyUpgrade","PurchaseUpgrade","UpgradeBase","LevelUp",
    "UpgradeItem","Buy","Purchase",
}

-- ─── Lấy level/tier của một object bằng nhiều phương pháp ───
local function getObjectLevel(obj)
    -- 1. Thuộc tính (Attribute)
    for _, attrName in ipairs({"Level","Tier","Grade","Power","Rank"}) do
        local v = obj:GetAttribute(attrName)
        if v and type(v) == "number" then return v end
    end
    -- 2. Con là IntValue / NumberValue tên "Level" v.v.
    for _, child in ipairs(obj:GetChildren()) do
        if (child:IsA("IntValue") or child:IsA("NumberValue")) then
            local n = child.Name:lower()
            if n == "level" or n == "tier" or n == "grade" or n == "value" or n == "rank" then
                return child.Value
            end
        end
    end
    -- 3. Trích số từ cuối tên (vd: "Nuke_5" → 5, "Bomb3" → 3)
    local num = obj.Name:match("(%d+)$") or obj.Name:match("_(%d+)")
    if num then return tonumber(num) end
    return 1 -- Mặc định level 1 nếu không xác định được
end

-- ─── Tìm TẤT CẢ bom/nuke của người chơi trong game ───
local function findAllNukes()
    local nukes = {} -- [level] = {obj1, obj2, ...}
    local seen  = {}

    -- Các thư mục cần tìm kiếm
    local searchRoots = {
        workspace,
        LocalPlayer,
        workspace:FindFirstChild(LocalPlayer.Name),
        workspace:FindFirstChild("Bases"),
        workspace:FindFirstChild("Nukes"),
        workspace:FindFirstChild("Bombs"),
        workspace:FindFirstChild("Items"),
        workspace:FindFirstChild("Map"),
        workspace:FindFirstChild("Field"),
        LocalPlayer:WaitForChild("Backpack", 0.1),
    }

    local NUKE_KEYWORDS = {"nuke","bomb","missile","rocket","warhead","grenade","mine","weapon"}

    for _, root in ipairs(searchRoots) do
        if not root then continue end
        for _, obj in ipairs(root:GetDescendants()) do
            -- Tránh xử lý trùng
            if seen[obj] then continue end
            seen[obj] = true

            -- Chỉ xét Model và BasePart (không phải GUI, IntValue, v.v.)
            if not (obj:IsA("Model") or obj:IsA("BasePart")) then continue end

            local isNuke = false
            local nameLower = obj.Name:lower()

            -- Kiểm tra từ khóa trong tên
            for _, kw in ipairs(NUKE_KEYWORDS) do
                if nameLower:find(kw) then isNuke = true; break end
            end

            -- Kiểm tra tên thư mục cha
            if not isNuke and obj.Parent then
                local pn = obj.Parent.Name:lower()
                for _, kw in ipairs(NUKE_KEYWORDS) do
                    if pn:find(kw) then isNuke = true; break end
                end
            end

            -- Kiểm tra attribute đặc biệt
            if not isNuke then
                isNuke = obj:GetAttribute("IsNuke")
                    or obj:GetAttribute("IsBomb")
                    or obj:GetAttribute("CanMerge")
                    or obj:GetAttribute("Mergeable")
            end

            if isNuke then
                local level = getObjectLevel(obj)
                if not nukes[level] then nukes[level] = {} end
                table.insert(nukes[level], obj)
            end
        end
    end
    return nukes
end

-- ─── Thực hiện ghép bom ───
local function performMerge()
    -- Tìm merge event (cả theo danh sách lẫn tìm ngầm qua tên)
    local mergeEvent = findRemote(MERGE_EVENTS)
    if not mergeEvent then
        for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
            if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                local n = obj.Name:lower()
                if n:find("merge") or n:find("combine") or n:find("fuse") then
                    mergeEvent = obj; break
                end
            end
        end
    end

    local nukes = findAllNukes()
    local didMerge = false
    local total = 0
    for _, list in pairs(nukes) do total = total + #list end

    if total == 0 then return false, 0 end

    for level, list in pairs(nukes) do
        if #list >= 2 then
            local a, b = list[1], list[2]
            if mergeEvent then
                -- Thử 5 cách gọi khác nhau để tương thích với mọi game
                pcall(function() mergeEvent:FireServer(a, b) end)
                task.wait(0.05)
                pcall(function() mergeEvent:FireServer(a.Name, b.Name) end)
                task.wait(0.05)
                pcall(function() mergeEvent:FireServer(a, b, level) end)
                task.wait(0.05)
                pcall(function() mergeEvent:FireServer({a, b}) end)
                task.wait(0.05)
                if mergeEvent:IsA("RemoteFunction") then
                    pcall(function() mergeEvent:InvokeServer(a, b) end)
                end
                didMerge = true
            else
                -- Không tìm thấy event → thử ClickDetector trên object
                pcall(function()
                    local cd = a:FindFirstChildOfClass("ClickDetector")
                    if cd then
                        local args = {[1] = game:GetService("Players").LocalPlayer}
                        cd.MouseClick:Fire(table.unpack(args))
                    end
                end)
            end
            break
        end
    end

    return didMerge, total
end

-- =====================================================================
-- PHẦN 4: GHOST HOP V2 (NÂNG CẤP HOÀN TOÀN)
-- =====================================================================

-- Quét sâu nhiều trang, ưu tiên phòng ít người nhất
local function GhostHopV2(maxAllowed)
    maxAllowed = maxAllowed or 1
    local label = maxAllowed == 0 and "phòng TRỐNG (0 người)" or ("phòng ≤" .. maxAllowed .. " người")
    SendNotify("👻 Ghost Hop V2", "Đang quét " .. label .. "...", 4)

    local placeId     = game.PlaceId
    local cursor      = ""
    local bestServer  = nil
    local scanned     = 0
    local MAX_PAGES   = 12 -- Tăng từ 5 lên 12 trang

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
            if srv.id ~= game.JobId then
                local playing = srv.playing or 0
                local maxP    = srv.maxPlayers or 999
                if playing <= maxAllowed and playing < maxP then
                    -- Ưu tiên server ít người nhất
                    if bestServer == nil or playing < (bestServer.playing or 999) then
                        bestServer = srv
                    end
                    -- Tìm thấy phòng 0 người → dừng ngay
                    if playing == 0 then break end
                end
            end
        end

        -- Nếu đã tìm thấy phòng hoàn toàn trống, không cần quét tiếp
        if bestServer and (bestServer.playing or 1) == 0 then break end

        if json.nextPageCursor and json.nextPageCursor ~= "" then
            cursor = json.nextPageCursor
        else
            break
        end

        task.wait(0.12)
    end

    -- Thông báo kết quả
    SendNotify("📊 Đã quét", scanned .. " servers.", 2)

    if bestServer then
        local p = bestServer.playing or 0
        local pText = p == 0 and "TRỐNG hoàn toàn" or (p .. " người")
        SendNotify("✅ Tìm thấy!", "Server có " .. pText .. ". Đang teleport...", 5)
        task.wait(1.2)
        TeleportService:TeleportToPlaceInstance(placeId, bestServer.id, LocalPlayer)
    else
        SendNotify("❌ Thất Bại", "Không tìm được server ≤" .. maxAllowed .. " người.\nThử lại sau!", 4)
    end
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

FarmTab:CreateSection("Ghép Bom & Thu Thập")

FarmTab:CreateToggle("⚡ Tự Động Gộp Bom (Merge V2)", false, function(state)
    _G.AutoMerge = state
    if state then
        SendNotify("Auto Merge V2", "Đã bật! Đang quét bom trong game...", 3)
        task.spawn(function()
            local noNukeCount = 0

            while _G.AutoMerge do
                task.wait(0.3)
                local ok, total = performMerge()

                if total == 0 then
                    noNukeCount = noNukeCount + 1
                    if noNukeCount >= 30 then
                        SendNotify("⚠️ Merge", "Không tìm thấy bom!\nKiểm tra tên object trong game.", 5)
                        noNukeCount = 0
                        task.wait(10)
                    end
                else
                    noNukeCount = 0
                end
            end
        end)
    else
        SendNotify("Auto Merge", "Đã tắt.", 2)
    end
end)

FarmTab:CreateToggle("💰 Tự Động Đi Cướp (Auto Raid)", false, function(state)
    _G.AutoRaid = state
    if state then
        SendNotify("Auto Raid", "Đã bật! Đang tìm mục tiêu...", 2)
        task.spawn(function()
            local launchNames = {
                "LaunchNukeEvent","LaunchBomb","RaidEvent",
                "AttackEvent","LaunchEvent","FireNuke","SendNuke",
            }
            while _G.AutoRaid do
                task.wait(1.5)
                local launchEvent = findRemote(launchNames)
                if launchEvent then
                    for _, target in ipairs(Players:GetPlayers()) do
                        if target ~= LocalPlayer and target:GetAttribute("BaseLocked") ~= true then
                            pcall(function() launchEvent:FireServer(target) end)
                            pcall(function() launchEvent:FireServer(target.Name) end)
                            break
                        end
                    end
                end
            end
        end)
    else
        SendNotify("Auto Raid", "Đã tắt.", 2)
    end
end)

FarmTab:CreateButton("🔍 Quét & Hiện Số Bom Hiện Có", function()
    local nukes = findAllNukes()
    local total = 0
    local parts = {}
    for level, list in pairs(nukes) do
        total = total + #list
        table.insert(parts, "Lv" .. level .. ": " .. #list)
    end
    if total == 0 then
        SendNotify("Kết Quả Quét", "Không tìm thấy bom nào.\n(Kiểm tra game có đúng không?)", 5)
    else
        SendNotify("Tìm thấy " .. total .. " quả!", table.concat(parts, " | "), 5)
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
        SendNotify("Lỗi", "Không tìm thấy Upgrade Event trong game.", 3)
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
        SendNotify("Lỗi", "Không tìm thấy Rebirth Event trong game.", 3)
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
        SendNotify("Lỗi", "Không tìm thấy Lock Base Event trong game.", 3)
    end
end)

-- ═══════════════════════ TAB 4: HOP SERVER ═══════════════════════════

ServerTab:CreateSection("Ghost Hop V2 (Quét Sâu 12 Trang)")

ServerTab:CreateButton("👻 Vào Server TRỐNG (0 Người)", function()
    GhostHopV2(0)
end)

ServerTab:CreateButton("👤 Vào Server Có ≤1 Người", function()
    GhostHopV2(1)
end)

ServerTab:CreateButton("👥 Vào Server Có ≤2 Người", function()
    GhostHopV2(2)
end)

ServerTab:CreateSection("Chế Độ Tự Động")

ServerTab:CreateToggle("🚨 Auto Chuồn Khi Có Người Lạ", false, function(state)
    _G.AntiStranger = state
    if state then
        SendNotify("Bảo Vệ VIP", "Đã bật! Tự thoát khi có người vào.", 3)
        -- Nếu phòng đang có nhiều người, tự rời ngay
        if #Players:GetPlayers() > 1 then
            SendNotify("🚨 Phòng Có Người", "Đang tự động thoát...", 3)
            task.wait(0.8)
            GhostHopV2(0)
        end
    else
        SendNotify("Bảo Vệ VIP", "Đã tắt tự động thoát.", 2)
    end
end)

-- Lắng nghe người lạ vào phòng
Players.PlayerAdded:Connect(function(player)
    if _G.AntiStranger and player ~= LocalPlayer then
        SendNotify("🚨 CẢNH BÁO!", player.Name .. " vừa vào! Đang chuồn...", 3)
        task.wait(0.3)
        GhostHopV2(0)
    end
end)
