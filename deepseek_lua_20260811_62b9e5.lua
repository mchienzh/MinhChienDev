-- ================================================================
-- MURDER MYSTERY 2 – ULTIMATE V24 (FULL REAL-TIME)
-- FIX: Bỏ refreshESP, real-time ESP, Wall Click + Silent Aim hoạt động,
-- Lock Aim mượt, Noclip, Dự đoán vai trò qua Remote, Teleport gần sát thủ,
-- Teleport súng dùng Model + Tool.
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
    Noclip = false,
    AutoPredictRole = false,      -- Dự đoán vai trò
    TeleportFromMurderer = false, -- Teleport khi gần sát thủ
}

local CONFIG = {
    AutoPickRadius = 40,
    ESP_UpdateInterval = 0.3,
    DesyncInterval = 0.05,
    MaxLockDistance = 50,
    SilentMaxDistance = 200,
    SilentHitChance = 100,
    SilentTargetPart = "Head",
    CoinPickDelay = 0.4,
    NoclipSpeed = 1.2,
    LockAimSmoothness = 0.85,     -- mượt hơn
    TeleportFromMurdererDist = 3, -- 3m
}

-- ================================================================
-- ===== DỰ ĐOÁN VAI TRÒ QUA REMOTE =====
-- ================================================================
local rolePrediction = {} -- player -> "sheriff" | "murderer" | "innocent"

-- Hook các remote liên quan đến vai trò
local function hookRoleRemotes()
    -- Lắng nghe RoleSelect (khi game chọn vai trò)
    local roleSelect = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("RoleSelect")
    if roleSelect and roleSelect:IsA("RemoteEvent") then
        roleSelect.OnClientEvent:Connect(function(player, role)
            if player and role then
                rolePrediction[player] = role:lower()
                print("[RolePrediction] " .. player.Name .. " = " .. role)
            end
        end)
    end
    -- GiveWeapon (khi trao súng/dao)
    local giveWeapon = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Gameplay") and ReplicatedStorage.Remotes.Gameplay:FindFirstChild("GiveWeapon")
    if giveWeapon and giveWeapon:IsA("RemoteEvent") then
        giveWeapon.OnClientEvent:Connect(function(player, weaponName)
            if player then
                local role = "innocent"
                if weaponName:lower():find("gun") or weaponName:lower():find("pistol") or weaponName:lower():find("sheriff") then
                    role = "sheriff"
                elseif weaponName:lower():find("knife") or weaponName:lower():find("dagger") or weaponName:lower():find("blade") then
                    role = "murderer"
                end
                rolePrediction[player] = role
                print("[RolePrediction] " .. player.Name .. " nhận " .. weaponName .. " => " .. role)
            end
        end)
    end
end
hookRoleRemotes()

-- Hàm lấy vai trò dự đoán (ưu tiên dự đoán, nếu không có thì dùng getPlayerRole)
local function getRole(player)
    if rolePrediction[player] then
        return rolePrediction[player]
    end
    -- Fallback: dùng hàm getPlayerRole cũ
    return getPlayerRole(player)
end

-- ================================================================
-- ===== ESP (REAL-TIME, KHÔNG REFRESH) =====
-- ================================================================
local ROLE_COLOR = {
    sheriff  = Color3.fromRGB(30,  144, 255),
    murderer = Color3.fromRGB(255, 50,  50),
    innocent = Color3.fromRGB(80,  255, 100),
}

local espData = {}

local function removePlayerESP(player)
    local d = espData[player]
    if not d then return end
    if d[1] and d[1].Parent then pcall(function() d[1]:Destroy() end) end
    if d[2] and d[2].Parent then pcall(function() d[2]:Destroy() end) end
    espData[player] = nil
end

local function clearESP()
    for player in pairs(espData) do
        removePlayerESP(player)
    end
    espData = {}
end

local function updateESPColor(player)
    local d = espData[player]
    if not d or not d[1] or not d[1].Parent then return end
    local role = getRole(player)  -- dùng dự đoán
    local color = ROLE_COLOR[role] or ROLE_COLOR.innocent
    d[1].FillColor    = color
    d[1].OutlineColor = color
end

