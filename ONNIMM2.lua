-- ═══════════════════════════════════════
--  DỊCH VỤ & BIẾN TOÀN CỤC
-- ═══════════════════════════════════════
local Players       = game:GetService("Players")
local RunService    = game:GetService("RunService")
local UserInput     = game:GetService("UserInputService")
local TweenService  = game:GetService("TweenService")
local Workspace     = game:GetService("Workspace")
local Camera        = Workspace.CurrentCamera

-- Chờ LocalPlayer sẵn sàng (tránh nil)
local LocalPlayer
repeat
    LocalPlayer = Players.LocalPlayer
    task.wait(0.05)
until LocalPlayer

-- Chờ PlayerGui sẵn sàng
local playerGui = LocalPlayer:WaitForChild("PlayerGui", 10)
if not playerGui then
    playerGui = Instance.new("ScreenGui")
    playerGui.Name = "PlayerGui"
    playerGui.Parent = LocalPlayer
end

-- ═══════════════════════════════════════
--  TRẠNG THÁI TÍNH NĂNG
-- ═══════════════════════════════════════
local ESP   = { Enabled = false, Boxes = {}, NameGuis = {}, DistGuis = {} }
local Aim   = { Enabled = false }
local Freeze = { Enabled = false }
local Hitbox = { Enabled = false, Scale = 1.8 }
local LagFix = { Enabled = false }
local Farm  = { CoinEnabled = false, WeaponEnabled = false }
local Dodge = { Enabled = false, DodgeDistance = 5, CheckRadius = 30 }

-- ═══════════════════════════════════════
--  HÀM TOAST THÔNG BÁO (NÂNG CẤP)
-- ═══════════════════════════════════════
local function Notify(message, duration, color)
    duration = duration or 3
    color = color or Color3.fromRGB(110, 60, 230)
    pcall(function()
        local old = playerGui:FindFirstChild("MM2_Toast")
        if old then old:Destroy() end

        local sg = Instance.new("ScreenGui")
        sg.Name = "MM2_Toast"
        sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = playerGui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 300, 0, 52)
        frame.Position = UDim2.new(0.5, -150, 0, -70)
        frame.BackgroundColor3 = Color3.fromRGB(16, 14, 26)
        frame.BorderSizePixel = 0
        frame.Parent = sg
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)

        local stroke = Instance.new("UIStroke", frame)
        stroke.Color = color
        stroke.Thickness = 1.5

        -- Gradient nền
        local grad = Instance.new("UIGradient", frame)
        grad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(22, 18, 40)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(14, 12, 22))
        }
        grad.Rotation = 135

        -- Icon
        local icon = Instance.new("TextLabel", frame)
        icon.Size = UDim2.new(0, 36, 0, 36)
        icon.Position = UDim2.new(0, 8, 0.5, -18)
        icon.BackgroundColor3 = color
        icon.BackgroundTransparency = 0.2
        icon.Text = "⚡"
        icon.TextColor3 = Color3.fromRGB(255, 255, 255)
        icon.TextSize = 16
        icon.Font = Enum.Font.GothamBold
        icon.TextXAlignment = Enum.TextXAlignment.Center
        icon.TextYAlignment = Enum.TextYAlignment.Center
        Instance.new("UICorner", icon).CornerRadius = UDim.new(0, 8)

        -- Nội dung
        local lbl = Instance.new("TextLabel", frame)
        lbl.Size = UDim2.new(1, -58, 1, -4)
        lbl.Position = UDim2.new(0, 50, 0, 2)
        lbl.BackgroundTransparency = 1
        lbl.Text = message
        lbl.TextColor3 = Color3.fromRGB(230, 228, 255)
        lbl.TextSize = 12
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.TextWrapped = true

        -- Progress bar
        local barBG = Instance.new("Frame", frame)
        barBG.Size = UDim2.new(1, -16, 0, 3)
        barBG.Position = UDim2.new(0, 8, 1, -6)
        barBG.BackgroundColor3 = Color3.fromRGB(40, 36, 60)
        barBG.BorderSizePixel = 0
        Instance.new("UICorner", barBG).CornerRadius = UDim.new(1, 0)

        local bar = Instance.new("Frame", barBG)
        bar.Size = UDim2.new(1, 0, 1, 0)
        bar.BackgroundColor3 = color
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

        -- Slide IN
        TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
            Position = UDim2.new(0.5, -150, 0, 12)
        }):Play()

        -- Shrink bar
        task.delay(0.1, function()
            TweenService:Create(bar, TweenInfo.new(duration - 0.4, Enum.EasingStyle.Linear), {
                Size = UDim2.new(0, 0, 1, 0)
            }):Play()
        end)

        -- Slide OUT
        task.delay(duration - 0.3, function()
            TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Position = UDim2.new(0.5, -150, 0, -70),
                BackgroundTransparency = 0.5
            }):Play()
            task.delay(0.35, function() pcall(sg.Destroy, sg) end)
        end)
    end)
end

-- ═══════════════════════════════════════
--  LẤY VAI TRÒ NGƯỜI CHƠI
-- ═══════════════════════════════════════
local function GetRole(player)
    if not player or not player.Character then return "Innocent" end
    local function checkTools(container)
        if not container then return nil end
        for _, tool in ipairs(container:GetChildren()) do
            if tool:IsA("Tool") then
                local n = tool.Name:lower()
                if n:find("knife") or n:find("blade") or n:find("dagger") then return "Murderer" end
                if n:find("gun") or n:find("pistol") or n:find("revolver") or n:find("shotgun") then return "Sheriff" end
            end
        end
        return nil
    end
    return checkTools(player.Character)
        or checkTools(player:FindFirstChild("Backpack"))
        or "Innocent"
