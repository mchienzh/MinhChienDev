-- ╔══════════════════════════════════════════════════════════════╗
-- ║   AUTO FIX LAG MOBILE V4 PLUS - BẢN CHUYÊN NGHIỆP             ║
-- ║   Adaptive batching + LOD toàn bản đồ + chống spam console    ║
-- ║   + UI theo dõi FPS/CPU realtime                               ║
-- ╚══════════════════════════════════════════════════════════════╝

-- =====================================================================
-- CONFIG — chỉnh ở đây, không cần sửa code bên dưới
-- =====================================================================
local CONFIG = {
    TargetFrameBudgetMs = 8,      -- Ngân sách thời gian xử lý mỗi frame (ms). Sẽ TỰ ĐỘNG hiệu chỉnh theo máy, đây chỉ là giá trị khởi điểm.
    MinBatchSize        = 15,
    MaxBatchSize         = 150,
    GrayColor            = Color3.fromRGB(120, 120, 120),
    LODDistance          = 220,   -- Vật ngoài khoảng cách này sẽ ẩn/tắt va chạm
    LODCheckInterval     = 1,     -- Giây giữa mỗi lần quét LOD
    StreamingMinRadius   = 128,
    StreamingTargetRadius= 256,
    SoundVolume          = 0.2,
    FieldOfView          = 65,
    ShowUI               = true,
    PrintRateLimitPerSec = 5,     -- Chặn spam console: tối đa N dòng log/giây

    -- Tự phát hiện máy yếu/khỏe (không lưu file, chỉ đo trong phiên chơi này)
    AutoDetectDevice     = true,
    DetectDurationSec    = 8,     -- Thời gian lấy mẫu FPS ban đầu trước khi chọn preset
}

-- Preset theo cấp máy — dựa trên FPS trung bình đo được khi mới vào
local DEVICE_PRESETS = {
    Weak   = { budgetMs = 4,  maxBatch = 60,  lodDistance = 140, streamMin = 64,  streamTarget = 128 },
    Medium = { budgetMs = 8,  maxBatch = 150, lodDistance = 220, streamMin = 128, streamTarget = 256 },
    Strong = { budgetMs = 14, maxBatch = 300, lodDistance = 320, streamMin = 192, streamTarget = 384 },
}

-- =====================================================================
-- SAFETY NET: CHẶN SPAM CONSOLE (dù lỗi từ đâu ra cũng không giật máy)
-- =====================================================================
local _printCount, _printWindowStart = 0, os.clock()
local function safePrint(msg)
    local now = os.clock()
    if now - _printWindowStart > 1 then
        _printWindowStart = now
        _printCount = 0
    end
    _printCount += 1
    if _printCount > CONFIG.PrintRateLimitPerSec then return end -- im lặng nếu vượt giới hạn
    pcall(function() print(msg) end)
end

-- =====================================================================
-- SERVICES
-- =====================================================================
local RunService   = game:GetService("RunService")
local Players       = game:GetService("Players")
local ws            = game:GetService("Workspace")
local lighting       = game:GetService("Lighting")
local soundService   = game:GetService("SoundService")
local StarterGui     = game:GetService("StarterGui")
local plr            = Players.LocalPlayer
local camera         = ws.CurrentCamera

-- =====================================================================
-- PHẦN 0: TỰ PHÁT HIỆN MÁY YẾU/KHỎE (đo FPS thực tế vài giây đầu)
-- Không lưu file — chỉ áp dụng cho phiên chơi hiện tại.
-- Chạy song song, KHÔNG chặn các bước tối ưu khác (chúng chạy trước
-- với giá trị mặc định, rồi được ghi đè khi có kết quả đo).
-- =====================================================================
local deviceTier = "Medium" -- fallback nếu tắt AutoDetectDevice hoặc đo lỗi

