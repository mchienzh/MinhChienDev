-- =============== COMPATIBILITY LAYER ===============
-- Fix: replace all executor-specific _GENV calls with a plain local table.
-- This makes the script run on any executor (Delta, Fluxus, Arceus X, etc.)
local _GENV = {
    _G = {},
    SelectedFriend = ""
}
-- Fallbacks for other executor-specific functions
if typeof(newcclosure) ~= "function" then
    newcclosure = function(f) return f end
end
if typeof(checkcaller) ~= "function" then
    checkcaller = function() return false end
end
-- ====================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalPlayer = Players.LocalPlayer

-- Khai báo cấu hình toàn cục
_GENV._G.AutoDooHee = false
_GENV._G.TweenMGear = false
_GENV._G.KillAura = false          -- Bật/tắt Kill Aura (cả quái và người)
_GENV._G.AutoKillV4 = false
_GENV._G.AutoQuestRace = false
_GENV._G.AutoHopFullMoon = false
_GENV._G.SelectWeapon = nil
_GENV._G.FriendsList = {}          -- Danh sách bạn bè để ngoại trừ (Whitelist)
_GENV.SelectedFriend = ""

local Pos = CFrame.new(0, 40, 0)
local ATTACK_DELAY = 0.01 -- Tốc độ mô phỏng giữ nút liên tục

--- ========================================================
--- HỆ THỐNG BYPASS ANTI-CHEAT
--- ========================================================

pcall(function()
    if typeof(getrawmetatable) == "function" then
        local gmt = getrawmetatable(game)
        setreadonly(gmt, false)
        local oldNamecall = gmt.__namecall

        gmt.__namecall = newcclosure(function(self, ...)
            local method = getnamecallmethod()
            if method == "Kick" or method == "kick" then
                return nil
            end
            return oldNamecall(self, ...)
        end)
        setreadonly(gmt, true)
    end
end)

local SpoofActive = true
pcall(function()
    if typeof(hookmetamethod) == "function" then
        local oldIndex
        oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            if SpoofActive and not checkcaller() and self:IsA("Humanoid")
                and LocalPlayer.Character and self:IsDescendantOf(LocalPlayer.Character) then
                if key == "WalkSpeed" then return 16 end
                if key == "PlatformStand" then return false end
                if key == "HipHeight" then return 0 end
            end
            return oldIndex(self, key)
        end))
    end
end)

local function AutoNukeAntiCheat()
    pcall(function()
        if typeof(getconnections) == "function" then
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local hum = char:WaitForChild("Humanoid", 5) or char:FindFirstChildOfClass("Humanoid")
            if hum then
                local signals = {"Changed", "GetPropertyChangedSignal"}
                for _, sigName in pairs(signals) do
                    local signal = (sigName == "Changed") and hum.Changed or hum:GetPropertyChangedSignal("WalkSpeed")
                    for _, connection in pairs(getconnections(signal)) do
                        connection:Disable()
                    end
                end
            end
        end
    end)
end

task.spawn(AutoNukeAntiCheat)
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    AutoNukeAntiCheat()
end)

local function SendNotification(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {Title = title, Text = text, Duration = duration or 4})
    end)
end

--- ========================================================
--- HÀM GÂY SÁT THƯƠNG QUA REMOTE
--- ========================================================
local function FireAttackRemote(targetEnemy)
    pcall(function()
        if targetEnemy and targetEnemy:FindFirstChild("HumanoidRootPart") then
            local argsHit = {
                targetEnemy:WaitForChild("HumanoidRootPart"),
                {},
                [4] = "560b7197"
            }
            game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterHit"):FireServer(unpack(argsHit))

            local argsAttack = { 0.4000000059604645 }
            game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RE/RegisterAttack"):FireServer(unpack(argsAttack))
        end
    end)
end