end

-- ═══════════════════════════════════════
--  ESP
-- ═══════════════════════════════════════
local function DestroyESP()
    for _, v in pairs(ESP.Boxes)    do pcall(v.Destroy, v) end
    for _, v in pairs(ESP.NameGuis) do pcall(v.Destroy, v) end
    for _, v in pairs(ESP.DistGuis) do pcall(v.Destroy, v) end
    ESP.Boxes = {}; ESP.NameGuis = {}; ESP.DistGuis = {}
end

local function UpdateESP()
    DestroyESP()
    if not ESP.Enabled then return end
    for _, player in pairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local role = GetRole(player)
        if role == "Innocent" then continue end
        local char = player.Character
        if not char then continue end
        local root = char:FindFirstChild("HumanoidRootPart")
        local head = char:FindFirstChild("Head")
        if not root or not head then continue end

        -- Highlight
        local hl = Instance.new("Highlight", char)
        hl.FillColor = role == "Murderer" and Color3.fromRGB(255, 30, 30) or Color3.fromRGB(30, 100, 255)
        hl.FillTransparency = 0.4
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.OutlineTransparency = 0.1
        ESP.Boxes[player] = hl

        -- Tên + vai trò
        local ng = Instance.new("BillboardGui", head)
        ng.Adornee = head
        ng.Size = UDim2.new(0, 160, 0, 38)
        ng.StudsOffset = Vector3.new(0, 2.8, 0)
        local nl = Instance.new("TextLabel", ng)
        nl.Size = UDim2.new(1, 0, 1, 0)
        nl.BackgroundTransparency = 1
        nl.Text = "⚠ " .. player.Name .. " [" .. role .. "]"
        nl.TextColor3 = role == "Murderer" and Color3.fromRGB(255, 60, 60) or Color3.fromRGB(60, 160, 255)
        nl.TextScaled = true
        nl.Font = Enum.Font.GothamBold
        ESP.NameGuis[player] = ng

        -- Khoảng cách
        local dg = Instance.new("BillboardGui", head)
        dg.Adornee = head
        dg.Size = UDim2.new(0, 80, 0, 22)
        dg.StudsOffset = Vector3.new(0, -1.8, 0)
        local dl = Instance.new("TextLabel", dg)
        dl.Size = UDim2.new(1, 0, 1, 0)
        dl.BackgroundTransparency = 1
        dl.TextColor3 = Color3.fromRGB(255, 230, 50)
        dl.TextScaled = true
        dl.Font = Enum.Font.Gotham
        ESP.DistGuis[player] = dg
    end
end

-- ═══════════════════════════════════════
--  AIM
-- ═══════════════════════════════════════
local function AimAt(target)
    if not target or not target.Character then return end
    local root = target.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    Camera.CFrame = CFrame.new(Camera.CFrame.Position, root.Position)
end

-- ═══════════════════════════════════════
--  KILL
-- ═══════════════════════════════════════
local function KillPlayer(target)
    if not target or not target.Character then return end
    local hum = target.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
end

-- ═══════════════════════════════════════
--  FREEZE
-- ═══════════════════════════════════════
local function ApplyFreeze(player, state)
    if not player or not player.Character then return end
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = state and 0 or 16
        hum.JumpPower = state and 0 or 50
    end
end

local function UpdateFreeze()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then ApplyFreeze(p, Freeze.Enabled) end
    end
end

-- ═══════════════════════════════════════
--  HITBOX
-- ═══════════════════════════════════════
local DEFAULT_SIZES = {
    Head = Vector3.new(2,1,1), Torso = Vector3.new(2,2,1),
    UpperTorso = Vector3.new(2,2,1), LeftArm = Vector3.new(1,2,1),
    RightArm = Vector3.new(1,2,1), LeftLeg = Vector3.new(1,2,1),
    RightLeg = Vector3.new(1,2,1),
}
local function ApplyHitbox(player, state)
    if not player or not player.Character then return end
    for _, part in pairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            if state then
                part.Size = part.Size * Hitbox.Scale
            elseif DEFAULT_SIZES[part.Name] then
                part.Size = DEFAULT_SIZES[part.Name]
            end
        end
    end
end

local function UpdateHitbox()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then ApplyHitbox(p, Hitbox.Enabled) end
    end
end

-- ═══════════════════════════════════════
--  LAG FIX
-- ═══════════════════════════════════════
local function ApplyLagFix(state)
    pcall(function()
        settings().Graphics.QualityLevel = state and 1 or 10
        settings().Graphics.MaterialQuality = state
            and Enum.MaterialQuality.Low
            or  Enum.MaterialQuality.High
    end)
end

-- ═══════════════════════════════════════
--  AUTO FARM
-- ═══════════════════════════════════════
local function GetNearest(filter)
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    local best, bestDist = nil, math.huge
    for _, obj in pairs(Workspace:GetDescendants()) do
        if filter(obj) then
            local pos = (obj:IsA("BasePart") and obj.Position)
                or (obj:IsA("Tool") and (obj:FindFirstChild("Handle") or obj:FindFirstChild("Part")) and
                    (obj:FindFirstChild("Handle") or obj:FindFirstChild("Part")).Position)
            if pos then
                local d = (pos - myRoot.Position).Magnitude
                if d < bestDist then bestDist = d; best = obj end
            end
        end
    end
    return best
