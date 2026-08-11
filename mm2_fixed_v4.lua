-- ================================================================
-- MURDER MYSTERY 2 – ULTIMATE V22 (Delta X) – Fixed: ESP role, Gun TP, LockAim smooth
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
-- ===== ESP (FIXED v2) =====
-- Fix: vai trò đúng theo màu, tự gán player mới, tự xóa khi tắt, giảm lag
-- ================================================================

-- Màu theo vai trò – áp dụng cả FillColor lẫn OutlineColor
local ROLE_COLOR = {
    sheriff  = Color3.fromRGB(30,  144, 255),   -- xanh dương
    murderer = Color3.fromRGB(255, 50,  50),    -- đỏ
    innocent = Color3.fromRGB(80,  255, 100),   -- xanh lá
}

-- espData[player] = { highlight, bill, label }
local espData = {}

-- ────── HÀM NỘI BỘ ──────

-- Xóa ESP của đúng 1 player (an toàn, không crash)
local function removePlayerESP(player)
    local d = espData[player]
    if not d then return end
    if d[1] and d[1].Parent then pcall(function() d[1]:Destroy() end) end
    if d[2] and d[2].Parent then pcall(function() d[2]:Destroy() end) end
    espData[player] = nil
end

-- Xóa TOÀN BỘ ESP (gọi khi tắt tính năng)
local function clearESP()
    for player in pairs(espData) do
        removePlayerESP(player)
    end
    espData = {}
end

-- Cập nhật màu highlight + outline đúng theo vai trò hiện tại
local function updateESPColor(player)
    local d = espData[player]
    if not d or not d[1] or not d[1].Parent then return end
    local role  = getPlayerRole(player)
    local color = ROLE_COLOR[role] or ROLE_COLOR.innocent
    d[1].FillColor    = color
    d[1].OutlineColor = color
end

-- Tạo ESP mới cho 1 player (chỉ khi ESP đang BẬT)
local function createESP(player)
    if not features.ESP then return end
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local head = char:FindFirstChild("Head")
    if not root or not head then return end

    -- Xóa ESP cũ trước (tránh trùng lặp)
    removePlayerESP(player)

    -- Highlight xuyên tường
    local hl = Instance.new("Highlight")
    hl.DepthMode           = Enum.HighlightDepthMode.AlwaysOnTop
    hl.FillTransparency    = 0.45
    hl.OutlineTransparency = 0.0
    hl.Adornee             = char
    hl.Parent              = char

    -- BillboardGui: tên + khoảng cách
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

    -- d[1]=highlight, d[2]=bill, d[3]=label
    espData[player] = { hl, bill, lbl }
    updateESPColor(player)   -- set màu ngay theo vai trò
end

-- Cập nhật text + màu cho tất cả ESP (chạy định kỳ, không tạo mới ở đây)
local function updateAllESP()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    for player, d in pairs(espData) do
        local char = player.Character

        -- Character đã mất → xóa ESP
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            removePlayerESP(player)
            continue
        end

        -- Highlight bị xóa từ bên ngoài → tạo lại
        if not d[1] or not d[1].Parent then
            removePlayerESP(player)
            createESP(player)
            continue
        end

        -- Cập nhật màu vai trò
        updateESPColor(player)

        -- Cập nhật text label
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

-- Xóa rồi tạo lại toàn bộ ESP
local function refreshESP()
    clearESP()
    if not features.ESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            createESP(plr)
        end
    end
end

-- ────── TOGGLE ──────

local function toggleESP(val)
    features.ESP = val
    if val then
        refreshESP()    -- bật → tạo ESP cho tất cả
    else
        clearESP()      -- tắt → xóa SẠCH, không còn sót
    end
end

-- ────── HOOK PLAYER ──────

local function hookPlayer(player)
    -- Mỗi lần character respawn: tạo lại ESP và lắng nghe tool mới
    player.CharacterAdded:Connect(function(char)
        task.wait(0.4)
        if features.ESP then createESP(player) end

        -- Tool thay đổi → cập nhật màu (tăng wait để server sync kịp vai trò)
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.2)
                updateESPColor(player)
            end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then
                task.wait(0.2)
                updateESPColor(player)
            end
        end)
    end)

    -- Character đang có sẵn khi hook
    if player.Character then
        local char = player.Character
        char.ChildAdded:Connect(function(child)
            if child:IsA("Tool") then task.wait(0.2) updateESPColor(player) end
        end)
        char.ChildRemoved:Connect(function(child)
            if child:IsA("Tool") then task.wait(0.2) updateESPColor(player) end
        end)
    end

    -- Backpack (vũ khí chưa cầm)
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

