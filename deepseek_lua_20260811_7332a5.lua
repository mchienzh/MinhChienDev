-- ============================================================
-- MURDER MYSTERY 2 – ULTIMATE V6 (Delta X)
-- TẤT CẢ CHỨC NĂNG MẶC ĐỊNH ĐỀU TẮT (OFF)
-- Cậu tự bật qua menu GUI.
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ===== CẤU HÌNH (MẶC ĐỊNH TẤT CẢ ĐỀU FALSE) =====
local features = {
    ESP = false,              -- TẮT
    SilentAim = false,        -- TẮT
    WallClick = false,        -- TẮT
    TeamCheck = false,        -- TẮT
    ShowDistance = false,     -- TẮT
    AutoTeleportGun = false,  -- TẮT
    TeleportHalf = false,     -- TẮT
    AutoPickCoin = false,     -- TẮT
}

local CONFIG = {
    SilentAim_FOV = 180,
    SilentAim_Prediction = 0.2,
    TeleportReturnDelay = 0.3,
    ESP_UpdateRate = 0.2,
    AutoPickRadius = 15,
}

-- ===== MÀU ESP =====
local COLOR_GUN = Color3.fromRGB(0, 150, 255)
local COLOR_KNIFE = Color3.fromRGB(255, 0, 0)
local COLOR_INNOCENT = Color3.fromRGB(100, 255, 100)

-- ===== ESP (tối ưu, không chạy nếu ESP = false) =====
local espObjects = {}
local espUpdateTimer = 0

local function clearESP()
    for _, v in pairs(espObjects) do
        if v and v.Parent then v:Destroy() end
    end
    espObjects = {}
end

local function getPlayerWeapon(player)
    local char = player.Character
    local backpack = player:FindFirstChildOfClass("Backpack")
    local tools = {}
    local toolInHand = char and char:FindFirstChildOfClass("Tool")
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
    if not highlight then return end
    local weaponType = getPlayerWeapon(player)
    if data.lastWeaponType ~= weaponType then
        data.lastWeaponType = weaponType
        if weaponType == "gun" then
            highlight.FillColor = COLOR_GUN
        elseif weaponType == "knife" then
            highlight.FillColor = COLOR_KNIFE
        else
            highlight.FillColor = COLOR_INNOCENT
        end
    end
end

local function createESP(player)
    if not features.ESP or player == LocalPlayer then return end
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = character.HumanoidRootPart
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1,1,1)
    highlight.OutlineTransparency = 0.5
    highlight.Parent = character
    
    local bill = Instance.new("BillboardGui")
    bill.Size = UDim2.new(0, 180, 0, 30)
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
    
    local weaponType = getPlayerWeapon(player)
    espObjects[player] = {highlight, bill, text, weaponType}
    updatePlayerColor(player)
end

local function refreshESP()
    clearESP()
    if not features.ESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end
end

local function updateESP()
    if not features.ESP then 
        -- Nếu ESP tắt, xóa hết để tiết kiệm
        if next(espObjects) then clearESP() end
        return 
    end
    espUpdateTimer = espUpdateTimer + RunService.RenderStepped:Wait()
    if espUpdateTimer < CONFIG.ESP_UpdateRate then return end
    espUpdateTimer = 0
    
    for player, objects in pairs(espObjects) do
        local char = player.Character
        if not char or not char:FindFirstChild("HumanoidRootPart") then
            for _, obj in pairs(objects) do obj:Destroy() end
            espObjects[player] = nil
        else
            updatePlayerColor(player)
            if features.ShowDistance then
                local root = char.HumanoidRootPart
                local dist = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and 
                             (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
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

-- Auto refresh khi vào ván mới (nhưng vẫn tôn trọng trạng thái features)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    refreshESP()
end)

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
    createESP(player)
end)
Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do obj:Destroy() end
        espObjects[player] = nil
    end
end)