end

local function MoveToPart(part)
    if not part then return end
    local pos = part:IsA("BasePart") and part.Position
        or (part:FindFirstChild("Handle") and part:FindFirstChild("Handle").Position)
    if not pos then return end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum:MoveTo(pos + Vector3.new(0, 2, 0)) end
end

-- ═══════════════════════════════════════
--  AUTO DODGE
-- ═══════════════════════════════════════
local function GetThreats()
    local threats = {}
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return threats end
    local myPos = myRoot.Position

    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Velocity.Magnitude > 10 then
            local dir = obj.Velocity.Unit
            local toward = (myPos - obj.Position).Unit
            if dir:Dot(toward) > 0.5 then
                local d = (obj.Position - myPos).Magnitude
                if d < Dodge.CheckRadius then
                    table.insert(threats, {Object=obj, Type="Projectile", Distance=d})
                end
            end
        end
    end
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer or GetRole(p) ~= "Murderer" then continue end
        local char = p.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local d = (root.Position - myPos).Magnitude
                if d < 15 then
                    table.insert(threats, {Object=root, Type="Melee", Distance=d})
                end
            end
        end
    end
    table.sort(threats, function(a,b) return a.Distance < b.Distance end)
    return threats
end

local function DodgeThreat(threat)
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local hum  = myChar:FindFirstChildOfClass("Humanoid")
    local root = myChar:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return end
    local away = (root.Position - threat.Object.Position).Unit
    if threat.Type == "Melee" then away = away + Vector3.new(0,0,1) end
    local perp = Vector3.new(-away.Z, 0, away.X)
    local dir  = (away * 0.7 + perp * 0.5).Unit
    hum:MoveTo(root.Position + dir * Dodge.DodgeDistance)
end

-- ═══════════════════════════════════════
--  BACKGROUND LOOPS
-- ═══════════════════════════════════════
RunService.RenderStepped:Connect(function()
    -- ESP distance update
    if ESP.Enabled then
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            for player, gui in pairs(ESP.DistGuis) do
                local char = player.Character
                if char then
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if root then
                        local lbl = gui:FindFirstChildOfClass("TextLabel")
                        if lbl then
                            lbl.Text = math.floor((root.Position - myRoot.Position).Magnitude) .. "m"
                        end
                    end
                end
            end
        end
    end
    -- Auto Aim
    if Aim.Enabled then
        local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myRoot then
            local best, bestDist = nil, math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p == LocalPlayer then continue end
                local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local d = (root.Position - myRoot.Position).Magnitude
                    if d < bestDist then bestDist = d; best = p end
                end
            end
            if best then AimAt(best) end
        end
    end
end)

coroutine.wrap(function()
    while true do
        if ESP.Enabled then UpdateESP() end
        task.wait(0.5)
    end
end)()

coroutine.wrap(function()
    while true do
        if Farm.CoinEnabled or Farm.WeaponEnabled then
            if LocalPlayer.Character then
                if Farm.CoinEnabled then
                    local coin = GetNearest(function(o)
                        return o:IsA("BasePart") and (o.Name:lower():find("coin") or o.Name:lower():find("money"))
                    end)
                    if coin then MoveToPart(coin) end
                end
                if Farm.WeaponEnabled then
                    local weapon = GetNearest(function(o)
                        if not o:IsA("Tool") then return false end
                        if o.Parent == LocalPlayer.Character or o.Parent == LocalPlayer then return false end
                        if o.Parent and o.Parent:IsA("Backpack") then return false end
                        return true
                    end)
                    if weapon then
                        MoveToPart(weapon)
                        task.wait(0.25)
                        local cd = weapon:FindFirstChildOfClass("ClickDetector")
                        if cd then pcall(function() cd:FireClick(LocalPlayer.Character) end) end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)()

coroutine.wrap(function()
    while true do
        if Dodge.Enabled then
            local threats = GetThreats()
            if #threats > 0 then
                DodgeThreat(threats[1])
                task.wait(0.1)
            else
                task.wait(0.2)
            end
        else
            task.wait(0.5)
        end
    end
end)()

Players.PlayerAdded:Connect(UpdateESP)
Players.PlayerRemoving:Connect(UpdateESP)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateESP()
end)

-- ═══════════════════════════════════════════════════════
--  XÂY DỰNG UI HIỆN ĐẠI (KHÔNG CẦN require hay script)
-- ═══════════════════════════════════════════════════════
-- Xóa instance cũ
local oldSG = playerGui:FindFirstChild("MM2HubGui")
if oldSG then oldSG:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2HubGui"
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = playerGui

-- ─── Bảng màu ───────────────────────────────────────
local C = {
    BG       = Color3.fromRGB(11, 10, 20),
    Panel    = Color3.fromRGB(16, 14, 28),
    Card     = Color3.fromRGB(22, 20, 36),
    CardHov  = Color3.fromRGB(28, 24, 46),
    Accent   = Color3.fromRGB(100, 55, 225),
    Accent2  = Color3.fromRGB(155, 80, 255),
    AccentHov= Color3.fromRGB(135, 75, 255),
    Text     = Color3.fromRGB(235, 232, 255),
    SubText  = Color3.fromRGB(130, 125, 170),
    Green    = Color3.fromRGB(60, 200, 110),
    Red      = Color3.fromRGB(220, 65, 65),
    Yellow   = Color3.fromRGB(240, 190, 40),
    Border   = Color3.fromRGB(45, 40, 70),
    BorderAc = Color3.fromRGB(100, 55, 225),
}

