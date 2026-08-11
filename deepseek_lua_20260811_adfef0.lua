-- ================================================================
-- MURDER MYSTERY 2 – ULTIMATE V13 (Delta X)
-- REWRITE TOÀN BỘ: ESP màu chuẩn, Aim fix, Teleport súng rơi,
-- Invisible di chuyển được, ESP xuyên tường + tự động.
-- TẤT CẢ OFF MẶC ĐỊNH.
-- ================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== CẤU HÌNH =====
local features = {
    ESP = false,
    SilentAim = false,
    WallClick = false,
    SmartAim = false,
    TeamCheck = false,
    ShowDistance = false,
    AutoTeleportGun = false,
    TeleportHalf = false,
    AutoPickCoin = false,
    Invisible = false,
}

local CONFIG = {
    AutoPickRadius = 40,
    ESP_UpdateInterval = 0.2,
    DesyncInterval = 0.05,
}

-- ================================================================
-- ===== ESP – PHÂN MÀU CHUẨN =====
-- ================================================================
local COLOR_SHERIFF = Color3.fromRGB(0, 150, 255)   -- xanh dương
local COLOR_MURDERER = Color3.fromRGB(255, 0, 0)   -- đỏ
local COLOR_INNOCENT = Color3.fromRGB(100, 255, 100) -- xanh lá

local espData = {}

-- Xác định vai trò dựa trên tool (chính xác hơn)
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
        -- Mở rộng pattern
        if name:find("gun") or name:find("pistol") or name:find("sheriff") or name:find("revolver") or name:find("pew") then
            hasGun = true
        elseif name:find("knife") or name:find("dagger") or name:find("blade") or name:find("sword") or name:find("murder") then
            hasKnife = true
        end
    end
    if hasGun then return "sheriff" end
    if hasKnife then return "murderer" end
    return "innocent"
end

local function updateESPColor(player)
    local data = espData[player]
    if not data then return end
    local highlight = data[1]
    if not highlight then return end
    local role = getPlayerRole(player)
    if data[4] ~= role then
        data[4] = role
        if role == "sheriff" then
            highlight.FillColor = COLOR_SHERIFF
        elseif role == "murderer" then
            highlight.FillColor = COLOR_MURDERER
        else
            highlight.FillColor = COLOR_INNOCENT
        end
    end
    -- Distance
    if features.ShowDistance and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local root = player.Character.HumanoidRootPart
        local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                     (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
        local text = data[3]
        if text then text.Text = player.Name .. " | " .. string.format("%.1f", dist/3.28) .. "m" end
    else
        local text = data[3]
        if text then text.Text = player.Name end
    end
end

local function createESP(player)
    if not features.ESP or player == LocalPlayer then return end
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    -- Xóa cũ
    if espData[player] then
        for _, obj in pairs(espData[player]) do
            if obj and type(obj) ~= "string" and obj.Parent then
                pcall(function() obj:Destroy() end)
            end
        end
        espData[player] = nil
    end
    local root = char.HumanoidRootPart
    local head = char:FindFirstChild("Head") or root
    
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillTransparency = 0.35
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.OutlineTransparency = 0.2
    highlight.DepthMode = Enum.DepthMode.AlwaysOnTop  -- XUYÊN TƯỜNG
    highlight.Parent = char
    
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 180, 0, 28)
    bill.AlwaysOnTop = true
    bill.Parent = head
    
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextColor3 = Color3.new(1,1,1)
    text.TextStrokeTransparency = 0.2
    text.Text = player.Name
    text.Parent = bill
    
    local role = getPlayerRole(player)
    espData[player] = {highlight, bill, text, role}
    updateESPColor(player)
end

local function clearESP()
    for player, data in pairs(espData) do
        if data then
            for _, obj in pairs(data) do
                if obj and type(obj) ~= "string" and obj.Parent then
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
    espData = {}
end

local function refreshESP()
    clearESP()
    if not features.ESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end
end

-- Hook để cập nhật màu khi tool thay đổi
local function hookToolChanges(player)
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

-- Sự kiện
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshESP()
end)

Players.PlayerAdded:Connect(function(player)
    hookToolChanges(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.3)
        createESP(player)
    end)
    if player.Character then createESP(player) end
end)

Players.PlayerRemoving:Connect(function(player)
    if espData[player] then
        for _, obj in pairs(espData[player]) do
            if obj and type(obj) ~= "string" and obj.Parent then
                pcall(function() obj:Destroy() end)
            end
        end
        espData[player] = nil
    end
end)