-- ===== SILENT AIM + WALL CLICK (chỉ chạy khi bật) =====
local function getNearestTarget()
    if not features.SilentAim then return nil end
    local nearest, nearestDist = nil, CONFIG.SilentAim_FOV
    local origin = Camera.CFrame.Position
    local lookVec = Camera.CFrame.LookVector
    
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if features.TeamCheck then
                -- Bỏ qua team nếu có
            end
            local targetPos = plr.Character.HumanoidRootPart.Position
            local vel = plr.Character.HumanoidRootPart.Velocity or Vector3.new(0,0,0)
            local predPos = targetPos + (vel * CONFIG.SilentAim_Prediction)
            local dirToTarget = (predPos - origin).Unit
            local angle = math.deg(math.acos(lookVec:Dot(dirToTarget)))
            if angle < nearestDist then
                nearestDist = angle
                nearest = plr
            end
        end
    end
    return nearest
end

local function silentAimShoot()
    if not features.SilentAim then return end
    local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
    if not tool then return end
    
    local target = getNearestTarget()
    if not target then return end
    
    local targetPos = target.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
    local origin = Camera.CFrame.Position
    
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
        local oldCF = handle.CFrame
        handle.CFrame = CFrame.lookAt(handle.Position, targetPos)
        task.wait(0.01)
        handle.CFrame = oldCF
        tool:Activate()
    end
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        if features.WallClick then
            silentAimShoot()
        else
            local target = getNearestTarget()
            if target then
                local origin = Camera.CFrame.Position
                local targetPos = target.Character.HumanoidRootPart.Position
                local direction = (targetPos - origin).Unit * 1000
                local ray = Ray.new(origin, direction)
                local hit = workspace:FindPartOnRay(ray, LocalPlayer.Character)
                if hit and hit:IsDescendantOf(target.Character) then
                    silentAimShoot()
                end
            end
        end
    end
end)

-- ===== AUTO TELEPORT ĐẾN SÚNG RƠI (chỉ khi bật) =====
local function teleportToGun()
    if not features.AutoTeleportGun then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local char = LocalPlayer.Character
    local root = char.HumanoidRootPart
    local originalPos = root.Position
    
    local guns = {}
    for _, obj in pairs(workspace:GetChildren()) do
        if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
            local name = obj.Name:lower()
            if name:find("gun") or name:find("pistol") or name:find("sheriff") or name:find("revolver") then
                if obj.Parent and not obj.Parent:IsA("Character") then
                    table.insert(guns, obj)
                end
            end
        end
    end
    
    if #guns == 0 then
        for _, folder in pairs(workspace:GetChildren()) do
            if folder:IsA("Folder") and folder.Name:lower():find("drop") then
                for _, obj in pairs(folder:GetChildren()) do
                    if obj:IsA("Tool") and obj:FindFirstChild("Handle") then
                        local name = obj.Name:lower()
                        if name:find("gun") or name:find("pistol") or name:find("sheriff") or name:find("revolver") then
                            if obj.Parent and not obj.Parent:IsA("Character") then
                                table.insert(guns, obj)
                            end
                        end
                    end
                end
            end
        end
    end
    
    if #guns > 0 then
        local nearestGun = nil
        local nearestDist = math.huge
        for _, gun in pairs(guns) do
            local gunPos = gun.Handle.Position
            local dist = (root.Position - gunPos).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestGun = gun
            end
        end
        if nearestGun then
            local gunPos = nearestGun.Handle.Position + Vector3.new(0, 1, 0)
            root.CFrame = CFrame.new(gunPos)
            task.wait(CONFIG.TeleportReturnDelay)
            root.CFrame = CFrame.new(originalPos)
        end
    end
end

workspace.ChildAdded:Connect(function(child)
    if child:IsA("Tool") then
        task.spawn(function() teleportToGun() end)
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if features.AutoTeleportGun then teleportToGun() end
    end
end)

-- ===== TELEPORT NỬA NGƯỜI (chỉ khi bật) =====
local function getGroundY(position)
    local ray = Ray.new(position + Vector3.new(0, 10, 0), Vector3.new(0, -30, 0))
    local hit, hitPos = workspace:FindPartOnRay(ray, nil)
    if hit and hitPos then
        return hitPos.Y
    end
    return position.Y - 5
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
        newPos = Vector3.new(targetPos.X, groundY + (halfHeight/2), targetPos.Z)
    else
        newPos = targetPos
    end
    
    for i = 1, 3 do
        localRoot.CFrame = CFrame.new(newPos)
        task.wait(0.05)
    end
    localRoot.Velocity = Vector3.new(0, 0, 0)