-- ─── Cửa sổ chính ───────────────────────────────────
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 590, 0, 420)
Main.Position = UDim2.new(0.5, -295, 0.5, -210)
Main.BackgroundColor3 = C.BG
Main.BorderSizePixel = 0
Main.Parent = ScreenGui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local mainStroke = Instance.new("UIStroke", Main)
mainStroke.Color = C.Accent
mainStroke.Thickness = 1.5

local mainGrad = Instance.new("UIGradient", Main)
mainGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 12, 28)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(9, 8, 16))
}
mainGrad.Rotation = 145

-- ─── Thanh tiêu đề ───────────────────────────────────
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundColor3 = C.Panel
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 2
TitleBar.Parent = Main
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 14)

-- Phủ góc dưới title bar
local titleFix = Instance.new("Frame", TitleBar)
titleFix.Size = UDim2.new(1, 0, 0.5, 0)
titleFix.Position = UDim2.new(0, 0, 0.5, 0)
titleFix.BackgroundColor3 = C.Panel
titleFix.BorderSizePixel = 0
titleFix.ZIndex = 2

-- Đường kẻ accent dưới title bar
local accentLine = Instance.new("Frame", TitleBar)
accentLine.Size = UDim2.new(1, -28, 0, 1.5)
accentLine.Position = UDim2.new(0, 14, 1, -1)
accentLine.BackgroundColor3 = C.Accent
accentLine.BorderSizePixel = 0
accentLine.ZIndex = 3
local lineGrad = Instance.new("UIGradient", accentLine)
lineGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(70, 30, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(70, 30, 180))
}

-- Logo
local Logo = Instance.new("Frame", TitleBar)
Logo.Size = UDim2.new(0, 32, 0, 32)
Logo.Position = UDim2.new(0, 10, 0.5, -16)
Logo.BackgroundColor3 = C.Accent
Logo.BorderSizePixel = 0
Logo.ZIndex = 3
Instance.new("UICorner", Logo).CornerRadius = UDim.new(0, 8)

local logoIcon = Instance.new("TextLabel", Logo)
logoIcon.Size = UDim2.new(1,0,1,0)
logoIcon.BackgroundTransparency = 1
logoIcon.Text = "⚡"
logoIcon.TextColor3 = Color3.fromRGB(255,255,255)
logoIcon.TextSize = 16
logoIcon.Font = Enum.Font.GothamBold
logoIcon.ZIndex = 4

-- Tiêu đề
local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(0, 160, 0, 22)
TitleLbl.Position = UDim2.new(0, 50, 0.2, 0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Text = "MM2 Hub"
TitleLbl.TextColor3 = Color3.fromRGB(255,255,255)
TitleLbl.TextSize = 15
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
TitleLbl.ZIndex = 3

local SubLbl = Instance.new("TextLabel", TitleBar)
SubLbl.Size = UDim2.new(0, 200, 0, 14)
SubLbl.Position = UDim2.new(0, 50, 0.6, 0)
SubLbl.BackgroundTransparency = 1
SubLbl.Text = "Murder Mystery 2  •  v2.0 Fixed"
SubLbl.TextColor3 = C.SubText
SubLbl.TextSize = 10
SubLbl.Font = Enum.Font.Gotham
SubLbl.TextXAlignment = Enum.TextXAlignment.Left
SubLbl.ZIndex = 3

-- Nút đóng
local function MkCtrlBtn(xOff, bgCol, txt)
    local btn = Instance.new("TextButton", TitleBar)
    btn.Size = UDim2.new(0, 28, 0, 28)
    btn.Position = UDim2.new(1, xOff, 0.5, -14)
    btn.BackgroundColor3 = bgCol
    btn.Text = txt
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.TextSize = 12
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.ZIndex = 3
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0.3}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.12), {BackgroundTransparency = 0}):Play()
    end)
    return btn
end

local CloseBtn = MkCtrlBtn(-38, Color3.fromRGB(210, 55, 65), "✕")
local MinBtn   = MkCtrlBtn(-72, Color3.fromRGB(230, 155, 30), "—")

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
        Size = UDim2.new(0,0,0,0),
        Position = UDim2.new(0.5,0,0.5,0)
    }):Play()
    task.delay(0.3, function() ScreenGui:Destroy() end)
end)

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quad), {
        Size = minimized and UDim2.new(0,590,0,48) or UDim2.new(0,590,0,420)
    }):Play()
end)

-- ─── Drag ─────────────────────────────────────────────
do
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true; dragStart = inp.Position; startPos = Main.Position
        end
    end)
    TitleBar.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    UserInput.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
end

-- ─── Sidebar ─────────────────────────────────────────
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 126, 1, -52)
Sidebar.Position = UDim2.new(0, 3, 0, 49)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 12, 22)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local sideBorder = Instance.new("Frame", Sidebar)
sideBorder.Size = UDim2.new(0, 1, 1, -16)
sideBorder.Position = UDim2.new(1, -1, 0, 8)
sideBorder.BackgroundColor3 = C.Accent
sideBorder.BackgroundTransparency = 0.65
sideBorder.BorderSizePixel = 0