--- ========================================================
--- HỆ THỐNG DI CHUYỂN (TELEPORT & TWEEN KÈM KHÓA CFRAME)
--- ========================================================
local function SafeMove(targetCFrame)
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then return end

        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end

        local dist = (root.Position - targetCFrame.Position).Magnitude

        if dist < 1000 then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            root.CFrame = targetCFrame
            task.wait(0.05)
            hum:ChangeState(Enum.HumanoidStateType.Running)
        else
            local speed = 300 
            local tweenTime = dist / speed
            if tweenTime < 0.1 then tweenTime = 0.1 end 
            
            local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
            local tween = TweenService:Create(root, tweenInfo, {CFrame = targetCFrame})
            
            local bv = root:FindFirstChild("SafeMove_BV") or Instance.new("BodyVelocity")
            bv.Name = "SafeMove_BV"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = (targetCFrame.Position - root.Position).Unit * speed
            bv.Parent = root
            
            local bg = root:FindFirstChild("SafeMove_BG") or Instance.new("BodyGyro")
            bg.Name = "SafeMove_BG"
            bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            bg.CFrame = targetCFrame
            bg.Parent = root
            
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            tween:Play()
            
            local connection = RunService.Stepped:Connect(function()
                if root and bv then
                    bv.Velocity = (targetCFrame.Position - root.Position).Unit * speed
                end
            end)
            
            tween.Completed:Wait()
            
            if connection then connection:Disconnect() end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
            
            hum:ChangeState(Enum.HumanoidStateType.Running)
        end
    end)
end

--- ========================================================
--- HỆ THỐNG HOP SERVER (DÙNG API KATABUMP + REMOTE TELEPORT)
--- ========================================================
local API_URL = "http://193.70.34.27:20351/get-server"

local function HopToFullMoonServer()
    SendNotification("🌕 Hop API", "Đang gọi API lấy server Full Moon...", 3)
    print("[🌕] Gọi API Full Moon...")

    local success, response = pcall(function()
        return game:HttpGet(API_URL)
    end)

    if not success or not response then
        SendNotification("❌ Lỗi API", "Không kết nối được tới server", 3)
        print("[❌] Không kết nối được API.")
        return false
    end

    local successDecode, data = pcall(function()
        return HttpService:JSONDecode(response)
    end)

    if not successDecode then
        SendNotification("⚠️ Lỗi JSON", "Dữ liệu API không hợp lệ", 3)
        print("[⚠️] JSON decode thất bại.")
        return false
    end

    if data.jobId then
        print("[🎯] Nhận được JobId: " .. data.jobId)
        SendNotification("✅ Tìm thấy Full Moon", "JobId: " .. data.jobId, 5)
        task.wait(1.5)

        pcall(function()
            ReplicatedStorage.__ServerBrowser:InvokeServer("teleport", data.jobId)
        end)
        return true
    else
        local errMsg = data.error or "Không có jobId"
        print("[📡] API trả về: " .. errMsg)
        SendNotification("🔍 Không có server", errMsg, 3)
        return false
    end
end

local function getPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player.Name ~= LocalPlayer.Name then
            table.insert(names, player.Name)
        end
    end
    return names
end

local function AutoHaki()
    pcall(function()
        if not LocalPlayer.Character:FindFirstChild("HasBuso") then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end
    end)
end

local function EquipWeapon(weaponName)
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local character = LocalPlayer.Character
        if backpack and character then
            if weaponName and backpack:FindFirstChild(weaponName) then
                backpack[weaponName].Parent = character
            elseif not character:FindFirstChildOfClass("Tool") then
                local tool = backpack:FindFirstChildOfClass("Tool")
                if tool then tool.Parent = character end
            end
        end
    end)
end

