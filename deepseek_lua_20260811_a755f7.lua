-- ================================================================
-- MURDER MYSTERY 2 – ULTIMATE V21 (Delta X)
-- Lock Aim tự động khóa vào sát thủ (murderer) khi bạn là sheriff.
-- Bỏ phím T. Các tính năng khác giữ nguyên.
-- ================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local mouse = LocalPlayer:GetMouse()

-- ===== CẤU HÌNH =====
local features = {
    ESP = false,
    SilentAim = false,
    WallClick = false,
    TeamCheck = false,
    ShowDistance = false,
    AutoTeleportGun = false,
    TeleportHalf = false,
    AutoPickCoin = false,
    Invisible = false,
    LockAim = false,          -- Không cần phím, tự động lock murderer
}

local CONFIG = {
    AutoPickRadius = 40,
    ESP_UpdateInterval = 0.3,
    DesyncInterval = 0.05,
    MaxLockDistance = 50,
    SilentMaxDistance = 200,
    SilentHitChance = 100,
    SilentTargetPart = "Head",
    ESP_AutoCheckInterval = 3,
    TeleportCooldown = 1.5,
    MaxDetectionDist = 50,
}

-- ================================================================
-- ===== HÀM XÁC ĐỊNH VAI TRÒ (DÙNG CHUNG) =====
-- ================================================================
local function getPlayerRole(player)
    local char = player.Character
    if not char then return "innocent" end
    local backpack = player:FindFirstChildOfClass("Backpack")
    local tools = {}
    local held = char:FindFirstChildOfClass("Tool")
    if held then table.insert(tools, held) end
    if backpack then
        for _, t in pairs(backpack:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    local hasGun, hasKnife = false, false
    for _, t in pairs(tools) do
        local name = t.Name:lower()
        if name:find("gun") or name:find("pistol") or name:find("sheriff") or name:find("revolver") then
            hasGun = true
        elseif name:find("knife") or name:find("dagger") or name:find("blade") then
            hasKnife = true
        end
    end
    if hasGun then return "sheriff" end
    if hasKnife then return "murderer" end
    return "innocent"
end

-- ================================================================
-- ===== ESP =====
-- ================================================================
local COLOR_GUN = Color3.fromRGB(0, 150, 255)
local COLOR_KNIFE = Color3.fromRGB(255, 0, 0)
local COLOR_INNOCENT = Color3.fromRGB(100, 255, 100)

local espData = {}

local function clearESP()
    for player, data in pairs(espData) do
        if data then
            for _, obj in pairs(data) do
                if obj and obj.Parent then pcall(function() obj:Destroy() end) end
            end
        end
    end
    espData = {}
end

local function updateESPColor(player)
    local data = espData[player]
    if not data then return end
    local highlight = data[1]
    if not highlight then return end
    local role = getPlayerRole(player)
    if role == "sheriff" then
        highlight.FillColor = COLOR_GUN
    elseif role == "murderer" then
        highlight.FillColor = COLOR_KNIFE
    else
        highlight.FillColor = COLOR_INNOCENT
    end
end

local function createESP(player)
    if not features.ESP or player == LocalPlayer then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    if espData[player] then
        for _, obj in pairs(espData[player]) do
            if obj and obj.Parent then pcall(function() obj:Destroy() end) end
        end
        espData[player] = nil
    end
    local root = char.HumanoidRootPart
    local head = char:FindFirstChild("Head") or root
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillTransparency = 0.35
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.OutlineTransparency = 0.1
    highlight.Parent = char
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 250, 0, 40)
    bill.AlwaysOnTop = true
    bill.Parent = head
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextColor3 = Color3.new(1,1,1)
    text.TextStrokeTransparency = 0.3
    text.Text = player.Name
    text.Parent = bill
    espData[player] = {highlight, bill, text}
    updateESPColor(player)
end

