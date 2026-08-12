-- ================================================================
-- MURDER MYSTERY 2 – ULTIMATE V24 (Delta X)
-- FIX: Wall Click (getAimTarget order), Lock Aim (Scriptable cam),
--      Teleport Gun (no name filter), Silent Aim (index fix),
--      ESP real-time (no button), + NoClip, AutoEscape <3m
-- ================================================================

local Players        = game:GetService("Players")
local RunService     = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera         = workspace.CurrentCamera
local LocalPlayer    = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local mouse          = LocalPlayer:GetMouse()

-- ===== CẤU HÌNH =====
local features = {
    ESP             = false,
    SilentAim       = false,
    WallClick       = false,
    TeamCheck       = false,
    ShowDistance    = false,
    AutoTeleportGun = false,
    TeleportHalf    = false,
    AutoPickCoin    = false,
    Invisible       = false,
    LockAim         = false,
    NoClip          = false,
    AutoEscape      = false,
}

local CONFIG = {
    DesyncInterval      = 0.05,
    SilentMaxDistance   = 200,
    SilentTargetPart    = "Head",
    MurdererEscapeDist  = 10, -- studs (~3 mét, 1 stud ≈ 0.3m)
    EscapeCooldown      = 2,
}

-- ================================================================
-- ===== VAI TRÒ =====
-- ================================================================
local function getPlayerRole(player)
    local char    = player.Character
    if not char then return "innocent" end
    local bp      = player:FindFirstChildOfClass("Backpack")
    local tools   = {}
    local held    = char:FindFirstChildOfClass("Tool")
    if held then table.insert(tools, held) end
    if bp then
        for _, t in pairs(bp:GetChildren()) do
            if t:IsA("Tool") then table.insert(tools, t) end
        end
    end
    local hasGun, hasKnife = false, false
    for _, t in pairs(tools) do
        local n = t.Name:lower()
        if n:find("gun") or n:find("pistol") or n:find("sheriff") or n:find("revolver")
           or n:find("blaster") or n:find("shot") then
            hasGun = true
        elseif n:find("knife") or n:find("dagger") or n:find("blade") or n:find("sword")
               or n:find("sickle") or n:find("axe") or n:find("cleav") or n:find("machete") then
            hasKnife = true
        end
    end
    if hasGun   then return "sheriff"   end
    if hasKnife then return "murderer"  end
    return "innocent"
end

-- ================================================================
-- ===== getAimTarget – PHẢI ĐẶT TRƯỚC InputBegan (wall click fix) =====
-- ================================================================
local function getAimTarget()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    -- Lock Aim ưu tiên: tìm sát thủ gần nhất
    if features.LockAim then
        local best, bestDist = nil, math.huge
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local r = plr.Character:FindFirstChild("HumanoidRootPart")
                if r and getPlayerRole(plr) == "murderer" then
                    local d = (myRoot.Position - r.Position).Magnitude
                    if d < bestDist then bestDist = d; best = plr end
                end
            end
        end
        if best then return best end
    end

    -- Silent Aim: player gần nhất trong tầm
    if features.SilentAim then
        local best, bestDist = nil, CONFIG.SilentMaxDistance
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local part = plr.Character:FindFirstChild("Head")
                local hum  = plr.Character:FindFirstChild("Humanoid")
                if part and hum and hum.Health > 0 then
                    local d = (myRoot.Position - part.Position).Magnitude
                    if d < bestDist then bestDist = d; best = plr end
                end
            end
        end
        if best then return best end
    end

    return nil
end

-- ================================================================
-- ===== ESP (REAL-TIME, KHÔNG CẦN REFRESH THỦ CÔNG) =====
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
    for player in pairs(espData) do removePlayerESP(player) end
    espData = {}
end

local function updateESPColor(player)
    local d = espData[player]
    if not d or not d[1] or not d[1].Parent then return end
    local color = ROLE_COLOR[getPlayerRole(player)] or ROLE_COLOR.innocent
    d[1].OutlineColor = color   -- chỉ viền, không fill
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
    hl.FillTransparency    = 1        -- bỏ fill đậm, chỉ giữ viền
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

