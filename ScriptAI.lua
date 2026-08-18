-- ============================================
-- KIỂM TRA MÔI TRƯỜNG ROBLOX
-- ============================================
if not game then error("Script chỉ chạy trong Roblox") end

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TextChatService = game:GetService("TextChatService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then error("LocalPlayer nil – inject thất bại") end

-- ============================================
-- LOAD RAYFIELD
-- ============================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- ============================================
-- BIẾN TOÀN CỤC
-- ============================================
local API_KEY = nil
local KEY_VALIDATED = false

-- ============================================
-- HÀM KIỂM TRA API KEY (KHÔNG TREO)
-- ============================================
local function ValidateKey(key)
    if not key or key == "" then 
        Rayfield:Notify({Title = "⚠️ LỖI", Content = "API key rỗng", Duration = 2})
        return false 
    end

    local requestFunc
    if syn and syn.request then requestFunc = syn.request
    elseif http and http.request then requestFunc = http.request
    elseif request then requestFunc = request
    elseif syn_request then requestFunc = syn_request
    else
        Rayfield:Notify({Title = "❌ LỖI EXECUTOR", Content = "Không tìm thấy request", Duration = 3})
        return false
    end

    local testUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=" .. key
    local testBody = { contents = {{ parts = {{ text = "Hello" }} }} }

    for attempt = 1, 3 do
        local success, res = pcall(function()
            return requestFunc({
                Url = testUrl,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(testBody),
                Timeout = 15
            })
        end)
        if not success then
            task.wait(2)
        else
            if res and res.StatusCode == 200 then
                Rayfield:Notify({Title = "✅ KEY HỢP LỆ", Content = "Chạy ngon lành!", Duration = 2})
                return true
            elseif res and (res.StatusCode == 401 or res.StatusCode == 403) then
                Rayfield:Notify({Title = "❌ KEY SAI", Content = "Key không hợp lệ", Duration = 3})
                return false
            else
                task.wait(2)
            end
        end
    end
    Rayfield:Notify({Title = "❌ THẤT BẠI", Content = "Không xác thực được key", Duration = 3})
    return false
end

-- ============================================
-- POPUP NHẬP KEY (ĐÃ FIX LỖI)
-- ============================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "APIKeyPopup"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

local PopupFrame = Instance.new("Frame")
PopupFrame.Size = UDim2.new(0, 420, 0, 220)
PopupFrame.Position = UDim2.new(0.5, -210, 0.5, -110)
PopupFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
PopupFrame.BorderSizePixel = 0
PopupFrame.Parent = ScreenGui
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = PopupFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, 0, 0, 40)
TitleLabel.Text = "🔑 NHẬP API KEY GEMINI"
TitleLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
TitleLabel.TextSize = 18
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.BackgroundTransparency = 1
TitleLabel.Parent = PopupFrame

local DescLabel = Instance.new("TextLabel")
DescLabel.Size = UDim2.new(1, -20, 0, 30)
DescLabel.Position = UDim2.new(0, 10, 0, 40)
DescLabel.Text = "Lấy key từ Google AI Studio (ai.google.dev)"
DescLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
DescLabel.TextSize = 13
DescLabel.TextXAlignment = Enum.TextXAlignment.Left
DescLabel.BackgroundTransparency = 1
DescLabel.Parent = PopupFrame

local KeyBox = Instance.new("TextBox")
KeyBox.Size = UDim2.new(1, -40, 0, 36)
KeyBox.Position = UDim2.new(0, 20, 0, 75)
KeyBox.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
KeyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyBox.TextSize = 14
KeyBox.Font = Enum.Font.SourceSans
KeyBox.PlaceholderText = "AIzaSy..."
KeyBox.ClearTextOnFocus = false
KeyBox.Text = ""
KeyBox.Parent = PopupFrame
local BoxCorner = Instance.new("UICorner")
BoxCorner.CornerRadius = UDim.new(0, 6)
BoxCorner.Parent = KeyBox

local CheckButton = Instance.new("TextButton")
CheckButton.Size = UDim2.new(0, 120, 0, 36)
CheckButton.Position = UDim2.new(0.5, -60, 0, 125)
CheckButton.Text = "✅ KIỂM TRA"
CheckButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CheckButton.TextSize = 14
CheckButton.Font = Enum.Font.SourceSansBold
CheckButton.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
CheckButton.BorderSizePixel = 0
CheckButton.Parent = PopupFrame
local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = CheckButton

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -40, 0, 24)
StatusLabel.Position = UDim2.new(0, 20, 0, 175)
StatusLabel.Text = "Nhập key và bấm kiểm tra"
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.TextSize = 12
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = PopupFrame

local CancelButton = Instance.new("TextButton")
CancelButton.Size = UDim2.new(0, 80, 0, 30)
CancelButton.Position = UDim2.new(1, -90, 1, -45)
CancelButton.Text = "THOÁT"
CancelButton.TextColor3 = Color3.fromRGB(180, 180, 180)
CancelButton.TextSize = 12
CancelButton.Font = Enum.Font.SourceSans
CancelButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
CancelButton.BorderSizePixel = 0
CancelButton.Parent = PopupFrame
local CancelCorner = Instance.new("UICorner")
CancelCorner.CornerRadius = UDim.new(0, 4)
CancelCorner.Parent = CancelButton

