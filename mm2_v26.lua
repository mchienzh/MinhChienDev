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
-- ===== LOCK AIM (SNAP DIRECTION – CAMERA TỰ THEO NHÂN VẬT) =====
-- ================================================================
RunService.RenderStepped:Connect(function()
    if not features.LockAim then return end
    if getPlayerRole(LocalPlayer) ~= "sheriff" then return end

    local myChar = LocalPlayer.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

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

    local aimPos = tRoot.Position + Vector3.new(0, 1.5, 0)
    local camPos = Camera.CFrame.Position
    -- Snap trực tiếp (không lerp, không Scriptable) – camera tự follow character
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
-- ===== TELEPORT SÚNG V4 – DEBUG + TÌM RỘNG =====
-- ================================================================
local KNIFE_PATTERNS = {
    "knife","dagger","blade","sword","sickle",
    "axe","cleav","machete","scythe","saber","shank"
}
local GUN_PATTERNS = {
    "gun","sheriff","revolver","pistol","blaster",
    "deagle","m9","luger","flintlock","shot"
}

local function isKnifeName(name)
    local n = name:lower()
    for _, p in ipairs(KNIFE_PATTERNS) do if n:find(p) then return true end end
    return false
end

local function isGunName(name)
    local n = name:lower()
    for _, p in ipairs(GUN_PATTERNS) do if n:find(p) then return true end end
    return false
end

-- Chỉ trả true khi đang trong character hoặc backpack
local function isInCharacterOrBP(obj)
    local cur = obj
    while cur and cur ~= workspace and cur ~= game do
        if cur:IsA("Backpack") then return true end
        if cur:IsA("Model") and cur:FindFirstChildOfClass("Humanoid") then return true end
        cur = cur.Parent
    end
    return false
end

-- Đã có súng thực sự chưa (chỉ đếm tool tên gun, không đếm mọi tool)
local function alreadyHasGun()
    local char = LocalPlayer.Character
    local bp   = LocalPlayer:FindFirstChildOfClass("Backpack")
    local function check(t)
        return t:IsA("Tool") and isGunName(t.Name)
    end
    if char then
        for _, t in pairs(char:GetChildren()) do if check(t) then return true end end
    end
    if bp then
        for _, t in pairs(bp:GetChildren()) do if check(t) then return true end end
    end
    return false
end

-- Tìm súng rơi: Tool hoặc BasePart có TouchInterest tên gun
local function FindDroppedGun()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return nil, nil end
    local myPos = root.Position
    local best, bestHandle, bestDist = nil, nil, math.huge

    for _, obj in pairs(workspace:GetDescendants()) do
        if isInCharacterOrBP(obj) then continue end

        local handle, parent = nil, nil

        -- Loại 1: Tool class (cách cũ)
        if obj:IsA("Tool") and not isKnifeName(obj.Name) then
            handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
            parent = obj

        -- Loại 2: BasePart có TouchInterest và tên liên quan súng
        elseif obj:IsA("BasePart") and obj:FindFirstChildOfClass("TouchInterest") then
            local n = obj.Name:lower()
            local pn = obj.Parent and obj.Parent.Name:lower() or ""
            if isGunName(n) or isGunName(pn) then
                handle = obj
                parent = obj.Parent or obj
            end

        -- Loại 3: Model tên súng chứa BasePart
        elseif obj:IsA("Model") and isGunName(obj.Name) then
            local h = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
            if h then handle = h; parent = obj end
        end

        if handle and parent then
            local ok, pos = pcall(function() return handle.Position end)
            if ok then
                local d = (myPos - pos).Magnitude
                if d < bestDist then
                    bestDist = d; best = parent; bestHandle = handle
                end
            end
        end
    end

    -- Scan nil instances
    if getnilinstances then
        local ok, nils = pcall(getnilinstances)
        if ok and nils then
            for _, obj in pairs(nils) do
                pcall(function()
                    if not obj:IsA("Tool") and not obj:IsA("Model") then return end
                    if isKnifeName(obj.Name) then return end
                    local h = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                    if not h then return end
                    local d = (myPos - h.Position).Magnitude
                    if d < bestDist then
                        bestDist = d; best = obj; bestHandle = h
                    end
                end)
            end
        end
    end

    -- DEBUG: in ra kết quả
    if best then
        print(string.format("[GUN] Tìm thấy: %s | parent: %s | cách: %.1f studs",
            bestHandle.Name, tostring(best.Name), bestDist))
    else
        print("[GUN] Không tìm thấy súng nào – in danh sách Tool trong workspace:")
        local count = 0
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Tool") then
                print("  Tool:", obj.Name, "| parent:", tostring(obj.Parent and obj.Parent.Name))
                count = count + 1
                if count >= 10 then print("  ..."); break end
            end
        end
        if count == 0 then print("  (không có Tool nào trong workspace)") end
    end

    return best, bestHandle
end

-- Nhặt súng: firetouchinterest cả 2 chiều trên mọi part của char × mọi part của gun
local function tryPickupGun(tool, handle)
    local char = LocalPlayer.Character
    if not char or not handle then return end

    -- Lấy tất cả BasePart của character
    local charParts = {}
    for _, p in pairs(char:GetDescendants()) do
        if p:IsA("BasePart") then table.insert(charParts, p) end
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then table.insert(charParts, root) end

    -- Lấy tất cả BasePart của gun
    local gunParts = {handle}
    if tool and tool ~= handle then
        for _, p in pairs(tool:GetDescendants()) do
            if p:IsA("BasePart") then table.insert(gunParts, p) end
        end
    end

    -- firetouchinterest cả 2 chiều argument (khác executor khác order)
    for _, cp in pairs(charParts) do
        for _, gp in pairs(gunParts) do
            pcall(function() firetouchinterest(cp, gp, 0) end)
            pcall(function() firetouchinterest(cp, gp, 1) end)
            pcall(function() firetouchinterest(gp, cp, 0) end)
            pcall(function() firetouchinterest(gp, cp, 1) end)
        end
    end

    -- ProximityPrompt
    pcall(function()
        if tool then
            for _, pp in pairs(tool:GetDescendants()) do
                if pp:IsA("ProximityPrompt") then fireproximityprompt(pp) end
            end
        end
        local pp2 = handle:FindFirstChildOfClass("ProximityPrompt")
        if pp2 then fireproximityprompt(pp2) end
    end)

    -- ClickDetector
    pcall(function()
        if tool then
            for _, cd in pairs(tool:GetDescendants()) do
                if cd:IsA("ClickDetector") then fireclickdetector(cd) end
            end
        end
    end)
end

-- Vòng lặp chính
task.spawn(function()
    while true do
        task.wait(0.4)
        if not features.AutoTeleportGun then continue end

        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum  = char and char:FindFirstChild("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end

        if alreadyHasGun() then
            -- print("[GUN] Đã có súng, bỏ qua")
            continue
        end

        local tool, handle = FindDroppedGun()
        if not handle then continue end

        -- Teleport đến súng
        print("[GUN] Đang teleport đến:", handle.Position)
        for _ = 1, 4 do
            root.CFrame = CFrame.new(handle.Position + Vector3.new(0, 2, 0))
            task.wait(0.06)
        end
        root.Velocity = Vector3.new(0, 0, 0)
        task.wait(0.1)

        -- Nhặt lần 1
        tryPickupGun(tool, handle)
        task.wait(0.2)

        -- Nhặt lần 2
        if not alreadyHasGun() then
            pcall(function()
                root.CFrame = CFrame.new(handle.Position + Vector3.new(0, 1, 0))
            end)
            task.wait(0.08)
            tryPickupGun(tool, handle)
            task.wait(0.15)

            if alreadyHasGun() then
                print("[GUN] ✅ Nhặt súng thành công!")
            else
                print("[GUN] ❌ Nhặt không được – xem console để debug")
            end
        else
            print("[GUN] ✅ Nhặt súng thành công!")
        end
    end
end)

-- ================================================================
-- ===== TELEPORT SÚNG – FindFirstChild("GunDrop", true) + nút nổi =====
-- ================================================================
local function TeleportToGunDrop()
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Tìm GunDrop theo tên chính xác, đệ quy trong workspace
    local gunDrop = workspace:FindFirstChild("GunDrop", true)
    if not gunDrop then
        print("[TeleGun] Không tìm thấy GunDrop trong workspace")
        return
    end

    -- Kiểm tra trạng thái Active/Status/Dropped (BoolValue, StringValue, Attribute)
    local isActive = true  -- mặc định true nếu không có value nào
    local function checkChild(obj, names)
        for _, n in ipairs(names) do
            local v = obj:FindFirstChild(n)
            if v then
                if v:IsA("BoolValue")   then return v.Value == true end
                if v:IsA("StringValue") then return v.Value:lower() == "true" end
                if v:IsA("IntValue")    then return v.Value == 1 end
            end
        end
        return nil
    end
    local NAMES = {"Active","Status","Dropped","Enabled","IsActive"}
    local res = checkChild(gunDrop, NAMES)
    if res == nil and gunDrop.Parent then res = checkChild(gunDrop.Parent, NAMES) end
    -- Attribute fallback
    if res == nil then
        for _, n in ipairs(NAMES) do
            local ok, av = pcall(function() return gunDrop:GetAttribute(n) end)
            if ok and av ~= nil then res = (av == true or tostring(av):lower() == "true"); break end
        end
    end
    if res ~= nil then isActive = res end

    if not isActive then
        print("[TeleGun] GunDrop không ở trạng thái True/Active")
        return
    end

    -- Xác định vị trí súng
    local gunPos
    if gunDrop:IsA("BasePart") then
        gunPos = gunDrop.Position
    else
        local h = gunDrop:FindFirstChild("Handle") or gunDrop:FindFirstChildOfClass("BasePart")
        if h then gunPos = h.Position end
    end
    if not gunPos then
        -- fallback: dùng PrimaryPart hoặc WorldPosition của model
        pcall(function()
            gunPos = gunDrop:GetPivot().Position
        end)
    end
    if not gunPos then print("[TeleGun] Không lấy được vị trí GunDrop"); return end

    -- Lưu vị trí cũ rồi teleport
    local oldCFrame = root.CFrame
    root.CFrame = CFrame.new(gunPos + Vector3.new(0, 2.5, 0))
    print("[TeleGun] ➡ Teleport đến GunDrop tại:", gunPos)

    task.wait(0.2)

    root.CFrame = oldCFrame
    print("[TeleGun] ↩ Đã teleport về vị trí cũ")
end

-- ================================================================
-- ===== SHOOT SÁT THỦ – tự cầm súng + bắn remote =====
-- ================================================================
local function ShootMurdererRemote()
    local myChar = LocalPlayer.Character
    if not myChar then return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHum  = myChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHum or myHum.Health <= 0 then return end

    -- Tự cầm súng nếu chưa cầm
    local tool = myChar:FindFirstChildOfClass("Tool")
    if not tool or not isGunName(tool.Name) then
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            for _, t in pairs(bp:GetChildren()) do
                if t:IsA("Tool") and isGunName(t.Name) then
                    pcall(function() myHum:EquipTool(t) end)
                    task.wait(0.25)
                    tool = myChar:FindFirstChildOfClass("Tool")
                    break
                end
            end
        end
    end
    if not tool or not isGunName(tool.Name) then
        print("[Shoot] Không có súng để bắn")
        return
    end

    -- Tìm sát thủ gần nhất (mọi player không phải innocent đều được tính)
    local target, bestDist = nil, math.huge
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local r   = plr.Character:FindFirstChild("HumanoidRootPart")
            local hum = plr.Character:FindFirstChild("Humanoid")
            if r and hum and hum.Health > 0 then
                local role = getPlayerRole(plr)
                if role == "murderer" then  -- ưu tiên sát thủ
                    local d = (myRoot.Position - r.Position).Magnitude
                    if d < bestDist then bestDist = d; target = plr end
                end
            end
        end
    end
    -- Fallback: nếu không tìm thấy sát thủ, bắn player gần nhất
    if not target then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local r   = plr.Character:FindFirstChild("HumanoidRootPart")
                local hum = plr.Character:FindFirstChild("Humanoid")
                if r and hum and hum.Health > 0 then
                    local d = (myRoot.Position - r.Position).Magnitude
                    if d < bestDist then bestDist = d; target = plr end
                end
            end
        end
    end
    if not target then print("[Shoot] Không tìm thấy mục tiêu"); return end

    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not tRoot then return end

    -- FIX: KHÔNG thay đổi Camera.CFrame – tránh khoá input màn hình sau khi bắn
    -- Tính toán hướng bắn từ camera hiện tại
    local origin    = Camera.CFrame.Position
    local targetPos = tRoot.Position + Vector3.new(0, 1.5, 0)
    local dir       = (targetPos - origin).Unit

    -- 1) Fire tất cả RemoteEvent trong Tool với nhiều dạng args
    for _, remote in pairs(tool:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function() remote:FireServer(origin, targetPos) end)
            pcall(function() remote:FireServer(CFrame.new(origin, targetPos), CFrame.new(targetPos)) end)
            pcall(function() remote:FireServer(Ray.new(origin, dir * 500)) end)
            pcall(function() remote:FireServer(targetPos) end)
        end
    end

    -- 2) Fire RemoteEvent trong ReplicatedStorage
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local n = remote.Name:lower()
            if n:find("shoot") or n:find("fire") or n:find("gun") or n:find("bullet") then
                pcall(function() remote:FireServer(origin, targetPos) end)
                pcall(function() remote:FireServer(CFrame.new(origin, targetPos), CFrame.new(targetPos)) end)
            end
        end
    end

    -- 3) Fire qua nil instances
    if getnilinstances then
        pcall(function()
            for _, v in pairs(getnilinstances()) do
                if v.ClassName == "RemoteEvent" then
                    local n = v.Name:lower()
                    if n:find("shoot") or n:find("fire") or n:find("gun") or n:find("bullet") then
                        pcall(function()
                            v:FireServer(CFrame.new(origin, targetPos), CFrame.new(targetPos))
                        end)
                    end
                end
            end
        end)
    end

    -- 4) Kích hoạt tool (giả lập tap màn hình)
    -- Tạm hướng camera vào mục tiêu, kích hoạt, rồi trả về NGAY – giảm delay
    local oldCamType = Camera.CameraType
    local oldCF = Camera.CFrame
    pcall(function()
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = CFrame.new(origin, targetPos)
    end)
    pcall(function() tool:Activate() end)
    -- Trả camera về ngay lập tức (không delay) để không khoá màn hình
    pcall(function()
        Camera.CFrame = oldCF
        Camera.CameraType = oldCamType
    end)

    print(string.format("[Shoot] ✅ Bắn %s (%.1f studs)", target.Name, bestDist))