local sideLayout = Instance.new("UIListLayout", Sidebar)
sideLayout.Padding = UDim.new(0, 5)
sideLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local sidePad = Instance.new("UIPadding", Sidebar)
sidePad.PaddingTop = UDim.new(0, 10)
sidePad.PaddingLeft = UDim.new(0, 7)
sidePad.PaddingRight = UDim.new(0, 7)

-- ─── Vùng nội dung ───────────────────────────────────
local ContentArea = Instance.new("Frame", Main)
ContentArea.Size = UDim2.new(1, -138, 1, -56)
ContentArea.Position = UDim2.new(0, 133, 0, 52)
ContentArea.BackgroundTransparency = 1

-- ═══════════════════════════════════════════════════
--  HÀM TẠO TAB + THÀNH PHẦN
-- ═══════════════════════════════════════════════════
local allTabs = {}

local function CreateTab(name, icon)
    -- Nút bên sidebar
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(18, 16, 30)
    btn.Text = ""
    btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 9)

    local indic = Instance.new("Frame", btn)
    indic.Size = UDim2.new(0, 3, 0.55, 0)
    indic.Position = UDim2.new(0, 1, 0.225, 0)
    indic.BackgroundColor3 = C.Accent2
    indic.BackgroundTransparency = 1
    indic.BorderSizePixel = 0
    Instance.new("UICorner", indic).CornerRadius = UDim.new(1, 0)

    local iconLbl = Instance.new("TextLabel", btn)
    iconLbl.Size = UDim2.new(0, 22, 1, 0)
    iconLbl.Position = UDim2.new(0, 8, 0, 0)
    iconLbl.BackgroundTransparency = 1
    iconLbl.Text = icon
    iconLbl.TextColor3 = C.SubText
    iconLbl.TextSize = 13
    iconLbl.Font = Enum.Font.GothamBold

    local nameLbl = Instance.new("TextLabel", btn)
    nameLbl.Size = UDim2.new(1, -36, 1, 0)
    nameLbl.Position = UDim2.new(0, 33, 0, 0)
    nameLbl.BackgroundTransparency = 1
    nameLbl.Text = name
    nameLbl.TextColor3 = C.SubText
    nameLbl.TextSize = 11
    nameLbl.Font = Enum.Font.GothamBold
    nameLbl.TextXAlignment = Enum.TextXAlignment.Left

    -- Vùng scroll nội dung tab
    local scroll = Instance.new("ScrollingFrame", ContentArea)
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = C.Accent2
    scroll.CanvasSize = UDim2.new(0,0,0,0)
    scroll.Visible = false

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 6)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

    local pad = Instance.new("UIPadding", scroll)
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 6)
    pad.PaddingRight = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 10)

    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 18)
    end)

    local tab = {
        Btn = btn, Scroll = scroll, Indic = indic,
        IconLbl = iconLbl, NameLbl = nameLbl
    }

    -- ── Kích hoạt tab ──────────────────────────────
    function tab:Activate()
        for _, t in pairs(allTabs) do
            t.Scroll.Visible = false
            TweenService:Create(t.Btn,    TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(18,16,30)}):Play()
            TweenService:Create(t.IconLbl,TweenInfo.new(0.15), {TextColor3 = C.SubText}):Play()
            TweenService:Create(t.NameLbl,TweenInfo.new(0.15), {TextColor3 = C.SubText}):Play()
            TweenService:Create(t.Indic,  TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
        scroll.Visible = true
        TweenService:Create(btn,     TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26,20,46)}):Play()
        TweenService:Create(iconLbl, TweenInfo.new(0.15), {TextColor3 = C.Accent2}):Play()
        TweenService:Create(nameLbl, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(255,255,255)}):Play()
        TweenService:Create(indic,   TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
    end

    btn.MouseButton1Click:Connect(function() tab:Activate() end)

    -- ── Section heading ────────────────────────────
    function tab:CreateSection(title)
        local f = Instance.new("Frame", scroll)
        f.Size = UDim2.new(1, 0, 0, 24)
        f.BackgroundTransparency = 1

        local lbl = Instance.new("TextLabel", f)
        lbl.Size = UDim2.new(1, -10, 1, 0)
        lbl.Position = UDim2.new(0, 5, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = "▸  " .. title:upper()
        lbl.TextColor3 = C.Accent2
        lbl.TextSize = 10
        lbl.Font = Enum.Font.GothamBold
        lbl.TextXAlignment = Enum.TextXAlignment.Left

        local line = Instance.new("Frame", f)
        line.Size = UDim2.new(1, 0, 0, 1)
        line.Position = UDim2.new(0, 0, 1, -1)
        line.BackgroundColor3 = C.Accent
        line.BackgroundTransparency = 0.68
        line.BorderSizePixel = 0
    end

    -- ── Toggle ────────────────────────────────────
    function tab:CreateToggle(label, default, callback)
        local card = Instance.new("Frame", scroll)
        card.Size = UDim2.new(1, 0, 0, 44)
        card.BackgroundColor3 = C.Card
        card.BorderSizePixel = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

        local cstroke = Instance.new("UIStroke", card)
        cstroke.Color = C.Border
        cstroke.Thickness = 1

        local lbl = Instance.new("TextLabel", card)
        lbl.Size = UDim2.new(1, -68, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = C.Text
        lbl.TextSize = 12
        lbl.Font = Enum.Font.Gotham
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.TextYAlignment = Enum.TextYAlignment.Center
        lbl.TextWrapped = true

        -- Status pill
        local pill = Instance.new("TextLabel", card)
        pill.Size = UDim2.new(0, 40, 0, 18)
        pill.Position = UDim2.new(1, -100, 0.5, -9)
        pill.BackgroundColor3 = default and C.Green or C.Red
        pill.Text = default and "ON" or "OFF"
        pill.TextColor3 = Color3.fromRGB(255,255,255)
        pill.TextSize = 9
        pill.Font = Enum.Font.GothamBold
        pill.BorderSizePixel = 0
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        -- Toggle switch
        local togBG = Instance.new("Frame", card)
        togBG.Size = UDim2.new(0, 44, 0, 24)
        togBG.Position = UDim2.new(1, -54, 0.5, -12)
        togBG.BackgroundColor3 = default and C.Green or Color3.fromRGB(48, 46, 68)
        togBG.BorderSizePixel = 0
        Instance.new("UICorner", togBG).CornerRadius = UDim.new(1, 0)

        local knob = Instance.new("Frame", togBG)
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = default and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
        knob.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob.BorderSizePixel = 0
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

        local state = default
        local hit = Instance.new("TextButton", card)
        hit.Size = UDim2.new(1,0,1,0)
        hit.BackgroundTransparency = 1
        hit.Text = ""

        local function SetToggle(s)
            state = s
            TweenService:Create(togBG, TweenInfo.new(0.2), {
                BackgroundColor3 = s and C.Green or Color3.fromRGB(48,46,68)
            }):Play()
            TweenService:Create(knob, TweenInfo.new(0.2, Enum.EasingStyle.Back), {
                Position = s and UDim2.new(1,-21,0.5,-9) or UDim2.new(0,3,0.5,-9)
            }):Play()
            TweenService:Create(pill, TweenInfo.new(0.15), {
                BackgroundColor3 = s and C.Green or C.Red
            }):Play()
            pill.Text = s and "ON" or "OFF"
            if callback then callback(s) end
        end

        hit.MouseButton1Click:Connect(function() SetToggle(not state) end)
        card.MouseEnter:Connect(function()
            TweenService:Create(cstroke, TweenInfo.new(0.15), {Color = C.BorderAc}):Play()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = C.CardHov}):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(cstroke, TweenInfo.new(0.15), {Color = C.Border}):Play()
            TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = C.Card}):Play()
        end)
    end

    -- ── Button ────────────────────────────────────
    function tab:CreateButton(label, callback)
        local btn2 = Instance.new("TextButton", scroll)
        btn2.Size = UDim2.new(1, 0, 0, 40)
        btn2.BackgroundColor3 = C.Accent
        btn2.Text = ""
        btn2.BorderSizePixel = 0
        Instance.new("UICorner", btn2).CornerRadius = UDim.new(0, 10)

        local bGrad = Instance.new("UIGradient", btn2)
        bGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(128, 68, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(78, 38, 195))
        }
        bGrad.Rotation = 90

        local bStroke = Instance.new("UIStroke", btn2)
        bStroke.Color = Color3.fromRGB(155, 90, 255)
        bStroke.Thickness = 1

        local bLbl = Instance.new("TextLabel", btn2)
        bLbl.Size = UDim2.new(1, -10, 1, 0)
        bLbl.BackgroundTransparency = 1
        bLbl.Text = label
        bLbl.TextColor3 = Color3.fromRGB(255,255,255)
        bLbl.TextSize = 12
        bLbl.Font = Enum.Font.GothamBold

        btn2.MouseButton1Click:Connect(function()
            TweenService:Create(btn2, TweenInfo.new(0.08), {BackgroundTransparency = 0.4}):Play()
            TweenService:Create(btn2, TweenInfo.new(0.08), {Size = UDim2.new(1,-4,0,38)}):Play()
            task.delay(0.12, function()
                TweenService:Create(btn2, TweenInfo.new(0.12, Enum.EasingStyle.Back), {
                    BackgroundTransparency = 0,
                    Size = UDim2.new(1,0,0,40)
                }):Play()
            end)
            if callback then callback() end
        end)
        btn2.MouseEnter:Connect(function()
            TweenService:Create(btn2, TweenInfo.new(0.15), {BackgroundColor3 = C.AccentHov}):Play()
        end)
        btn2.MouseLeave:Connect(function()
            TweenService:Create(btn2, TweenInfo.new(0.15), {BackgroundColor3 = C.Accent}):Play()
        end)
    end

    -- ── Slider ────────────────────────────────────
    function tab:CreateSlider(label, minV, maxV, default, callback)
        local card = Instance.new("Frame", scroll)
        card.Size = UDim2.new(1, 0, 0, 62)
        card.BackgroundColor3 = C.Card
        card.BorderSizePixel = 0
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

        local cstroke2 = Instance.new("UIStroke", card)
        cstroke2.Color = C.Border
        cstroke2.Thickness = 1

        local topLbl = Instance.new("TextLabel", card)
        topLbl.Size = UDim2.new(1, -60, 0, 22)
        topLbl.Position = UDim2.new(0, 12, 0, 6)
        topLbl.BackgroundTransparency = 1
        topLbl.Text = label
        topLbl.TextColor3 = C.Text
        topLbl.TextSize = 12
        topLbl.Font = Enum.Font.Gotham
        topLbl.TextXAlignment = Enum.TextXAlignment.Left

        local valLbl = Instance.new("TextLabel", card)
        valLbl.Size = UDim2.new(0, 50, 0, 22)
        valLbl.Position = UDim2.new(1, -58, 0, 6)
        valLbl.BackgroundTransparency = 1
        valLbl.Text = tostring(default)
        valLbl.TextColor3 = C.Accent2
        valLbl.TextSize = 13
        valLbl.Font = Enum.Font.GothamBold
        valLbl.TextXAlignment = Enum.TextXAlignment.Right

        -- Track
        local track = Instance.new("Frame", card)
        track.Size = UDim2.new(1, -24, 0, 6)
        track.Position = UDim2.new(0, 12, 0, 38)
        track.BackgroundColor3 = Color3.fromRGB(38, 36, 58)
        track.BorderSizePixel = 0
        Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

        local ratio0 = (default - minV) / (maxV - minV)

        local fill = Instance.new("Frame", track)
        fill.Size = UDim2.new(ratio0, 0, 1, 0)
        fill.BackgroundColor3 = C.Accent2
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

        local fillGrad = Instance.new("UIGradient", fill)
        fillGrad.Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(100,55,225)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(175,100,255))
        }

        local knob2 = Instance.new("Frame", track)
        knob2.Size = UDim2.new(0, 14, 0, 14)
        knob2.AnchorPoint = Vector2.new(0.5, 0.5)
        knob2.Position = UDim2.new(ratio0, 0, 0.5, 0)
        knob2.BackgroundColor3 = Color3.fromRGB(255,255,255)
        knob2.BorderSizePixel = 0
        knob2.ZIndex = 2
        Instance.new("UICorner", knob2).CornerRadius = UDim.new(1, 0)

        local knobShadow = Instance.new("UIStroke", knob2)
        knobShadow.Color = C.Accent2
        knobShadow.Thickness = 2

        local sliderHit = Instance.new("TextButton", track)
        sliderHit.Size = UDim2.new(1, 0, 0, 26)
        sliderHit.Position = UDim2.new(0, 0, 0.5, -13)
        sliderHit.BackgroundTransparency = 1
        sliderHit.Text = ""
        sliderHit.ZIndex = 3

        local draggingSlider = false

        local function Drag(inp)
            local rx = math.clamp(
                (inp.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1
            )
            local val = math.floor(minV + rx * (maxV - minV) + 0.5)
            local r   = (val - minV) / (maxV - minV)
            fill.Size = UDim2.new(r, 0, 1, 0)
            knob2.Position = UDim2.new(r, 0, 0.5, 0)
            valLbl.Text = tostring(val)
            if callback then callback(val) end
        end

        sliderHit.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = true
                Drag(inp)
            end
        end)
        sliderHit.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then
                draggingSlider = false
            end
        end)
        UserInput.InputChanged:Connect(function(inp)
            if draggingSlider and inp.UserInputType == Enum.UserInputType.MouseMovement then
                Drag(inp)
            end
        end)

        card.MouseEnter:Connect(function()
            TweenService:Create(cstroke2, TweenInfo.new(0.15), {Color = C.BorderAc}):Play()
        end)
        card.MouseLeave:Connect(function()
            TweenService:Create(cstroke2, TweenInfo.new(0.15), {Color = C.Border}):Play()
        end)
    end

    table.insert(allTabs, tab)
    return tab