local function EquipByToolTip(toolTipType)
    pcall(function()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        local character = LocalPlayer.Character
        if backpack and character then
            for _, tool in pairs(backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.ToolTip == toolTipType then
                    character.Humanoid:EquipTool(tool)
                    break
                end
            end
        end
    end)
end

--- ========================================================
--- KHỐI ENGINE UI CHẠY TRỰC TIẾP TRONG SCRIPT
--- ========================================================
local RedzUiEngine = {}
local openState = true

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
    Title.Text = "MINHCHIEN HUB"
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
                    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
                    btn.TextColor3 = Color3.fromRGB(180, 180, 180)
                    local stroke = btn:FindFirstChildOfClass("UIStroke")
                    if stroke then stroke.Color = Color3.fromRGB(40, 40, 40) end
                end
            end
            TabPage.Visible = true
            TabBtn.BackgroundColor3 = Color3.fromRGB(30, 15, 18)
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
            ActionBtn.Parent = TabPage

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 5)
            BtnCorner.Parent = ActionBtn

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Color3.fromRGB(35, 35, 35)
            BtnStroke.Thickness = 1
            BtnStroke.Parent = ActionBtn

            ActionBtn.MouseButton1Click:Connect(function()
                ActionBtn.BackgroundColor3 = Color3.fromRGB(40, 24, 26)
                task.wait(0.1)
                ActionBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                pcall(callback)
            end)
        end

        function elements:CreateToggle(toggleText, defaultState, callback)
            local toggled = defaultState

            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Size = UDim2.new(1, -10, 0, 38)
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            ToggleFrame.Text = ""
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
                Txt.TextColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 170)
                Switch.BackgroundColor3 = toggled and Color3.fromRGB(255, 30, 60) or Color3.fromRGB(45, 45, 45)
                Indicator.Position = toggled and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            end

            ToggleFrame.MouseButton1Click:Connect(function()
                toggled = not toggled
                updateToggle()
                pcall(callback, toggled)
            end)
        end

        function elements:CreateInput(inputText, placeholder, callback)
            local InputFrame = Instance.new("Frame")
            InputFrame.Size = UDim2.new(1, -10, 0, 42)
            InputFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            InputFrame.Parent = TabPage

            local IFCorner = Instance.new("UICorner")
            IFCorner.CornerRadius = UDim.new(0, 5)
            IFCorner.Parent = InputFrame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.5, 0, 1, 0)
            Label.Position = UDim2.new(0, 10, 0, 0)
            Label.BackgroundTransparency = 1
            Label.Text = inputText
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = InputFrame

            local TextBox = Instance.new("TextBox")
            TextBox.Size = UDim2.new(0.45, 0, 0, 26)
            TextBox.Position = UDim2.new(1, -155, 0.5, -13)
            TextBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            TextBox.Text = ""
            TextBox.PlaceholderText = placeholder
            TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
            TextBox.PlaceholderColor3 = Color3.fromRGB(80, 80, 80)
            TextBox.Font = Enum.Font.Gotham
            TextBox.TextSize = 11
            TextBox.ClipsDescendants = true
            TextBox.Parent = InputFrame

            local TBCorner = Instance.new("UICorner")
            TBCorner.CornerRadius = UDim.new(0, 4)
            TBCorner.Parent = TextBox

            local TBStroke = Instance.new("UIStroke")
            TBStroke.Color = Color3.fromRGB(255, 30, 60)
            TBStroke.Thickness = 0.8
            TBStroke.Parent = TextBox

            TextBox.FocusLost:Connect(function()
                pcall(callback, TextBox.Text)
            end)
        end

        function elements:CreateDropdown(dropText, listData, callback)
            local expanded = false

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, -10, 0, 38)
            DropFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            DropFrame.ClipsDescendants = true
            DropFrame.Parent = TabPage

            local DFCorner = Instance.new("UICorner")
            DFCorner.CornerRadius = UDim.new(0, 5)
            DFCorner.Parent = DropFrame

            local MainBtn = Instance.new("TextButton")
            MainBtn.Size = UDim2.new(1, 0, 0, 38)
            MainBtn.BackgroundTransparency = 1
            MainBtn.Text = "  " .. dropText .. " : " .. tostring(listData[1] or "None")
            MainBtn.TextColor3 = Color3.fromRGB(255, 30, 60)
            MainBtn.Font = Enum.Font.GothamBold
            MainBtn.TextSize = 12
            MainBtn.TextXAlignment = Enum.TextXAlignment.Left
            MainBtn.Parent = DropFrame

            local ItemsScroll = Instance.new("ScrollingFrame")
            ItemsScroll.Size = UDim2.new(1, -10, 0, 100)
            ItemsScroll.Position = UDim2.new(0, 5, 0, 40)
            ItemsScroll.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
            ItemsScroll.BorderSizePixel = 0
            ItemsScroll.ScrollBarThickness = 2
            ItemsScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 30, 60)
            ItemsScroll.Parent = DropFrame

            local ScrollLayout = Instance.new("UIListLayout")
            ScrollLayout.Padding = UDim.new(0, 2)
            ScrollLayout.Parent = ItemsScroll

            local function buildList(currentData)
                for _, oldBtn in ipairs(ItemsScroll:GetChildren()) do
                    if oldBtn:IsA("TextButton") then oldBtn:Destroy() end
                end
                for _, itemValue in ipairs(currentData) do
                    local ItemBtn = Instance.new("TextButton")
                    ItemBtn.Size = UDim2.new(1, 0, 0, 25)
                    ItemBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
                    ItemBtn.Text = tostring(itemValue)
                    ItemBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    ItemBtn.Font = Enum.Font.Gotham
                    ItemBtn.TextSize = 11
                    ItemBtn.Parent = ItemsScroll

                    ItemBtn.MouseButton1Click:Connect(function()
                        MainBtn.Text = "  " .. dropText .. " : " .. tostring(itemValue)
                        expanded = false
                        DropFrame.Size = UDim2.new(1, -10, 0, 38)
                        pcall(callback, itemValue)
                    end)
                end
            end

            buildList(listData)

            MainBtn.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    DropFrame.Size = UDim2.new(1, -10, 0, 145)
                else
                    DropFrame.Size = UDim2.new(1, -10, 0, 38)
                end
            end)

            local dropControls = {}
            function dropControls:Refresh(newData)
                buildList(newData)
                MainBtn.Text = "  " .. dropText .. " : " .. tostring(newData[1] or "None")
            end
            return dropControls
        end

        function elements:CreateSlider(sliderText, min, max, default, callback)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, -10, 0, 45)
            SliderFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            SliderFrame.Parent = TabPage

            local SFCorner = Instance.new("UICorner")
            SFCorner.CornerRadius = UDim.new(0, 5)
            SFCorner.Parent = SliderFrame

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 0, 20)
            Label.Position = UDim2.new(0, 10, 0, 2)
            Label.BackgroundTransparency = 1
            Label.Text = sliderText
            Label.TextColor3 = Color3.fromRGB(200, 200, 200)
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = SliderFrame

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0.3, 0, 0, 20)
            ValLabel.Position = UDim2.new(1, -110, 0, 2)
            ValLabel.BackgroundTransparency = 1
            ValLabel.Text = tostring(default)
            ValLabel.TextColor3 = Color3.fromRGB(255, 30, 60)
            ValLabel.Font = Enum.Font.GothamBold
            ValLabel.TextSize = 12
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.Parent = SliderFrame

            local SliderBar = Instance.new("TextButton")
            SliderBar.Size = UDim2.new(1, -20, 0, 6)
            SliderBar.Position = UDim2.new(0, 10, 0, 28)
            SliderBar.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            SliderBar.Text = ""
            SliderBar.Parent = SliderFrame

            local SBCorner = Instance.new("UICorner")
            SBCorner.CornerRadius = UDim.new(0, 3)
            SBCorner.Parent = SliderBar

            local Fill = Instance.new("Frame")
            local initPercent = (default - min) / (max - min)
            Fill.Size = UDim2.new(initPercent, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 30, 60)
            Fill.Parent = SliderBar

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(0, 3)
            FillCorner.Parent = Fill

            local uis = game:GetService("UserInputService")
            local holding = false

            local function updateSliderInput(input)
                local pos = math.clamp((input.Position.X - SliderBar.AbsolutePosition.X) / SliderBar.AbsoluteSize.X, 0, 1)
                Fill.Size = UDim2.new(pos, 0, 1, 0)
                local finalVal = math.floor(min + (max - min) * pos)
                ValLabel.Text = tostring(finalVal)
                pcall(callback, finalVal)
            end

            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    holding = true
                    updateSliderInput(input)
                end
            end)

            uis.InputChanged:Connect(function(input)
                if holding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateSliderInput(input)
                end
            end)

            uis.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    holding = false
                end
            end)
        end

        return elements
    end

    return tabs