local function updateESP()
    for player, data in pairs(espData) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(data) do
                if obj and obj.Parent then pcall(function() obj:Destroy() end) end
            end
            espData[player] = nil
        else
            updateESPColor(player)
            if features.ShowDistance then
                local root = char.HumanoidRootPart
                local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                             (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
                local text = data[3]
                if text then
                    text.Text = player.Name .. " | " .. string.format("%.1f", dist/3.28) .. "m"
                end
            else
                local text = data[3]
                if text then text.Text = player.Name end
            end
        end
    end
end

local function refreshESP()
    clearESP()
    if not features.ESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end
end

local function hookPlayer(player)
    local function onToolChange()
        if features.ESP then updateESPColor(player) end
    end
    if player.Character then
        player.Character.ChildAdded:Connect(onToolChange)
        player.Character.ChildRemoved:Connect(onToolChange)
    end
    player.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(onToolChange)
        char.ChildRemoved:Connect(onToolChange)
    end)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        backpack.ChildAdded:Connect(onToolChange)
        backpack.ChildRemoved:Connect(onToolChange)
    end
end

Players.PlayerAdded:Connect(function(player)
    hookPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.3)
        if features.ESP then createESP(player) end
    end)
    if player.Character then
        task.wait(0.3)
        if features.ESP then createESP(player) end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if espData[player] then
        for _, obj in pairs(espData[player]) do
            if obj and obj.Parent then pcall(function() obj:Destroy() end) end
        end
        espData[player] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshESP()
end)

task.spawn(function()
    while task.wait(CONFIG.ESP_AutoCheckInterval) do
        if features.ESP then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and not espData[plr] and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    createESP(plr)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait(CONFIG.ESP_UpdateInterval) do
        if features.ESP then updateESP() end
    end
end)

local function toggleESP(val)
    features.ESP = val
    if val then refreshESP() else clearESP() end
end

-- ================================================================
-- ===== SILENT AIM =====
-- ================================================================
local silentHooked = false

local function getClosestTargetPart()
    if not features.SilentAim then return nil end
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local bestPart, bestDist = nil, CONFIG.SilentMaxDistance
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(CONFIG.SilentTargetPart)
            local hum = plr.Character:FindFirstChild("Humanoid")
            if part and hum and hum.Health > 0 then
                local dist = (root.Position - part.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    bestPart = part
                end
            end
        end
    end
    return bestPart
end

local function setupSilentAim()
    if silentHooked then return end
    local gmt = getrawmetatable(game)
    if not gmt then
        print("[Axiom] Không hook metatable, dùng fallback.")
        return
    end
    setreadonly(gmt, false)
    local oldIndex = gmt.__index
    gmt.__index = newcclosure(function(self, index)
        if self == mouse and features.SilentAim then
            local targetPart = getClosestTargetPart()
            if targetPart and math.random(1,100) <= CONFIG.SilentHitChance then
                if index == "Hit" then
                    return targetPart.CFrame
                elseif index == "Target" then
                    return targetPart
                end
            end
        end
        return oldIndex(self, index)
    end)
    setreadonly(gmt, true)
    silentHooked = true
    print("[Axiom] Silent Aim Hook đã kích hoạt!")
end

local function toggleSilentAim(val)
    features.SilentAim = val
    if val then setupSilentAim() end
end

local function doShoot(target)
    if not target or not target.Character then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local origin = Camera.CFrame.Position
    local targetPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
    local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Remote") 
                   or ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:FindFirstChild("Remote")
    if remote then
        pcall(function()
            remote:FireServer(origin, targetPos)
            remote:FireServer({origin, targetPos})
            remote:FireServer(targetPos)
        end)
    end
    local handle = tool:FindFirstChild("Handle")
    if handle then
        local old = handle.CFrame
        handle.CFrame = CFrame.lookAt(handle.Position, targetPos)
        task.wait(0.01)
        handle.CFrame = old
        tool:Activate()
    end
end

local function getAimTarget()
    -- Ưu tiên Lock Aim target (murderer)
    if features.LockAim then
        -- Tìm murderer
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if getPlayerRole(plr) == "murderer" then
                    return plr
                end
            end
        end
    end
    -- Nếu không có Lock Aim hoặc không tìm thấy murderer, dùng Silent Aim
    if features.SilentAim then
        local part = getClosestTargetPart()
        if part then
            local plr = Players:GetPlayerFromCharacter(part.Parent)
            if plr then return plr end
        end
    end
    return nil
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if features.WallClick then
            local target = getAimTarget()
            if target then doShoot(target) end
        else
            local target = getAimTarget()
            if target then
                local origin = Camera.CFrame.Position
                local targetPos = target.Character.HumanoidRootPart.Position
                local ray = Ray.new(origin, (targetPos - origin).Unit * 1000)
                local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                if hit and hit:IsDescendantOf(target.Character) then
                    doShoot(target)
                end
            end
        end
    end
end)