local isChecking = false

local function OnCheck()
    if isChecking then 
        StatusLabel.Text = "⏳ Đang kiểm tra, vui lòng đợi..."
        StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
        return 
    end
    local key = KeyBox.Text
    if not key or key == "" then
        StatusLabel.Text = "❌ Vui lòng nhập key!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        return
    end
    isChecking = true
    StatusLabel.Text = "⏳ Đang kiểm tra (10-15s)..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 200, 50)
    CheckButton.Text = "⏳ ĐANG TEST"
    CheckButton.BackgroundColor3 = Color3.fromRGB(128, 128, 128)

    task.spawn(function()
        local valid = ValidateKey(key)
        isChecking = false
        if valid then
            API_KEY = key
            KEY_VALIDATED = true
            StatusLabel.Text = "✅ Key hợp lệ! Khởi động bot..."
            StatusLabel.TextColor3 = Color3.fromRGB(50, 205, 50)
            task.wait(1)
            ScreenGui:Destroy()
            InitializeBot()
        else
            StatusLabel.Text = "❌ Key sai hoặc lỗi mạng, thử lại!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
            CheckButton.Text = "🔄 KIỂM TRA LẠI"
            CheckButton.BackgroundColor3 = Color3.fromRGB(30, 144, 255)
        end
    end)
end

CheckButton.MouseButton1Click:Connect(OnCheck)
KeyBox.FocusLost:Connect(function(enterPressed) if enterPressed then OnCheck() end end)
CancelButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    Rayfield:Notify({Title = "ĐÃ HỦY", Content = "Bạn đã thoát mà không nhập key", Duration = 3})
end)