end

--- ========================================================
--- KHỞI TẠO UI VÀ ĐĂNG KÝ CÁC PHẦN TỬ CHỨC NĂNG
--- ========================================================

-- Thử tạo UI, nếu thất bại thì thử lại sau 2s (tránh crash nếu PlayerGui chưa load)
local vu616, TabMain
for attempt = 1, 3 do
    local ok = pcall(function()
        vu616 = RedzUiEngine:CreateWindow()
        TabMain = vu616:CreateTab("Chức Năng Chính")
    end)
    if ok and vu616 and TabMain then break end
    task.wait(2)
end
if not TabMain then
    -- UI không load được - các vòng lặp nền vẫn hoạt động bình thường
    warn("[MinhChienHub] UI không thể khởi tạo.")
    TabMain = setmetatable({}, {__index = function() return function() end end})
end

local friendDropdown = TabMain:CreateDropdown("Chọn Player để Whitelist", getPlayerNames(), function(selected)
    _GENV.SelectedFriend = selected
end)

TabMain:CreateButton("Thêm Player đã chọn vào Whitelist", function()
    if _GENV.SelectedFriend and _GENV.SelectedFriend ~= "" then
        if not table.find(_GENV._G.FriendsList, _GENV.SelectedFriend) then
            table.insert(_GENV._G.FriendsList, _GENV.SelectedFriend)
            SendNotification("Whitelist", "Đã chừa ra: " .. _GENV.SelectedFriend, 3)
        else
            SendNotification("Thông báo", "Player này đã được thêm từ trước", 2)
        end
    else
        SendNotification("Lỗi", "Vui lòng chọn 1 tên trong Dropdown trước", 2)
    end
end)

