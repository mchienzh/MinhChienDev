-- ===== CAGE TOOL NÂNG CẤP – GIAM ALL + TẤN CÔNG =====
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")

-- Quản lý các lồng: mỗi người bị giam có một bảng vật thể
local cages = {} -- key = tên người chơi, value = {objects = {}, maintainLoop = nil, target = ...}
local selectedTarget = nil
local isCaging = false
local isSpectating = false
local isMinimized = false

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "CageMenu"
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = gui
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.Position = UDim2.new(0.5, 0, 0.4, 0)
mainFrame.Size = UDim2.new(0, 280, 0, 290)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.BackgroundTransparency = 0.1
mainFrame.ZIndex = 10
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.BackgroundTransparency = 1

local title = Instance.new("TextLabel")
title.Parent = titleBar
title.Size = UDim2.new(0.8, 0, 1, 0)
title.BackgroundTransparency = 1
title.Text = "🪤 Cage Tool"
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Position = UDim2.new(0, 10, 0, 0)
title.ZIndex = 11

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Parent = titleBar
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(1, -30, 0, 2)
minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
minimizeBtn.Text = "➖"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.TextSize = 16
minimizeBtn.BorderSizePixel = 0
minimizeBtn.ZIndex = 12
local cornerMin = Instance.new("UICorner")
cornerMin.CornerRadius = UDim.new(0, 5)
cornerMin.Parent = minimizeBtn

local contentContainer = Instance.new("Frame")
contentContainer.Parent = mainFrame
contentContainer.Size = UDim2.new(1, 0, 1, -30)
contentContainer.Position = UDim2.new(0, 0, 0, 30)
contentContainer.BackgroundTransparency = 1

-- Dropdown
local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Parent = contentContainer
dropdownBtn.Size = UDim2.new(0, 180, 0, 30)
dropdownBtn.Position = UDim2.new(0.5, -90, 0, 10)
dropdownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
dropdownBtn.Text = "Chọn mục tiêu..."
dropdownBtn.TextColor3 = Color3.new(1, 1, 1)
dropdownBtn.Font = Enum.Font.GothamBold
dropdownBtn.TextSize = 14
dropdownBtn.BorderSizePixel = 0
dropdownBtn.ZIndex = 11
local cornerBtn = Instance.new("UICorner")
cornerBtn.CornerRadius = UDim.new(0, 6)
cornerBtn.Parent = dropdownBtn

local dropList = Instance.new("ScrollingFrame")
dropList.Parent = contentContainer
dropList.Size = UDim2.new(0, 180, 0, 80)
dropList.Position = UDim2.new(0.5, -90, 0, 42)
dropList.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
dropList.BorderSizePixel = 0
dropList.Visible = false
dropList.ZIndex = 12
local cornerList = Instance.new("UICorner")
cornerList.CornerRadius = UDim.new(0, 6)
cornerList.Parent = dropList
dropList.CanvasSize = UDim2.new(0, 0, 0, 0)
dropList.ScrollBarThickness = 4

-- Hàng 1: Giam, Duy trì, Spectate
local cageBtn = Instance.new("TextButton")
cageBtn.Parent = contentContainer
cageBtn.Size = UDim2.new(0, 80, 0, 28)
cageBtn.Position = UDim2.new(0.5, -130, 0, 135)
cageBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
cageBtn.Text = "Giam"
cageBtn.TextColor3 = Color3.new(1, 1, 1)
cageBtn.Font = Enum.Font.GothamBold
cageBtn.TextSize = 13
cageBtn.BorderSizePixel = 0
cageBtn.ZIndex = 11
local cornerCage = Instance.new("UICorner")
cornerCage.CornerRadius = UDim.new(0, 6)
cornerCage.Parent = cageBtn