-- Cập nhật real-time: màu + label + tạo ESP cho player mới
local function updateAllESP()
    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")

    -- Cập nhật player đang có ESP
    for player, d in pairs(espData) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            removePlayerESP(player); continue
        end
        if not d[1] or not d[1].Parent then
            removePlayerESP(player); createESP(player); continue
        end
        updateESPColor(player)
        local lbl = d[3]
        if lbl and lbl.Parent then
            if features.ShowDistance and myRoot then
                local r    = char:FindFirstChild("HumanoidRootPart")
                local dist = r and math.floor((myRoot.Position - r.Position).Magnitude) or 0
                lbl.Text   = player.Name .. " | " .. dist .. "st"
            else
                lbl.Text = player.Name
            end
        end
    end

    -- Tạo ESP cho player chưa có (real-time, không cần refresh)
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and not espData[plr] then
            createESP(plr)
        end
    end
end

local function refreshESP()
    clearESP()
    if not features.ESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then createESP(plr) end
    end
end

local function toggleESP(val)
    features.ESP = val
    if val then refreshESP() else clearESP() end
end

-- Hook player để tự cập nhật khi đổi tool (vai trò đổi)
local function hookPlayer(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.4)
        if features.ESP then createESP(player) end
        char.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then task.wait(0.2); updateESPColor(player) end
        end)
        char.ChildRemoved:Connect(function(c)
            if c:IsA("Tool") then task.wait(0.2); updateESPColor(player) end
        end)
    end)
    if player.Character then
        player.Character.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then task.wait(0.2); updateESPColor(player) end
        end)
        player.Character.ChildRemoved:Connect(function(c)
            if c:IsA("Tool") then task.wait(0.2); updateESPColor(player) end
        end)
    end
    local function hookBP(bp)
        if not bp then return end
        bp.ChildAdded:Connect(function(c)
            if c:IsA("Tool") then task.wait(0.2); updateESPColor(player) end
        end)
        bp.ChildRemoved:Connect(function(c)
            if c:IsA("Tool") then task.wait(0.2); updateESPColor(player) end
        end)
    end
    hookBP(player:FindFirstChildOfClass("Backpack"))
    player.ChildAdded:Connect(function(c)
        if c:IsA("Backpack") then hookBP(c) end
    end)
end

Players.PlayerAdded:Connect(function(player)
    hookPlayer(player)
    if player.Character and features.ESP then
        task.wait(0.4); createESP(player)
    end
end)
Players.PlayerRemoving:Connect(function(player)
    removePlayerESP(player)
end)
for _, plr in pairs(Players:GetPlayers()) do
    if plr ~= LocalPlayer then hookPlayer(plr) end
end

-- Vòng lặp cập nhật real-time (0.5s)
task.spawn(function()
    while true do
        task.wait(0.5)
        if features.ESP then updateAllESP() end
    end
end)

-- ================================================================
-- ===== SILENT AIM (metatable hook, fix oldIndex call) =====
-- ================================================================
local silentHooked = false

local function getClosestTargetPart()
    if not features.SilentAim then return nil end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil end
    local best, bestDist = nil, CONFIG.SilentMaxDistance
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local part = plr.Character:FindFirstChild(CONFIG.SilentTargetPart)
            local hum  = plr.Character:FindFirstChild("Humanoid")
            if part and hum and hum.Health > 0 then
                local d = (root.Position - part.Position).Magnitude
                if d < bestDist then bestDist = d; best = part end
            end
        end
    end
    return best
end