TabMain:CreateButton("Làm mới danh sách Player", function()
    friendDropdown:Refresh(getPlayerNames())
    SendNotification("Hệ thống", "Đã cập nhật lại danh sách người chơi mới", 2)
end)

TabMain:CreateToggle("Auto Hop Full Moon", _GENV._G.AutoHopFullMoon, function(bool)
    _GENV._G.AutoHopFullMoon = bool
end)

TabMain:CreateButton("Check Full Moon Hiện Tại", function()
    pcall(function()
        local sky = game:GetService("Lighting"):FindFirstChildOfClass("Sky")
        if sky then
            local moonId = tostring(sky.MoonTextureId)
            if string.find(moonId, "9709149431") then
                SendNotification("✅ Check", "ĐANG CÓ TRĂNG TRÒN!", 5)
            else
                SendNotification("❌ Check", "CHƯA CÓ trăng tròn.", 5)
            end
        else
            SendNotification("❌ Check", "Không tìm thấy Sky.", 5)
        end
    end)
end)

TabMain:CreateToggle("Look Moon + V3", _GENV._G.AutoDooHee, function(bool)
    _GENV._G.AutoDooHee = bool
end)

TabMain:CreateToggle("Auto Tween To Gear", _GENV._G.TweenMGear, function(bool)
    _GENV._G.TweenMGear = bool
end)

TabMain:CreateToggle("Kill Aura", _GENV._G.KillAura, function(bool)
    _GENV._G.KillAura = bool
end)

TabMain:CreateToggle("Auto Kill Player Trial", _GENV._G.AutoKillV4, function(bool)
    _GENV._G.AutoKillV4 = bool
end)

TabMain:CreateToggle("Auto Trial All Race", _GENV._G.AutoQuestRace, function(bool)
    _GENV._G.AutoQuestRace = bool
end)

TabMain:CreateButton("Teleport To Top GreatTree", function()
    pcall(function() SafeMove(CFrame.new(3030.39453125, 2280.6171875, -7320.18359375)) end)
end)

TabMain:CreateButton("Teleport Lever Pull", function()
    pcall(function() SafeMove(CFrame.new(28575.181640625, 14936.6279296875, 72.31636810302734)) end)
end)

TabMain:CreateButton("Teleport Temple Of Time", function()
    pcall(function() SafeMove(CFrame.new(28286.35546875, 14895.3017578125, 102.62469482421875)) end)
end)

TabMain:CreateButton("Buy Ancient One Quest", function()
    pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Buy") end)
end)

TabMain:CreateButton("Auto Race Door", function()
    pcall(function()
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then
            SafeMove(CFrame.new(28286.35546875, 14895.3017578125, 102.62469482421875))
            task.wait(1.5)
            local raceValue = LocalPlayer.Data.Race.Value
            if raceValue == "Human" then
                SafeMove(CFrame.new(29221.822265625, 14890.9755859375, -205.99114990234375))
            elseif raceValue == "Skypiea" then
                SafeMove(CFrame.new(28960.158203125, 14919.6240234375, 235.03948974609375))
            elseif raceValue == "Fishman" then
                SafeMove(CFrame.new(28231.17578125, 14890.9755859375, -211.64173889160156))
            elseif raceValue == "Cyborg" then
                SafeMove(CFrame.new(28502.681640625, 14895.9755859375, -423.7279357910156))
            elseif raceValue == "Ghoul" then
                SafeMove(CFrame.new(28674.244140625, 14890.6767578125, 445.4310607910156))
            elseif raceValue == "Mink" then
                SafeMove(CFrame.new(29012.341796875, 14890.9755859375, -380.1492614746094))
            end
        end
    end)
end)