end

-- ================================================================
-- ===== KILL ALL (SÁT THỦ) =====
-- ================================================================
local killAllRunning = false

local function KillAll()
    if killAllRunning then
        print("[KillAll] Đang chạy, bỏ qua...")
        return
    end
    killAllRunning = true

    local myChar = LocalPlayer.Character
    if not myChar then killAllRunning = false; return end
    local myRoot = myChar:FindFirstChild("HumanoidRootPart")
    local myHum  = myChar:FindFirstChildOfClass("Humanoid")
    if not myRoot or not myHum or myHum.Health <= 0 then killAllRunning = false; return end

    -- Bước 1: Check/tự trang bị dao
    local knife = myChar:FindFirstChildOfClass("Tool")
    if not knife or not isKnifeName(knife.Name) then
        knife = nil
        local bp = LocalPlayer:FindFirstChildOfClass("Backpack")
        if bp then
            for _, t in pairs(bp:GetChildren()) do
                if t:IsA("Tool") and isKnifeName(t.Name) then
                    pcall(function() myHum:EquipTool(t) end)
                    task.wait(0.25)
                    knife = myChar:FindFirstChildOfClass("Tool")
                    break
                end
            end
        end
    end
    if not knife or not isKnifeName(knife.Name) then
        print("[KillAll] Không tìm thấy dao – bạn có phải sát thủ không?")
        killAllRunning = false
        return
    end

    -- Lấy handle dao để firetouchinterest
    local knifeHandle = knife:FindFirstChild("Handle") or knife:FindFirstChildOfClass("BasePart")

    -- Danh sách char parts của mình (dùng cho touch interest)
    local myParts = {}
    for _, p in pairs(myChar:GetDescendants()) do
        if p:IsA("BasePart") then table.insert(myParts, p) end
    end

    print("[KillAll] Bắt đầu giết " .. tostring(#Players:GetPlayers() - 1) .. " người...")

    -- Bước 2: Lần lượt từng player
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LocalPlayer then continue end
        local tChar = plr.Character
        if not tChar then continue end
        local tRoot = tChar:FindFirstChild("HumanoidRootPart")
        local tHum  = tChar:FindFirstChild("Humanoid")
        if not tRoot or not tHum or tHum.Health <= 0 then continue end

        -- Re-check myRoot vẫn còn sống
        if myHum.Health <= 0 then break end

        -- Mang player tới trước mặt (offset 2.5 studs)
        local frontCF = myRoot.CFrame * CFrame.new(0, 0, -2.5)
        pcall(function() tRoot.CFrame = frontCF end)
        task.wait(0.1)

        -- Tính vị trí target để bắn/chém
        local targetPos = tRoot.Position + Vector3.new(0, 1, 0)

        -- Giả lập chém: kích hoạt tool (giả lập click màn hình)
        local oldCamType = Camera.CameraType
        local oldCF = Camera.CFrame
        pcall(function()
            Camera.CameraType = Enum.CameraType.Scriptable
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
        end)
        pcall(function() knife:Activate() end)
        pcall(function()
            Camera.CFrame = oldCF
            Camera.CameraType = oldCamType
        end)

        -- Fire tất cả RemoteEvent trong dao
        for _, remote in pairs(knife:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                pcall(function() remote:FireServer(targetPos) end)
                pcall(function() remote:FireServer(tRoot) end)
                pcall(function() remote:FireServer(plr, targetPos) end)
                pcall(function() remote:FireServer(plr.Character, targetPos) end)
                pcall(function() remote:FireServer(tRoot.Position) end)
            end
        end

        -- Fire nil instances – tìm remote liên quan dao/kill
        if getnilinstances then
            pcall(function()
                for _, v in pairs(getnilinstances()) do
                    if v.ClassName == "RemoteEvent" then
                        local n = v.Name:lower()
                        if n:find("knife") or n:find("kill") or n:find("stab") or
                           n:find("slash") or n:find("attack") or n:find("melee") or
                           n:find("murder") then
                            pcall(function() v:FireServer(targetPos) end)
                            pcall(function() v:FireServer(tRoot) end)
                            pcall(function() v:FireServer(plr, targetPos) end)
                        end
                    end
                end
            end)
        end

        -- firetouchinterest: dao chạm vào tất cả part của nạn nhân
        if knifeHandle then
            local victimParts = {}
            for _, p in pairs(tChar:GetDescendants()) do
                if p:IsA("BasePart") then table.insert(victimParts, p) end
            end
            for _, vp in pairs(victimParts) do
                pcall(function() firetouchinterest(knifeHandle, vp, 0) end)
                pcall(function() firetouchinterest(knifeHandle, vp, 1) end)
                pcall(function() firetouchinterest(vp, knifeHandle, 0) end)
                pcall(function() firetouchinterest(vp, knifeHandle, 1) end)
            end
            -- char của mình chạm vào nạn nhân
            for _, mp in pairs(myParts) do
                for _, vp in pairs(victimParts) do
                    pcall(function() firetouchinterest(mp, vp, 0) end)
                    pcall(function() firetouchinterest(mp, vp, 1) end)
                end
            end
        end

        print(string.format("[KillAll] ⚔ Đã chém: %s", plr.Name))
        task.wait(0.45) -- chờ giữa các lần chém
    end

    killAllRunning = false
    print("[KillAll] ✅ Xong!")
end

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
    -- FIX MOBILE: track đúng input object, dùng UIS.InputChanged để theo ngón tay ra ngoài GUI
    local dragging = false
    local dragInput = nil
    local dragStart = nil
    local startPos  = nil

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragInput = input
            dragStart = input.Position
            startPos  = gui.Position
        end
    end)

    -- Dùng UserInputService để bắt di chuyển ngón tay dù ra ngoài frame
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then return end
        if input ~= dragInput and
           input.UserInputType ~= Enum.UserInputType.MouseMovement and
           input.UserInputType ~= Enum.UserInputType.Touch then return end
        -- Với touch: chỉ update khi đúng input object
        if input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then return end
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging  = false
            dragInput = nil
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

-- ================================================================
-- ===== NÚT NỔI DI CHUYỂN ĐƯỢC (MOBILE) =====
-- ================================================================
local function CreateFloatBtn(text, color, initPos, onPress)
    local frame = Instance.new("Frame", ScreenGui)
    frame.Size            = UDim2.new(0, 85, 0, 50)
    frame.Position        = initPos
    frame.BackgroundColor3 = color
    frame.Active          = true
    frame.Visible         = false
    frame.ZIndex          = 10
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
    local stroke = Instance.new("UIStroke", frame)
    stroke.Thickness = 2.5; stroke.Color = Color3.new(1, 1, 1)
    Drag(frame)   -- kéo được trên điện thoại
    -- Đổ bóng nhẹ
    local shadow = Instance.new("UIGradient", frame)
    shadow.Rotation = 90
    shadow.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.new(0.7,0.7,0.7))
    })
    shadow.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.0),
        NumberSequenceKeypoint.new(1, 0.35)
    })
    local btn = Instance.new("TextButton", frame)
    btn.Size              = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text              = text
    btn.TextColor3        = Color3.new(1, 1, 1)
    btn.Font              = Enum.Font.GothamBold
    btn.TextSize          = 11
    btn.TextWrapped       = true
    btn.ZIndex            = 11
    btn.Activated:Connect(function()
        ClickSound:Play()
        onPress()
    end)
    return frame