local function setupSilentAim()
    if silentHooked then return end
    local ok, err = pcall(function()
        local gmt = getrawmetatable(game)
        assert(gmt, "no metatable")
        setreadonly(gmt, false)
        local oldIndex = rawget(gmt, "__index")
        local function newIndex(self, index)
            if self == mouse and features.SilentAim then
                local part = getClosestTargetPart()
                if part then
                    if index == "Hit"     then return CFrame.new(part.Position) end
                    if index == "Target"  then return part end
                    if index == "UnitRay" then
                        local orig = Camera.CFrame.Position
                        return Ray.new(orig, (part.Position - orig).Unit * 500)
                    end
                    if index == "Origin"  then return Camera.CFrame.Position end
                end
            end
            -- FIX: oldIndex có thể là function hoặc table
            if type(oldIndex) == "function" then
                return oldIndex(self, index)
            end
            return rawget(self, index)
        end
        gmt.__index = newcclosure and newcclosure(newIndex) or newIndex
        setreadonly(gmt, true)
    end)
    if ok then silentHooked = true; print("[MM2] Silent Aim: OK")
    else warn("[MM2] Silent Aim thất bại: " .. tostring(err)) end
end

local function toggleSilentAim(val)
    features.SilentAim = val
    if val then setupSilentAim() end
end

-- ================================================================
-- ===== FIRE GUN (helper cho Wall Click) =====
-- ================================================================
local function fireGun(target)
    if not target or not target.Character then return end
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool then return end
    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end

    local targetPos = tRoot.Position + Vector3.new(0, 1.5, 0)
    local origin    = Camera.CFrame.Position
    local dir       = (targetPos - origin).Unit

    local oldCF = Camera.CFrame
    Camera.CFrame = CFrame.new(origin, targetPos)

    for _, remote in pairs(tool:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(origin, targetPos) end)
            pcall(function() remote:FireServer(CFrame.new(origin, targetPos)) end)
            pcall(function() remote:FireServer(Ray.new(origin, dir * 500)) end)
        end
    end
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local n = remote.Name:lower()
            if n:find("shoot") or n:find("fire") or n:find("gun") or n:find("bullet") then
                pcall(function() remote:FireServer(origin, targetPos) end)
            end
        end
    end
    pcall(function() tool:Activate() end)
    task.delay(0.03, function() Camera.CFrame = oldCF end)
end

-- ================================================================
-- ===== WALL CLICK – getAimTarget đã được định nghĩa ở trên rồi =====
-- ================================================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    if not features.WallClick then return end
    local target = getAimTarget()
    if target then fireGun(target) end
end)

-- ================================================================
-- ===== LOCK AIM – CAMERA THEO NHÂN VẬT (FIX: KHÔNG BỊ ĐỨNG YÊN) =====
-- ================================================================
local lockAimSavedOffset = nil   -- offset camera so với HumanoidRootPart

RunService.RenderStepped:Connect(function()
    if not features.LockAim then
        -- Tắt Lock Aim → trả camera về Custom
        if Camera.CameraType == Enum.CameraType.Scriptable then
            Camera.CameraType = Enum.CameraType.Custom
        end
        lockAimSavedOffset = nil
        return
    end

    if getPlayerRole(LocalPlayer) ~= "sheriff" then
        Camera.CameraType = Enum.CameraType.Custom
        lockAimSavedOffset = nil
        return
    end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    -- Tìm murderer gần nhất
    local murderer, bestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local r = plr.Character:FindFirstChild("HumanoidRootPart")
            if r and getPlayerRole(plr) == "murderer" then
                local d = (myRoot.Position - r.Position).Magnitude
                if d < bestDist then bestDist = d; murderer = plr end
            end
        end
    end

    if not murderer then
        Camera.CameraType = Enum.CameraType.Custom
        lockAimSavedOffset = nil
        return
    end

    local tRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
    local tHum  = murderer.Character:FindFirstChild("Humanoid")
    if not tRoot or not tHum or tHum.Health <= 0 then
        Camera.CameraType = Enum.CameraType.Custom
        lockAimSavedOffset = nil
        return
    end

    -- Lần đầu bật: lưu offset camera relative to character
    -- Mỗi frame sau: camPos = myRoot.Position + savedOffset → camera theo nhân vật
    if not lockAimSavedOffset then
        lockAimSavedOffset = Camera.CFrame.Position - myRoot.Position
    end

    Camera.CameraType = Enum.CameraType.Scriptable
    local camPos = myRoot.Position + lockAimSavedOffset
    local aimPos = tRoot.Position  + Vector3.new(0, 1.5, 0)
    Camera.CFrame = CFrame.new(camPos, aimPos)
end)