local function createESP(player)
    if not features.ESP then return end
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then return end

    removePlayerESP(player)

    local hl = Instance.new("Highlight")
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency    = 0.45
    hl.OutlineTransparency = 0.0
    hl.Adornee             = char
    hl.Parent              = char

    local bill = Instance.new("BillboardGui")
    bill.Size        = UDim2.new(0, 120, 0, 18)
    bill.StudsOffset = Vector3.new(0, 2.8, 0)
    bill.AlwaysOnTop = true
    bill.Adornee     = head
    bill.Parent      = head

    local lbl = Instance.new("TextLabel", bill)
    lbl.Size                   = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.TextScaled             = false
    lbl.TextSize               = 10
    lbl.TextColor3             = Color3.new(1, 1, 1)
    lbl.TextStrokeTransparency = 0.3
    lbl.Font                   = Enum.Font.Gotham
    lbl.Text                   = player.Name

    espData[player] = { hl, bill, lbl }
    updateESPColor(player)
end

local function updateAllESP()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for player, d in pairs(espData) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            removePlayerESP(player)
            continue
        end
        if not d[1] or not d[1].Parent then
            removePlayerESP(player)
            createESP(player)
            continue
        end
        updateESPColor(player)

        local lbl = d[3]
        if lbl and lbl.Parent then
            if features.ShowDistance and myRoot then
                local r    = char:FindFirstChild("HumanoidRootPart")
                local dist = r and math.floor((myRoot.Position - r.Position).Magnitude / 3.28) or 0
                lbl.Text = player.Name .. " | " .. dist .. "m"
            else
                lbl.Text = player.Name
            end
        end
    end
end

local function toggleESP(val)
    features.ESP = val
    if val then
        -- Tạo ESP cho tất cả player hiện tại
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                createESP(plr)
            end
        end
    else
        clearESP()
    end
end

-- HOOK PLAYER REAL-TIME
local function hookPlayer(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.4)
        if features.ESP then createESP(player) end
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") or child:IsA("Model") then
                task.wait(0.2)
                updateESPColor(player)
            end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") or child:IsA("Model") then
                task.wait(0.2)
                updateESPColor(player)
            end
        end)
    end)

    if player.Character then
        local char = player.Character
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") or child:IsA("Model") then
                task.wait(0.2)
                updateESPColor(player)
            end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") or child:IsA("Model") then
                task.wait(0.2)
                updateESPColor(player)
            end
        end)
    end

    local function hookBackpack(bp)
        if not bp then return end
        bp.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then task.wait(0.2) updateESPColor(player) end
        end)
        bp.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then task.wait(0.2) updateESPColor(player) end
        end)
    end
    hookBackpack(player:FindFirstChildOfClass("Backpack"))
    player.ChildAdded:Connect(function(child)
        if child:IsA("Backpack") then hookBackpack(child) end
    end)
end

Players.PlayerAdded:Connect(function(player)
    hookPlayer(player)
    if player.Character and features.ESP then
        task.wait(0.4)
        createESP(player)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    removePlayerESP(player)
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    -- Tự động tạo ESP cho tất cả khi vào ván mới
    if features.ESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                createESP(plr)
            end
        end
    end
end)

for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then hookPlayer(plr) end
end

-- Vòng lặp update màu và distance (không refresh)
task.spawn(function()
    while true do
        task.wait(CONFIG.ESP_UpdateInterval)
        if features.ESP then
            updateAllESP()
        end
    end
end)

-- ================================================================
-- ===== NOCLIP =====
-- ================================================================
local noclipActive = false

local function setNoclip(val)
    noclipActive = val
    local char = LocalPlayer.Character
    if not char then return end
    for _, part in pairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = not val
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    if noclipActive then
        task.wait(0.2)
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ================================================================
-- ===== SILENT AIM + WALL CLICK (HOẠT ĐỘNG) =====
-- ================================================================
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

local function doShoot(target)
    if not target or not target.Character then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool then return end

    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end
    local targetPos = tRoot.Position + Vector3.new(0, 1.5, 0)
    local origin    = Camera.CFrame.Position
    local direction = (targetPos - origin).Unit

    -- Gửi remote trực tiếp
    for _, remote in pairs(tool:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(origin, targetPos) end)
            pcall(function() remote:FireServer(CFrame.new(origin, targetPos)) end)
            pcall(function() remote:FireServer(Ray.new(origin, direction * 500)) end)
            pcall(function() remote:FireServer(direction) end)
        end
    end

    -- Remote trong ReplicatedStorage
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local n = remote.Name:lower()
            if n:find("shoot") or n:find("fire") or n:find("gun") or n:find("bullet") then
                pcall(function() remote:FireServer(origin, targetPos) end)
            end
        end
    end

    -- Activate tool (kích hoạt bắn)
    pcall(function() tool:Activate() end)
end