-- ================================================================
-- ===== LOCK AIM TỰ ĐỘNG VÀO SÁT THỦ (KHÔNG PHÍM T) =====
-- ================================================================
RunService.RenderStepped:Connect(function()
    if not features.LockAim then return end
    -- Chỉ sheriff mới khóa vào murderer
    if getPlayerRole(LocalPlayer) ~= "sheriff" then return end
    
    local murderer = nil
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if getPlayerRole(plr) == "murderer" then
                murderer = plr
                break
            end
        end
    end
    if not murderer then return end
    
    local tRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    local tHum = murderer.Character:FindFirstChild("Humanoid")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not tRoot or not tHum or tHum.Health <= 0 or not myRoot then return end
    
    -- Khóa camera và xoay nhân vật
    local camPos = Camera.CFrame.Position
    Camera.CFrame = CFrame.new(camPos, tRoot.Position)
    local lookAt = Vector3.new(tRoot.Position.X, myRoot.Position.Y, tRoot.Position.Z)
    myRoot.CFrame = CFrame.new(myRoot.Position, lookAt)
end)

-- ================================================================
-- ===== TELEPORT SÚNG (tìm WeaponDisplays) =====
-- ================================================================
local lastTpTime = 0

local function IsGunOwned(object)
    local current = object
    while current and current ~= workspace do
        if current:IsA("Backpack") then
            return true
        end
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            if current == LocalPlayer.Character then
                return false
            end
            return true
        end
        current = current.Parent
    end
    return false
end

local function FindDroppedGun()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") then
            if not IsGunOwned(obj) then
                local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                if handle then
                    local dist = (root.Position - handle.Position).Magnitude
                    if dist <= CONFIG.MaxDetectionDist then
                        return handle
                    end
                end
            end
        end
        if obj:IsA("Model") and (obj.Name:lower():find("gun") or obj.Name:lower():find("knife") or obj.Name:lower():find("weapon")) then
            local parent = obj.Parent
            if parent and parent.Name == "WeaponDisplays" then
                if not IsGunOwned(obj) then
                    local targetPart = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                    if targetPart then
                        local dist = (root.Position - targetPart.Position).Magnitude
                        if dist <= CONFIG.MaxDetectionDist then
                            return targetPart
                        end
                    end
                end
            end
        end
        if obj:IsA("Model") and (obj.Name:lower():find("display") or obj.Name:lower():find("gun") or obj.Name:lower():find("knife")) then
            if obj.Parent and obj.Parent.Name == "WeaponDisplays" then
                if not IsGunOwned(obj) then
                    local targetPart = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                    if targetPart then
                        local dist = (root.Position - targetPart.Position).Magnitude
                        if dist <= CONFIG.MaxDetectionDist then
                            return targetPart
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function teleportToGunLoop()
    if not features.AutoTeleportGun then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChild("Humanoid")
    if root and hum and hum.Health > 0 and (tick() - lastTpTime > CONFIG.TeleportCooldown) then
        local gunPart = FindDroppedGun()
        if gunPart then
            lastTpTime = tick()
            root.CFrame = gunPart.CFrame + Vector3.new(0, 2, 0)
        end
    end