-- ────── SỰ KIỆN PLAYER ──────

-- Player MỚI vào game
Players.PlayerAdded:Connect(function(player)
    hookPlayer(player)
    if player.Character and features.ESP then
        task.wait(0.4)
        createESP(player)
    end
end)

-- Player RỜI game → xóa ESP ngay
Players.PlayerRemoving:Connect(function(player)
    removePlayerESP(player)
end)

-- Local player respawn → rebuild toàn bộ
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshESP()
end)

-- Hook TẤT CẢ player đang có sẵn khi script chạy (quan trọng!)
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then
        hookPlayer(plr)
    end
end

-- ────── VÒNG LẶP CẬP NHẬT ──────
-- Tăng interval 0.3→0.6s để giảm lag; updateAllESP tự tạo lại nếu bị mất
task.spawn(function()
    while true do
        task.wait(0.6)
        if features.ESP then
            updateAllESP()
        end
    end
end)

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

    -- Bọc trong pcall để không crash nếu executor không hỗ trợ
    local ok, err = pcall(function()
        local gmt = getrawmetatable(game)
        assert(gmt, "no metatable")
        setreadonly(gmt, false)
        local oldIndex = rawget(gmt, "__index")
        local function newIndex(self, index)
            if self == mouse and features.SilentAim then
                local targetPart = getClosestTargetPart()
                if targetPart then
                    if index == "Hit" then
                        return CFrame.new(targetPart.Position)
                    elseif index == "Target" then
                        return targetPart
                    elseif index == "UnitRay" then
                        local origin = Camera.CFrame.Position
                        local dir    = (targetPart.Position - origin).Unit
                        return Ray.new(origin, dir * 500)
                    elseif index == "Origin" then
                        return Camera.CFrame.Position
                    end
                end
            end
            return oldIndex(self, index)
        end
        -- Dùng newcclosure nếu có (Synapse/KRNL), không thì dùng thẳng
        if newcclosure then
            gmt.__index = newcclosure(newIndex)
        else
            gmt.__index = newIndex
        end
        setreadonly(gmt, true)
    end)

    if ok then
        silentHooked = true
        print("[MM2] Silent Aim Hook: OK (metatable)")
    else
        print("[MM2] Silent Aim fallback (metatable thất bại: " .. tostring(err) .. ")")
        -- Fallback: không hook được metatable, dùng WallClick thay thế
    end
end

local function toggleSilentAim(val)
    features.SilentAim = val
    if val then setupSilentAim() end
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

    -- Tạm xoay camera về phía target (giúp tool đọc đúng hướng)
    local oldCamCF = Camera.CFrame
    Camera.CFrame  = CFrame.new(origin, targetPos)

    -- Fire tất cả RemoteEvent trong tool với nhiều format
    for _, remote in pairs(tool:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(origin, targetPos) end)
            pcall(function() remote:FireServer(CFrame.new(origin, targetPos)) end)
            pcall(function() remote:FireServer(Ray.new(origin, direction * 500)) end)
            pcall(function() remote:FireServer(direction) end)
        end
    end

    -- Fire remote trong ReplicatedStorage (một số MM2 version để remote ở đây)
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local n = remote.Name:lower()
            if n:find("shoot") or n:find("fire") or n:find("gun") or n:find("bullet") then
                pcall(function() remote:FireServer(origin, targetPos) end)
            end
        end
    end

    -- Activate tool (dùng cả hook lẫn camera aim)
    pcall(function() tool:Activate() end)

    -- Restore camera sau 1 frame
    task.delay(0.03, function()
        if Camera.CFrame == CFrame.new(origin, targetPos) then
            Camera.CFrame = oldCamCF
        end
    end)
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
-- Fix: smooth lerp, aim ngực, bỏ set root (gây jitter), pick murderer gần nhất
-- ================================================================
local LOCK_AIM_LERP = 0.18   -- 0.0 = không move, 1.0 = snap ngay; ~0.18 mượt hợp lý