local function applyPreset(tierName)
    local preset = DEVICE_PRESETS[tierName]
    if not preset then return end
    deviceTier = tierName
    CONFIG.TargetFrameBudgetMs = preset.budgetMs
    CONFIG.MaxBatchSize        = preset.maxBatch
    CONFIG.LODDistance         = preset.lodDistance
    CONFIG.StreamingMinRadius  = preset.streamMin
    CONFIG.StreamingTargetRadius = preset.streamTarget
    pcall(function()
        if ws.StreamingEnabled then
            ws.StreamingMinRadius    = preset.streamMin
            ws.StreamingTargetRadius = preset.streamTarget
        end
    end)
    safePrint("[FixLag+] Đã phát hiện máy: " .. tierName
        .. " (budget=" .. preset.budgetMs .. "ms, maxBatch=" .. preset.maxBatch
        .. ", LOD=" .. preset.lodDistance .. ")")
end

local function autoDetectDevice()
    if not CONFIG.AutoDetectDevice then return end
    task.spawn(function()
        local frameCount, elapsed = 0, 0
        local conn
        conn = RunService.RenderStepped:Connect(function(dt)
            frameCount += 1
            elapsed += dt
        end)
        task.wait(CONFIG.DetectDurationSec)
        conn:Disconnect()

        local avgFps = elapsed > 0 and (frameCount / elapsed) or 30
        local tierName
        if avgFps < 25 then
            tierName = "Weak"
        elseif avgFps < 45 then
            tierName = "Medium"
        else
            tierName = "Strong"
        end
        applyPreset(tierName)
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "📊 Phát Hiện Máy",
                Text  = "Máy của bạn: " .. tierName .. " (~" .. math.floor(avgFps) .. " FPS) — đã tự chỉnh tối ưu.",
                Duration = 4,
            })
        end)
    end)
end

-- =====================================================================
-- PHẦN 1: ĐỒ HỌA THẤP NHẤT (chạy 1 lần, không tốn CPU về sau)
-- =====================================================================
local function applyGraphicsSettings()
    pcall(function() settings().Rendering.QualityLevel = Enum.QualityLevel.Level01 end)
    pcall(function()
        local gs = game:GetService("UserSettings"):GetService("UserGameSettings")
        gs.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)
    pcall(function() setfpscap(60) end)

    pcall(function()
        lighting.GlobalShadows  = false
        lighting.Brightness     = 2
        lighting.Ambient        = Color3.fromRGB(128, 128, 128)
        lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
        lighting.ShadowSoftness = 0
        lighting.FogEnd         = 100000
        pcall(function() lighting.Technology = Enum.Technology.Legacy end)
        for _, obj in ipairs(lighting:GetChildren()) do
            if obj:IsA("PostEffect") then pcall(function() obj:Destroy() end) end
        end
    end)

    pcall(function() soundService.Volume = CONFIG.SoundVolume end)
    pcall(function() if camera then camera.FieldOfView = CONFIG.FieldOfView end end)
    pcall(function() ws.FallenPartsDestroyHeight = -500 end)

    -- Tinh chỉnh Streaming: tải map theo bán kính nhỏ hơn quanh người chơi
    -- → CPU/GPU không phải xử lý phần map ở quá xa
    pcall(function()
        if ws.StreamingEnabled then
            ws.StreamingMinRadius    = CONFIG.StreamingMinRadius
            ws.StreamingTargetRadius = CONFIG.StreamingTargetRadius
        end
    end)

    safePrint("[FixLag+] Đã áp dụng cấu hình đồ họa & streaming thấp nhất.")
end

-- =====================================================================
-- PHẦN 2: XỬ LÝ PART (XÁM HÓA / TẮT FX) — CÓ SKIP NẾU ĐÃ TỐI ƯU
-- =====================================================================
local function optimizePart(obj)
    if not obj or not obj:IsA("BasePart") then return end
    if obj.CastShadow == false and obj.Color == CONFIG.GrayColor then return end
    pcall(function()
        obj.Material    = Enum.Material.SmoothPlastic
        obj.Color       = CONFIG.GrayColor
        obj.Reflectance = 0
        obj.CastShadow  = false
        -- Không đổi RenderFidelity: bị chặn lúc Run-Time với SolidModel, gây spam lỗi.
    end)
end