end

-- ═══════════════════════════════════════
--  TẠO TẤT CẢ TABS
-- ═══════════════════════════════════════
local espTab = CreateTab("ESP", "👁")
espTab:CreateSection("Cài đặt ESP")
espTab:CreateToggle("ESP Murderer & Sheriff", false, function(s)
    ESP.Enabled = s; UpdateESP()
    Notify("ESP " .. (s and "✓ Bật" or "✗ Tắt"), 2,
        s and C.Green or C.Red)
end)
espTab:CreateButton("↺  Làm mới ESP", function()
    UpdateESP()
    Notify("✓ ESP đã được làm mới!", 2, C.Accent2)
end)

local aimTab = CreateTab("Aim", "🎯")
aimTab:CreateSection("Cài đặt Aim")
aimTab:CreateToggle("Auto Aim (người gần nhất)", false, function(s)
    Aim.Enabled = s
    Notify("Auto Aim " .. (s and "✓ Bật" or "✗ Tắt"), 2,
        s and C.Green or C.Red)
end)
aimTab:CreateButton("🎯  Aim Thủ Công (1 lần)", function()
    local best, bestDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then Notify("✗ Nhân vật chưa sẵn sàng!", 2, C.Red); return end
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if r then
            local d = (r.Position - myRoot.Position).Magnitude
            if d < bestDist then bestDist = d; best = p end
        end
    end
    if best then
        AimAt(best)
        Notify("🎯 Đang nhắm → " .. best.Name, 2, C.Accent2)
    else
        Notify("✗ Không tìm thấy mục tiêu", 2, C.Red)
    end
end)