-- ============================================
-- HÀM KHỞI TẠO BOT (SAU KHI KEY HỢP LỆ)
-- ============================================
function InitializeBot()
    -- CẤU HÌNH
    local CONFIG = {
        API_KEY = API_KEY,
        PREFIX = "!ai ",
        MODEL = "gemini-2.5-flash-lite",
        COOLDOWN = 2,
        MAX_RETRIES = 5,
        TIMEOUT = 10,
        MAX_REPLY_LENGTH = 80,        -- giảm để an toàn
        ENABLE_HISTORY = true,
        HISTORY_LIMIT = 5,
        BASE_INTERVAL = 1.5,           -- tăng lên
        JITTER = 0.5,
        ENABLE_HOMOGLYPH = true,
        STEALTH_LEVEL = "Aggressive",  -- Normal / Aggressive
        AUTO_CHAT_ENABLED = true,
        AUTO_GREET_ON_JOIN = true,
        AUTO_RESPOND_NO_PREFIX = true,
        GREET_MESSAGE = "Chào mừng! Tôi là AI Bot, hỏi tôi bất cứ điều gì.",
        TRIGGER_KEYWORDS = {"ai", "bot", "trợ giúp", "help", "ơi", "ê"},
        MIN_MESSAGE_LENGTH = 3,
        BOT_ENABLED = true,
    }

    local GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/" .. CONFIG.MODEL .. ":generateContent?key=" .. CONFIG.API_KEY

    -- TÌM REQUEST
    local requestFunc
    if syn and syn.request then requestFunc = syn.request
    elseif http and http.request then requestFunc = http.request
    elseif request then requestFunc = request
    elseif syn_request then requestFunc = syn_request
    else 
        Rayfield:Notify({Title = "❌ LỖI", Content = "Không tìm thấy request", Duration = 3})
        return 
    end

    -- ============================================
    -- HOMOGLYPH MỞ RỘNG + RANDOM + ZERO-WIDTH
    -- ============================================
    local HOMO_VARIANTS = {
        ['a'] = {'а', 'α', 'à', 'á', 'â', 'ã', 'ä', 'å', 'ą', 'ǎ', 'ȧ', 'ă', 'ā', 'ã', 'ä', 'å', 'ᵃ', 'ᴀ'},
        ['b'] = {'Ь', 'Ꮟ', 'ḅ', 'ƅ', 'ɓ', 'β', 'ᵇ', 'ᴃ'},
        ['c'] = {'с', 'ϲ', 'ᴄ', 'ⅽ', 'ƈ', 'ċ', 'ć', 'č', 'ç'},
        ['d'] = {'ԁ', 'ᴅ', 'ⅾ', 'ḋ', 'ď', 'đ', 'ɗ'},
        ['e'] = {'е', 'є', 'ε', 'è', 'é', 'ê', 'ë', 'ė', 'ę', 'ě', 'ĕ', 'ē', 'ᵉ'},
        ['f'] = {'ｆ', 'ḟ', 'ƒ', 'ᶠ', 'ϝ'},
        ['g'] = {'ɡ', 'ġ', 'ğ', 'ǧ', 'ǵ', 'ɢ', 'ᵍ'},
        ['h'] = {'һ', 'ħ', 'ḣ', 'ḥ', 'ȟ', 'ɦ', 'ʜ'},
        ['i'] = {'і', 'ί', 'ì', 'í', 'î', 'ï', 'ĩ', 'ī', 'į', 'ỉ', 'ᴉ', 'ᵢ'},
        ['j'] = {'ј', 'ĵ', 'ɉ', 'ᴊ', 'ʲ'},
        ['k'] = {'κ', 'ķ', 'ḱ', 'ǩ', 'ʞ', 'ᵏ'},
        ['l'] = {'ⅼ', 'ĺ', 'ļ', 'ľ', 'ł', 'ᴫ', 'ᶫ'},
        ['m'] = {'ｍ', 'ṃ', 'ḿ', 'ṁ', 'ɱ', 'ᵐ'},
        ['n'] = {'п', 'ń', 'ņ', 'ň', 'ñ', 'ṅ', 'ᵑ', 'ɴ'},
        ['o'] = {'о', 'ο', 'ό', 'ò', 'ó', 'ô', 'õ', 'ö', 'ø', 'ō', 'ŏ', 'ő', 'ơ', 'ǒ', 'ȯ', 'ᴏ'},
        ['p'] = {'р', 'ρ', 'ṗ', 'ƥ', 'ᵖ', 'ᴘ'},
        ['q'] = {'ԛ', 'Ԛ', 'ƣ', 'ʠ', 'ɋ'},
        ['r'] = {'г', 'ŕ', 'ŗ', 'ř', 'ṙ', 'ɾ', 'ʀ', 'ᴦ'},
        ['s'] = {'ѕ', 'ś', 'ŝ', 'š', 'ş', 'ș', 'ṡ', 'ʂ', 'ᵴ'},
        ['t'] = {'ｔ', 'ţ', 'ť', 'ț', 'ṫ', 'ƫ', 'ʇ', 'ᴛ'},
        ['u'] = {'υ', 'ù', 'ú', 'û', 'ü', 'ũ', 'ū', 'ŭ', 'ů', 'ű', 'ų', 'ư', 'ǔ', 'ᵘ'},
        ['v'] = {'ν', 'ṿ', 'ʋ', 'ᵛ', 'ᴠ'},
        ['w'] = {'ѡ', 'ŵ', 'ẅ', 'ẉ', 'ẘ', 'ᴡ'},
        ['x'] = {'х', 'χ', 'ẋ', 'ẍ', 'ᶍ'},
        ['y'] = {'у', 'ý', 'ŷ', 'ÿ', 'ỹ', 'ȳ', 'ẏ', 'ẙ', 'ʏ'},
        ['z'] = {'ᴢ', 'ź', 'ż', 'ž', 'ẓ', 'ʐ', 'ƶ'},
        -- Hoa
        ['A'] = {'Α', 'À', 'Á', 'Â', 'Ã', 'Ä', 'Å', 'Ą', 'Ā', 'Ă', 'Ǎ', 'Ȧ', 'Ꭺ'},
        ['B'] = {'Β', 'Ḃ', 'Ḅ', 'Ɓ', 'Ᏼ'},
        ['C'] = {'С', 'Ç', 'Ċ', 'Č', 'Ć', 'Ꮯ'},
        ['D'] = {'Ꭰ', 'Ḋ', 'Ḍ', 'Ď', 'Đ', 'Ɗ'},
        ['E'] = {'Ε', 'È', 'É', 'Ê', 'Ë', 'Ė', 'Ę', 'Ě', 'Ē', 'Ĕ', 'Є'},
        ['F'] = {'Ϝ', 'Ḟ', 'Ƒ', 'Ꭰ'},
        ['G'] = {'Ԍ', 'Ġ', 'Ğ', 'Ǧ', 'Ǵ', 'Ꮹ'},
        ['H'] = {'Η', 'Ḣ', 'Ḥ', 'Ħ', 'Ȟ'},
        ['I'] = {'Ι', 'Ì', 'Í', 'Î', 'Ï', 'Ĩ', 'Ī', 'Į', 'Ỉ', 'Ꮖ'},
        ['J'] = {'ᒍ', 'Ĵ', 'Ɉ'},
        ['K'] = {'Κ', 'Ḱ', 'Ǩ', 'Ķ'},
        ['L'] = {'ᒪ', 'Ĺ', 'Ļ', 'Ľ', 'Ł'},
        ['M'] = {'Μ', 'Ṁ', 'Ṃ', 'Ꮇ'},
        ['N'] = {'Ν', 'Ń', 'Ņ', 'Ň', 'Ñ', 'Ꮑ'},
        ['O'] = {'Ο', 'Ò', 'Ó', 'Ô', 'Õ', 'Ö', 'Ø', 'Ō', 'Ŏ', 'Ő', 'Ơ', 'Ǒ', 'Ȯ', 'Ꮎ'},
        ['P'] = {'Ρ', 'Ṗ', 'Ƥ', 'Ꮲ'},
        ['Q'] = {'Ԛ', 'Ǫ', 'Ǭ'},
        ['R'] = {'Ꭱ', 'Ŕ', 'Ŗ', 'Ř', 'Ṙ', 'Ɍ'},
        ['S'] = {'Ѕ', 'Ś', 'Ŝ', 'Š', 'Ş', 'Ș', 'Ṡ', 'Ꮪ'},
        ['T'] = {'Τ', 'Ţ', 'Ť', 'Ț', 'Ṫ', 'Ƭ', 'Ꭲ'},
        ['U'] = {'Υ', 'Ù', 'Ú', 'Û', 'Ü', 'Ũ', 'Ū', 'Ŭ', 'Ů', 'Ű', 'Ų', 'Ư', 'Ǔ', 'Ꮜ'},
        ['V'] = {'Ѵ', 'Ṿ', 'Ʋ', 'Ꮩ'},
        ['W'] = {'Ꮤ', 'Ŵ', 'Ẅ', 'Ẇ', 'Ẉ'},
        ['X'] = {'Χ', 'Ẋ', 'Ẍ', 'Ꮍ'},
        ['Y'] = {'Υ', 'Ý', 'Ŷ', 'Ÿ', 'Ỹ', 'Ȳ', 'Ẏ', 'Ꮿ'},
        ['Z'] = {'Ζ', 'Ź', 'Ż', 'Ž', 'Ẓ', 'Ƶ'},
    }

    -- Hàm chuyển đổi homoglyph với random và zero-width
    local function ToHomoglyph(str)
        if not CONFIG.ENABLE_HOMOGLYPH then return str end
        local out = {}
        local i = 1
        while i <= #str do
            local ch = string.sub(str, i, i)
            local lower = string.lower(ch)
            local variants = HOMO_VARIANTS[lower]
            local replacement
            if variants and #variants > 0 then
                local idx = math.random(1, #variants)
                replacement = variants[idx]
                -- Nếu là chữ hoa, có thể giữ nguyên dạng hoa hoặc không (tùy)
                if ch == string.upper(ch) and string.lower(replacement) ~= replacement then
                    -- đã có sẵn ký tự hoa trong variants
                end
            else
                replacement = ch
            end
            table.insert(out, replacement)
            -- Chèn zero-width space (U+200B) ngẫu nhiên sau mỗi 2-3 ký tự
            if CONFIG.STEALTH_LEVEL == "Aggressive" and math.random(1, 3) == 1 then
                table.insert(out, "​") -- zero-width space
            end
            i = i + 1
        end
        return table.concat(out)
    end

    -- ============================================
    -- HÀNG ĐỢI GỬI TIN (NÂNG CẤP)
    -- ============================================
    local messageQueue = {}
    local isProcessing = false
    local lastSendTime = 0

    local function SendRaw(text, isWhisper, targetPlayer)
        if not text or text == "" then return true end
        local obfuscated = ToHomoglyph(text)
        local function doSend(msg)
            if isWhisper and targetPlayer then
                local remote = game:GetService("ReplicatedStorage"):FindFirstChild("WhisperMessage", true)
                if remote then remote:FireServer(targetPlayer, msg) return true end
            end
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if channel then channel:SendAsync(msg) return true end
            end
            local remote = game:GetService("ReplicatedStorage"):FindFirstChild("SayMessageRequest", true)
            if remote then remote:FireServer(msg, "All") return true end
            return false
        end

        -- Thử với nhiều biến thể
        local variants = {obfuscated}
        -- Biến thể 2: đảo ngược một phần
        if #obfuscated > 10 then
            local mid = math.floor(#obfuscated/2)
            local rev = string.reverse(string.sub(obfuscated, mid)) .. string.sub(obfuscated, 1, mid-1)
            table.insert(variants, rev)
        end
        -- Biến thể 3: thêm nhiều zero-width
        if CONFIG.STEALTH_LEVEL == "Aggressive" then
            local zw = string.gsub(obfuscated, "([%w%p])", "%1​​")
            table.insert(variants, zw)
        end

        for attempt = 1, 3 do
            local chosen = variants[(attempt-1) % #variants + 1]
            if doSend(chosen) then return true end
            task.wait(0.5 + math.random() * 0.5)
        end
        return false
    end

    local function ProcessQueue()
        if isProcessing then return end
        isProcessing = true
        while #messageQueue > 0 do
            local item = table.remove(messageQueue, 1)
            local now = tick()
            local delay = CONFIG.BASE_INTERVAL + math.random() * CONFIG.JITTER
            local waitTime = delay - (now - lastSendTime)
            if waitTime > 0 then task.wait(waitTime) end
            if SendRaw(item.text, item.whisper, item.target) then
                lastSendTime = tick()
            elseif not item.retry then
                item.retry = true
                table.insert(messageQueue, item)
            end
        end
        isProcessing = false
    end

    local function SendReply(answer, isWhisper, targetPlayer)
        if not answer or answer == "" then return end
        local full = "AI BOT: " .. answer
        local chunks = {}
        if #full > CONFIG.MAX_REPLY_LENGTH then
            for i = 1, #full, CONFIG.MAX_REPLY_LENGTH do
                table.insert(chunks, string.sub(full, i, i + CONFIG.MAX_REPLY_LENGTH - 1))
            end
        else
            table.insert(chunks, full)
        end
        for _, chunk in ipairs(chunks) do
            table.insert(messageQueue, {text = chunk, whisper = isWhisper or false, target = targetPlayer, retry = false})
        end
        task.spawn(ProcessQueue)
    end

    -- ============================================
    -- PHẦN CÒN LẠI: LỊCH SỬ, GỌI AI, COOLDOWN, LỆNH, CHAT, GUI, ...
    -- (giữ nguyên như bản trước, chỉ thay cấu hình)
    -- ============================================

    -- LỊCH SỬ
    local history = {}
    local function GetHistory(pName)
        if not CONFIG.ENABLE_HISTORY then return {} end
        if not history[pName] then history[pName] = {} end
        return history[pName]
    end
    local function AddHistory(pName, role, text)
        if not CONFIG.ENABLE_HISTORY then return end
        local h = GetHistory(pName)
        table.insert(h, {role = role, text = text})
        if #h > CONFIG.HISTORY_LIMIT * 2 then table.remove(h, 1) end
    end

    local function BuildPrompt(question, pName)
        local h = GetHistory(pName)
        local context = ""
        if #h > 0 then
            local parts = {}
            for _, msg in ipairs(h) do
                table.insert(parts, (msg.role == "user" and "Người" or "AI") .. ": " .. msg.text)
            end
            context = "Lịch sử:\n" .. table.concat(parts, "\n") .. "\n\n"
        end
        return context .. "Trợ lý AI thân thiện. Trả lời Tiếng Việt, ngắn gọn, vui vẻ. Câu hỏi: " .. question
    end

    -- GỌI AI
    local function AskAI(question, playerName)
        local prompt = BuildPrompt(question, playerName)
        local requestBody = { contents = {{ parts = {{ text = prompt }} }} }
        local retries = 0
        local waitTime = 1
        while retries < CONFIG.MAX_RETRIES do
            local ok, res = pcall(function()
                return requestFunc({
                    Url = GEMINI_URL,
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = HttpService:JSONEncode(requestBody),
                    Timeout = CONFIG.TIMEOUT
                })
            end)
            if not ok then
                retries = retries + 1
                task.wait(waitTime)
                waitTime = waitTime * 2
            elseif res.StatusCode == 200 then
                local data = HttpService:JSONDecode(res.Body)
                if data and data.candidates and data.candidates[1] and data.candidates[1].content then
                    local ans = data.candidates[1].content.parts[1].text
                    ans = string.gsub(ans, "[\n\r\t]", " ")
                    ans = string.gsub(ans, "%s+", " ")
                    AddHistory(playerName, "user", question)
                    AddHistory(playerName, "assistant", ans)
                    return ans, nil
                else
                    Rayfield:Notify({Title = "AI", Content = "Trả về rỗng", Duration = 2})
                    return nil, "AI rỗng"
                end
            elseif res.StatusCode == 429 then
                retries = retries + 1
                task.wait(waitTime * 2)
                waitTime = waitTime * 3
                Rayfield:Notify({Title = "⏳ GIỚI HẠN", Content = "Rate limit, thử lại "..retries, Duration = 2})
            else
                Rayfield:Notify({Title = "❌ LỖI", Content = "HTTP "..res.StatusCode, Duration = 2})
                return nil, "HTTP "..res.StatusCode
            end
        end
        Rayfield:Notify({Title = "❌ LỖI", Content = "Hết retry", Duration = 2})
        return nil, "Hết retry"
    end

    -- COOLDOWN
    local lastTime = {}
    local function CanProcess(speaker)
        local now = tick()
        if now - (lastTime[speaker] or 0) < CONFIG.COOLDOWN then
            Rayfield:Notify({Title = "⏳ COOLDOWN", Content = "Đợi "..CONFIG.COOLDOWN.."s", Duration = 1})
            return false
        end
        lastTime[speaker] = now
        return true
    end

    -- XỬ LÝ LỆNH
    local function ProcessCommand(cmd, speaker)
        if cmd == "auto on" then
            CONFIG.AUTO_CHAT_ENABLED = true
            CONFIG.AUTO_RESPOND_NO_PREFIX = true
            Rayfield:Notify({Title = "✅ AUTO", Content = "Đã BẬT", Duration = 2})
            return true
        elseif cmd == "auto off" then
            CONFIG.AUTO_CHAT_ENABLED = false
            CONFIG.AUTO_RESPOND_NO_PREFIX = false
            Rayfield:Notify({Title = "⛔ AUTO", Content = "Đã TẮT", Duration = 2})
            return true
        elseif cmd == "greet on" then
            CONFIG.AUTO_GREET_ON_JOIN = true
            Rayfield:Notify({Title = "✅ GREET", Content = "Đã BẬT", Duration = 2})
            return true
        elseif cmd == "greet off" then
            CONFIG.AUTO_GREET_ON_JOIN = false
            Rayfield:Notify({Title = "⛔ GREET", Content = "Đã TẮT", Duration = 2})
            return true
        elseif string.sub(cmd, 1, 6) == "setpre" then
            local newPrefix = string.sub(cmd, 8)
            if newPrefix and newPrefix ~= "" then
                CONFIG.PREFIX = newPrefix
                Rayfield:Notify({Title = "✅ PREFIX", Content = "Đổi thành: "..newPrefix, Duration = 2})
            end
            return true
        elseif string.sub(cmd, 1, 5) == "model" then
            local newModel = string.sub(cmd, 7)
            if newModel and newModel ~= "" then
                CONFIG.MODEL = newModel
                GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/"..newModel..":generateContent?key="..CONFIG.API_KEY
                Rayfield:Notify({Title = "✅ MODEL", Content = "Đổi thành: "..newModel, Duration = 2})
            end
            return true
        elseif cmd == "cooldown" then
            local num = tonumber(string.sub(cmd, 10))
            if num and num > 0 then
                CONFIG.COOLDOWN = num
                Rayfield:Notify({Title = "✅ COOLDOWN", Content = "Đặt thành: "..num.."s", Duration = 2})
            end
            return true
        elseif cmd == "help" then
            SendReply("Lệnh: setpre, model, cooldown, clear, bypass on/off, auto on/off, greet on/off, stealth normal/agg", false)
            return true
        elseif cmd == "clear" then
            history = {}
            Rayfield:Notify({Title = "🗑️ HISTORY", Content = "Đã xóa", Duration = 2})
            return true
        elseif cmd == "bypass on" then
            CONFIG.ENABLE_HOMOGLYPH = true
            Rayfield:Notify({Title = "✅ BYPASS", Content = "Đã BẬT", Duration = 2})
            return true
        elseif cmd == "bypass off" then
            CONFIG.ENABLE_HOMOGLYPH = false
            Rayfield:Notify({Title = "⛔ BYPASS", Content = "Đã TẮT", Duration = 2})
            return true
        elseif cmd == "stealth normal" then
            CONFIG.STEALTH_LEVEL = "Normal"
            CONFIG.MAX_REPLY_LENGTH = 150
            CONFIG.BASE_INTERVAL = 1.2
            Rayfield:Notify({Title = "🕵️ STEALTH", Content = "Chế độ Normal (ít ẩn hơn)", Duration = 2})
            return true
        elseif cmd == "stealth agg" then
            CONFIG.STEALTH_LEVEL = "Aggressive"
            CONFIG.MAX_REPLY_LENGTH = 80
            CONFIG.BASE_INTERVAL = 1.5
            Rayfield:Notify({Title = "🕵️ STEALTH", Content = "Chế độ Aggressive (tối đa ẩn)", Duration = 2})
            return true
        end
        return false
    end

    local function HandleChatMessage(content, speaker, isCommandOnly)
        if not CONFIG.BOT_ENABLED then return false end
        local lower = string.lower(content)
        if string.sub(lower, 1, #CONFIG.PREFIX) == CONFIG.PREFIX then
            local command = string.sub(content, #CONFIG.PREFIX + 1)
            if command == "" then return end
            task.spawn(function()
                if ProcessCommand(command, speaker.Name) then return end
                if CanProcess(speaker.Name) then
                    local ans, err = AskAI(command, speaker.Name)
                    if ans then SendReply(ans, false, speaker.Name) end
                end
            end)
            return true
        end
        if CONFIG.AUTO_RESPOND_NO_PREFIX and not isCommandOnly then
            if #content < CONFIG.MIN_MESSAGE_LENGTH then return false end
            local lowerContent = string.lower(content)
            local matched = false
            for _, kw in ipairs(CONFIG.TRIGGER_KEYWORDS) do
                if string.find(lowerContent, kw, 1, true) then
                    matched = true
                    break
                end
            end
            if matched or string.find(lowerContent, "giúp") or string.find(lowerContent, "cho tôi") then
                if CanProcess(speaker.Name) then
                    task.spawn(function()
                        local ans, err = AskAI(content, speaker.Name)
                        if ans then SendReply(ans, false, speaker.Name) end
                    end)
                    return true
                end
            end
        end
        return false
    end

    -- BẮT CHAT CŨ
    local function FindChatFrame()
        for _, obj in ipairs(CoreGui:GetChildren()) do
            if obj:IsA("Frame") and (obj:FindFirstChild("ChatBarParent") or obj.Name == "Chat" or obj.Name == "ChatFrame") then
                return obj
            end
        end
        for _, obj in ipairs(LocalPlayer.PlayerGui:GetChildren()) do
            if obj:IsA("Frame") and (obj.Name == "Chat" or obj.Name == "ChatFrame") then return obj end
        end
        return nil
    end

    local function HookChatOld()
        local chatFrame = FindChatFrame()
        if not chatFrame then
            Rayfield:Notify({Title = "⚠️ CHAT CŨ", Content = "Không tìm thấy khung chat", Duration = 2})
            return
        end
        local chatLog = chatFrame:FindFirstChild("ChatLog") or chatFrame:FindFirstChild("ScrollingFrame")
        if chatLog then
            chatLog.ChildAdded:Connect(function(child)
                if child:IsA("TextLabel") or child:IsA("TextButton") then
                    local text = child.Text
                    if text and text ~= "" then
                        local _, endIndex = string.find(text, ": ")
                        if endIndex then
                            local name = string.sub(text, 1, endIndex - 2)
                            local content = string.sub(text, endIndex + 1)
                            if name and content and content ~= "" then
                                local speaker = Players:FindFirstChild(name) or LocalPlayer
                                if speaker ~= LocalPlayer then
                                    if CONFIG.AUTO_CHAT_ENABLED then
                                        HandleChatMessage(content, speaker)
                                    end
                                end
                            end
                        end
                    end
                end
            end)
        else
            Rayfield:Notify({Title = "⚠️ CHAT CŨ", Content = "Không tìm thấy ChatLog", Duration = 2})
        end
    end

    local function StartListening()
        if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
            TextChatService.MessageReceived:Connect(function(msg)
                local speaker = msg.TextSource
                if not speaker or speaker == LocalPlayer then return end
                local content = msg.Text
                if content and content ~= "" then
                    HandleChatMessage(content, speaker)
                end
            end)
            Rayfield:Notify({Title = "✅ CHAT MỚI", Content = "Đã sẵn sàng", Duration = 2})
        else
            LocalPlayer.Chatted:Connect(function(msg)
                if string.sub(string.lower(msg), 1, #CONFIG.PREFIX) == CONFIG.PREFIX then
                    local q = string.sub(msg, #CONFIG.PREFIX + 1)
                    if q ~= "" then
                        task.spawn(function()
                            if ProcessCommand(q, LocalPlayer.Name) then return end
                            if CanProcess(LocalPlayer.Name) then
                                local ans, err = AskAI(q, LocalPlayer.Name)
                                if ans then SendReply(ans, false, LocalPlayer.Name) end
                            end
                        end)
                    end
                end
            end)
            HookChatOld()
            Rayfield:Notify({Title = "✅ CHAT CŨ", Content = "Đã sẵn sàng", Duration = 2})
        end
    end

    -- AUTO GREET
    if CONFIG.AUTO_GREET_ON_JOIN then
        Players.PlayerAdded:Connect(function(player)
            if player ~= LocalPlayer then
                task.wait(2)
                if CONFIG.BOT_ENABLED and CONFIG.AUTO_CHAT_ENABLED then
                    SendReply("Chào "..player.Name.."! "..CONFIG.GREET_MESSAGE, false, player.Name)
                end
            end
        end)
    end

    -- ============================================
    -- RAYFIELD MENU (thêm Stealth Level)
    -- ============================================
    local Window = Rayfield:CreateWindow({
        Name = "MINHCHIEN X AIBOT",
        Icon = 0,
        LoadingTitle = "MINHCHIEN X AIBOT",
        LoadingSubtitle = "by Axiom",
        Theme = "Default",
        ToggleUIKeybind = "K",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "MINHCHIEN_AI",
            FileName = "Config"
        },
        KeySystem = false,
    })

    local MainTab = Window:CreateTab("Tổng quan", 4483362458)
    MainTab:CreateSection("Trạng thái")
    MainTab:CreateToggle({
        Name = "Bật/Tắt Bot",
        CurrentValue = CONFIG.BOT_ENABLED,
        Flag = "BotEnabled",
        Callback = function(Value)
            CONFIG.BOT_ENABLED = Value
            Rayfield:Notify({Title = "🤖 BOT", Content = Value and "Đã BẬT" or "Đã TẮT", Duration = 2})
        end
    })

    local AutoTab = Window:CreateTab("Tự động", 4483362458)
    AutoTab:CreateSection("Auto-chat")
    AutoTab:CreateToggle({
        Name = "Auto-chat",
        CurrentValue = CONFIG.AUTO_CHAT_ENABLED,
        Flag = "AutoChat",
        Callback = function(Value)
            CONFIG.AUTO_CHAT_ENABLED = Value
            CONFIG.AUTO_RESPOND_NO_PREFIX = Value
            Rayfield:Notify({Title = "🤖 AUTO", Content = Value and "Đã BẬT" or "Đã TẮT", Duration = 2})
        end
    })
    AutoTab:CreateToggle({
        Name = "Chào hỏi người mới",
        CurrentValue = CONFIG.AUTO_GREET_ON_JOIN,
        Flag = "AutoGreet",
        Callback = function(Value)
            CONFIG.AUTO_GREET_ON_JOIN = Value
            Rayfield:Notify({Title = "👋 GREET", Content = Value and "Đã BẬT" or "Đã TẮT", Duration = 2})
        end
    })

    local SecurityTab = Window:CreateTab("Bảo mật", 4483362458)
    SecurityTab:CreateSection("Bypass Filter")
    SecurityTab:CreateToggle({
        Name = "Bypass Homoglyph (chống ###)",
        CurrentValue = CONFIG.ENABLE_HOMOGLYPH,
        Flag = "Homoglyph",
        Callback = function(Value)
            CONFIG.ENABLE_HOMOGLYPH = Value
            Rayfield:Notify({Title = "🔐 BYPASS", Content = Value and "Đã BẬT" or "Đã TẮT", Duration = 2})
        end
    })
    SecurityTab:CreateDropdown({
        Name = "Chế độ ẩn (Stealth)",
        Options = {"Normal", "Aggressive"},
        CurrentOption = CONFIG.STEALTH_LEVEL,
        Callback = function(opt)
            CONFIG.STEALTH_LEVEL = opt
            if opt == "Normal" then
                CONFIG.MAX_REPLY_LENGTH = 150
                CONFIG.BASE_INTERVAL = 1.2
            else
                CONFIG.MAX_REPLY_LENGTH = 80
                CONFIG.BASE_INTERVAL = 1.5
            end
            Rayfield:Notify({Title = "🕵️ STEALTH", Content = "Chế độ "..opt, Duration = 2})
        end
    })

    local SettingsTab = Window:CreateTab("Cài đặt", 4483362458)
    SettingsTab:CreateSection("Cấu hình AI")
    SettingsTab:CreateInput({
        Name = "Prefix (mặc định: !ai )",
        PlaceholderText = "Nhập prefix mới",
        RemoveTextAfterFocusLost = true,
        Callback = function(Text)
            if Text and Text ~= "" then
                CONFIG.PREFIX = Text
                Rayfield:Notify({Title = "✅ PREFIX", Content = "Đổi thành: "..Text, Duration = 2})
            end
        end
    })
    SettingsTab:CreateInput({
        Name = "Model (mặc định: gemini-2.5-flash-lite)",
        PlaceholderText = "Nhập tên model",
        RemoveTextAfterFocusLost = true,
        Callback = function(Text)
            if Text and Text ~= "" then
                CONFIG.MODEL = Text
                GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/"..Text..":generateContent?key="..CONFIG.API_KEY
                Rayfield:Notify({Title = "✅ MODEL", Content = "Đổi thành: "..Text, Duration = 2})
            end
        end
    })
    SettingsTab:CreateSlider({
        Name = "Cooldown (giây)",
        Range = {0, 10},
        Increment = 0.5,
        Suffix = "s",
        CurrentValue = CONFIG.COOLDOWN,
        Flag = "Cooldown",
        Callback = function(Value)
            CONFIG.COOLDOWN = Value
            Rayfield:Notify({Title = "✅ COOLDOWN", Content = "Đặt thành: "..Value.."s", Duration = 2})
        end
    })

    SettingsTab:CreateSection("Cài đặt tin nhắn")
    SettingsTab:CreateSlider({
        Name = "Độ dài tin nhắn tối đa",
        Range = {30, 200},
        Increment = 10,
        Suffix = " ký tự",
        CurrentValue = CONFIG.MAX_REPLY_LENGTH,
        Flag = "MaxLength",
        Callback = function(Value)
            CONFIG.MAX_REPLY_LENGTH = Value
            Rayfield:Notify({Title = "✅ ĐỘ DÀI", Content = "Đặt thành: "..Value, Duration = 2})
        end
    })
    SettingsTab:CreateSlider({
        Name = "Khoảng cách gửi tin (giây)",
        Range = {0.5, 5},
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = CONFIG.BASE_INTERVAL,
        Flag = "SendInterval",
        Callback = function(Value)
            CONFIG.BASE_INTERVAL = Value
            Rayfield:Notify({Title = "✅ KHOẢNG CÁCH", Content = "Đặt thành: "..Value.."s", Duration = 2})
        end
    })

    SettingsTab:CreateSection("Lệnh nhanh")
    SettingsTab:CreateButton({
        Name = "Xóa lịch sử hội thoại",
        Callback = function()
            history = {}
            Rayfield:Notify({Title = "🗑️ HISTORY", Content = "Đã xóa!", Duration = 2})
        end
    })
    SettingsTab:CreateButton({
        Name = "Reset toàn bộ cấu hình",
        Callback = function()
            CONFIG.PREFIX = "!ai "
            CONFIG.MODEL = "gemini-2.5-flash-lite"
            CONFIG.COOLDOWN = 2
            CONFIG.MAX_REPLY_LENGTH = 80
            CONFIG.BASE_INTERVAL = 1.5
            CONFIG.ENABLE_HOMOGLYPH = true
            CONFIG.STEALTH_LEVEL = "Aggressive"
            CONFIG.AUTO_CHAT_ENABLED = true
            CONFIG.AUTO_RESPOND_NO_PREFIX = true
            CONFIG.AUTO_GREET_ON_JOIN = true
            CONFIG.BOT_ENABLED = true
            GEMINI_URL = "https://generativelanguage.googleapis.com/v1beta/models/"..CONFIG.MODEL..":generateContent?key="..CONFIG.API_KEY
            Rayfield:Notify({Title = "🔄 RESET", Content = "Đã reset!", Duration = 3})
        end
    })

    -- KHỞI ĐỘNG
    StartListening()
    Rayfield:Notify({Title = "🚀 KHỞI ĐỘNG", Content = "AI BOT + STEALTH MODE ĐÃ CHẠY!", Duration = 3})
    Rayfield:Notify({Title = "⌨️ PHÍM TẮT", Content = "Nhấn K để mở menu", Duration = 3})
    Rayfield:Notify({Title = "🕵️ STEALTH", Content = "Chế độ "..CONFIG.STEALTH_LEVEL, Duration = 3})
end