local maintainBtn = Instance.new("TextButton")
maintainBtn.Parent = contentContainer
maintainBtn.Size = UDim2.new(0, 80, 0, 28)
maintainBtn.Position = UDim2.new(0.5, -40, 0, 135)
maintainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
maintainBtn.Text = "Duy trì: OFF"
maintainBtn.TextColor3 = Color3.new(1, 1, 1)
maintainBtn.Font = Enum.Font.GothamBold
maintainBtn.TextSize = 13
maintainBtn.BorderSizePixel = 0
maintainBtn.ZIndex = 11
local cornerMaintain = Instance.new("UICorner")
cornerMaintain.CornerRadius = UDim.new(0, 6)
cornerMaintain.Parent = maintainBtn

local spectateBtn = Instance.new("TextButton")
spectateBtn.Parent = contentContainer
spectateBtn.Size = UDim2.new(0, 80, 0, 28)
spectateBtn.Position = UDim2.new(0.5, 50, 0, 135)
spectateBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
spectateBtn.Text = "Spectate"
spectateBtn.TextColor3 = Color3.new(1, 1, 1)
spectateBtn.Font = Enum.Font.GothamBold
spectateBtn.TextSize = 13
spectateBtn.BorderSizePixel = 0
spectateBtn.ZIndex = 11
local cornerSpectate = Instance.new("UICorner")
cornerSpectate.CornerRadius = UDim.new(0, 6)
cornerSpectate.Parent = spectateBtn

-- Hàng 2: Giam All, Tấn công
local cageAllBtn = Instance.new("TextButton")
cageAllBtn.Parent = contentContainer
cageAllBtn.Size = UDim2.new(0, 120, 0, 28)
cageAllBtn.Position = UDim2.new(0.5, -130, 0, 170)
cageAllBtn.BackgroundColor3 = Color3.fromRGB(200, 100, 0)
cageAllBtn.Text = "Giam Tất Cả"
cageAllBtn.TextColor3 = Color3.new(1, 1, 1)
cageAllBtn.Font = Enum.Font.GothamBold
cageAllBtn.TextSize = 12
cageAllBtn.BorderSizePixel = 0
cageAllBtn.ZIndex = 11
local cornerCageAll = Instance.new("UICorner")
cornerCageAll.CornerRadius = UDim.new(0, 6)
cornerCageAll.Parent = cageAllBtn

local attackBtn = Instance.new("TextButton")
attackBtn.Parent = contentContainer
attackBtn.Size = UDim2.new(0, 120, 0, 28)
attackBtn.Position = UDim2.new(0.5, 10, 0, 170)
attackBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 180)
attackBtn.Text = "Tấn công"
attackBtn.TextColor3 = Color3.new(1, 1, 1)
attackBtn.Font = Enum.Font.GothamBold
attackBtn.TextSize = 12
attackBtn.BorderSizePixel = 0
attackBtn.ZIndex = 11
local cornerAttack = Instance.new("UICorner")
cornerAttack.CornerRadius = UDim.new(0, 6)
cornerAttack.Parent = attackBtn

-- Status label
local statusLabel = Instance.new("TextLabel")
statusLabel.Parent = contentContainer
statusLabel.Size = UDim2.new(1, -20, 0, 20)
statusLabel.Position = UDim2.new(0, 10, 0, 210)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Chưa giam ai"
statusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextSize = 12
statusLabel.TextXAlignment = Enum.TextXAlignment.Center

-- Hàm cập nhật danh sách người chơi
local function updatePlayerList()
    for _, child in pairs(dropList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
    local count = 0
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, -4, 0, 25)
            btn.Position = UDim2.new(0, 2, 0, count * 25)
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            btn.Text = p.Name
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.Font = Enum.Font.GothamBold
            btn.TextSize = 13
            btn.BorderSizePixel = 0
            btn.ZIndex = 13
            btn.Parent = dropList
            local cornerItem = Instance.new("UICorner")
            cornerItem.CornerRadius = UDim.new(0, 4)
            cornerItem.Parent = btn
            btn.MouseButton1Click:Connect(function()
                selectedTarget = p
                dropdownBtn.Text = p.Name
                dropList.Visible = false
                statusLabel.Text = "Đã chọn: " .. p.Name
            end)
            count = count + 1
        end
    end
    dropList.CanvasSize = UDim2.new(0, 0, 0, count * 25)