local killTab = CreateTab("Kill", "💀")
killTab:CreateSection("Tùy chọn Kill")
killTab:CreateButton("⚡  Kill Người Gần Nhất", function()
    local best, bestDist = nil, math.huge
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then Notify("✗ Nhân vật chưa sẵn sàng!", 2, C.Red); return end
    for _, p in pairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if r then
            local d = (r.Position - myRoot.Position).Magnitude
            if d < bestDist then bestDist = d; best = p end
        end
    end
    if best then
        KillPlayer(best)
        Notify("💀 Đã tiêu diệt: " .. best.Name, 2, C.Red)
    else
        Notify("✗ Không tìm thấy mục tiêu", 2, C.Red)
    end
end)
killTab:CreateButton("☠  Kill Tất Cả Người Chơi", function()
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then KillPlayer(p); count += 1 end
    end
    Notify("☠ Đã tiêu diệt " .. count .. " người!", 2, C.Red)
end)

local playerTab = CreateTab("Player", "🛡")
playerTab:CreateSection("Điều khiển nhân vật")
playerTab:CreateToggle("Đóng Băng Tất Cả", false, function(s)
    Freeze.Enabled = s; UpdateFreeze()
    Notify("Đóng băng " .. (s and "✓ Bật" or "✗ Tắt"), 2,
        s and C.Green or C.Red)
end)
playerTab:CreateToggle("Mở Rộng Hitbox (×1.8)", false, function(s)
    Hitbox.Enabled = s; UpdateHitbox()
    Notify("Hitbox " .. (s and "✓ Mở rộng" or "↩ Bình thường"), 2,
        s and C.Green or C.Red)
end)

