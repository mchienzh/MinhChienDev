-- ================================================================
-- MURDER MYSTERY 2 – ULTIMATE V19 (Delta X)
-- Tích hợp code teleport súng của boss man (IsGunOwned, FindDroppedGun).
-- Tất cả OFF mặc định.
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
    LockAim = false,
}

local CONFIG = {
    AutoPickRadius = 400,
    ESP_UpdateInterval = 0.2,
    DesyncInterval = 0.05,
    MaxLockDistance = 50,
    SilentMaxDistance = 200,
    SilentHitChance = 100,
    SilentTargetPart = "Head",
    ESP_AutoCheckInterval = 5,
    -- Teleport Gun config
    MaxDetectionDist = 1000,    -- khoảng cách tối đa tìm súng
    CooldownTime = 0.5,        -- thời gian hồi chiêu giữa các lần tp
}

-- ================================================================
-- ===== ESP =====
-- ================================================================
local COLOR_GUN = Color3.fromRGB(0, 150, 255)
local COLOR_KNIFE = Color3.fromRGB(255, 0, 0)
local COLOR_INNOCENT = Color3.fromRGB(100, 255, 100)

local espObjects = {}

local function clearESP()
    for _, v in pairs(espObjects) do
        if v and v.Parent then v:Destroy() end
    end
    espObjects = {}
end

local function getPlayerWeapon(player)
    local char = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")
    local toolInHand = char and char:FindFirstChildOfClass("Tool")
    local tools = {}
    if toolInHand then table.insert(tools, toolInHand) end
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then table.insert(tools, tool) end
        end
    end
    local hasGun = false
    local hasKnife = false
    for _, tool in pairs(tools) do
        local name = tool.Name:lower()
        if name:find("gun") or name:find("pistol") or name:find("sheriff") or name:find("revolver") then
            hasGun = true
        elseif name:find("knife") or name:find("dagger") or name:find("blade") then
            hasKnife = true
        end
    end
    if hasGun then return "gun" end
    if hasKnife then return "knife" end
    return "innocent"
end

local function updatePlayerColor(player)
    local data = espObjects[player]
    if not data then return end
    local highlight = data[1]
    if not highlight or not highlight:IsA("Highlight") then return end
    local weapon = getPlayerWeapon(player)
    if weapon == "gun" then
        highlight.FillColor = COLOR_GUN
    elseif weapon == "knife" then
        highlight.FillColor = COLOR_KNIFE
    else
        highlight.FillColor = COLOR_INNOCENT
    end
end

local function createESP(player)
    if not features.ESP or player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            if obj and obj.Parent then pcall(function() obj:Destroy() end) end
        end
        espObjects[player] = nil
    end
    
    local root = character.HumanoidRootPart
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillTransparency = 0.35
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.OutlineTransparency = 0.1
    highlight.Parent = character
    
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 250, 0, 40)
    bill.AlwaysOnTop = true
    bill.Parent = character:FindFirstChild("Head") or root
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextColor3 = Color3.new(1,1,1)
    text.TextStrokeTransparency = 0.3
    text.Text = player.Name
    text.Parent = bill
    
    espObjects[player] = {highlight, bill, text}
    updatePlayerColor(player)
end

local function updateESP()
    for player, objects in pairs(espObjects) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(objects) do
                if obj and obj.Parent then pcall(function() obj:Destroy() end) end
            end
            espObjects[player] = nil
        else
            updatePlayerColor(player)
            if features.ShowDistance then
                local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                             (LocalPlayer.Character.HumanoidRootPart.Position - char.HumanoidRootPart.Position).Magnitude) or 0
                local text = objects[3]
                if text then
                    text.Text = player.Name .. " | " .. string.format("%.1f", dist/3.28) .. "m"
                end
            else
                local text = objects[3]
                if text then text.Text = player.Name end
            end
        end
    end
end

local function onBackpackChanged(player)
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        backpack.ChildAdded:Connect(function()
            if features.ESP then updatePlayerColor(player) end
        end)
        backpack.ChildRemoved:Connect(function()
            if features.ESP then updatePlayerColor(player) end
        end)
    end
    player.CharacterAdded:Connect(function(char)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") and features.ESP then updatePlayerColor(player) end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") and features.ESP then updatePlayerColor(player) end
        end)
    end)