--- ========================================================
--- CÁC VÒNG LẶP XỬ LÝ NỀN (LOOPS THREADS)
--- ========================================================

-- Luồng Auto Hop Full Moon (Chỉ dùng duy nhất API chính)
task.spawn(function()
    local shouldStop = false
    while not shouldStop do
        task.wait(2)
        if _GENV._G.AutoHopFullMoon then
            pcall(function()
                local sky = game:GetService("Lighting"):FindFirstChildOfClass("Sky")
                if sky then
                    task.wait(2)
                    local moonId = tostring(sky.MoonTextureId)
                    if string.find(moonId, "9709149431") then
                        _GENV._G.AutoHopFullMoon = false
                        SendNotification("✅ THÀNH CÔNG", "Server này ĐANG CÓ TRĂNG TRÒN!", 10)
                    else
                        SendNotification("🔍 Tìm kiếm", "Chưa có trăng, gọi API Hop...", 3)
                        local teleported = HopToFullMoonServer()
                        if teleported then
                            _GENV._G.AutoHopFullMoon = false
                            shouldStop = true  -- Thay thế break bất hợp lệ trong pcall
                        else
                            task.wait(12)
                        end
                    end
                end
            end)
        end
    end
end)

-- Luồng Look Moon + TỰ ĐỘNG BẬT TỘC V3
task.spawn(function()
    while true do
        task.wait(0.5)
        pcall(function()
            if _GENV._G.AutoDooHee and LocalPlayer.Character then
                local moonDir = game.Lighting:GetMoonDirection()
                local targetPos = game.Workspace.CurrentCamera.CFrame.p + moonDir * 100
                game.Workspace.CurrentCamera.CFrame = CFrame.lookAt(game.Workspace.CurrentCamera.CFrame.p, targetPos)
                local args = { "ActivateAbility" }
                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommE"):FireServer(unpack(args))
            end
        end)
    end
end)

-- Luồng Tween Mystic Island Gear
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            if _GENV._G.TweenMGear and game:GetService("Workspace").Map:FindFirstChild("MysticIsland") then
                for _, object in pairs(game:GetService("Workspace").Map.MysticIsland:GetChildren()) do
                    if object:IsA("MeshPart") and object.Material == Enum.Material.Neon then
                        SafeMove(object.CFrame)
                        task.wait(0.5)
                    end
                end
            end
        end)
    end
end)

-- Luồng Kill Aura (PvE + PvP có lọc bạn bè)
task.spawn(function()
    while task.wait(ATTACK_DELAY) do
        pcall(function()
            if _GENV._G.KillAura then
                local character = LocalPlayer.Character
                local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                local tool = character and character:FindFirstChildOfClass("Tool")
                if rootPart and tool then
                    local closestTarget = nil
                    local closestDist = 65

                    local enemiesFolder = game:GetService("Workspace"):FindFirstChild("Enemies")
                    if enemiesFolder then
                        for _, enemy in pairs(enemiesFolder:GetChildren()) do
                            local enemyRoot = enemy:FindFirstChild("HumanoidRootPart")
                            local enemyHuman = enemy:FindFirstChild("Humanoid")
                            if enemyRoot and enemyHuman and enemyHuman.Health > 0 then
                                local dist = (rootPart.Position - enemyRoot.Position).Magnitude
                                if dist < closestDist then
                                    closestDist = dist
                                    closestTarget = enemy
                                end
                            end
                        end
                    end

                    local charactersFolder = game:GetService("Workspace"):FindFirstChild("Characters")
                    if charactersFolder then
                        for _, targetPlayer in pairs(charactersFolder:GetChildren()) do
                            if targetPlayer.Name ~= LocalPlayer.Name and not table.find(_GENV._G.FriendsList, targetPlayer.Name) then
                                local enemyRoot = targetPlayer:FindFirstChild("HumanoidRootPart")
                                local enemyHuman = targetPlayer:FindFirstChild("Humanoid")
                                if enemyRoot and enemyHuman and enemyHuman.Health > 0 then
                                    local dist = (rootPart.Position - enemyRoot.Position).Magnitude
                                    if dist < closestDist then
                                        closestDist = dist
                                        closestTarget = targetPlayer
                                    end
                                end
                            end
                        end
                    end

                    if closestTarget then
                        FireAttackRemote(closestTarget)
                    end
                end
            end
        end)
    end
end)