end

dropdownBtn.MouseButton1Click:Connect(function()
    dropList.Visible = not dropList.Visible
    updatePlayerList()
end)

-- Đóng dropdown khi click ngoài
UIS.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = UIS:GetMouseLocation()
        local btnPos = dropdownBtn.AbsolutePosition
        local btnSize = dropdownBtn.AbsoluteSize
        local listPos = dropList.AbsolutePosition
        local listSize = dropList.AbsoluteSize
        if not (mousePos.X >= btnPos.X and mousePos.X <= btnPos.X + btnSize.X and mousePos.Y >= btnPos.Y and mousePos.Y <= btnPos.Y + btnSize.Y) and
           not (mousePos.X >= listPos.X and mousePos.X <= listPos.X + listSize.X and mousePos.Y >= listPos.Y and mousePos.Y <= listPos.Y + listSize.Y) then
            dropList.Visible = false
        end
    end
end)

Players.PlayerAdded:Connect(updatePlayerList)
Players.PlayerRemoving:Connect(updatePlayerList)

-- ===== CÁC HÀM CHÍNH =====

-- Lấy danh sách vật thể có thể di chuyển
local function getMovableObjects()
    local objects = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") 
            and obj.CanCollide 
            and obj.Anchored == false 
            and obj.Transparency < 0.5 
            and obj.Size.Magnitude > 12
            and obj.Size.Y > 3
        then
            local parent = obj.Parent
            if parent and not parent:FindFirstChildWhichIsA("Humanoid") then
                table.insert(objects, obj)
            end
        end
    end
    return objects
end

-- Chạm vật thể để lấy quyền sở hữu
local function touchObject(obj)
    if not obj or not obj.Parent then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local oldCF = root.CFrame
    root.CFrame = CFrame.new(obj.Position + Vector3.new(0, 0.5, 0))
    task.wait(0.1)
    root.CFrame = oldCF
end

-- Tạo lồng cho một người, trả về bảng vật thể
local function createCage(target)
    if not target or not target.Character then return nil end
    local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
    if not targetRoot then return nil end

    local objects = getMovableObjects()
    -- Lọc ra những vật thể chưa được dùng trong các lồng khác
    local usedObjects = {}
    for _, cage in pairs(cages) do
        for _, obj in pairs(cage.objects) do
            usedObjects[obj] = true
        end
    end
    local available = {}
    for _, obj in pairs(objects) do
        if not usedObjects[obj] then
            table.insert(available, obj)
        end
    end

    if #available < 8 then return nil end

    -- Sắp xếp theo khoảng cách đến mục tiêu
    local sorted = {}
    for _, obj in pairs(available) do
        local dist = (obj.Position - targetRoot.Position).Magnitude
        table.insert(sorted, {obj = obj, dist = dist})
    end
    table.sort(sorted, function(a,b) return a.dist < b.dist end)

    local chosen = {}
    for i = 1, 8 do
        table.insert(chosen, sorted[i].obj)
    end

    -- Xếp thành vòng tròn
    local angles = {}
    for i = 1, 8 do
        local angle = (i - 1) * (2 * math.pi / 8)
        table.insert(angles, angle)
    end
    local groundY = targetRoot.Position.Y - 2

    for i, obj in pairs(chosen) do
        touchObject(obj)
        task.wait(0.05)
        local x = targetRoot.Position.X + 3.5 * math.cos(angles[i])
        local z = targetRoot.Position.Z + 3.5 * math.sin(angles[i])
        local newPos = Vector3.new(x, groundY, z)
        obj.CFrame = CFrame.new(newPos)
        task.wait(0.05)
    end

    return chosen
end

