-- Axiom FE Bypass - Rayfield UI (Optimized Tabs + Remote Viewer & Copy Code)
-- Tác giả: Axiom
-- Yêu cầu: Roblox Delta X, Rayfield UI
-- Chức năng chính: Hook 5 loại remote real-time, xem log remote đã hook, chọn để resend, copy code mẫu.
-- Chức năng phụ (trong Settings): ExecuteOnTeleport, IgnorePlayerModule, AnticheatBypass, PreferBufferFromString.

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

-- ==================== CẤU HÌNH BAN ĐẦU ====================
getgenv().PreferBufferFromString = true
shared.PreferBufferFromString = true

-- Bảng lưu trữ các lần gọi remote đã log
getgenv().AxiomLoggedRemotes = getgenv().AxiomLoggedRemotes or {}

-- ==================== WINDOW CHÍNH ====================
local Window = Rayfield:CreateWindow({
    Name = "Axiom FE Bypass",
    LoadingTitle = "Axiom FE Bypass",
    LoadingSubtitle = "by Axiom",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "Axiom",
        FileName = "FE_Bypass_Config"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false
})

-- ==================== TAB 1: REMOTE HOOK ====================
local RemoteHookTab = Window:CreateTab("Remote Hook", 4483362458)
local HookSection = RemoteHookTab:CreateSection("Bật/tắt hook & quét remote")

-- Biến lưu trạng thái hook
local hookStates = {
    RemoteEvent = true,
    RemoteFunction = true,
    UnreliableRemoteEvent = true,
    BindableEvent = true,
    BindableFunction = true
}

local hookOriginalMethods = {} -- Lưu method gốc

-- Hàm lấy đường dẫn đầy đủ của object
function getFullPath(obj)
    local parts = {}
    local current = obj
    while current and current.Parent do
        table.insert(parts, 1, current.Name)
        current = current.Parent
    end
    return table.concat(parts, ".")
end

-- Hàm parse args từ chuỗi (hỗ trợ số, chuỗi, boolean, nil)
function parseArgsFromString(str)
    if str:gsub("%s", "") == "" then return {} end
    local args = {}
    local i = 1
    local len = #str
    while i <= len do
        while i <= len and (str:sub(i,i) == " " or str:sub(i,i) == ",") do i = i + 1 end
        if i > len then break end
        local char = str:sub(i,i)
        if char == "'" or char == '"' then
            local quote = char
            i = i + 1
            local start = i
            while i <= len and str:sub(i,i) ~= quote do i = i + 1 end
            table.insert(args, str:sub(start, i-1))
            i = i + 1
        elseif char == "t" and str:sub(i, i+3) == "true" then
            table.insert(args, true)
            i = i + 4
        elseif char == "f" and str:sub(i, i+4) == "false" then
            table.insert(args, false)
            i = i + 5
        elseif char == "n" and str:sub(i, i+2) == "nil" then
            table.insert(args, nil)
            i = i + 3
        else
            local start = i
            while i <= len and (str:sub(i,i):match("[%d%.%-]")) do i = i + 1 end
            local numStr = str:sub(start, i-1)
            local num = tonumber(numStr)
            if num then
                table.insert(args, num)
            else
                table.insert(args, numStr)
            end
        end
    end
    return args
end