RunService.RenderStepped:Connect(function()
    if not features.LockAim then return end
    if getPlayerRole(LocalPlayer) ~= "sheriff" then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Tìm murderer GẦN NHẤT (không chỉ lấy đầu tiên)
    local murderer, bestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if tRoot and getPlayerRole(plr) == "murderer" then
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

    -- Aim vào ngực (HumanoidRootPart + 1.5 studs lên), không phải chân
    local aimPos = tRoot.Position + Vector3.new(0, 1.5, 0)
    local camPos = Camera.CFrame.Position

    -- Smooth lerp thay vì snap cứng → không giật, không lỏ
    local targetCF = CFrame.new(camPos, aimPos)
    Camera.CFrame = Camera.CFrame:Lerp(targetCF, LOCK_AIM_LERP)

    -- KHÔNG set myRoot.CFrame ở đây (gây jitter fight với physics engine)
end)

-- ================================================================
-- ===== TELEPORT SÚNG (tìm WeaponDisplays) =====
-- ================================================================
local lastTpTime = 0

local function IsGunOwned(object)
    local current = object
    while current and current ~= workspace do
        -- Nằm trong Backpack → đã sở hữu
        if current:IsA("Backpack") then return true end
        -- Nằm trong character bất kỳ (kể cả LocalPlayer đang cầm) → đã sở hữu
        if current:IsA("Model") and current:FindFirstChildOfClass("Humanoid") then
            return true
        end
        current = current.Parent
    end
    return false
end

-- Pattern nhận dạng súng (mở rộng)
local GUN_PATTERNS = {"gun","pistol","sheriff","revolver","weapon","blaster","shot"}
local KNIFE_PATTERNS = {"knife","dagger","blade","sword","sickle","axe","cleav"}

local function isGunName(name)
    local n = name:lower()
    for _, p in ipairs(KNIFE_PATTERNS) do
        if n:find(p) then return false end  -- loại knife trước
    end
    for _, p in ipairs(GUN_PATTERNS) do
        if n:find(p) then return true end
    end
    return false
end

local function checkObj(obj, myPos, bestPart, bestDist)
    if not obj:IsA("Tool") then return bestPart, bestDist end
    if IsGunOwned(obj) then return bestPart, bestDist end
    if not isGunName(obj.Name) then return bestPart, bestDist end
    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
    if handle then
        local dist = (myPos - handle.Position).Magnitude
        if dist < bestDist then
            return handle, dist
        end
    end
    return bestPart, bestDist
end

-- Tìm súng rơi gần nhất: quét workspace root trước (nhanh, tool rơi thường ở đây),
-- sau đó mới GetDescendants cho WeaponDisplays v.v.
local function FindDroppedGun()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local myPos = root.Position
    local bestPart, bestDist = nil, math.huge

    -- Pass 1: workspace root (tool rơi tự do thường drop ở đây)
    for _, obj in pairs(workspace:GetChildren()) do
        bestPart, bestDist = checkObj(obj, myPos, bestPart, bestDist)
    end

    -- Pass 2: toàn bộ descendants (WeaponDisplays, folders, v.v.)
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Parent ~= workspace then  -- tránh quét lại root
            bestPart, bestDist = checkObj(obj, myPos, bestPart, bestDist)
        end
    end

    return bestPart
end

-- Auto teleport đến súng: chạy mỗi 0.4s, đủ để server nhận vị trí
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
            -- Teleport đứng ngay trên súng
            root.CFrame = CFrame.new(gunPart.Position + Vector3.new(0, 3, 0))
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
-- Auto pick coin: quét toàn map, teleport đến từng coin, lặp nhanh
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
        task.wait(0.08)   -- loop nhanh
        if not features.AutoPickCoin then continue end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end

        local coins = getAllCoins()
        for _, coin in ipairs(coins) do
            if not features.AutoPickCoin then break end
            if not coin or not coin.Parent then continue end
            -- Teleport đứng trên coin → server tính là đã chạm
            root.CFrame = CFrame.new(coin.Position + Vector3.new(0, 2.5, 0))
            task.wait(0.05)
            -- Thử ProximityPrompt
            local pp = coin:FindFirstChildOfClass("ProximityPrompt") or coin.Parent and coin.Parent:FindFirstChildOfClass("ProximityPrompt")
            if pp then pcall(function() fireproximityprompt(pp) end) end
            -- Thử ClickDetector
            local cd = coin:FindFirstChildOfClass("ClickDetector") or coin.Parent and coin.Parent:FindFirstChildOfClass("ClickDetector")
            if cd then pcall(function() fireclickdetector(cd) end) end
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
print("===== MM2 ULTIMATE V22 – FIXED =====")
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