end

-- Nút 1: Teleport Súng
local teleGunFloatBtn = CreateFloatBtn(
    "🔫\nTELE\nGUN",
    Color3.fromRGB(15, 70, 145),
    UDim2.new(0, 10, 0.55, 0),
    function()
        task.spawn(TeleportToGunDrop)
    end
)

-- Nút 2: Shoot Sát Thủ
local shootFloatBtn = CreateFloatBtn(
    "💥\nSHOOT\nKILLER",
    Color3.fromRGB(145, 15, 15),
    UDim2.new(0, 105, 0.55, 0),
    function()
        task.spawn(ShootMurdererRemote)
    end
)

-- Nút 3: Kill All (sát thủ)
local killAllFloatBtn = CreateFloatBtn(
    "☠\nKILL\nALL",
    Color3.fromRGB(100, 0, 130),
    UDim2.new(0, 200, 0.55, 0),
    function()
        task.spawn(KillAll)
    end
)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 3
task.spawn(function()
    while task.wait(0.05) do
        MainStroke.Color = Color3.fromHSV(tick() % 5 / 5, 1, 1)
    end
end)

local Title = Instance.new("TextLabel", Main)
Title.Size              = UDim2.new(1, 0, 0, 40)
Title.Text              = "MINHCHIEN MM2  v25"
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