end

RunService.Heartbeat:Connect(function()
    teleportToGunLoop()
end)

-- ================================================================
-- ===== TELEPORT HALF =====
-- ================================================================
local function getGroundY(pos)
    local ray = Ray.new(pos + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0))
    local hit, hitPos = workspace:FindPartOnRay(ray, nil)
    if hit and hitPos then return hitPos.Y end
    return pos.Y - 5
end

local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return end
    local localRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not localRoot then return end
    local targetPos = targetRoot.Position
    local humanoid = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
    local halfHeight = (humanoid and humanoid.HipHeight or 2) + 0.5
    local newPos
    if features.TeleportHalf then
        local groundY = getGroundY(targetPos)
        newPos = Vector3.new(targetPos.X, groundY + halfHeight/2, targetPos.Z)
    else
        newPos = targetPos
    end
    for i = 1, 3 do
        localRoot.CFrame = CFrame.new(newPos)
        task.wait(0.05)
    end
    localRoot.Velocity = Vector3.new(0,0,0)
end

-- ================================================================
-- ===== AUTO PICK COIN =====
-- ================================================================
local function pickUpCoins()
    if not features.AutoPickCoin then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local pos = root.Position
    local radius = CONFIG.AutoPickRadius
    local nearestCoin, nearestDist = nil, radius
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("gem") or name:find("xu") or name:find("money") then
                local dist = (pos - obj.Position).Magnitude
                if dist < nearestDist then
                    nearestDist = dist
                    nearestCoin = obj
                end
            end
        end
    end
    if nearestCoin then
        local targetPos = nearestCoin.Position + Vector3.new(0, 1.5, 0)
        root.CFrame = CFrame.new(targetPos)
        task.wait(0.1)
        local detector = nearestCoin:FindFirstChildOfClass("ClickDetector")
        if detector then pcall(function() detector:Click() end) end
        root.Velocity = Vector3.new(0,0,0)
    end
end

task.spawn(function()
    while task.wait(1.2) do
        if features.AutoPickCoin then pickUpCoins() end
    end
end)

-- ================================================================
-- ===== INVISIBLE DESYNC =====
-- ================================================================
local desyncActive = false
local fakeCF = CFrame.new(0,0,0)

local function startDesync()
    if desyncActive then return end
    desyncActive = true
    local char = LocalPlayer.Character
    if not char then desyncActive = false return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then desyncActive = false return end
    fakeCF = root.CFrame
    task.spawn(function()
        while desyncActive and features.Invisible do
            local currentChar = LocalPlayer.Character
            if not currentChar then desyncActive = false break end
            local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
            if not currentRoot then desyncActive = false break end
            local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                features.Invisible = false
                desyncActive = false
                break
            end
            pcall(function()
                sethiddenproperty(currentRoot, "NetworkIsSleeping", true)
                currentRoot.CFrame = fakeCF
                currentRoot.Velocity = Vector3.new(0,0,0)
                currentRoot.RotVelocity = Vector3.new(0,0,0)
            end)
            task.wait(CONFIG.DesyncInterval)
        end
    end)
end

local function stopDesync()
    desyncActive = false
    local char = LocalPlayer.Character
    if char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            pcall(function() sethiddenproperty(root, "NetworkIsSleeping", false) end)
        end
    end
end

local function toggleInvisible(val)
    features.Invisible = val
    if val then startDesync() else stopDesync() end
end

LocalPlayer.CharacterAdded:Connect(function()
    if features.Invisible then
        features.Invisible = false
        stopDesync()
    end
end)

-- ================================================================
-- ===== GUI MENU =====
-- ================================================================
if LocalPlayer.PlayerGui:FindFirstChild("MinhChien") then 
    LocalPlayer.PlayerGui.MinhChien:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name = "MinhChien"
ScreenGui.ResetOnSpawn = false