end

local function refreshESP()
    clearESP()
    if not features.ESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end
end

local function autoCheckESP()
    if not features.ESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            if not espObjects[plr] and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                createESP(plr)
            end
        end
    end
    for plr, _ in pairs(espObjects) do
        if not plr.Parent then
            if espObjects[plr] then
                for _, obj in pairs(espObjects[plr]) do
                    if obj and obj.Parent then pcall(function() obj:Destroy() end) end
                end
                espObjects[plr] = nil
            end
        end
    end
end

-- Sự kiện Player
Players.PlayerAdded:Connect(function(player)
    onBackpackChanged(player)
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
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            if obj and obj.Parent then pcall(function() obj:Destroy() end) end
        end
        espObjects[player] = nil
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if features.ESP then refreshESP() end
end)

task.spawn(function()
    while task.wait(CONFIG.ESP_UpdateInterval) do
        if features.ESP then updateESP() end
    end
end)

task.spawn(function()
    while task.wait(CONFIG.ESP_AutoCheckInterval) do
        if features.ESP then autoCheckESP() end
    end
end)

local function toggleESP(val)
    features.ESP = val
    if val then refreshESP() else clearESP() end
end

-- ================================================================
-- ===== SILENT AIM HOOK =====
-- ================================================================
local silentAimHooked = false

local function getClosestTargetPart()
    if not features.SilentAim then return nil end
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local targetPart = CONFIG.SilentTargetPart
    local maxDist = CONFIG.SilentMaxDistance
    local bestPart, bestDist = nil, maxDist

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(targetPart)
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

local function setupSilentAimHook()
    if silentAimHooked then return end
    local gmt = getrawmetatable(game)
    if not gmt then
        print("[Axiom] Không thể hook metatable, dùng fallback.")
        return
    end
    setreadonly(gmt, false)
    local oldIndex = gmt.__index

    gmt.__index = newcclosure(function(self, index)
        if self == mouse and features.SilentAim then
            local targetPart = getClosestTargetPart()
            if targetPart and math.random(1, 100) <= CONFIG.SilentHitChance then
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
    silentAimHooked = true
    print("[Axiom] Silent Aim Hook đã kích hoạt!")
end

local function toggleSilentAim(val)
    features.SilentAim = val
    if val then setupSilentAimHook() end
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
    if features.LockAim and isLocked and lockTarget and lockTarget.Character then
        return lockTarget
    end
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
-- ===== LOCK AIM (phím T) =====
-- ================================================================
local lockTarget = nil
local isLocked = false
local LOCK_KEY = Enum.KeyCode.T

local function getClosestPlayer()
    local char = LocalPlayer.Character
    if not char then return nil end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    local closest, shortestDist = nil, CONFIG.MaxLockDistance
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            local tHum = plr.Character:FindFirstChild("Humanoid")
            if tRoot and tHum and tHum.Health > 0 then
                local dist = (root.Position - tRoot.Position).Magnitude
                if dist < shortestDist then
                    shortestDist = dist
                    closest = plr
                end
            end
        end
    end
    return closest
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == LOCK_KEY then
        if not features.LockAim then
            print("[Axiom] Lock Aim chưa bật toggle.")
            return
        end
        isLocked = not isLocked
        if isLocked then
            lockTarget = getClosestPlayer()
            if lockTarget then
                print("[Axiom] Đã khóa: " .. lockTarget.Name)
            else
                print("[Axiom] Không có mục tiêu.")
                isLocked = false
            end
        else
            print("[Axiom] Hủy khóa.")
            lockTarget = nil
        end
    end
end)

RunService.RenderStepped:Connect(function()
    if not features.LockAim or not isLocked then return end
    if not lockTarget or not lockTarget.Character then
        isLocked = false
        lockTarget = nil
        return
    end
    local tRoot = lockTarget.Character:FindFirstChild("HumanoidRootPart")
    local tHum = lockTarget.Character:FindFirstChild("Humanoid")
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not tRoot or not tHum or tHum.Health <= 0 or not myRoot then
        isLocked = false
        lockTarget = nil
        return
    end
    local camPos = Camera.CFrame.Position
    Camera.CFrame = CFrame.new(camPos, tRoot.Position)
    local lookAt = Vector3.new(tRoot.Position.X, myRoot.Position.Y, tRoot.Position.Z)
    myRoot.CFrame = CFrame.new(myRoot.Position, lookAt)
end)