CreateLabel("MOBILE BUTTONS")
CreateToggle("Teleport Súng [BTN]", false, function(v)
    teleGunFloatBtn.Visible = v
end)
CreateToggle("Shoot Sát Thủ [BTN]", false, function(v)
    shootFloatBtn.Visible = v
end)
CreateToggle("Kill All [BTN] (Sát Thủ)", false, function(v)
    killAllFloatBtn.Visible = v
end)

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
print("===== MINHCHIEN MM2 v26 – FIXED =====")
print("✅ FIX Drag: Kéo GUI đúng trên mobile (UserInputService.InputChanged + track input object)")
print("✅ FIX Shoot Sát Thủ: không đổi CameraType nên không khoá màn hình sau khi bắn")
print("✅ FIX Shoot: bắn đúng mục tiêu, fallback nếu không có sát thủ")
print("✅ MỚI Kill All: equip dao → mang player tới trước → chém (firetouchinterest + Activate + Remote)")
print("✅ ESP / Lock Aim / Silent Aim / Wall Click / NoClip / Auto Escape / Auto Pick Coin")
print("📱 Nút nổi: Teleport Gun | Shoot Killer | Kill All (bật trong menu MOBILE BUTTONS)")
print("👉 Mở menu: ấn icon tròn góc trái trên")