-- Hàm giam một người (thêm vào bảng cages)
local function cagePlayer(target)
    if not target then return false end
    if cages[target.Name] then
        -- Đã bị giam, không làm gì
        return true
    end
    local objects = createCage(target)
    if not objects then return false end
    cages[target.Name] = {
        objects = objects,
        target = target,
        maintainLoop = nil
    }
    return true
end

-- Hàm giam tất cả
local function cageAll()
    local targets = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(targets, p)
        end
    end
    if #targets == 0 then
        game.StarterGui:SetCore("SendNotification", {Title = "Lỗi", Text = "Không có người chơi nào", Duration = 2})
        return
    end

    -- Kiểm tra đủ vật thể cho tất cả
    local totalObjects = #getMovableObjects()
    local maxCage = math.floor(totalObjects / 8)
    if maxCage < #targets then
        game.StarterGui:SetCore("SendNotification", {Title = "Cảnh báo", Text = "Chỉ đủ vật thể để giam " .. maxCage .. " người", Duration = 3})
    end

    local count = 0
    for _, p in pairs(targets) do
        if count >= maxCage then break end
        if not cages[p.Name] then
            local success = cagePlayer(p)
            if success then
                count = count + 1
                statusLabel.Text = "Đã giam: " .. p.Name
                task.wait(0.5)
            end
        end
    end
    game.StarterGui:SetCore("SendNotification", {Title = "Hoàn thành", Text = "Đã giam " .. count .. " người", Duration = 3})
end

-- Hàm tấn công: di chuyển các lồng đến vị trí người chơi khác
local function attackAll()
    if not next(cages) then
        game.StarterGui:SetCore("SendNotification", {Title = "Lỗi", Text = "Chưa có lồng nào để tấn công", Duration = 2})
        return
    end

    -- Lấy danh sách nạn nhân (người chơi khác, không phải người đang bị giam)
    local victims = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            -- Kiểm tra xem p có đang bị giam không
            local isCaged = cages[p.Name] ~= nil
            if not isCaged then
                table.insert(victims, p)
            end
        end
    end

    if #victims == 0 then
        game.StarterGui:SetCore("SendNotification", {Title = "Thông báo", Text = "Không có nạn nhân nào khả dụng", Duration = 2})
        return
    end

    -- Với mỗi lồng, di chuyển đến vị trí của từng nạn nhân
    for name, cageData in pairs(cages) do
        local targetRoot = cageData.target and cageData.target.Character and cageData.target.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then 
            -- Nếu mục tiêu đã chết hoặc mất, bỏ qua
            goto continue
        end
        for _, victim in pairs(victims) do
            local victimRoot = victim.Character:FindFirstChild("HumanoidRootPart")
            if victimRoot then
                -- Tính vector dịch chuyển từ mục tiêu đến victim
                local offset = victimRoot.Position - targetRoot.Position
                for _, obj in pairs(cageData.objects) do
                    if obj and obj.Parent then
                        local newPos = obj.Position + offset
                        obj.CFrame = CFrame.new(newPos)
                    end
                end
                -- Cập nhật vị trí của mục tiêu (để lần sau di chuyển tiếp)
                task.wait(0.1)
            end
        end
        ::continue::
    end
    game.StarterGui:SetCore("SendNotification", {Title = "Tấn công", Text = "Đã di chuyển lồng đến các nạn nhân", Duration = 2})
end