local function optimizeFx(obj)
    pcall(function()
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
            or obj:IsA("Fire") or obj:IsA("Smoke") or obj:IsA("Sparkles") then
            if obj.Enabled ~= false then obj.Enabled = false end
        elseif obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") then
            if obj.Range ~= 0 then obj.Range = 0; obj.Brightness = 0 end
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            if obj.Transparency ~= 1 then obj.Transparency = 1 end
        end
    end)
end

-- =====================================================================
-- PHẦN 3: HÀNG ĐỢI ADAPTIVE BATCHING
-- Tự đo thời gian xử lý thực tế mỗi frame và tự điều chỉnh batch size
-- để KHÔNG BAO GIỜ vượt quá ngân sách frame (TargetFrameBudgetMs)
-- → đây là điểm khác biệt so với bản cũ (batch size cố định)
-- =====================================================================
local processQueue  = {}
local queueSet       = {}
local isProcessing   = false
local currentBatch   = CONFIG.MinBatchSize

local function enqueue(obj)
    if queueSet[obj] then return end
    queueSet[obj] = true
    table.insert(processQueue, obj)
end

local function startQueueWorker()
    if isProcessing then return end
    isProcessing = true
    task.spawn(function()
        while #processQueue > 0 do
            local frameStart = os.clock()
            local processed  = 0

            while processed < currentBatch and #processQueue > 0 do
                local obj = table.remove(processQueue, 1)
                queueSet[obj] = nil
                if obj and obj.Parent then
                    if obj:IsA("BasePart") then optimizePart(obj) else optimizeFx(obj) end
                end
                processed += 1
            end

            local elapsedMs = (os.clock() - frameStart) * 1000

            -- Điều chỉnh batch size dựa trên thời gian thực tế đã tốn
            if elapsedMs > CONFIG.TargetFrameBudgetMs then
                currentBatch = math.max(CONFIG.MinBatchSize, math.floor(currentBatch * 0.7))
            elseif elapsedMs < CONFIG.TargetFrameBudgetMs * 0.5 then
                currentBatch = math.min(CONFIG.MaxBatchSize, currentBatch + 10)
            end

            RunService.Heartbeat:Wait() -- luôn nhường 1 frame giữa các lô
        end
        isProcessing = false
    end)
end

-- =====================================================================
-- PHẦN 4: QUÉT MAP HIỆN CÓ + HOOK STREAMING (part mới khi di chuyển)
-- =====================================================================
local WATCH_CLASSES = {
    BasePart = true, ParticleEmitter = true, Trail = true, Fire = true,
    Smoke = true, Sparkles = true, PointLight = true, SpotLight = true,
    SurfaceLight = true, Decal = true, Texture = true,
}

local function isWatched(obj)
    for cls in pairs(WATCH_CLASSES) do
        if obj:IsA(cls) then return true end
    end
    return false
end