-- Luồng PvP Auto Kill Player Trial (Có check danh sách whitelist bạn bè)
task.spawn(function()
    while task.wait(0.2) do
        if _GENV._G.AutoKillV4 then
            pcall(function()
                local charsFolder = game.Workspace:FindFirstChild("Characters")
                if charsFolder then
                    for _, targetPlayer in pairs(charsFolder:GetChildren()) do
                        if targetPlayer.Name ~= LocalPlayer.Name and not table.find(_GENV._G.FriendsList, targetPlayer.Name) then
                            local enemyHuman = targetPlayer:FindFirstChild("Humanoid")
                            local enemyRoot = targetPlayer:FindFirstChild("HumanoidRootPart")
                            local enemyHead = targetPlayer:FindFirstChild("Head")
                            local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

                            if enemyHuman and enemyRoot and enemyHead and myRoot and enemyHuman.Health > 0 then
                                if (myRoot.Position - enemyRoot.Position).Magnitude <= 230 then
                                    repeat
                                        task.wait(ATTACK_DELAY)
                                        AutoHaki()
                                        EquipWeapon(_GENV._G.SelectWeapon)
                                        SafeMove(enemyRoot.CFrame * CFrame.new(1, 1, 2))
                                        enemyRoot.Size = Vector3.new(60, 60, 60)
                                        enemyRoot.CanCollide = false
                                        enemyHead.CanCollide = false
                                        enemyHuman.WalkSpeed = 0
                                        FireAttackRemote(targetPlayer)
                                    until not _GENV._G.AutoKillV4 or enemyHuman.Health <= 0
                                        or not targetPlayer.Parent or not targetPlayer:FindFirstChild("HumanoidRootPart")
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- Luồng Auto Quest Trial các Tộc
task.spawn(function()
    while task.wait(0.5) do
        if _GENV._G.AutoQuestRace then
            pcall(function()
                local currentRace = LocalPlayer.Data.Race.Value
                if currentRace == "Human" or currentRace == "Ghoul" then
                    local enemies = game.Workspace:FindFirstChild("Enemies")
                    if enemies then
                        for _, enemy in pairs(enemies:GetDescendants()) do
                            if enemy:FindFirstChild("Humanoid") and enemy:FindFirstChild("HumanoidRootPart")
                                and enemy.Humanoid.Health > 0 then
                                repeat
                                    task.wait(0.2)
                                    enemy.Humanoid.Health = 0
                                    enemy.HumanoidRootPart.CanCollide = false
                                until not _GENV._G.AutoQuestRace or not enemy.Parent or enemy.Humanoid.Health <= 0
                            end
                        end
                    end
                elseif currentRace == "Skypiea" then
                    local skyTrialModel = game:GetService("Workspace").Map:FindFirstChild("SkyTrial")
                        and game:GetService("Workspace").Map.SkyTrial:FindFirstChild("Model")
                    if skyTrialModel then
                        for _, part in pairs(skyTrialModel:GetDescendants()) do
                            if part.Name == "snowisland_Cylinder.081" then SafeMove(part.CFrame) end
                        end
                    end
                elseif currentRace == "Cyborg" then
                    SafeMove(CFrame.new(28654, 14898.7832, -30))
                elseif currentRace == "Mink" then
                    for _, part in pairs(game:GetService("Workspace"):GetDescendants()) do
                        if part.Name == "StartPoint" then
                            SafeMove(part.CFrame * CFrame.new(0, 3, 0))
                            _GENV._G.AutoQuestRace = false
                        end
                    end
                elseif currentRace == "Fishman" then
                    local seaBeasts = game:GetService("Workspace"):FindFirstChild("SeaBeasts")
                        and game:GetService("Workspace").SeaBeasts:FindFirstChild("SeaBeast1")
                    if seaBeasts then
                        for _, part in pairs(seaBeasts:GetDescendants()) do
                            if part.Name == "HumanoidRootPart" then
                                SafeMove(part.CFrame * Pos)
                                EquipByToolTip("Melee")
                                EquipByToolTip("Blox Fruit")
                                EquipByToolTip("Sword")
                                EquipByToolTip("Gun")
                            end
                        end
                    end
                end
            end)
        end
    end
end)