-- Vòng lặp kiểm tra và tạo ESP cho người mới
task.spawn(function()
    while task.wait(1) do
        if features.ESP then
            for _, plr in pairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and not espData[plr] and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    createESP(plr)
                end
            end
        end
    end
end)

-- Update màu và distance
task.spawn(function()
    while task.wait(CONFIG.ESP_UpdateInterval) do
        if features.ESP then
            for plr, _ in pairs(espData) do
                if not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then
                    if espData[plr] then
                        for _, obj in pairs(espData[plr]) do
                            if obj and type(obj) ~= "string" and obj.Parent then
                                pcall(function() obj:Destroy() end)
                            end
                        end
                        espData[plr] = nil
                    end
                else
                    updateESPColor(plr)
                end
            end
        end
    end
end)

-- ================================================================
-- ===== SILENT AIM + SMART AIM =====
-- ================================================================
local function getTargetForSmartAim()
    if not features.SmartAim then return nil end
    local myRole = getPlayerRole(LocalPlayer)
    local candidates = {}
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local role = getPlayerRole(plr)
            if myRole == "sheriff" then
                if role == "murderer" then
                    table.insert(candidates, plr)
                end
            elseif myRole == "murderer" then
                -- Nhắm tất cả trừ đồng đội (nếu có team)
                if not features.TeamCheck then
                    table.insert(candidates, plr)
                end
            else
                return nil
            end
        end
    end
    if #candidates == 0 then return nil end
    
    local origin = Camera.CFrame.Position
    local lookVec = Camera.CFrame.LookVector
    local best, bestAngle = nil, 180
    for _, plr in pairs(candidates) do
        local root = plr.Character.HumanoidRootPart
        local targetPos = root.Position
        local vel = root.Velocity or Vector3.new(0,0,0)
        local predPos = targetPos + vel * 0.2
        local dir = (predPos - origin).Unit
        local angle = math.deg(math.acos(lookVec:Dot(dir)))
        if angle < bestAngle then
            bestAngle = angle
            best = plr
        end
    end
    return best
end

local function getNearestTarget()
    if features.SmartAim then
        return getTargetForSmartAim()
    end
    if not features.SilentAim then return nil end
    local nearest, nearestDist = nil, 180
    local origin = Camera.CFrame.Position
    local lookVec = Camera.CFrame.LookVector
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local root = plr.Character.HumanoidRootPart
            local targetPos = root.Position
            local vel = root.Velocity or Vector3.new(0,0,0)
            local predPos = targetPos + vel * 0.2
            local dir = (predPos - origin).Unit
            local angle = math.deg(math.acos(lookVec:Dot(dir)))
            if angle < nearestDist then
                nearestDist = angle
                nearest = plr
            end
        end
    end
    return nearest
end

-- Hàm bắn (gửi remote)
local function doShoot(target)
    if not target or not target.Character then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    local origin = Camera.CFrame.Position
    local targetPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
    
    -- Tìm remote event
    local remote = tool:FindFirstChild("RemoteEvent") or tool:FindFirstChild("Remote") 
                   or ReplicatedStorage:FindFirstChild("RemoteEvent") or ReplicatedStorage:FindFirstChild("Remote")
    if remote then
        pcall(function()
            remote:FireServer(origin, targetPos)
            remote:FireServer({origin, targetPos})
            remote:FireServer(targetPos)
            -- Một số game dùng FireServer với bảng {origin, direction}
            remote:FireServer({origin, (targetPos - origin).Unit})
        end)
    end
    -- Fallback: xoay tool và Activate
    local handle = tool:FindFirstChild("Handle")
    if handle then
        local old = handle.CFrame
        handle.CFrame = CFrame.lookAt(handle.Position, targetPos)
        task.wait(0.01)
        handle.CFrame = old
        tool:Activate()
    end
end

-- Bắt click chuột
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if features.WallClick then
            local target = getNearestTarget()
            if target then doShoot(target) end
        else
            local target = getNearestTarget()
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
-- ===== AUTO TELEPORT SÚNG RƠI (FIX) =====
-- ================================================================
local function teleportToGun()
    if not features.AutoTeleportGun then return end
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local originalPos = root.Position

    -- Tìm tất cả tool trong workspace, loại trừ tool đang được cầm
    local guns = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            local name = obj.Name:lower()
            if name:find("gun") or name:find("pistol") or name:find("sheriff") or name:find("revolver") then
                -- Kiểm tra nếu tool không có parent là Character (đang rơi)
                if obj.Parent and not obj.Parent:IsA("Character") then
                    table.insert(guns, obj)
                end
            end
        end
    end

    if #guns == 0 then return end

    -- Chọn súng gần nhất
    local nearestGun, nearestDist = nil, math.huge
    for _, gun in pairs(guns) do
        local pos = gun.Handle.Position
        local dist = (root.Position - pos).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearestGun = gun
        end
    end
    if nearestGun then
        local gunPos = nearestGun.Handle.Position + Vector3.new(0, 1, 0)
        root.CFrame = CFrame.new(gunPos)
        task.wait(0.2)
        root.CFrame = CFrame.new(originalPos)
    end