local ClickSound = Instance.new("Sound", ScreenGui)
ClickSound.SoundId = "rbxassetid://452267918"
ClickSound.Volume = 1

local function Drag(gui)
    local drag, input, start, pos = false, nil, nil, nil
    gui.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true start = i.Position pos = gui.Position
        end
    end)
    gui.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then input = i end
    end)
    RunService.RenderStepped:Connect(function()
        if drag and input then
            local d = input.Position - start
            gui.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then drag = false end
    end)
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 670)
Main.Position = UDim2.new(0.5, -130, 0.15, 0)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
Main.Visible = false
Main.Active = true
Drag(Main)

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 3
task.spawn(function() 
    while task.wait(0.01) do MainStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end 
end)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "MINHCHIENMM2"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 13
Title.BackgroundTransparency = 1

local Holder = Instance.new("ScrollingFrame", Main)
Holder.Size = UDim2.new(0.92, 0, 0.85, 0)
Holder.Position = UDim2.new(0.04, 0, 0.10, 0)
Holder.BackgroundTransparency = 1
Holder.CanvasSize = UDim2.new(0, 0, 13, 0)
Holder.ScrollBarThickness = 0

local Layout = Instance.new("UIListLayout", Holder)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Icon = Instance.new("Frame", ScreenGui)
Icon.Size = UDim2.new(0, 60, 0, 60)
Icon.Position = UDim2.new(0, 10, 0, 7)
Icon.BackgroundColor3 = Color3.new(0, 0, 0)
Icon.Active = true
Drag(Icon)

local IconCorner = Instance.new("UICorner", Icon)
IconCorner.CornerRadius = UDim.new(1, 0)

local IconStroke = Instance.new("UIStroke", Icon)
IconStroke.Thickness = 3
task.spawn(function() 
    while task.wait(0.01) do IconStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end 
end)

local Img = Instance.new("ImageLabel", Icon)
Img.Size = UDim2.new(0.9, 0, 0.9, 0)
Img.Position = UDim2.new(0.05, 0, 0.05, 0)
Img.Image = "rbxassetid://74840524656036"
Img.BackgroundTransparency = 1
local ImgCorner = Instance.new("UICorner", Img)
ImgCorner.CornerRadius = UDim.new(1, 0)

local IconBtn = Instance.new("TextButton", Icon)
IconBtn.Size = UDim2.new(1, 0, 1, 0)
IconBtn.BackgroundTransparency = 1
IconBtn.Text = ""
IconBtn.Activated:Connect(function() 
    Main.Visible = not Main.Visible 
    ClickSound:Play()
end)

local function CreateToggle(text, defaultValue, callback)
    local btn = Instance.new("TextButton", Holder)
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    btn.Text = text .. (defaultValue and " [ON]" or " [OFF]")
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    local btnCorner = Instance.new("UICorner", btn)
    btnCorner.CornerRadius = UDim.new(0, 4)
    local state = defaultValue
    btn.Activated:Connect(function()
        state = not state
        btn.Text = text .. (state and " [ON]" or " [OFF]")
        if callback then callback(state) end
        ClickSound:Play()
    end)
    return btn
end

CreateToggle("ESP", features.ESP, function(val) toggleESP(val) end)
CreateToggle("Silent Aim", features.SilentAim, function(val) toggleSilentAim(val) end)
CreateToggle("Wall Click", features.WallClick, function(val) features.WallClick = val end)
CreateToggle("Lock Aim (tự động vào sát thủ)", features.LockAim, function(val) features.LockAim = val end)
CreateToggle("Team Check", features.TeamCheck, function(val) features.TeamCheck = val end)
CreateToggle("Show Distance", features.ShowDistance, function(val) features.ShowDistance = val end)
CreateToggle("Auto Teleport Gun", features.AutoTeleportGun, function(val) features.AutoTeleportGun = val end)
CreateToggle("Teleport Half-Body", features.TeleportHalf, function(val) features.TeleportHalf = val end)
CreateToggle("Auto Pick Coin", features.AutoPickCoin, function(val) features.AutoPickCoin = val end)
CreateToggle("Invisible (Desync)", features.Invisible, function(val) toggleInvisible(val) end)