-- Hàm hook một class method
local function hookClassMethod(className, methodName, logPrefix)
    if not hookOriginalMethods[className .. "_" .. methodName] then
        local instance = Instance.new(className)
        local original = instance[methodName]
        if original then
            hookOriginalMethods[className .. "_" .. methodName] = original
            if hookfunction then
                hookfunction(original, function(self, ...)
                    local args = {...}
                    if hookStates[className] then
                        -- Log vào console (giữ để debug)
                        print(logPrefix, "Fire:", getFullPath(self), "Args:", unpack(args))
                        -- Lưu vào bảng log
                        table.insert(getgenv().AxiomLoggedRemotes, {
                            className = className,
                            path = getFullPath(self),
                            object = self,
                            args = args,
                            timestamp = os.clock()
                        })
                    end
                    return original(self, ...)
                end)
            else
                -- Fallback nếu không có hookfunction
                local mt = getrawmetatable(instance)
                if mt and mt.__index then
                    local oldIndex = mt.__index
                    mt.__index = function(t, k)
                        if k == methodName and hookStates[className] then
                            return function(_, ...)
                                local args = {...}
                                print(logPrefix, "Fire:", getFullPath(self), "Args:", unpack(args))
                                table.insert(getgenv().AxiomLoggedRemotes, {
                                    className = className,
                                    path = getFullPath(self),
                                    object = self,
                                    args = args,
                                    timestamp = os.clock()
                                })
                                return original(_, ...)
                            end
                        end
                        return oldIndex(t, k)
                    end
                end
            end
        end
    end
end

-- Cấu hình hook
local hookConfig = {
    RemoteEvent = {methods = {"FireServer"}, logPrefix = "[RemoteEvent]"},
    RemoteFunction = {methods = {"InvokeServer"}, logPrefix = "[RemoteFunction]"},
    UnreliableRemoteEvent = {methods = {"FireServer"}, logPrefix = "[UnreliableRemoteEvent]"},
    BindableEvent = {methods = {"Fire"}, logPrefix = "[BindableEvent]"},
    BindableFunction = {methods = {"Invoke"}, logPrefix = "[BindableFunction]"}
}

-- Áp dụng hook ban đầu
for className, config in pairs(hookConfig) do
    for _, methodName in ipairs(config.methods) do
        pcall(function()
            hookClassMethod(className, methodName, config.logPrefix)
        end)
    end
end

-- Toggle cho từng loại remote
for className, enabled in pairs(hookStates) do
    local Toggle = RemoteHookTab:CreateToggle({
        Name = "Hook " .. className,
        CurrentValue = enabled,
        Flag = "hook_" .. className,
        Callback = function(Value)
            hookStates[className] = Value
            Rayfield:Notify({
                Title = "Hook Status",
                Content = "Hook " .. className .. " set to " .. tostring(Value),
                Duration = 2,
                Image = 4483362458,
                Actions = {}
            })
        end
    })
end