-- ================================================================
-- ===== NOCLIP (MỚI) =====
-- ================================================================
task.spawn(function()
    while true do
        task.wait()   -- mỗi frame
        if features.NoClip then
            local char = LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end
    end
end)

-- ================================================================
-- ===== AUTO ESCAPE – SAT THU < 3M → TELEPORT ĐẾN PLAYER XA NHẤT (MỚI) =====
-- ================================================================
local escapeCooldown = false

task.spawn(function()
    while true do
        task.wait(0.15)
        if not features.AutoEscape or escapeCooldown then continue end

        local myChar = LocalPlayer.Character
        local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
        local myHum  = myChar and myChar:FindFirstChild("Humanoid")
        if not myRoot or not myHum or myHum.Health <= 0 then continue end

        -- Kiểm tra sát thủ trong vòng 10 studs (~3m)
        local tooClose = false
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local r = plr.Character:FindFirstChild("HumanoidRootPart")
                if r and getPlayerRole(plr) == "murderer" then
                    if (myRoot.Position - r.Position).Magnitude <= CONFIG.MurdererEscapeDist then
                        tooClose = true; break
                    end
                end
            end
        end

        if not tooClose then continue end

        -- Tìm player xa nhất
        local farthest, maxDist = nil, 0
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local r = plr.Character:FindFirstChild("HumanoidRootPart")
                if r then
                    local d = (myRoot.Position - r.Position).Magnitude
                    if d > maxDist then maxDist = d; farthest = plr end
                end
            end
        end

        if farthest and farthest.Character then
            local fr = farthest.Character:FindFirstChild("HumanoidRootPart")
            if fr then
                escapeCooldown = true
                -- Teleport với offset nhỏ để không chồng lên người ta
                local offset = Vector3.new(math.random(-4, 4), 2, math.random(-4, 4))
                myRoot.CFrame = CFrame.new(fr.Position + offset)
                task.delay(CONFIG.EscapeCooldown, function() escapeCooldown = false end)
            end
        end
    end
end)

-- ================================================================
-- ===== TELEPORT SÚNG V2 – VIẾT LẠI HOÀN TOÀN =====
-- ================================================================
local KNIFE_PATTERNS = {
    "knife","dagger","blade","sword","sickle",
    "axe","cleav","machete","scythe","saber","shank"
}

local function isKnifeName(name)
    local n = name:lower()
    for _, p in ipairs(KNIFE_PATTERNS) do
        if n:find(p) then return true end
    end
    return false
end

-- Kiểm tra tool đang thuộc về character/backpack (đã có chủ)
local function isToolOwned(obj)
    local cur = obj.Parent
    while cur and cur ~= workspace do
        if cur:IsA("Backpack") then return true end
        if cur:IsA("Model") and cur:FindFirstChildOfClass("Humanoid") then return true end
        cur = cur.Parent
    end
    return false
end

-- Tìm súng rơi gần nhất trong workspace
local function FindDroppedGun()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local myPos  = root.Position
    local best, bestHandle, bestDist = nil, nil, math.huge

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and not isKnifeName(obj.Name) and not isToolOwned(obj) then
            local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
            if handle then
                local d = (myPos - handle.Position).Magnitude
                if d < bestDist then
                    bestDist   = d
                    best       = obj      -- Tool object
                    bestHandle = handle   -- Handle/BasePart
                end
            end
        end
    end
    return best, bestHandle
end