-- Hàm duy trì cho một người
local function toggleMaintain(target)
    if not target then return end
    local cageData = cages[target.Name]
    if not cageData then
        game.StarterGui:SetCore("SendNotification", {Title = "Lỗi", Text = "Người này chưa bị giam", Duration = 2})
        return
    end
    if cageData.maintainLoop then
        cageData.maintainLoop:Disconnect()
        cageData.maintainLoop = nil
        maintainBtn.Text = "Duy trì: OFF"
        maintainBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        statusLabel.Text = "Duy trì: TẮT"
        return
    end
    maintainBtn.Text = "Duy trì: ON"
    maintainBtn.BackgroundColor3 = Color3.fromRGB(60, 200, 60)
    statusLabel.Text = "Duy trì: BẬT cho " .. target.Name

    cageData.maintainLoop = RunService.Stepped:Connect(function()
        if not target.Character then return end
        local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
        if not targetRoot then return end
        local count = #cageData.objects
        local groundY = targetRoot.Position.Y - 2
        for i, obj in pairs(cageData.objects) do
            if obj and obj.Parent then
                local angle = (i - 1) * (2 * math.pi / count)
                local x = targetRoot.Position.X + 3.5 * math.cos(angle)
                local z = targetRoot.Position.Z + 3.5 * math.sin(angle)
                local newPos = Vector3.new(x, groundY, z)
                obj.CFrame = CFrame.new(newPos)
            end
        end
        task.wait(0.5)
    end)
end

-- ===== GÁN SỰ KIỆN =====
cageBtn.MouseButton1Click:Connect(function()
    if not selectedTarget then
        game.StarterGui:SetCore("SendNotification", {Title = "Lỗi", Text = "Chọn mục tiêu trước!", Duration = 2})
        return
    end
    if isCaging then return end
    isCaging = true
    local success = cagePlayer(selectedTarget)
    if success then
        statusLabel.Text = "Đã giam: " .. selectedTarget.Name
        game.StarterGui:SetCore("SendNotification", {Title = "Thành công", Text = "Đã giam " .. selectedTarget.Name, Duration = 2})
    else
        statusLabel.Text = "Giam thất bại"
        game.StarterGui:SetCore("SendNotification", {Title = "Thất bại", Text = "Không đủ đồ vật hoặc lỗi", Duration = 2})
    end
    isCaging = false
end)

cageAllBtn.MouseButton1Click:Connect(function()
    if isCaging then return end
    isCaging = true
    cageAll()
    isCaging = false
end)

attackBtn.MouseButton1Click:Connect(function()
    attackAll()
end)

maintainBtn.MouseButton1Click:Connect(function()
    if not selectedTarget then
        game.StarterGui:SetCore("SendNotification", {Title = "Lỗi", Text = "Chọn mục tiêu trước!", Duration = 2})
        return
    end
    toggleMaintain(selectedTarget)
end)

spectateBtn.MouseButton1Click:Connect(function()
    if not selectedTarget then
        game.StarterGui:SetCore("SendNotification", {Title = "Lỗi", Text = "Chọn mục tiêu trước", Duration = 2})
        return
    end
    isSpectating = not isSpectating
    if isSpectating then
        if selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            camera.CameraSubject = selectedTarget.Character.Humanoid
            spectateBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
            spectateBtn.Text = "Thôi"
            statusLabel.Text = "Đang xem: " .. selectedTarget.Name
        else
            isSpectating = false
            game.StarterGui:SetCore("SendNotification", {Title = "Lỗi", Text = "Mục tiêu không có nhân vật", Duration = 2})
        end
    else
        camera.CameraSubject = player.Character and player.Character:FindFirstChild("Humanoid") or nil
        spectateBtn.BackgroundColor3 = Color3.fromRGB(40, 100, 200)
        spectateBtn.Text = "Spectate"
        statusLabel.Text = "Đã dừng xem"
    end
end)

minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 200, 0, 35)
        contentContainer.Visible = false
        minimizeBtn.Text = "➕"
    else
        mainFrame.Size = UDim2.new(0, 280, 0, 290)
        contentContainer.Visible = true
        minimizeBtn.Text = "➖"
    end
end)

-- ===== KÉO THẢ (dùng RunService.RenderStepped) =====
local drag = false
local dragInput, dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        drag = false
        dragInput = nil
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

RunService.RenderStepped:Connect(function()
    if drag and dragInput then
        local delta = dragInput.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Khởi tạo
updatePlayerList()
game.StarterGui:SetCore("SendNotification", {Title = "Cage Tool", Text = "Đã sẵn sàng! Chọn mục tiêu hoặc 'Giam Tất Cả'.", Duration = 3})