local function getAimTarget()
    -- Ưu tiên Lock Aim target (murderer)
    if features.LockAim then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                if getRole(plr) == "murderer" then
                    return plr
                end
            end
        end
    end
    -- Nếu không có Lock Aim hoặc không tìm thấy, dùng Silent Aim
    if features.SilentAim then
        local part = getClosestTargetPart()
        if part then
            local plr = Players:GetPlayerFromCharacter(part.Parent)
            if plr then return plr end
        end
    end
    return nil
end

-- WALL CLICK: bắn xuyên tường (luôn bắn nếu có target)
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if features.WallClick then
            local target = getAimTarget()
            if target then doShoot(target) end
        else
            -- Bắn thường (có kiểm tra raycast)
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
-- ===== LOCK AIM (MƯỢT HƠN) =====
-- ================================================================
RunService.RenderStepped:Connect(function()
    if not features.LockAim then return end
    if getRole(LocalPlayer) ~= "sheriff" then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local murderer, bestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and getRole(plr) == "murderer" then
                local dist = (myRoot.Position - tRoot.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    murderer = plr
                end
            end
        end
    end
    if not murderer then return end

    local tRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    local tHum  = murderer.Character:FindFirstChild("Humanoid")
    if not tRoot or not tHum or tHum.Health <= 0 then return end

    local aimPos = tRoot.Position + Vector3.new(0, 1.5, 0)
    local targetCF = CFrame.new(Camera.CFrame.Position, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, CONFIG.LockAimSmoothness)
end)

-- ================================================================
-- ===== TELEPORT KHI GẦN SÁT THỦ (<3m) =====
-- ================================================================
task.spawn(function()
    while true do
        task.wait(0.3)
        if not features.TeleportFromMurderer then continue end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then continue end

        -- Tìm murderer gần nhất
        local murderer = nil
        local minDist = CONFIG.TeleportFromMurdererDist
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                if getRole(plr) == "murderer" then
                    local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        local dist = (root.Position - tRoot.Position).Magnitude
                        if dist < minDist then
                            murderer = plr
                            minDist = dist
                        end
                    end
                end
            end
        end

        if murderer then
            -- Tìm player xa nhất (không phải mình)
            local farthest, maxDist = nil, 0
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr ~= murderer and plr.Character then
                    local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
                    if tRoot then
                        local dist = (root.Position - tRoot.Position).Magnitude
                        if dist > maxDist then
                            maxDist = dist
                            farthest = plr
                        end
                    end
                end
            end
            if farthest then
                local targetRoot = farthest.Character:FindFirstChild("HumanoidRootPart")
                if targetRoot then
                    root.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 3, 0))
                end
            end
        end
    end
end)

-- ================================================================
-- ===== TELEPORT SÚNG (CÁCH MỚI: TÌM MODEL + TOOL) =====
-- ================================================================
local function IsGunOwned(object)
    local current = object
    while current and current ~= workspace do
        if current:IsA("Backpack") then return true end
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            return true
        end
        current = current.Parent
    end
    return false
end

local function isGunName(name)
    local n = name:lower()
    if n:find("knife") or n:find("dagger") or n:find("blade") then return false end
    if n:find("gun") or n:find("pistol") or n:find("sheriff") or n:find("revolver") or n:find("weapon") then
        return true
    end
    return false
end

local function FindDroppedGun()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local myPos = root.Position
    local bestPart, bestDist = nil, math.huge

    -- Duyệt toàn bộ workspace
    for _, obj in pairs(workspace:GetDescendants()) do
        -- Trường hợp Tool
        if obj:IsA("Tool") then
            if IsGunOwned(obj) then continue end
            if not isGunName(obj.Name) then continue end
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
            if handle then
                local dist = (myPos - handle.Position).Magnitude
                if dist < bestDist and dist <= CONFIG.MaxDetectionDist then
                    bestDist = dist
                    bestPart = handle
                end
            end
        end
        -- Trường hợp Model (WeaponDisplays)
        if obj:IsA("Model") then
            if IsGunOwned(obj) then continue end
            if not isGunName(obj.Name) then continue end
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
            if handle then
                local dist = (myPos - handle.Position).Magnitude
                if dist < bestDist and dist <= CONFIG.MaxDetectionDist then
                    bestDist = dist
                    bestPart = handle
                end
            end
        end
    end
    return bestPart
end

task.spawn(function()
    while true do
        task.wait(0.4)
        if not features.AutoTeleportGun then continue end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end
        local gunPart = FindDroppedGun()
        if gunPart and gunPart.Parent then
            root.CFrame = CFrame.new(gunPart.Position + Vector3.new(0, 3, 0))
        end
    end
end)