-- Thử tất cả cách nhặt súng: touch, proximity, click, remote
local function tryPickupGun(root, tool, handle)
    if not tool or not handle then return end

    -- 1. firetouchinterest trên Handle (cách chính trong MM2)
    pcall(function()
        local ti = handle:FindFirstChild("TouchInterest")
        if ti then
            firetouchinterest(root, handle, 0)
            task.wait(0.05)
            firetouchinterest(root, handle, 1)
        end
    end)

    -- 2. Scan toàn bộ children của Handle tìm TouchInterest khác
    pcall(function()
        for _, child in pairs(handle:GetChildren()) do
            if child.ClassName == "TouchInterest" then
                firetouchinterest(root, handle, 0)
                task.wait(0.03)
                firetouchinterest(root, handle, 1)
            end
        end
    end)

    -- 3. ProximityPrompt (một số map dùng)
    local function tryPP(obj)
        if not obj then return end
        local pp = obj:FindFirstChildOfClass("ProximityPrompt")
        if pp then pcall(function() fireproximityprompt(pp) end) end
    end
    tryPP(handle); tryPP(tool)

    -- 4. ClickDetector
    local function tryCD(obj)
        if not obj then return end
        local cd = obj:FindFirstChildOfClass("ClickDetector")
        if cd then pcall(function() fireclickdetector(cd) end) end
    end
    tryCD(handle); tryCD(tool)

    -- 5. Scan RemoteEvent trong tool (MM2 dùng remote pickup ở một số version)
    pcall(function()
        for _, rem in pairs(tool:GetDescendants()) do
            if rem:IsA("RemoteEvent") then
                local n = rem.Name:lower()
                if n:find("pick") or n:find("grab") or n:find("collect") or n:find("touch") then
                    rem:FireServer(handle.Position)
                end
            end
        end
    end)

    -- 6. Scan RemoteEvent trong ReplicatedStorage
    pcall(function()
        for _, rem in pairs(ReplicatedStorage:GetDescendants()) do
            if rem:IsA("RemoteEvent") then
                local n = rem.Name:lower()
                if n:find("pick") or n:find("grab") or n:find("collect") then
                    rem:FireServer(tool, handle.Position)
                end
            end
        end
    end)
end

-- Vòng lặp chính: tìm súng → teleport → nhặt
task.spawn(function()
    while true do
        task.wait(0.35)
        if not features.AutoTeleportGun then continue end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end

        -- Kiểm tra đã có súng chưa (nếu có rồi thì không cần tele)
        local alreadyHasGun = false
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        local held = char:FindFirstChildOfClass("Tool")
        local allTools = {}
        if held then table.insert(allTools, held) end
        if bp then for _, t in pairs(bp:GetChildren()) do if t:IsA("Tool") then table.insert(allTools, t) end end end
        for _, t in pairs(allTools) do
            local n = t.Name:lower()
            if n:find("gun") or n:find("sheriff") or n:find("pistol") or n:find("revolver") or n:find("blaster") then
                alreadyHasGun = true; break
            end
        end
        if alreadyHasGun then continue end

        local tool, handle = FindDroppedGun()
        if not tool or not handle then continue end

        -- Teleport đến súng (thử 3 lần chắc chắn)
        for i = 1, 3 do
            root.CFrame = CFrame.new(handle.Position + Vector3.new(0, 2.5, 0))
            task.wait(0.06)
        end
        root.Velocity = Vector3.new(0, 0, 0)
        task.wait(0.1)

        -- Nhặt súng bằng mọi cách
        tryPickupGun(root, tool, handle)
        task.wait(0.15)

        -- Thử lần 2 nếu vẫn chưa nhặt được
        if tool and tool.Parent and not isToolOwned(tool) then
            root.CFrame = CFrame.new(handle.Position + Vector3.new(0, 1, 0))
            task.wait(0.05)
            tryPickupGun(root, tool, handle)
        end
    end
end)

-- ================================================================
-- ===== TELEPORT HALF =====
-- ================================================================
local function getGroundY(pos)
    local ray = Ray.new(pos + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0))
    local hit, hitPos = workspace:FindPartOnRay(ray, nil)
    return (hit and hitPos) and hitPos.Y or (pos.Y - 5)
end