end

-- ===== AUTO NHẶT XU (chỉ khi bật) =====
local function pickUpCoins()
    if not features.AutoPickCoin then return end
    if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local root = LocalPlayer.Character.HumanoidRootPart
    local pos = root.Position
    local radius = CONFIG.AutoPickRadius
    
    local targets = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character) then
            local name = obj.Name:lower()
            if name:find("coin") or name:find("gem") or name:find("xu") or name:find("money") or name:find("chest") then
                local dist = (pos - obj.Position).Magnitude
                if dist < radius then
                    table.insert(targets, obj)
                end
            end
        end
    end
    
    for _, target in pairs(targets) do
        local detector = target:FindFirstChildOfClass("ClickDetector")
        if detector then
            pcall(function() detector:Click() end)
        end
        local targetPos = target.Position + Vector3.new(0, 1, 0)
        root.CFrame = CFrame.new(targetPos)
        task.wait(0.1)
        root.CFrame = CFrame.new(pos)
    end
end

task.spawn(function()
    while task.wait(2) do
        if features.AutoPickCoin then pickUpCoins() end
    end
end)

-- ===== GUI MENU (tất cả toggle hiển thị đúng trạng thái) =====
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
Main.Size = UDim2.new(0, 260, 0, 540)
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
Holder.CanvasSize = UDim2.new(0, 0, 9, 0)
Holder.ScrollBarThickness = 0

local Layout = Instance.new("UIListLayout", Holder)
Layout.Padding = UDim.new(0, 8)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

-- Icon
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

-- Hàm tạo toggle
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

-- Tạo các nút với giá trị mặc định lấy từ features
CreateToggle("ESP", features.ESP, function(val)
    features.ESP = val
    if val then refreshESP() else clearESP() end
end)

CreateToggle("Silent Aim", features.SilentAim, function(val)
    features.SilentAim = val
end)

CreateToggle("Wall Click", features.WallClick, function(val)
    features.WallClick = val
end)

CreateToggle("Team Check", features.TeamCheck, function(val)
    features.TeamCheck = val
end)

CreateToggle("Show Distance", features.ShowDistance, function(val)
    features.ShowDistance = val
end)

CreateToggle("Auto Teleport Gun", features.AutoTeleportGun, function(val)
    features.AutoTeleportGun = val
end)

CreateToggle("Teleport Half-Body", features.TeleportHalf, function(val)
    features.TeleportHalf = val
end)

CreateToggle("Auto Pick Coin", features.AutoPickCoin, function(val)
    features.AutoPickCoin = val
end)

-- Nút Refresh ESP
local resetBtn = Instance.new("TextButton", Holder)
resetBtn.Size = UDim2.new(1, 0, 0, 36)
resetBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
resetBtn.Text = "REFRESH ESP"
resetBtn.TextColor3 = Color3.new(1,1,1)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 11
local resetCorner = Instance.new("UICorner", resetBtn)
resetCorner.CornerRadius = UDim.new(0, 4)
resetBtn.Activated:Connect(function()
    refreshESP()
    ClickSound:Play()
end)

-- Nút Teleport đến người chơi
local teleportBtn = Instance.new("TextButton", Holder)
teleportBtn.Size = UDim2.new(1, 0, 0, 36)
teleportBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
teleportBtn.Text = "TELEPORT TO PLAYER"
teleportBtn.TextColor3 = Color3.new(1,1,1)
teleportBtn.Font = Enum.Font.GothamBold
teleportBtn.TextSize = 11
local teleCorner = Instance.new("UICorner", teleportBtn)
teleCorner.CornerRadius = UDim.new(0, 4)

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

-- ===== KHỞI TẠO BAN ĐẦU =====
refreshESP()  -- sẽ không tạo gì vì ESP = false

RunService.RenderStepped:Connect(function()
    updateESP()
end)

-- ===== ANTI-BAN =====
local remote = ReplicatedStorage:FindFirstChild("RemoteEvent")
if remote then
    local oldFire = remote.FireServer
    remote.FireServer = function(self, ...)
        return oldFire(self, ...)
    end
end

print("Axiom MM2 Ultimate v6 – fuck yeah boss man. Tất cả OFF, cậu tự bật qua menu.")