-- Button quét remote mới
local ScanButton = RemoteHookTab:CreateButton({
    Name = "Scan Remotes Now",
    Callback = function()
        local count = 0
        for _, container in pairs({ReplicatedStorage, Workspace, Players.LocalPlayer}) do
            for _, obj in pairs(container:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or
                   obj:IsA("UnreliableRemoteEvent") or obj:IsA("BindableEvent") or
                   obj:IsA("BindableFunction") then
                    count = count + 1
                    print("[Axiom] Found:", obj.ClassName, getFullPath(obj))
                end
            end
        end
        Rayfield:Notify({
            Title = "Remote Scan",
            Content = "Found " .. count .. " remotes",
            Duration = 3,
            Image = 4483362458,
            Actions = {}
        })
    end
})

-- ==================== TAB 2: REMOTE VIEWER & RESEND ====================
local RemoteViewerTab = Window:CreateTab("Remote Viewer", 4483362458)
local ViewerSection = RemoteViewerTab:CreateSection("Danh sách remote đã hook & công cụ")

-- Biến lưu remote đang chọn để resend
local selectedLoggedRemote = nil
local selectedLoggedIndex = nil

-- Tạo ScrollingFrame để hiển thị danh sách remote đã log
local LogListFrame = Instance.new("ScrollingFrame")
LogListFrame.Size = UDim2.new(1, -10, 0, 300)
LogListFrame.Position = UDim2.new(0, 5, 0, 20)
LogListFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
LogListFrame.BackgroundTransparency = 0.3
LogListFrame.BorderSizePixel = 0
LogListFrame.Parent = RemoteViewerTab:GetTabPage()

local LogListLayout = Instance.new("UIListLayout")
LogListLayout.Parent = LogListFrame
LogListLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- TextBox nhập tham số mới cho remote được chọn
local CustomArgsInput = Instance.new("TextBox")
CustomArgsInput.Size = UDim2.new(1, -10, 0, 30)
CustomArgsInput.Position = UDim2.new(0, 5, 0, 330)
CustomArgsInput.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
CustomArgsInput.TextColor3 = Color3.new(1, 1, 1)
CustomArgsInput.PlaceholderText = "Nhập tham số mới (phân cách bằng dấu phẩy, vd: 1, 'abc', true)"
CustomArgsInput.Parent = RemoteViewerTab:GetTabPage()

-- Nút Resend Selected
local ResendButton = Instance.new("TextButton")
ResendButton.Size = UDim2.new(1, -10, 0, 30)
ResendButton.Position = UDim2.new(0, 5, 0, 370)
ResendButton.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
ResendButton.TextColor3 = Color3.new(1, 1, 1)
ResendButton.Text = "RESEND SELECTED"
ResendButton.Parent = RemoteViewerTab:GetTabPage()

-- Nút Copy Code
local CopyCodeButton = Instance.new("TextButton")
CopyCodeButton.Size = UDim2.new(1, -10, 0, 30)
CopyCodeButton.Position = UDim2.new(0, 5, 0, 405)
CopyCodeButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
CopyCodeButton.TextColor3 = Color3.new(1, 1, 1)
CopyCodeButton.Text = "COPY CODE"
CopyCodeButton.Parent = RemoteViewerTab:GetTabPage()

-- Nút Clear Log
local ClearLogButton = Instance.new("TextButton")
ClearLogButton.Size = UDim2.new(1, -10, 0, 30)
ClearLogButton.Position = UDim2.new(0, 5, 0, 440)
ClearLogButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
ClearLogButton.TextColor3 = Color3.new(1, 1, 1)
ClearLogButton.Text = "CLEAR LOG"
ClearLogButton.Parent = RemoteViewerTab:GetTabPage()

-- Hàm render lại danh sách log
local function renderLogList()
    -- Xóa cũ
    for _, child in pairs(LogListFrame:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end

    -- Lấy danh sách log
    local logs = getgenv().AxiomLoggedRemotes
    for index, logEntry in ipairs(logs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 25)
        btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
        btn.TextColor3 = Color3.new(1, 1, 1)
        btn.Text = string.format("[%d] %s | %s | Args: %s", index, logEntry.className, logEntry.path, tostring(unpack(logEntry.args)))
        btn.Parent = LogListFrame

        -- Lưu index vào button
        btn.Name = "Log_" .. index

        btn.MouseButton1Click:Connect(function()
            -- Highlight button
            for _, child in pairs(LogListFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
                end
            end
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)

            selectedLoggedRemote = logEntry
            selectedLoggedIndex = index
            -- Điền args cũ vào TextBox
            CustomArgsInput.Text = table.concat(logEntry.args, ", ")
        end)
    end
end

-- Gọi render lần đầu
renderLogList()

-- Cập nhật danh sách khi có log mới (sử dụng spawn để không chặn)
spawn(function()
    while true do
        task.wait(2)
        -- Kiểm tra xem số lượng log có thay đổi không
        local currentCount = #getgenv().AxiomLoggedRemotes
        local renderedCount = 0
        for _, child in pairs(LogListFrame:GetChildren()) do
            if child:IsA("TextButton") then
                renderedCount = renderedCount + 1
            end
        end
        if renderedCount ~= currentCount then
            renderLogList()
        end
    end
end)

-- Hàm resend remote
ResendButton.MouseButton1Click:Connect(function()
    if not selectedLoggedRemote then
        Rayfield:Notify({
            Title = "Error",
            Content = "Chưa chọn remote nào để resend",
            Duration = 3,
            Image = 4483362458,
            Actions = {}
        })
        return
    end

    local argsStr = CustomArgsInput.Text
    local customArgs = parseArgsFromString(argsStr)

    local logEntry = selectedLoggedRemote
    pcall(function()
        if logEntry.className == "RemoteEvent" or logEntry.className == "UnreliableRemoteEvent" then
            logEntry.object:FireServer(unpack(customArgs))
        elseif logEntry.className == "RemoteFunction" then
            local result = logEntry.object:InvokeServer(unpack(customArgs))
            Rayfield:Notify({
                Title = "Invoke Result",
                Content = tostring(result),
                Duration = 5,
                Image = 4483362458,
                Actions = {}
            })
        elseif logEntry.className == "BindableEvent" then
            logEntry.object:Fire(unpack(customArgs))
        elseif logEntry.className == "BindableFunction" then
            local result = logEntry.object:Invoke(unpack(customArgs))
            Rayfield:Notify({
                Title = "Bindable Result",
                Content = tostring(result),
                Duration = 5,
                Image = 4483362458,
                Actions = {}
            })
        end
        Rayfield:Notify({
            Title = "Resend",
            Content = "Resend thành công: " .. logEntry.path,
            Duration = 3,
            Image = 4483362458,
            Actions = {}
        })
    end)
end)

-- Hàm copy code mẫu của remote đã chọn
CopyCodeButton.MouseButton1Click:Connect(function()
    if not selectedLoggedRemote then
        Rayfield:Notify({
            Title = "Error",
            Content = "Chưa chọn remote nào để copy code",
            Duration = 3,
            Image = 4483362458,
            Actions = {}
        })
        return
    end

    local logEntry = selectedLoggedRemote
    local codeTemplate = ""
    if logEntry.className == "RemoteEvent" or logEntry.className == "UnreliableRemoteEvent" then
        codeTemplate = string.format("game:GetService('ReplicatedStorage'):FindFirstChild('%s'):FireServer(...)", logEntry.path)
    elseif logEntry.className == "RemoteFunction" then
        codeTemplate = string.format("game:GetService('ReplicatedStorage'):FindFirstChild('%s'):InvokeServer(...)", logEntry.path)
    elseif logEntry.className == "BindableEvent" then
        codeTemplate = string.format("game:GetService('ReplicatedStorage'):FindFirstChild('%s'):Fire(...)", logEntry.path)
    elseif logEntry.className == "BindableFunction" then
        codeTemplate = string.format("game:GetService('ReplicatedStorage'):FindFirstChild('%s'):Invoke(...)", logEntry.path)
    end

    -- Thử copy vào clipboard
    pcall(function()
        setclipboard(codeTemplate)
        Rayfield:Notify({
            Title = "Code Copied",
            Content = "Đã copy code mẫu vào clipboard:\n" .. codeTemplate,
            Duration = 5,
            Image = 4483362458,
            Actions = {}
        })
    end)
end)

ClearLogButton.MouseButton1Click:Connect(function()
    getgenv().AxiomLoggedRemotes = {}
    selectedLoggedRemote = nil
    selectedLoggedIndex = nil
    CustomArgsInput.Text = ""
    renderLogList()
    Rayfield:Notify({
        Title = "Clear Log",
        Content = "Đã xóa toàn bộ log",
        Duration = 3,
        Image = 4483362458,
        Actions = {}
    })
end)

-- ==================== TAB 3: SETTINGS ====================
local SettingsTab = Window:CreateTab("Settings", 4483362458)
local SettingsSection = SettingsTab:CreateSection("Chức năng phụ & cấu hình")

-- ==== EXECUTE ON TELEPORT ====
local TeleportToggle = SettingsTab:CreateToggle({
    Name = "Execute On Teleport",
    CurrentValue = true,
    Flag = "exec_on_teleport",
    Callback = function(Value)
        getgenv().AxiomExecOnTeleport = Value
        Rayfield:Notify({
            Title = "Execute On Teleport",
            Content = "Bật/tắt re-execute sau teleport: " .. tostring(Value),
            Duration = 2,
            Image = 4483362458,
            Actions = {}
        })
    end
})

local function onTeleport()
    if getgenv().AxiomExecOnTeleport then
        Rayfield:Notify({
            Title = "Teleport Detected",
            Content = "Re-executing script...",
            Duration = 5,
            Image = 4483362458,
            Actions = {}
        })
        pcall(function()
            local source = getgenv().AxiomScriptSource
            if source and source ~= "" then
                loadstring(source)()
            else
                Rayfield:Notify({
                    Title = "Error",
                    Content = "Script source not cached. Please re-execute manually.",
                    Duration = 5,
                    Image = 4483362458,
                    Actions = {}
                })
            end
        end)
    end
end

if TeleportService then
    TeleportService.LocalPlayerTeleporting:Connect(onTeleport)
end
if Players.LocalPlayer then
    Players.LocalPlayer.OnTeleport:Connect(onTeleport)
end

-- Lưu source script để re-execute (đặt ở đây)
getgenv().AxiomScriptSource = [[
-- Đặt toàn bộ script của bạn ở đây nếu muốn tự động re-execute
print("[Axiom] Re-executed script.")
]]

-- ==== IGNORE PLAYERMODULE ====
local function disablePlayerModule()
    local localPlayer = Players.LocalPlayer
    if not localPlayer then return end
    local playerScripts = localPlayer:FindFirstChild("PlayerScripts")
    if not playerScripts then return end
    local playerModule = playerScripts:FindFirstChild("PlayerModule")
    if playerModule then
        pcall(function()
            playerModule.Enabled = false
            playerModule.Disabled = true
            Rayfield:Notify({
                Title = "PlayerModule",
                Content = "PlayerModule disabled",
                Duration = 3,
                Image = 4483362458,
                Actions = {}
            })
        end)
    else
        Rayfield:Notify({
            Title = "PlayerModule",
            Content = "PlayerModule not found",
            Duration = 3,
            Image = 4483362458,
            Actions = {}
        })
    end
end

local DisablePMButton = SettingsTab:CreateButton({
    Name = "Disable PlayerModule Now",
    Callback = disablePlayerModule
})

local AutoDisablePMToggle = SettingsTab:CreateToggle({
    Name = "Auto Disable on Respawn",
    CurrentValue = true,
    Flag = "auto_disable_pm",
    Callback = function(Value)
        getgenv().AxiomAutoDisablePM = Value
        Rayfield:Notify({
            Title = "Auto Disable PM",
            Content = "Auto disable PlayerModule on respawn: " .. tostring(Value),
            Duration = 2,
            Image = 4483362458,
            Actions = {}
        })
    end
})

if Players.LocalPlayer then
    Players.LocalPlayer.CharacterAdded:Connect(function()
        if getgenv().AxiomAutoDisablePM then
            task.wait(1)
            disablePlayerModule()
        end
    end)
end

-- ==== ANTICHEAT BYPASS ====
local function bypassAnticheat()
    local containers = {
        Players.LocalPlayer,
        Players.LocalPlayer and Players.LocalPlayer.PlayerScripts,
        Players.LocalPlayer and Players.LocalPlayer.Backpack,
        Players.LocalPlayer and Players.LocalPlayer.Character,
        ReplicatedStorage,
        Workspace
    }

    local suspiciousNames = {"Anti", "AC", "Cheat", "Ban", "Kick", "VAC", "Secure", "Guard"}
    local disabledCount = 0

    local function scanContainer(container)
        if not container then return end
        for _, obj in pairs(container:GetDescendants()) do
            local name = obj.Name:lower()
            for _, keyword in ipairs(suspiciousNames) do
                if name:find(keyword:lower()) then
                    if obj:IsA("LocalScript") or obj:IsA("Script") or obj:IsA("ModuleScript") then
                        pcall(function()
                            obj.Enabled = false
                            obj.Disabled = true
                            disabledCount = disabledCount + 1
                        end)
                    elseif obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        -- chỉ log nghi ngờ
                    end
                end
            end
        end
    end

    for _, container in ipairs(containers) do
        pcall(function()
            scanContainer(container)
        end)
    end

    Rayfield:Notify({
        Title = "Anticheat Bypass",
        Content = "Disabled " .. disabledCount .. " anticheat scripts",
        Duration = 3,
        Image = 4483362458,
        Actions = {}
    })
end

local BypassButton = SettingsTab:CreateButton({
    Name = "Run Anticheat Bypass Now",
    Callback = bypassAnticheat
})

local AutoBypassToggle = SettingsTab:CreateToggle({
    Name = "Auto Bypass (every 10s)",
    CurrentValue = false,
    Flag = "auto_bypass",
    Callback = function(Value)
        getgenv().AxiomAutoBypass = Value
        Rayfield:Notify({
            Title = "Auto Anticheat Bypass",
            Content = "Auto bypass anticheat every 10s: " .. tostring(Value),
            Duration = 2,
            Image = 4483362458,
            Actions = {}
        })
    end
})

spawn(function()
    while true do
        task.wait(10)
        if getgenv().AxiomAutoBypass then
            bypassAnticheat()
        end
    end
end)

-- ==== PREFER BUFFER FROM STRING ====
local PreferBufferToggle = SettingsTab:CreateToggle({
    Name = "PreferBufferFromString",
    CurrentValue = true,
    Flag = "prefer_buffer",
    Callback = function(Value)
        getgenv().PreferBufferFromString = Value
        shared.PreferBufferFromString = Value
        Rayfield:Notify({
            Title = "PreferBufferFromString",
            Content = "PreferBufferFromString set to " .. tostring(Value),
            Duration = 2,
            Image = 4483362458,
            Actions = {}
        })
    end
})

-- ==== RENDERING & CLEANUP ====
local RenderingToggle = SettingsTab:CreateToggle({
    Name = "3D Rendering",
    CurrentValue = true,
    Flag = "render_3d",
    Callback = function(Value)
        RunService:Set3dRenderingEnabled(Value)
        Rayfield:Notify({
            Title = "3D Rendering",
            Content = "3D Rendering: " .. tostring(Value),
            Duration = 2,
            Image = 4483362458,
            Actions = {}
        })
    end
})

local CleanupButton = SettingsTab:CreateButton({
    Name = "Cleanup Memory",
    Callback = function()
        pcall(function()
            collectgarbage("collect")
            Rayfield:Notify({
                Title = "Cleanup",
                Content = "Memory cleaned",
                Duration = 3,
                Image = 4483362458,
                Actions = {}
            })
        end)
    end
})

-- ==================== REAL-TIME MONITORING ====================
-- Theo dõi remote mới spawn và thông báo (chỉ Notify khi có remote mới, không spam)
local function setupRealTimeMonitoring(container)
    if not container then return end
    container.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("RemoteEvent") or descendant:IsA("RemoteFunction") or
           descendant:IsA("UnreliableRemoteEvent") or descendant:IsA("BindableEvent") or
           descendant:IsA("BindableFunction") then
            Rayfield:Notify({
                Title = "New Remote",
                Content = descendant.ClassName .. " spawned: " .. getFullPath(descendant),
                Duration = 3,
                Image = 4483362458,
                Actions = {}
            })
        end
    end)
end

setupRealTimeMonitoring(ReplicatedStorage)
setupRealTimeMonitoring(Workspace)
if Players.LocalPlayer then
    setupRealTimeMonitoring(Players.LocalPlayer)
end

-- ==================== KHỞI ĐỘNG ====================
Rayfield:Notify({
    Title = "Axiom FE Bypass",
    Content = "Script loaded. Hook 5 remote, Remote Viewer, Settings ready.",
    Duration = 5,
    Image = 4483362458,
    Actions = {}
})