local function teleportToPlayer(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return end
    local tRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    local tp = tRoot.Position
    local newPos
    if features.TeleportHalf then
        local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
        local hh  = (hum and hum.HipHeight or 2) + 0.5
        newPos = Vector3.new(tp.X, getGroundY(tp) + hh / 2, tp.Z)
    else
        newPos = tp
    end
    for _ = 1, 3 do myRoot.CFrame = CFrame.new(newPos); task.wait(0.05) end
    myRoot.Velocity = Vector3.new(0, 0, 0)
end

-- ================================================================
-- ===== AUTO PICK COIN =====
-- ================================================================
task.spawn(function()
    while true do
        task.wait(0.5)
        if not features.AutoPickCoin then continue end
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if not features.AutoPickCoin then break end
            if obj:IsA("BasePart") and not obj:IsDescendantOf(char) then
                local n = obj.Name:lower()
                if n:find("coin") or n:find("gem") or n:find("collectible") or n:find("pickup") then
                    if (root.Position - obj.Position).Magnitude <= 30 then
                        root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 2.5, 0))
                        task.wait(0.1)
                        local pp = obj:FindFirstChildOfClass("ProximityPrompt")
                               or (obj.Parent and obj.Parent:FindFirstChildOfClass("ProximityPrompt"))
                        if pp then pcall(function() fireproximityprompt(pp) end) end
                        local cd = obj:FindFirstChildOfClass("ClickDetector")
                               or (obj.Parent and obj.Parent:FindFirstChildOfClass("ClickDetector"))
                        if cd then pcall(function() fireclickdetector(cd) end) end
                    end
                end
            end
        end
    end
end)

-- ================================================================
-- ===== INVISIBLE DESYNC =====
-- ================================================================
local desyncActive = false
local fakeCF       = CFrame.new(0, 0, 0)

local function startDesync()
    if desyncActive then return end
    desyncActive = true
    local char = LocalPlayer.Character
    if not char then desyncActive = false; return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then desyncActive = false; return end
    fakeCF = root.CFrame
    task.spawn(function()
        while desyncActive and features.Invisible do
            local cc = LocalPlayer.Character
            if not cc then desyncActive = false; break end
            local cr = cc:FindFirstChild("HumanoidRootPart")
            if not cr then desyncActive = false; break end
            local hum = cc:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health <= 0 then features.Invisible = false; desyncActive = false; break end
            pcall(function()
                sethiddenproperty(cr, "NetworkIsSleeping", true)
                cr.CFrame        = fakeCF
                cr.Velocity      = Vector3.new(0, 0, 0)
                cr.RotVelocity   = Vector3.new(0, 0, 0)
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
        if root then pcall(function() sethiddenproperty(root, "NetworkIsSleeping", false) end) end
    end
end

local function toggleInvisible(val)
    features.Invisible = val
    if val then startDesync() else stopDesync() end
end

-- CharacterAdded: reset Invisible + refresh ESP (một chỗ duy nhất)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if features.Invisible then features.Invisible = false; stopDesync() end
    if features.ESP then refreshESP() end
end)

-- ================================================================
-- ===== GUI MENU =====
-- ================================================================
if LocalPlayer.PlayerGui:FindFirstChild("MinhChien") then
    LocalPlayer.PlayerGui.MinhChien:Destroy()
end

local ScreenGui        = Instance.new("ScreenGui", LocalPlayer.PlayerGui)
ScreenGui.Name         = "MinhChien"
ScreenGui.ResetOnSpawn = false

local ClickSound    = Instance.new("Sound", ScreenGui)
ClickSound.SoundId  = "rbxassetid://452267918"
ClickSound.Volume   = 1

local function Drag(gui)
    local drag, inp, start, startPos = false, nil, nil, nil
    gui.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = true; start = i.Position; startPos = gui.Position
        end
    end)
    gui.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
            inp = i
        end
    end)
    RunService.RenderStepped:Connect(function()
        if drag and inp then
            local d = inp.Position - start
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X,
                                      startPos.Y.Scale, startPos.Y.Offset + d.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size            = UDim2.new(0, 265, 0, 720)
Main.Position        = UDim2.new(0.5, -132, 0.1, 0)
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 10)
Main.Visible         = false
Main.Active          = true
Drag(Main)

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 3
task.spawn(function()
    while task.wait(0.05) do
        MainStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

local Title = Instance.new("TextLabel", Main)
Title.Size              = UDim2.new(1, 0, 0, 40)
Title.Text              = "MINHCHIEN MM2  v24"
Title.TextColor3        = Color3.new(1, 1, 1)
Title.Font              = Enum.Font.GothamBlack
Title.TextSize          = 13
Title.BackgroundTransparency = 1

local Holder = Instance.new("ScrollingFrame", Main)
Holder.Size              = UDim2.new(0.92, 0, 0.86, 0)
Holder.Position          = UDim2.new(0.04, 0, 0.10, 0)
Holder.BackgroundTransparency = 1
Holder.CanvasSize        = UDim2.new(0, 0, 16, 0)
Holder.ScrollBarThickness = 0

local Layout = Instance.new("UIListLayout", Holder)
Layout.Padding            = UDim.new(0, 7)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Icon tròn mở menu
local Icon = Instance.new("Frame", ScreenGui)
Icon.Size            = UDim2.new(0, 60, 0, 60)
Icon.Position        = UDim2.new(0, 10, 0, 7)
Icon.BackgroundColor3 = Color3.new(0, 0, 0)
Icon.Active          = true
Drag(Icon)

local IC = Instance.new("UICorner", Icon); IC.CornerRadius = UDim.new(1, 0)
local IS = Instance.new("UIStroke",  Icon); IS.Thickness = 3
task.spawn(function()
    while task.wait(0.05) do IS.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1) end
end)