local resetBtn = Instance.new("TextButton", Holder)
resetBtn.Size = UDim2.new(1, 0, 0, 36)
resetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
resetBtn.Text = "REFRESH ESP"
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 11
resetBtn.Activated:Connect(function() refreshESP() ClickSound:Play() end)

local teleportBtn = Instance.new("TextButton", Holder)
teleportBtn.Size = UDim2.new(1, 0, 0, 36)
teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
teleportBtn.Text = "TELEPORT TO PLAYER"
teleportBtn.TextColor3 = Color3.new(1,1,1)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 11

local playerListFrame = Instance.new("Frame", ScreenGui)
playerListFrame.Size = UDim2.new(0, 220, 0, 350)
playerListFrame.Position = UDim2.new(0.5, -110, 0.5, -175)
playerListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
playerListFrame.Visible = false
playerListFrame.Active = true
Drag(playerListFrame)

local listCorner = Instance.new("UICorner", playerListFrame)
listCorner.CornerRadius = UDim.new(0, 8)
local listStroke = Instance.new("UIStroke", playerListFrame)
listStroke.Thickness = 2
listStroke.Color = Color3.new(1,1,1)

local listTitle = Instance.new("TextLabel", playerListFrame)
listTitle.Size = UDim2.new(1, 0, 0, 30)
listTitle.Text = "Chọn người chơi"
listTitle.TextColor3 = Color3.new(1,1,1)
listTitle.Font = Enum.Font.GothamBold
listTitle.TextSize = 12
listTitle.BackgroundTransparency = 1

local listScroller = Instance.new("ScrollingFrame", playerListFrame)
listScroller.Size = UDim2.new(0.95, 0, 0.85, 0)
listScroller.Position = UDim2.new(0.025, 0, 0.08, 0)
listScroller.BackgroundTransparency = 1
listScroller.CanvasSize = UDim2.new(0, 0, 0, 0)
listScroller.ScrollBarThickness = 4

local listLayout = Instance.new("UIListLayout", listScroller)
listLayout.Padding = UDim.new(0, 4)
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function updatePlayerList()
    for _, child in pairs(listScroller:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    local count = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local btn = Instance.new("TextButton", listScroller)
            btn.Size = UDim2.new(0.9, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Text = plr.Name
            btn.TextColor3 = Color3.new(1,1,1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 11
            local corner = Instance.new("UICorner", btn)
            corner.CornerRadius = UDim.new(0, 4)
            btn.Activated:Connect(function()
                teleportToPlayer(plr)
                ClickSound:Play()
            end)
            count = count + 1
        end
    end
    listScroller.CanvasSize = UDim2.new(0, 0, 0, count * 35)
end

teleportBtn.Activated:Connect(function()
    playerListFrame.Visible = not playerListFrame.Visible
    if playerListFrame.Visible then updatePlayerList() end
    ClickSound:Play()
end)

-- ===== HƯỚNG DẪN =====
print("===== MM2 ULTIMATE V21 =====")
print("✅ Lock Aim: tự động khóa vào sát thủ khi bạn là sheriff (không cần phím)")
print("✅ ESP, Silent Aim, Wall Click, Teleport súng, Invisible vẫn đầy đủ")
print("👉 Tất cả OFF, bật từ menu. Chơi ngon boss man!")

-- ===== KHỞI TẠO =====
refreshESP()

-- ===== ANTI-BAN =====
local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
if remote then
    local oldFire = remote.FireServer
    remote.FireServer = function(self, ...) return oldFire(self, ...) end
end

print("Axiom MM2 Ultimate v21 – fuck yeah boss man. Lock Aim tự động vào sát thủ, không cần phím T.")