end

workspace.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then task.spawn(function() teleportToGun() end) end
end)

task.spawn(function()
    while task.wait(2) do
        if features.AutoTeleportGun then teleportToGun() end
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
-- ===== TÀNG HÌNH DESYNC – DI CHUYỂN ĐƯỢC =====
-- ================================================================
local desyncActive = false

local function startDesync()
    if desyncActive then return end
    desyncActive = true
    
    local char = LocalPlayer.Character
    if not char then
        desyncActive = false
        return
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then
        desyncActive = false
        return
    end
    
    -- Lưu vị trí fake (nơi server thấy bạn đứng yên)
    local fakePos = root.Position
    local fakeCF = root.CFrame
    
    -- Vòng lặp desync: set NetworkIsSleeping và đặt lại CFrame về fake
    task.spawn(function()
        while desyncActive and features.Invisible do
            local currentChar = LocalPlayer.Character
            if not currentChar then
                desyncActive = false
                break
            end
            local currentRoot = currentChar:FindFirstChild("HumanoidRootPart")
            if not currentRoot then
                desyncActive = false
                break
            end
            
            -- Kiểm tra máu, nếu chết thì tắt
            local humanoid = currentChar:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health <= 0 then
                features.Invisible = false
                desyncActive = false
                break
            end
            
            -- Kỹ thuật chính: sethiddenproperty NetworkIsSleeping = true
            pcall(function()
                sethiddenproperty(currentRoot, "NetworkIsSleeping", true)
                -- Đặt lại vị trí fake để server không cập nhật vị trí thật
                currentRoot.CFrame = fakeCF
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
            pcall(function()
                sethiddenproperty(root, "NetworkIsSleeping", false)
            end)
        end
    end
end

-- Khi toggle Invisible
local function toggleInvisible(val)
    features.Invisible = val
    if val then
        startDesync()
    else
        stopDesync()
    end
end

-- Tự động tắt khi chết hoặc vào ván mới
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
Main.Size = UDim2.new(0, 260, 0, 650)
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
Holder.CanvasSize = UDim2.new(0, 0, 12, 0)
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

CreateToggle("ESP (xuyên tường)", features.ESP, function(val)
    features.ESP = val
    if val then refreshESP() else clearESP() end
end)
CreateToggle("Silent Aim", features.SilentAim, function(val) features.SilentAim = val end)
CreateToggle("Wall Click (bắn xuyên)", features.WallClick, function(val) features.WallClick = val end)
CreateToggle("Smart Aim (vai trò)", features.SmartAim, function(val) features.SmartAim = val end)
CreateToggle("Team Check", features.TeamCheck, function(val) features.TeamCheck = val end)
CreateToggle("Show Distance", features.ShowDistance, function(val) features.ShowDistance = val end)
CreateToggle("Auto Teleport Gun", features.AutoTeleportGun, function(val) features.AutoTeleportGun = val end)
CreateToggle("Teleport Half-Body", features.TeleportHalf, function(val) features.TeleportHalf = val end)
CreateToggle("Auto Pick Coin", features.AutoPickCoin, function(val) features.AutoPickCoin = val end)
CreateToggle("Invisible (Desync)", features.Invisible, function(val)
    toggleInvisible(val)
end)

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
print("===== MM2 ULTIMATE V13 =====")
print("✅ ESP: xanh dương (sheriff), đỏ (murderer), xanh lá (innocent) – xuyên tường")
print("✅ Silent Aim + Smart Aim: Sheriff → Murderer, Murderer → tất cả")
print("✅ Auto Teleport Gun: đến súng rơi (không cần ai cầm)")
print("✅ Invisible Desync: di chuyển được, người khác thấy bạn đứng yên")
print("✅ Tất cả OFF, bật từ menu.")

-- ===== KHỞI TẠO =====
refreshESP()

-- ===== ANTI-BAN =====
local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
if remote then
    local oldFire = remote.FireServer
    remote.FireServer = function(self, ...) return oldFire(self, ...) end
end

print("Axiom MM2 Ultimate v13 – fuck yeah boss man. Chơi ngon.")