local Img = Instance.new("ImageLabel", Icon)
Img.Size = UDim2.new(0.9, 0, 0.9, 0)
Img.Position = UDim2.new(0.05, 0, 0.05, 0)
Img.Image = "rbxassetid://74840524656036"
Img.BackgroundTransparency = 1
Instance.new("UICorner", Img).CornerRadius = UDim.new(1, 0)

local IconBtn = Instance.new("TextButton", Icon)
IconBtn.Size = UDim2.new(1, 0, 1, 0)
IconBtn.BackgroundTransparency = 1
IconBtn.Text = ""
IconBtn.Activated:Connect(function()
    Main.Visible = not Main.Visible; ClickSound:Play()
end)

-- Toggle factory
local COLOR_OFF = Color3.fromRGB(30, 30, 40)
local COLOR_ON  = Color3.fromRGB(0,  90, 45)

local function CreateToggle(text, defaultValue, callback)
    local btn = Instance.new("TextButton", Holder)
    btn.Size              = UDim2.new(1, 0, 0, 36)
    btn.BackgroundColor3  = defaultValue and COLOR_ON or COLOR_OFF
    btn.Text              = text .. (defaultValue and " [ON]" or " [OFF]")
    btn.TextColor3        = Color3.new(1, 1, 1)
    btn.Font              = Enum.Font.GothamBold
    btn.TextSize          = 11
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local state = defaultValue
    btn.Activated:Connect(function()
        state = not state
        btn.Text             = text .. (state and " [ON]" or " [OFF]")
        btn.BackgroundColor3 = state and COLOR_ON or COLOR_OFF
        if callback then callback(state) end
        ClickSound:Play()
    end)
    return btn
end

-- Section label
local function CreateLabel(text)
    local lbl = Instance.new("TextLabel", Holder)
    lbl.Size              = UDim2.new(1, 0, 0, 20)
    lbl.Text              = "── " .. text .. " ──"
    lbl.TextColor3        = Color3.fromRGB(180, 180, 180)
    lbl.Font              = Enum.Font.GothamBold
    lbl.TextSize          = 10
    lbl.BackgroundTransparency = 1
end

-- === Toggles ===
CreateLabel("VISUAL")
CreateToggle("ESP",              features.ESP,             function(v) toggleESP(v) end)
CreateToggle("Show Distance",    features.ShowDistance,    function(v) features.ShowDistance = v end)

CreateLabel("COMBAT")
CreateToggle("Silent Aim",       features.SilentAim,       function(v) toggleSilentAim(v) end)
CreateToggle("Wall Click",       features.WallClick,       function(v) features.WallClick = v end)
CreateToggle("Lock Aim (murderer)", features.LockAim,      function(v) features.LockAim = v end)