local farmTab = CreateTab("Farm", "🌾")
farmTab:CreateSection("Auto Farm")
farmTab:CreateToggle("Auto Farm Coins", false, function(s)
    Farm.CoinEnabled = s
    Notify("Auto Farm Coins " .. (s and "✓ Bật" or "✗ Tắt"), 2,
        s and C.Green or C.Red)
end)
farmTab:CreateToggle("Auto Nhặt Vũ Khí", false, function(s)
    Farm.WeaponEnabled = s
    Notify("Auto Nhặt Vũ Khí " .. (s and "✓ Bật" or "✗ Tắt"), 2,
        s and C.Green or C.Red)
end)

local dodgeTab = CreateTab("Dodge", "💨")
dodgeTab:CreateSection("Cài đặt Auto Dodge")
dodgeTab:CreateToggle("Auto Dodge (Đạn & Melee)", false, function(s)
    Dodge.Enabled = s
    Notify("Auto Dodge " .. (s and "✓ Bật" or "✗ Tắt"), 2,
        s and C.Green or C.Red)
end)
dodgeTab:CreateSlider("Khoảng cách né", 3, 10, 5, function(v)
    Dodge.DodgeDistance = v
    Notify("Khoảng cách né: " .. v, 1.5, C.Accent2)
end)
dodgeTab:CreateSlider("Tầm phát hiện mối đe dọa", 10, 50, 30, function(v)
    Dodge.CheckRadius = v
    Notify("Tầm phát hiện: " .. v, 1.5, C.Accent2)
end)

local miscTab = CreateTab("Misc", "⚙")
miscTab:CreateSection("Hiệu suất & Tiện ích")
miscTab:CreateToggle("Giảm Lag (Low Graphics)", false, function(s)
    LagFix.Enabled = s; ApplyLagFix(s)
    Notify("Đồ họa thấp " .. (s and "✓ Bật" or "✗ Tắt"), 2,
        s and C.Green or C.Red)
end)
miscTab:CreateButton("🔄  Làm Mới Tất Cả Tính Năng", function()
    UpdateESP(); UpdateFreeze(); UpdateHitbox()
    Notify("✓ Đã làm mới toàn bộ!", 2, C.Green)
end)
miscTab:CreateButton("🗑  Huỷ Đông Cứng Tất Cả", function()
    Freeze.Enabled = false
    for _, p in pairs(Players:GetPlayers()) do
        ApplyFreeze(p, false)
    end
    Notify("✓ Đã huỷ đóng băng!", 2, C.Green)
end)

-- ═══════════════════════════════════════
--  OPEN ANIMATION + KÍCH HOẠT TAB ĐẦU
-- ═══════════════════════════════════════
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 590, 0, 420),
    Position = UDim2.new(0.5, -295, 0.5, -210)
}):Play()

task.delay(0.15, function()
    if allTabs[1] then allTabs[1]:Activate() end
end)

-- ═══════════════════════════════════════
--  KHỞI TẠO
-- ═══════════════════════════════════════
UpdateESP()
ApplyLagFix(false)

task.delay(0.6, function()
    Notify("⚡ MM2 Hub v2.0 đã tải thành công!", 4, C.Accent2)
end)
═══════════════════
--  OPEN ANIMATION + KÍCH HOẠT TAB ĐẦU
-- ═══════════════════════════════════════
Main.Size = UDim2.new(0, 0, 0, 0)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(Main, TweenInfo.new(0.45, Enum.EasingStyle.Back), {
    Size = UDim2.new(0, 590, 0, 420),
    Position = UDim2.new(0.5, -295, 0.5, -210)
}):Play()

task.delay(0.15, function()
    if allTabs[1] then allTabs[1]:Activate() end
end)

-- ═══════════════════════════════════════
--  KHỞI TẠO
-- ═══════════════════════════════════════
UpdateESP()
ApplyLagFix(false)

task.delay(0.6, function()
    Notify("⚡ MM2 Hub v2.0 đã tải thành công!", 4, C.Accent2)
end)