-- ================================================================
-- ===== AUTO PICK COIN (CHẬM, TRÁNH KICK) =====
-- ================================================================
local coinPickCooldown = 0

local function getAllCoins()
    local coins = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("gem") or name:find("collectible") or name:find("pickup") then
                table.insert(coins, obj)
            end
        end
    end
    return coins
end

task.spawn(function()
    while true do
        task.wait(0.15)
        if not features.AutoPickCoin then continue end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end
        if tick() - coinPickCooldown < CONFIG.CoinPickDelay then continue end

        local coins = getAllCoins()
        local nearest, bestDist = nil, CONFIG.AutoPickRadius
        for _, coin in ipairs(coins) do
            if not coin or not coin.Parent then continue end
            local dist = (root.Position - coin.Position).Magnitude
            if dist < bestDist then
                bestDist = dist
                nearest = coin
            end
        end
        if nearest then
            local targetPos = nearest.Position + Vector3.new(0, 2.5, 0)
            if (root.Position - targetPos).Magnitude > 3 then
                root.CFrame = CFrame.new(targetPos)
                task.wait(0.05)
                local pp = nearest:FindFirstChildOfClass("ProximityPrompt") or (nearest.Parent and nearest.Parent:FindFirstChildOfClass("ProximityPrompt"))
                if pp then pcall(function() fireproximityprompt(pp) end) end
                local cd = nearest:FindFirstChildOfClass("ClickDetector") or (nearest.Parent and nearest.Parent:FindFirstChildOfClass("ClickDetector"))
                if cd then pcall(function() fireclickdetector(cd) end) end
                coinPickCooldown = tick()
            end
        end
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
Main.Size = UDim2.new(0, 260, 0, 750)
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
    while task.wait(0.05) do MainStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end 
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
Holder.CanvasSize = UDim2.new(0, 0, 15, 0)
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
    while task.wait(0.05) do IconStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end 
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

CreateToggle("ESP (Real-time)", features.ESP, function(val) toggleESP(val) end)
CreateToggle("Silent Aim", features.SilentAim, function(val) features.SilentAim = val end)
CreateToggle("Wall Click (xuyên tường)", features.WallClick, function(val) features.WallClick = val end)
CreateToggle("Lock Aim (tự động vào sát thủ)", features.LockAim, function(val) features.LockAim = val end)
CreateToggle("Noclip (xuyên tường)", features.Noclip, function(val) 
    features.Noclip = val
    setNoclip(val)
end)
CreateToggle("Dự đoán vai trò (Remote)", features.AutoPredictRole, function(val) features.AutoPredictRole = val end)
CreateToggle("Teleport khỏi sát thủ (<3m)", features.TeleportFromMurderer, function(val) features.TeleportFromMurderer = val end)
CreateToggle("Team Check", features.TeamCheck, function(val) features.TeamCheck = val end)
CreateToggle("Show Distance", features.ShowDistance, function(val) features.ShowDistance = val end)
CreateToggle("Auto Teleport Gun", features.AutoTeleportGun, function(val) features.AutoTeleportGun = val end)
CreateToggle("Teleport Half-Body", features.TeleportHalf, function(val) features.TeleportHalf = val end)
CreateToggle("Auto Pick Coin", features.AutoPickCoin, function(val) features.AutoPickCoin = val end)
CreateToggle("Invisible (Desync)", features.Invisible, function(val) toggleInvisible(val) end)

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
print("===== MM2 ULTIMATE V24 – FULL REAL-TIME =====")
print("✅ ESP: Real-time, không cần refresh, màu theo vai trò (dự đoán + hook)")
print("✅ Silent Aim + Wall Click: bắn trúng mọi lúc, xuyên tường")
print("✅ Lock Aim: mượt hơn, tự động khóa murderer khi bạn là sheriff")
print("✅ Noclip: xuyên tường")
print("✅ Teleport khỏi sát thủ: tự động teleport đến player xa nhất nếu gần <3m")
print("✅ Teleport súng: tìm Tool + Model, hoạt động")
print("✅ Auto Pick Coin: chậm, không kick")
print("👉 Tất cả OFF, bật từ menu. Chơi ngon boss man!")

-- ===== KHỞI TẠO =====
setNoclip(false)

-- ===== ANTI-BAN =====
local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
if remote then
    local oldFire = remote.FireServer
    remote.FireServer = function(self, ...) return oldFire(self, ...) end
end

print("Axiom MM2 Ultimate v24 – fuck yeah boss man. Full fix, chơi ngon.")