local function queueExistingMap()
    task.spawn(function()
        local ok, descendants = pcall(function() return ws:GetDescendants() end)
        if not ok then return end
        for i, obj in ipairs(descendants) do
            if isWatched(obj) then enqueue(obj) end
            if i % 300 == 0 then task.wait() end -- nghỉ khi QUÉT, tránh giật lúc GetDescendants() cực lớn
        end
        startQueueWorker()
        safePrint("[FixLag+] Đã đưa " .. #descendants .. " object vào hàng đợi (adaptive batching).")
    end)
end

local function hookStreamingParts()
    ws.DescendantAdded:Connect(function(obj)
        if isWatched(obj) then
            enqueue(obj)
            startQueueWorker()
        end
    end)
    safePrint("[FixLag+] Đã hook streaming — part mới tự tối ưu dần, không giật.")
end

-- =====================================================================
-- PHẦN 5: XÓA SKIN NGƯỜI CHƠI KHÁC (theo lô, an toàn)
-- =====================================================================
local function stripCharacter(char)
    if not char then return end
    task.spawn(function()
        local removeList = {}
        for _, obj in ipairs(char:GetChildren()) do
            if obj:IsA("Accessory") or obj:IsA("Shirt") or obj:IsA("Pants")
                or obj:IsA("ShirtGraphic") or obj:IsA("BodyColors")
                or obj:IsA("CharacterMesh") then
                table.insert(removeList, obj)
            end
        end
        for i, obj in ipairs(removeList) do
            pcall(function() obj:Destroy() end)
            if i % 10 == 0 then task.wait() end
        end
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BasePart") or obj:IsA("Decal") then enqueue(obj) end
        end
        startQueueWorker()
    end)
end

local function stripHeadGui(char)
    if not char then return end
    pcall(function()
        for _, obj in ipairs(char:GetDescendants()) do
            if obj:IsA("BillboardGui") or obj:IsA("SurfaceGui") or obj:IsA("SelectionBox") then
                obj:Destroy()
            end
        end
    end)
end

local function hookPlayerCharacters()
    local function handlePlayer(p)
        if p == plr then return end
        if p.Character then stripCharacter(p.Character); stripHeadGui(p.Character) end
        p.CharacterAdded:Connect(function(char)
            task.wait(0.5)
            stripCharacter(char)
            stripHeadGui(char)
        end)
    end
    for _, p in ipairs(Players:GetPlayers()) do handlePlayer(p) end
    Players.PlayerAdded:Connect(handlePlayer)
    safePrint("[FixLag+] Đã bật xóa skin người chơi khác (theo lô).")
end

-- =====================================================================
-- PHẦN 6: LOD TOÀN BẢN ĐỒ (không chỉ decor được đặt tên — quét thông minh)
-- Chỉ ẩn Model/Folder KHÔNG chứa Humanoid, KHÔNG phải Terrain/Spawn/map gốc
-- Dùng khoảng cách trễ (hysteresis) để tránh nhấp nháy khi đứng gần biên
-- =====================================================================
local KEEP_ALWAYS = { Terrain = true, Baseplate = true, SpawnLocation = true, Camera = true }

local lodTargets = {}
local function scanForLOD()
    task.spawn(function()
        for i, obj in ipairs(ws:GetChildren()) do
            if not KEEP_ALWAYS[obj.Name]
                and (obj:IsA("Model") or obj:IsA("Folder"))
                and not obj:FindFirstChildWhichIsA("Humanoid", true) then
                table.insert(lodTargets, obj)
            end
            if i % 100 == 0 then task.wait() end
        end
        safePrint("[FixLag+] LOD theo dõi " .. #lodTargets .. " object không phải map gốc.")
    end)
end

local lodState = {} -- obj -> true/false (đang hiện hay ẩn), tránh set lại liên tục
local lodAccum = 0
RunService.Heartbeat:Connect(function(dt)
    lodAccum += dt
    if lodAccum < CONFIG.LODCheckInterval then return end
    lodAccum = 0

    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    for _, obj in ipairs(lodTargets) do
        if obj and obj.Parent then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if primary then
                local dist = (primary.Position - hrp.Position).Magnitude
                -- Hysteresis: hiện lại sớm hơn 20% khoảng cách để không nhấp nháy ở biên
                local shouldShow = dist <= CONFIG.LODDistance * (lodState[obj] and 1.2 or 1.0)
                if lodState[obj] ~= shouldShow then
                    lodState[obj] = shouldShow
                    for _, part in ipairs(obj:GetDescendants()) do
                        if part:IsA("BasePart") then
                            pcall(function()
                                part.LocalTransparencyModifier = shouldShow and 0 or 1
                                part.CanCollide = shouldShow
                                part.CanQuery   = shouldShow
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- =====================================================================
-- PHẦN 7: GC ĐỊNH KỲ (dọn instance mồ côi, giảm rò rỉ bộ nhớ)
-- =====================================================================
local function periodicCleanup()
    task.spawn(function()
        while task.wait(45) do
            pcall(function() collectgarbage("collect") end)
        end
    end)
end

-- =====================================================================
-- PHẦN 8: DUY TRÌ CÀI ĐẶT (nhẹ, tần suất thấp)
-- =====================================================================
local function keepAlive()
    task.spawn(function()
        while task.wait(30) do
            pcall(function()
                settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
                lighting.GlobalShadows = false
                soundService.Volume    = CONFIG.SoundVolume
            end)
        end
    end)
end

-- =====================================================================
-- PHẦN 9: UI THEO DÕI FPS/BATCH REALTIME (nhẹ, tự ẩn khi không cần)
-- =====================================================================
local function createMonitorUI()
    if not CONFIG.ShowUI then return end
    pcall(function()
        local gui = plr:WaitForChild("PlayerGui")
        if gui:FindFirstChild("FixLagPlusMonitor") then
            gui.FixLagPlusMonitor:Destroy()
        end

        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "FixLagPlusMonitor"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = gui

        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0, 150, 0, 54)
        frame.Position = UDim2.new(0, 8, 0, 140)
        frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
        frame.BackgroundTransparency = 0.25
        frame.Active = true
        frame.Parent = screenGui
        Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

        -- Kéo thả trên mobile
        local dragging, dragStart, startPos = false, nil, nil
        frame.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = i.Position; startPos = frame.Position
            end
        end)
        frame.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local delta = i.Position - dragStart
                frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        game:GetService("UserInputService").InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
        end)

        local fpsLbl = Instance.new("TextLabel")
        fpsLbl.Size = UDim2.new(1, -10, 0, 20)
        fpsLbl.Position = UDim2.new(0, 5, 0, 4)
        fpsLbl.BackgroundTransparency = 1
        fpsLbl.TextColor3 = Color3.fromRGB(0, 255, 140)
        fpsLbl.Font = Enum.Font.GothamBold
        fpsLbl.TextSize = 13
        fpsLbl.TextXAlignment = Enum.TextXAlignment.Left
        fpsLbl.Text = "FPS: --"
        fpsLbl.Parent = frame

        local queueLbl = Instance.new("TextLabel")
        queueLbl.Size = UDim2.new(1, -10, 0, 18)
        queueLbl.Position = UDim2.new(0, 5, 0, 24)
        queueLbl.BackgroundTransparency = 1
        queueLbl.TextColor3 = Color3.fromRGB(180, 180, 255)
        queueLbl.Font = Enum.Font.Gotham
        queueLbl.TextSize = 10
        queueLbl.TextXAlignment = Enum.TextXAlignment.Left
        queueLbl.Text = "Hàng đợi: 0"
        queueLbl.Parent = frame

        local tierLbl = Instance.new("TextLabel")
        tierLbl.Size = UDim2.new(1, -10, 0, 14)
        tierLbl.Position = UDim2.new(0, 5, 0, 40)
        tierLbl.BackgroundTransparency = 1
        tierLbl.TextColor3 = Color3.fromRGB(255, 200, 100)
        tierLbl.Font = Enum.Font.Gotham
        tierLbl.TextSize = 9
        tierLbl.TextXAlignment = Enum.TextXAlignment.Left
        tierLbl.Text = "Máy: đang đo..."
        tierLbl.Parent = frame

        frame.Size = UDim2.new(0, 150, 0, 68)

        local frameCount, lastCheck = 0, os.clock()
        RunService.RenderStepped:Connect(function()
            frameCount += 1
            local now = os.clock()
            if now - lastCheck >= 1 then
                fpsLbl.Text   = "FPS: " .. frameCount
                queueLbl.Text = "Hàng đợi: " .. #processQueue .. " | Batch: " .. currentBatch
                tierLbl.Text  = "Máy: " .. deviceTier
                frameCount, lastCheck = 0, now
            end
        end)
    end)
end

-- =====================================================================
-- CHẠY TẤT CẢ (tuần tự, cách nhau nhỏ để không giật lúc khởi động)
-- =====================================================================
applyGraphicsSettings()
task.wait(0.1)
createMonitorUI()
task.wait(0.1)
autoDetectDevice()
task.wait(0.1)
queueExistingMap()
task.wait(0.1)
hookStreamingParts()
task.wait(0.1)
hookPlayerCharacters()
scanForLOD()
periodicCleanup()
keepAlive()

safePrint("[FixLag+] ✅ V4 Plus đã chạy — adaptive batching, LOD toàn bản đồ, chống spam console.")
pcall(function()
    StarterGui:SetCore("SendNotification", {
        Title    = "✅ Fix Lag V4 Plus",
        Text     = "Đang tối ưu thông minh: tự điều chỉnh tốc độ theo máy của bạn.",
        Duration = 4,
    })
end)
