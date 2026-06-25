local function StartMainScript()
    local RedzUiEngine = {}
    local openState = true
    local TweenService = game:GetService("TweenService")

    function RedzUiEngine:CreateWindow()
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        if not player then return end
        local playerGui = player:WaitForChild("PlayerGui")

        if playerGui:FindFirstChild("MinhChienDev") then
            playerGui:FindFirstChild("MinhChienDev"):Destroy()
        end

        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "MinhChienDev"
        ScreenGui.ResetOnSpawn = false
        ScreenGui.Parent = playerGui

        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainFrame"
        MainFrame.Size = UDim2.new(0, 540, 0, 360)
        MainFrame.Position = UDim2.new(0.5, -270, 0.5, -180)
        MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        MainFrame.BorderSizePixel = 0
        MainFrame.Active = true
        MainFrame.Draggable = true
        MainFrame.Parent = ScreenGui

        local MainCorner = Instance.new("UICorner")
        MainCorner.CornerRadius = UDim.new(0, 8)
        MainCorner.Parent = MainFrame

        local MainStroke = Instance.new("UIStroke")
        MainStroke.Color = Color3.fromRGB(255, 30, 60)
        MainStroke.Thickness = 1.5
        MainStroke.Parent = MainFrame

        local TopBar = Instance.new("Frame")
        TopBar.Name = "TopBar"
        TopBar.Size = UDim2.new(1, 0, 0, 35)
        TopBar.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        TopBar.BorderSizePixel = 0
        TopBar.Parent = MainFrame

        local TopCorner = Instance.new("UICorner")
        TopCorner.CornerRadius = UDim.new(0, 8)
        TopCorner.Parent = TopBar

        local Title = Instance.new("TextLabel")
        Title.Size = UDim2.new(0.7, 0, 1, 0)
        Title.Position = UDim2.new(0, 15, 0, 0)
        Title.BackgroundTransparency = 1
        Title.Text = "GOODLUCK HUB — GARDEN V4 (ACTIVATED)"
        Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        Title.TextSize = 14
        Title.Font = Enum.Font.GothamBold
        Title.TextXAlignment = Enum.TextXAlignment.Left
        Title.Parent = TopBar

        local CloseBtn = Instance.new("TextButton")
        CloseBtn.Size = UDim2.new(0, 30, 0, 25)
        CloseBtn.Position = UDim2.new(1, -40, 0.5, -12)
        CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 20, 20)
        CloseBtn.Text = "X"
        CloseBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
        CloseBtn.Font = Enum.Font.GothamBold
        CloseBtn.TextSize = 12
        CloseBtn.AutoButtonColor = false
        CloseBtn.Parent = TopBar

        local CloseCorner = Instance.new("UICorner")
        CloseCorner.CornerRadius = UDim.new(0, 5)
        CloseCorner.Parent = CloseBtn
        
        CloseBtn.MouseButton1Click:Connect(function()
            ScreenGui:Destroy()
        end)

        local SideBar = Instance.new("ScrollingFrame")
        SideBar.Name = "SideBar"
        SideBar.Size = UDim2.new(0, 130, 1, -45)
        SideBar.Position = UDim2.new(0, 5, 0, 40)
        SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
        SideBar.BorderSizePixel = 0
        SideBar.ScrollBarThickness = 2
        SideBar.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
        SideBar.Parent = MainFrame

        local SideLayout = Instance.new("UIListLayout")
        SideLayout.Padding = UDim.new(0, 4)
        SideLayout.Parent = SideBar

        local ContentContainer = Instance.new("Frame")
        ContentContainer.Name = "ContentContainer"
        ContentContainer.Size = UDim2.new(1, -145, 1, -45)
        ContentContainer.Position = UDim2.new(0, 140, 0, 40)
        ContentContainer.BackgroundTransparency = 1
        ContentContainer.Parent = MainFrame

        local MobileToggle = Instance.new("ImageButton")
        MobileToggle.Name = "MinhChienDev"
        MobileToggle.Size = UDim2.new(0, 50, 0, 50)
        MobileToggle.Position = UDim2.new(0, 10, 0, 80)
        MobileToggle.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        MobileToggle.Image = "rbxassetid://74840524656036"
        MobileToggle.ImageColor3 = Color3.fromRGB(255, 255, 255)
        MobileToggle.ScaleType = Enum.ScaleType.Stretch
        MobileToggle.Active = true
        MobileToggle.Draggable = true
        MobileToggle.Parent = ScreenGui

        local MobileCorner = Instance.new("UICorner")
        MobileCorner.CornerRadius = UDim.new(0, 25)
        MobileCorner.Parent = MobileToggle

        local MobileStroke = Instance.new("UIStroke")
        MobileStroke.Color = Color3.fromRGB(255, 30, 60)
        MobileStroke.Thickness = 2
        MobileStroke.Parent = MobileToggle

        MobileToggle.MouseButton1Click:Connect(function()
            openState = not openState
            MainFrame.Visible = openState
        end)

        local tabs = {}
        local firstTab = true

        function tabs:CreateTab(tabName)
            local TabPage = Instance.new("ScrollingFrame")
            TabPage.Name = tabName .. "Page"
            TabPage.Size = UDim2.new(1, 0, 1, 0)
            TabPage.BackgroundTransparency = 1
            TabPage.Visible = firstTab
            TabPage.ScrollBarThickness = 3
            TabPage.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
            TabPage.Parent = ContentContainer

            local PageLayout = Instance.new("UIListLayout")
            PageLayout.Padding = UDim.new(0, 6)
            PageLayout.Parent = TabPage

            local TabBtn = Instance.new("TextButton")
            TabBtn.Name = tabName .. "Btn"
            TabBtn.Size = UDim2.new(1, -5, 0, 32)
            TabBtn.BackgroundColor3 = firstTab and Color3.fromRGB(30, 15, 18) or Color3.fromRGB(22, 22, 22)
            TabBtn.Text = tabName
            TabBtn.TextColor3 = firstTab and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(180, 180, 180)
            TabBtn.Font = Enum.Font.GothamBold
            TabBtn.TextSize = 12
            TabBtn.Parent = SideBar

            local TabBtnCorner = Instance.new("UICorner")
            TabBtnCorner.CornerRadius = UDim.new(0, 5)
            TabBtnCorner.Parent = TabBtn

            local TabBtnStroke = Instance.new("UIStroke")
            TabBtnStroke.Color = firstTab and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(40, 40, 40)
            TabBtnStroke.Thickness = 1
            TabBtnStroke.Parent = TabBtn

            TabBtn.MouseButton1Click:Connect(function()
                for _, page in ipairs(ContentContainer:GetChildren()) do
                    if page:IsA("ScrollingFrame") then page.Visible = false end
                end
                for _, btn in ipairs(SideBar:GetChildren()) do
                    if btn:IsA("TextButton") then
                        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(22, 22, 22)}):Play()
                        btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                        local stroke = btn:FindFirstChildOfClass("UIStroke")
                        if stroke then stroke.Color = Color3.fromRGB(40, 40, 40) end
                    end
                end
                TabPage.Visible = true
                TweenService:Create(TabBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 15, 18)}):Play()
                TabBtn.TextColor3 = Color3.fromRGB(255, 30, 60)
                TabBtnStroke.Color = Color3.fromRGB(255, 30, 60)
            end)

            firstTab = false
            local elements = {}

            function elements:CreateSection(sectionText)
                local SecLabel = Instance.new("TextLabel")
                SecLabel.Size = UDim2.new(1, 0, 0, 20)
                SecLabel.BackgroundTransparency = 1
                SecLabel.Text = "—— " .. sectionText .. " ——"
                SecLabel.TextColor3 = Color3.fromRGB(255, 30, 60)
                SecLabel.Font = Enum.Font.GothamBold
                SecLabel.TextSize = 11
                SecLabel.Parent = TabPage
            end
            
            function elements:CreateButton(btnText, callback)
                local ActionBtn = Instance.new("TextButton")
                ActionBtn.Size = UDim2.new(1, -10, 0, 35)
                ActionBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                ActionBtn.Text = "  " .. btnText
                ActionBtn.TextColor3 = Color3.fromRGB(230, 230, 230)
                ActionBtn.Font = Enum.Font.GothamMedium
                ActionBtn.TextSize = 12
                ActionBtn.TextXAlignment = Enum.TextXAlignment.Left
                ActionBtn.AutoButtonColor = false
                ActionBtn.Parent = TabPage

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 5)
                BtnCorner.Parent = ActionBtn

                local BtnStroke = Instance.new("UIStroke")
                BtnStroke.Color = Color3.fromRGB(35, 35, 35)
                BtnStroke.Thickness = 1
                BtnStroke.Parent = ActionBtn

                ActionBtn.MouseButton1Down:Connect(function()
                    TweenService:Create(ActionBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 24, 26)}):Play()
                end)
                ActionBtn.MouseButton1Up:Connect(function()
                    TweenService:Create(ActionBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
                    pcall(callback)
                end)
                ActionBtn.MouseLeave:Connect(function()
                    TweenService:Create(ActionBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(24, 24, 24)}):Play()
                end)
            end

            function elements:CreateToggle(toggleText, defaultState, callback)
                local toggled = defaultState
                local ToggleFrame = Instance.new("TextButton")
                ToggleFrame.Size = UDim2.new(1, -10, 0, 38)
                ToggleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                ToggleFrame.Text = ""
                ToggleFrame.AutoButtonColor = false
                ToggleFrame.Parent = TabPage

                local TFCorner = Instance.new("UICorner")
                TFCorner.CornerRadius = UDim.new(0, 5)
                TFCorner.Parent = ToggleFrame

                local TFStroke = Instance.new("UIStroke")
                TFStroke.Color = Color3.fromRGB(35, 35, 35)
                TFStroke.Thickness = 1
                TFStroke.Parent = ToggleFrame

                local Txt = Instance.new("TextLabel")
                Txt.Size = UDim2.new(0.7, 0, 1, 0)
                Txt.Position = UDim2.new(0, 10, 0, 0)
                Txt.BackgroundTransparency = 1
                Txt.Text = toggleText
                Txt.TextColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
                Txt.Font = Enum.Font.GothamMedium
                Txt.TextSize = 12
                Txt.TextXAlignment = Enum.TextXAlignment.Left
                Txt.Parent = ToggleFrame

                local Switch = Instance.new("Frame")
                Switch.Size = UDim2.new(0, 34, 0, 18)
                Switch.Position = UDim2.new(1, -45, 0.5, -9)
                Switch.BackgroundColor3 = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(45, 45, 45)
                Switch.Parent = ToggleFrame

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(0, 9)
                SwitchCorner.Parent = Switch

                local Indicator = Instance.new("Frame")
                Indicator.Size = UDim2.new(0, 14, 0, 14)
                Indicator.Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
                Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Indicator.Parent = Switch

                local IndCorner = Instance.new("UICorner")
                IndCorner.CornerRadius = UDim.new(0, 7)
                IndCorner.Parent = Indicator

                local function updateToggle()
                    local tInfo = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    TweenService:Create(Txt, tInfo, {TextColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)}):Play()
                    TweenService:Create(Switch, tInfo, {BackgroundColor3 = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(45, 45, 45)}):Play()
                    TweenService:Create(Indicator, tInfo, {Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
                end

                ToggleFrame.MouseButton1Click:Connect(function()
                    toggled = not toggled
                    updateToggle()
                    pcall(callback, toggled)
                end)
            end

            return elements
        end
        return tabs
    end

    local Workspace = game:GetService("Workspace")
    local Lighting = game:GetService("Lighting")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VirtualUser = game:GetService("VirtualUser")
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local HttpService = game:GetService("HttpService")
    local currentThread = HttpService:GenerateGUID(false)

    _G.Goodluck = _G.Goodluck or {}
    _G.Goodluck.ThreadID = currentThread

    _G.Goodluck.AutoHarvest = false
    _G.Goodluck.AutoBuyPlant = false
    _G.Goodluck.AutoFarm = false
    _G.Goodluck.AutoCollectFruits = false
    _G.Goodluck.AutoSteal = false
    _G.Goodluck.AutoPet = false
    _G.Goodluck.AutoMythicSeed = false
    _G.Goodluck.AutoSuperSeed = false
    _G.Goodluck.AntiAFK = false

    local function getCharacter() return LocalPlayer.Character end
    local function getRootPart()
        local char = getCharacter()
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function teleportTo(cframe)
        local root = getRootPart()
        if root then
            root.CFrame = cframe
            task.wait(0.3)
        end
    end

    local function getWallet()
        local stats = LocalPlayer:FindFirstChild("leaderstats")
        if stats then
            local money = stats:FindFirstChild("Coins") or stats:FindFirstChild("Cash") or stats:FindFirstChild("Money")
            if money then return money.Value end
        end
        return 0
    end

    local function checkInventoryFull()
        local isFull = false
        pcall(function()
            local stats = LocalPlayer:FindFirstChild("leaderstats")
            if stats then
                local current, max
                for _, child in pairs(stats:GetChildren()) do
                    if child:IsA("IntValue") or child:IsA("NumberValue") then
                        local cName = string.lower(child.Name)
                        if cName == "maxinventory" or cName == "maxbag" or cName == "capacity" then
                            max = child.Value
                        elseif cName == "inventory" or cName == "bag" or cName == "fruits" then
                            current = child.Value
                        end
                    end
                end
                if current and max and max > 0 and current >= max then isFull = true end
            end
        end)
        return isFull
    end

    local function isNightTime() return Lighting.ClockTime >= 18 or Lighting.ClockTime <= 6 end

    local sellPartCache = nil
    local mythicShopPrompt = nil
    local superShopPrompt = nil
    local harvestPrompts = {}
    local plantPrompts = {}

    task.spawn(function()
        while true do
            if _G.Goodluck.ThreadID ~= currentThread then break end
            pcall(function()
                if not sellPartCache then
                    for _, obj in pairs(Workspace:GetDescendants()) do
                        if obj:IsA("BasePart") and string.find(string.lower(obj.Name), "sell") then
                            sellPartCache = obj
                            break
                        end
                    end
                end
                local tempHarvest = {}
                local tempPlant = {}
                for _, p in pairs(Workspace:GetDescendants()) do
                    if p:IsA("ProximityPrompt") then
                        local act = string.lower(tostring(p.ActionText))
                        local pName = p.Parent and string.lower(p.Parent.Name) or ""
                        if (string.find(act, "harvest") or string.find(act, "take") or string.find(act, "pick") or string.find(pName, "fruit") or string.find(pName, "crop")) and not string.find(act, "talk") then
                            if p.Parent:IsA("BasePart") then table.insert(tempHarvest, p) end
                        elseif string.find(act, "plant") or string.find(act, "sow") then
                            if p.Parent:IsA("BasePart") then table.insert(tempPlant, p) end
                        elseif string.find(pName, "mythic") and (string.find(act, "buy") or string.find(act, "seed") or string.find(act, "shop")) then
                            mythicShopPrompt = p
                        elseif string.find(pName, "super") and (string.find(act, "buy") or string.find(act, "seed") or string.find(act, "shop")) then
                            superShopPrompt = p
                        end
                    end
                end
                harvestPrompts = tempHarvest
                plantPrompts = tempPlant
            end)
            task.wait(1.5)
        end
    end)

    -- Threads Canh Tác
    task.spawn(function()
        while true do
            task.wait(0.3)
            if _G.Goodluck.ThreadID ~= currentThread then break end
            if not _G.Goodluck.AutoHarvest then continue end
            local root = getRootPart()
            if not root then continue end

            if checkInventoryFull() and sellPartCache then
                local savedPos = root.CFrame
                root.CFrame = sellPartCache.CFrame * CFrame.new(0, 3, 0)
                task.wait(0.8)
                pcall(function()
                    for _, p in pairs(Workspace:GetDescendants()) do
                        if p:IsA("ProximityPrompt") and (root.Position - p.Parent.Position).Magnitude < 25 then
                            fireproximityprompt(p)
                            break
                        end
                    end
                end)
                while checkInventoryFull() and _G.Goodluck.AutoHarvest and _G.Goodluck.ThreadID == currentThread do
                    task.wait(0.5)
                end
                root.CFrame = savedPos
                task.wait(0.5)
            else
                local acted = false
                if _G.Goodluck.AutoBuyPlant and #plantPrompts > 0 then
                    local wallet = getWallet()
                    local targetShop = nil
                    if wallet >= 10000 and mythicShopPrompt then targetShop = mythicShopPrompt
                    elseif wallet >= 5000 and superShopPrompt then targetShop = superShopPrompt end
                    if targetShop and targetShop.Parent then
                        root.CFrame = targetShop.Parent.CFrame * CFrame.new(0, 2, 0)
                        task.wait(0.3)
                        fireproximityprompt(targetShop)
                        task.wait(0.3)
                    end
                    local activePlot = plantPrompts[1]
                    if activePlot and activePlot.Parent and activePlot.Parent:IsA("BasePart") then
                        root.CFrame = activePlot.Parent.CFrame * CFrame.new(0, 2, 0)
                        task.wait(0.3)
                        fireproximityprompt(activePlot)
                        task.wait(0.1)
                        acted = true
                    end
                end
                if not acted then
                    for _, prompt in pairs(harvestPrompts) do
                        if not _G.Goodluck.AutoHarvest or checkInventoryFull() or _G.Goodluck.ThreadID ~= currentThread then break end
                        if #plantPrompts > 0 then break end
                        if prompt and prompt.Parent and prompt.Parent:IsA("BasePart") then
                            root.CFrame = prompt.Parent.CFrame * CFrame.new(0, 2, 0)
                            task.wait(0.3)
                            fireproximityprompt(prompt)
                            task.wait(0.1)
                        end
                    end
                end
            end
        end
    end)

    task.spawn(function()
        while true do
            task.wait(0.3)
            if _G.Goodluck.ThreadID ~= currentThread then break end
            if not _G.Goodluck.AutoFarm then continue end
            local root = getRootPart()
            if not root then continue end
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("ProximityPrompt") and _G.Goodluck.AutoFarm then
                    local namaParent = string.lower(v.Parent.Name)
                    if string.find(namaParent, "fruit") or string.find(namaParent, "harvest") or v.ObjectText == "Harvest" or v.ActionText == "Harvest" then
                        root.CFrame = v.Parent.CFrame * CFrame.new(0, 2, 0)
                        task.wait(0.2)
                        fireproximityprompt(v)
                        task.wait(0.1)
                    end
                end
            end
        end
    end)

    pcall(function()
        LocalPlayer.Idled:Connect(function()
            if _G.Goodluck.AntiAFK and _G.Goodluck.ThreadID == currentThread then
                VirtualUser:Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
                task.wait(0.2)
                VirtualUser:Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
            end
        end)
    end)

    local Tabs = RedzUiEngine:CreateWindow()
    local MainTab = Tabs:CreateTab("Canh Tác")
    local ShopTab = Tabs:CreateTab("Cửa Hàng")
    local ConfigTab = Tabs:CreateTab("Cấu Hình")

    MainTab:CreateSection("Hệ Thống Thu Hoạch Cây Trồng")
    MainTab:CreateToggle("Tự Động Thu Hoạch Nâng Cao", false, function(state) _G.Goodluck.AutoHarvest = state end)
    MainTab:CreateToggle("Tự Động Mua Kèm Hạt Khi Trồng", false, function(state) _G.Goodluck.AutoBuyPlant = state end)
    MainTab:CreateToggle("Auto Vòng Lặp Nông Trại", false, function(state) _G.Goodluck.AutoFarm = state end)

    MainTab:CreateSection("Hành Động Khác")
    MainTab:CreateToggle("Hút Trái Cây / Vật Phẩm Rơi", false, function(state) _G.Goodluck.AutoCollectFruits = state end)
    MainTab:CreateToggle("Chế Độ Trộm Đêm Auto", false, function(state) _G.Goodluck.AutoSteal = state end)

    ShopTab:CreateSection("Tự Động Mua Thú Cưng & Hạt")
    ShopTab:CreateToggle("Tự Động Mua Trứng Legendary (50k)", false, function(state) _G.Goodluck.AutoPet = state end)
    ShopTab:CreateToggle("Tự Động Mua Hạt Mythic (10k)", false, function(state) _G.Goodluck.AutoMythicSeed = state end)
    ShopTab:CreateToggle("Tự Động Mua Hạt Super (5k)", false, function(state) _G.Goodluck.AutoSuperSeed = state end)

    ConfigTab:CreateSection("Bảo Vệ & Hiệu Suất")
    ConfigTab:CreateToggle("Kích Hoạt Chống Treo Máy (Anti-AFK)", false, function(state) _G.Goodluck.AntiAFK = state end)

    ConfigTab:CreateButton("🔥 KÍCH HOẠT SIÊU FIX LAG (Max FPS)", function()
        pcall(function()
            local Past = {"Part", "MeshPart", "UnionOperation", "CornerWedgePart", "TrussPart"}
            for _, zx in next, Workspace:GetDescendants() do
                if table.find(Past, zx.ClassName) then zx.Material = Enum.Material.Plastic end
            end
            local decalsyeeted = true
            local g = game
            local w = g.Workspace
            local l = g.Lighting
            local t = w:FindFirstChildOfClass("Terrain")
            if t then
                t.WaterWaveSize = 0
                t.WaterWaveSpeed = 0
                t.WaterReflectance = 0
                t.WaterTransparency = 0
            end
            l.GlobalShadows = false
            l.FogEnd = 9e9
            l.Brightness = 0
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
            for _, v in pairs(g:GetDescendants()) do
                pcall(function()
                    if v:IsA("Part") or v:IsA("UnionOperation") or v:IsA("CornerWedgePart") or v:IsA("TrussPart") then
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                    elseif (v:IsA("Decal") or v:IsA("Texture")) and decalsyeeted then
                        v.Transparency = 1
                    elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                        v.Lifetime = NumberRange.new(0)
                    elseif v:IsA("Explosion") then
                        v.BlastPressure = 1
                        v.BlastRadius = 1
                    elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") or v:IsA("Sparkles") then
                        v.Enabled = false
                    elseif v:IsA("MeshPart") then
                        v.Material = Enum.Material.Plastic
                        v.Reflectance = 0
                        v.TextureID = "rbxassetid://10385902758728957"
                    end
                end)
            end
            for _, e in pairs(l:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect") or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect") or e:IsA("DepthOfFieldEffect") then
                    e.Enabled = false
                end
            end
        end)
    end)
end

-- =============================================================================
-- [ PHẦN 2 ] LOADER & KEY SYSTEM BẢO MẬT (MINHCHIEN SCRIPT V13)
-- =============================================================================
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 🔴 CẤU HÌNH ĐƯỜNG DẪN VPS CỦA BẠN
local VPS_URL = "http://usa6.kerit.cloud:9221/api/key/verify" --[cite: 3]

-- Lấy HWID
local myHWID = "UNKNOWN-HWID"
if gethwid then
    myHWID = gethwid() --[cite: 3]
else
    pcall(function()
        if not isfile("mc_hwid_backup.txt") then
            writefile("mc_hwid_backup.txt", tostring(math.random(100000, 999999)) .. "-" .. tostring(LocalPlayer.UserId)) --[cite: 3]
        end
        myHWID = readfile("mc_hwid_backup.txt") --[cite: 3]
    end)
end

-- Hàm xác thực với VPS
local function verifyKeyFromServer(userKey)
    local requestFunction = syn and syn.request or http and http.request or fluxus and fluxus.request or request --[cite: 3]
    
    if not requestFunction then
        LocalPlayer:Kick("Executor của bạn không hỗ trợ Http Request bảo mật!") --[cite: 3]
        return
    end

    local success, response = pcall(function()
        return requestFunction({
            Url = VPS_URL, --[cite: 3]
            Method = "POST", --[cite: 3]
            Headers = { ["Content-Type"] = "application/json" }, --[cite: 3]
            Body = HttpService:JSONEncode({ key = userKey, hwid = myHWID }) --[cite: 3]
        })
    end)

    if success and response.StatusCode == 200 then
        local data = HttpService:JSONDecode(response.Body)
        if data.success then
            print("====================================")
            print("[SERVER NOTIFICATION]: " .. tostring(data.notification))
            print("====================================")
            
            -- LƯU Ý: Nếu thành công, gọi Main Script thay vì load từ server như cũ.
            writefile("MinhChien_SavedKey.txt", userKey) --[cite: 3]
            StartMainScript()
        else
            LocalPlayer:Kick("Xác thực thất bại: " .. tostring(data.message)) --[cite: 3]
        end
    elseif response and response.StatusCode == 403 then
        local data = HttpService:JSONDecode(response.Body)
        LocalPlayer:Kick("Bị từ chối: " .. tostring(data.message)) --[cite: 3]
    else
        LocalPlayer:Kick("Không thể kết nối tới Server quản lý của Minh Chien!") --[cite: 3]
    end
end

-- Tạo Giao Diện Nhập Key
local function createKeyUI()
    if isfile("MinhChien_SavedKey.txt") then
        local saved = readfile("MinhChien_SavedKey.txt") --[cite: 3]
        if saved and saved ~= "" then
            verifyKeyFromServer(saved) --[cite: 3]
            return
        end
    end

    local ScreenGui = Instance.new("ScreenGui", Players.LocalPlayer:WaitForChild("PlayerGui"))
    ScreenGui.Name = "MinhChienLoader"
    
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 320, 0, 160)
    Frame.Position = UDim2.new(0.5, -160, 0.5, -80)
    Frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    
    local Corner = Instance.new("UICorner", Frame)
    Corner.CornerRadius = UDim.new(0, 8)
    
    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Color = Color3.fromRGB(255, 30, 60)
    Stroke.Thickness = 1.5
    
    local Title = Instance.new("TextLabel", Frame)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "MINHCHIEN SCRIPT V13 — KEY SYSTEM" --[cite: 3]
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.Font = Enum.Font.GothamBold
    Title.TextSize = 12
    Title.BackgroundTransparency = 1

    local TextBox = Instance.new("TextBox", Frame)
    TextBox.Size = UDim2.new(0.9, 0, 0, 35)
    TextBox.Position = UDim2.new(0.05, 0, 0.3, 0)
    TextBox.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    TextBox.Text = ""
    TextBox.PlaceholderText = "Dán mã Key của bạn vào đây..."
    TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextBox.Font = Enum.Font.GothamMedium
    TextBox.TextSize = 12
    Instance.new("UICorner", TextBox).CornerRadius = UDim.new(0, 5)

    local SubmitBtn = Instance.new("TextButton", Frame)
    SubmitBtn.Size = UDim2.new(0.4, 0, 0, 35)
    SubmitBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
    SubmitBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 18)
    SubmitBtn.Text = "KÍCH HOẠT" --[cite: 3]
    SubmitBtn.TextColor3 = Color3.fromRGB(255, 30, 60)
    SubmitBtn.Font = Enum.Font.GothamBold
    SubmitBtn.TextSize = 12
    Instance.new("UICorner", SubmitBtn).CornerRadius = UDim.new(0, 5)

    local GetKeyBtn = Instance.new("TextButton", Frame)
    GetKeyBtn.Size = UDim2.new(0.4, 0, 0, 35)
    GetKeyBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
    GetKeyBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    GetKeyBtn.Text = "LẤY KEY (24H)" --[cite: 3]
    GetKeyBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
    GetKeyBtn.Font = Enum.Font.GothamBold
    GetKeyBtn.TextSize = 12
    Instance.new("UICorner", GetKeyBtn).CornerRadius = UDim.new(0, 5)

    SubmitBtn.MouseButton1Click:Connect(function()
        local inputKey = TextBox.Text:gsub("%s+", "")
        if inputKey ~= "" then
            ScreenGui:Destroy()
            verifyKeyFromServer(inputKey) --[cite: 3]
        end
    end)

    GetKeyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard("http://usa6.kerit.cloud:9221/api/key/generate") --
            TextBox.PlaceholderText = "Đã copy link Get Key vào bộ nhớ tạm!" --
        else
            TextBox.Text = "http://usa6.kerit.cloud:9221/api/key/generate" --[cite: 3]
        end
    end)
end

-- Gọi hàm tạo giao diện ở cuối file
createKeyUI()