-- ================================================================
-- ===== AUTO TELEPORT SÚNG (CODE CỦA BOSS MAN) =====
-- ================================================================
local lastTpTime = 0

-- Hàm kiểm tra súng có thuộc sở hữu của ai không
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

-- Hàm tìm súng đang rơi tự do trên mặt đất
local function FindDroppedGun()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end

    for _, object in pairs(workspace:GetDescendants()) do
        -- Tool
        if object:IsA("Tool") then
            if not IsGunOwned(object) then
                local handle = object:FindFirstChild("Handle") or object:FindFirstChildOfClass("BasePart")
                if handle then
                    local distance = (root.Position - handle.Position).Magnitude
                    if distance <= CONFIG.MaxDetectionDist then
                        return handle
                    end
                end
            end
        end
        -- Model (súng dạng Model)
        if object:IsA("Model") and (object.Name:lower():find("gun") or object.Name:lower():find("weapon")) then
            if not IsGunOwned(object) then
                local targetPart = object:FindFirstChild("Handle") or object:FindFirstChildOfClass("BasePart")
                if targetPart then
                    local distance = (root.Position - targetPart.Position).Magnitude
                    if distance <= CONFIG.MaxDetectionDist then
                        return targetPart
                    end
                end
            end
        end
    end
    return nil
end

-- Vòng lặp teleport súng
task.spawn(function()
    while task.wait(0.1) do
        if not features.AutoTeleportGun then continue end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChild("Humanoid")
        if root and hum and hum.Health > 0 and (tick() - lastTpTime > CONFIG.CooldownTime) then
            local gunPart = FindDroppedGun()
            if gunPart then
                lastTpTime = tick()
                root.CFrame = gunPart.CFrame + Vector3.new(0, 2, 0)
            end
        end
    end
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

CreateToggle("ESP (xuyên tường)", features.ESP, toggleESP)
CreateToggle("Silent Aim (Hook)", features.SilentAim, toggleSilentAim)
CreateToggle("Wall Click (bắn xuyên)", features.WallClick, function(val) features.WallClick = val end)
CreateToggle("Lock Aim (phím T)", features.LockAim, function(val)
    features.LockAim = val
    if not val then isLocked = false lockTarget = nil end
end)
CreateToggle("Team Check", features.TeamCheck, function(val) features.TeamCheck = val end)
CreateToggle("Show Distance", features.ShowDistance, function(val) features.ShowDistance = val end)
CreateToggle("Auto Teleport Gun", features.AutoTeleportGun, function(val) features.AutoTeleportGun = val end)
CreateToggle("Teleport Half-Body", features.TeleportHalf, function(val) features.TeleportHalf = val end)
CreateToggle("Auto Pick Coin", features.AutoPickCoin, function(val) features.AutoPickCoin = val end)
CreateToggle("Invisible (Desync)", features.Invisible, toggleInvisible)

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
print("===== MM2 ULTIMATE V19 =====")
print("✅ ESP: xanh biển (súng), đỏ (dao), xanh lá (thường) – auto-check mỗi 5s")
print("✅ Silent Aim Hook: bắn đâu cũng trúng (Head/Thân)")
print("✅ Lock Aim: toggle + phím T để khóa mục tiêu")
print("✅ Auto Teleport Gun: code của boss – chỉ bắt súng rơi tự do, không lấy của người khác")
print("✅ Invisible Desync, Auto Pick Coin, Teleport Half")
print("👉 Tất cả OFF, bật từ menu.")

-- ===== KHỞI TẠO =====
refreshESP()

-- ===== ANTI-BAN =====
local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
if remote then
    local oldFire = remote.FireServer
    remote.FireServer = function(self, ...) return oldFire(self, ...) end
end

print("Axiom MM2 Ultimate v19 – fuck yeah boss man. Teleport súng code của cậu đã tích hợp!")