CreateLabel("MOVEMENT")
CreateToggle("NoClip",           features.NoClip,          function(v) features.NoClip = v end)
CreateToggle("Auto Escape <3m",  features.AutoEscape,      function(v) features.AutoEscape = v end)
CreateToggle("Invisible (Desync)",features.Invisible,      function(v) toggleInvisible(v) end)

CreateLabel("UTILITY")
CreateToggle("Auto Teleport Gun",features.AutoTeleportGun, function(v) features.AutoTeleportGun = v end)
CreateToggle("Teleport Half-Body",features.TeleportHalf,   function(v) features.TeleportHalf = v end)
CreateToggle("Auto Pick Coin",   features.AutoPickCoin,    function(v) features.AutoPickCoin = v end)
CreateToggle("Team Check",       features.TeamCheck,       function(v) features.TeamCheck = v end)

-- Teleport to Player
CreateLabel("TELEPORT")
local teleportBtn = Instance.new("TextButton", Holder)
teleportBtn.Size             = UDim2.new(1, 0, 0, 36)
teleportBtn.BackgroundColor3 = Color3.fromRGB(20, 60, 100)
teleportBtn.Text             = "TELEPORT TO PLAYER"
teleportBtn.TextColor3       = Color3.new(1, 1, 1)
teleportBtn.Font             = Enum.Font.GothamBold
teleportBtn.TextSize         = 11
Instance.new("UICorner", teleportBtn).CornerRadius = UDim.new(0, 4)

-- Player list popup
local playerListFrame = Instance.new("Frame", ScreenGui)
playerListFrame.Size             = UDim2.new(0, 220, 0, 350)
playerListFrame.Position         = UDim2.new(0.5, -110, 0.5, -175)
playerListFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
playerListFrame.Visible          = false
playerListFrame.Active           = true
Drag(playerListFrame)

Instance.new("UICorner", playerListFrame).CornerRadius = UDim.new(0, 8)
local ls2 = Instance.new("UIStroke", playerListFrame)
ls2.Thickness = 2; ls2.Color = Color3.new(1,1,1)

local listTitle = Instance.new("TextLabel", playerListFrame)
listTitle.Size              = UDim2.new(1, 0, 0, 30)
listTitle.Text              = "Chọn người chơi"
listTitle.TextColor3        = Color3.new(1,1,1)
listTitle.Font              = Enum.Font.GothamBold
listTitle.TextSize          = 12
listTitle.BackgroundTransparency = 1

local listScroller = Instance.new("ScrollingFrame", playerListFrame)
listScroller.Size                = UDim2.new(0.95, 0, 0.85, 0)
listScroller.Position            = UDim2.new(0.025, 0, 0.08, 0)
listScroller.BackgroundTransparency = 1
listScroller.CanvasSize          = UDim2.new(0, 0, 0, 0)
listScroller.ScrollBarThickness  = 4
Instance.new("UIListLayout", listScroller).Padding = UDim.new(0, 4)

local function updatePlayerList()
    for _, c in pairs(listScroller:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    local count = 0
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer then
            local role = getPlayerRole(plr)
            local btn  = Instance.new("TextButton", listScroller)
            btn.Size             = UDim2.new(0.9, 0, 0, 30)
            btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            btn.Text             = plr.Name .. "  [" .. role .. "]"
            btn.TextColor3       = ROLE_COLOR[role] or Color3.new(1,1,1)
            btn.Font             = Enum.Font.GothamBold
            btn.TextSize         = 11
            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
            btn.Activated:Connect(function()
                teleportToPlayer(plr); ClickSound:Play()
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

-- ================================================================
print("===== MINHCHIEN MM2 v25 – PATCHED =====")
print("✅ ESP: bỏ màu fill đậm, chỉ giữ viền màu nhạt")
print("✅ Teleport Gun: viết lại hoàn toàn (touch/PP/CD/remote)")
print("✅ Lock Aim: camera theo nhân vật (savedOffset fix)")
print("✅ Silent Aim: metatable hook")
print("✅ Wall Click: getAimTarget fix")
print("✅ NoClip / Auto Escape / Auto Pick Coin")
print("👉 Bật từ menu (icon trái trên)")
