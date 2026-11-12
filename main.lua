local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
    Title = "AIM MENU - WIND UI",
    Author = "TikTok: thangtran050594",
    Folder = "WindUI_Aim"
})

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------
-- TAB AIM
--------------------------------------------------

local Tab = Window:Tab({
    Title = "Aim",
    Icon = "crosshair"
})

local AimEnabled = false
local CircleEnabled = true
local FOVSize = 200
local Prediction = 0
local AimDistance = 0
local AimSmoothness = 0
local IgnorePlayers = {}

local CircleGui = Instance.new("ScreenGui")
CircleGui.Name = "AimFOV"
CircleGui.IgnoreGuiInset = true
CircleGui.ResetOnSpawn = false
CircleGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local Circle = Instance.new("Frame")
Circle.Name = "Circle"
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.Position = UDim2.fromScale(0.5, 0.5)
Circle.Size = UDim2.fromOffset(FOVSize * 2, FOVSize * 2)
Circle.BackgroundTransparency = 1
Circle.Visible = false
Circle.Parent = CircleGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(1, 0)
Corner.Parent = Circle

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 2
Stroke.Parent = Circle

local Hue = 0

local function UpdateCircle()
    Circle.Visible = AimEnabled and CircleEnabled
end

RunService.RenderStepped:Connect(function(DeltaTime)
    Hue = (Hue + DeltaTime * 0.25) % 1
    Stroke.Color = Color3.fromHSV(Hue, 1, 1)
end)

local function GetCenterTarget()
    if AimDistance <= 0 then
        return nil
    end

    local Center = Camera.ViewportSize / 2
    local ClosestPlayer = nil
    local ClosestScreenDistance = FOVSize

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and not IgnorePlayers[Player.Name] then
            local Character = Player.Character
            local Root = Character and Character:FindFirstChild("HumanoidRootPart")
            local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")

            if Root and Humanoid and Humanoid.Health > 0 then
                local WorldDistance =
                    (Root.Position - Camera.CFrame.Position).Magnitude

                if WorldDistance <= AimDistance then
                    local ScreenPos, OnScreen =
                        Camera:WorldToViewportPoint(Root.Position)

                    if OnScreen then
                        local ScreenDistance =
                            (Vector2.new(ScreenPos.X, ScreenPos.Y) - Center).Magnitude

                        if ScreenDistance <= ClosestScreenDistance then
                            ClosestScreenDistance = ScreenDistance
                            ClosestPlayer = Player
                        end
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

RunService.RenderStepped:Connect(function()
    if not AimEnabled or AimDistance <= 0 then
        return
    end

    local Target = GetCenterTarget()

    if Target and Target.Character then
        local Root = Target.Character:FindFirstChild("HumanoidRootPart")

        if Root then
            local Velocity = Root.AssemblyLinearVelocity

            local AimPosition =
                Root.Position + Velocity * (Prediction / 100)

            local TargetCFrame = CFrame.lookAt(
                Camera.CFrame.Position,
                AimPosition
            )

            if AimSmoothness <= 0 then
                Camera.CFrame = TargetCFrame
            else
                local Alpha =
                    0.05 + (AimSmoothness / 100) * 0.95

                Camera.CFrame =
                    Camera.CFrame:Lerp(TargetCFrame, Alpha)
            end
        end
    end
end)

local function GetPlayerNames()
    local Names = {}

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            table.insert(Names, Player.Name)
        end
    end

    table.sort(Names)
    return Names
end

Tab:Toggle({
    Title = "Aim",
    Default = false,

    Callback = function(Value)
        AimEnabled = Value
        UpdateCircle()
    end
})

Tab:Toggle({
    Title = "Hiện vòng",
    Default = true,

    Callback = function(Value)
        CircleEnabled = Value
        UpdateCircle()
    end
})

Tab:Slider({
    Title = "Kích thước vòng",
    Step = 1,

    Value = {
        Min = 50,
        Max = 500,
        Default = 200
    },

    Callback = function(Value)
        FOVSize = Value
        Circle.Size = UDim2.fromOffset(FOVSize * 2, FOVSize * 2)
    end
})

Tab:Slider({
    Title = "Prediction",
    Step = 1,

    Value = {
        Min = 0,
        Max = 100,
        Default = 0
    },

    Callback = function(Value)
        Prediction = Value
    end
})

Tab:Slider({
    Title = "Độ mượt",
    Step = 1,

    Value = {
        Min = 0,
        Max = 100,
        Default = 0
    },

    Callback = function(Value)
        AimSmoothness = Value
    end
})

Tab:Slider({
    Title = "Độ xa",
    Step = 1,

    Value = {
        Min = 0,
        Max = 500,
        Default = 0
    },

    Callback = function(Value)
        AimDistance = Value
    end
})

local IgnoreDropdown = Tab:Dropdown({
    Title = "Chọn người không aim",
    Values = GetPlayerNames(),
    Value = {},
    Multi = true,
    AllowNone = true,
    SearchBarEnabled = true,

    Callback = function(Values)
        IgnorePlayers = {}

        if type(Values) == "table" then
            for _, Name in ipairs(Values) do
                IgnorePlayers[Name] = true
            end
        end
    end
})

local function RefreshPlayers()
    if IgnoreDropdown and IgnoreDropdown.Refresh then
        IgnoreDropdown:Refresh(GetPlayerNames())
    end
end

Players.PlayerAdded:Connect(function()
    task.wait(0.2)
    RefreshPlayers()
end)

Players.PlayerRemoving:Connect(function(Player)
    IgnorePlayers[Player.Name] = nil
    task.wait(0.1)
    RefreshPlayers()
end)

--------------------------------------------------
-- TAB MUSIC VIP
--------------------------------------------------

local MusicTab = Window:Tab({
    Title = "Music VIP",
    Icon = "music"
})

local Sound = Instance.new("Sound")
Sound.Name = "VIPMusic"
Sound.Volume = 1
Sound.Looped = true
Sound.Parent = workspace

local CurrentID = ""
local CustomID = ""

local MusicList = {
    ["See Tình"] = "121242950842428",
    ["Trả Lại Cho Anh Remix"] = "110396752508363",
    ["Tuyển Vợ Remix"] = "139968910103444",
    ["2 Phút Hơn × Mimimi Remix"] = "124166975687737",
    ["Cố Giang Tình DJ"] = "103038059531764",
    ["Hối Hận Trong Anh DJ"] = "80415307715259",
    ["Thế Gian Xoay Vòng Remix"] = "113675312413032",
    ["Phía Sau Một Cô Gái Remix"] = "109743636792463",
    ["Khuê Mộc Lan"] = "98361989582185",
    ["Chỉ Còn Là Giấc Mơ Remix"] = "121051113937228",
    ["Phố Cũ Còn Anh Remix"] = "107810773290624",
    ["Katy Katy Remix"] = "95300067259927",
    ["Sóng Và Gió Remix"] = "90113853563664",
    ["Chuyện Nàng Trinh Nữ Tên Thi Remix"] = "119526323504077",
    ["Lạc Chốn Hồng Trần"] = "116260601379194",
    ["Mất Anh Rồi"] = "118574601343022"
}

local MusicNames = {}

for Name in pairs(MusicList) do
    table.insert(MusicNames, Name)
end

table.sort(MusicNames)

MusicTab:Dropdown({
    Title = "Chọn bài nhạc",
    Values = MusicNames,
    Value = MusicNames[1],

    Callback = function(Value)
        CurrentID = MusicList[Value] or ""
    end
})

MusicTab:Button({
    Title = "▶ Play",

    Callback = function()
        if CurrentID ~= "" then
            Sound:Stop()
            Sound.SoundId = "rbxassetid://" .. CurrentID
            Sound.TimePosition = 0
            Sound:Play()
        end
    end
})

MusicTab:Button({
    Title = "⏹ Stop",

    Callback = function()
        Sound:Stop()
    end
})

MusicTab:Slider({
    Title = "🔊 Âm lượng",
    Step = 1,

    Value = {
        Min = 0,
        Max = 100,
        Default = 100
    },

    Callback = function(Value)
        Sound.Volume = Value / 100
    end
})

MusicTab:Space({
    Size = 30
})

MusicTab:Input({
    Title = "ID nhạc",
    Placeholder = "Nhập ID nhạc...",

    Callback = function(Value)
        CustomID = tostring(Value)
    end
})

MusicTab:Button({
    Title = "▶ Play ID",

    Callback = function()
        local ID = CustomID:gsub("%D", "")

        if ID ~= "" then
            Sound:Stop()
            Sound.SoundId = "rbxassetid://" .. ID
            Sound.TimePosition = 0
            Sound:Play()
        end
    end
})

MusicTab:Button({
    Title = "⏹ Stop ID",

    Callback = function()
        Sound:Stop()
    end
})

MusicTab:Slider({
    Title = "🔊 Âm lượng ID",
    Step = 1,

    Value = {
        Min = 0,
        Max = 100,
        Default = 100
    },

    Callback = function(Value)
        Sound.Volume = Value / 100
    end
})

--------------------------------------------------
-- TAB ESP
--------------------------------------------------

local ESPTab = Window:Tab({
    Title = "ESP",
    Icon = "eye"
})

local ESPEnabled = false
local ESPNameEnabled = false
local ESPDistance = 0
local ESPObjects = {}
local ESPHue = 0

local function RemoveESP(Player)
    local Data = ESPObjects[Player]

    if Data then
        if Data.Highlight then
            Data.Highlight:Destroy()
        end

        if Data.NameTag then
            Data.NameTag:Destroy()
        end

        ESPObjects[Player] = nil
    end
end

local function CreateESP(Player)
    if Player == LocalPlayer then
        return
    end

    RemoveESP(Player)

    local Character = Player.Character
    if not Character then
        return
    end

    local Root = Character:FindFirstChild("HumanoidRootPart")
    if not Root then
        return
    end

    local Highlight

    if ESPEnabled then
        Highlight = Instance.new("Highlight")
        Highlight.Name = "ESPHighlight"
        Highlight.Adornee = Character
        Highlight.FillTransparency = 0.5
        Highlight.OutlineTransparency = 0
        Highlight.Parent = Character
    end

    local NameTag

    if ESPNameEnabled then
        NameTag = Instance.new("BillboardGui")
        NameTag.Name = "ESPName"
        NameTag.Adornee = Root
        NameTag.Size = UDim2.fromOffset(220, 40)
        NameTag.StudsOffset = Vector3.new(0, 3, 0)
        NameTag.AlwaysOnTop = false
        NameTag.MaxDistance = ESPDistance
        NameTag.Parent = Character

        local NameLabel = Instance.new("TextLabel")
        NameLabel.Size = UDim2.fromScale(1, 1)
        NameLabel.BackgroundTransparency = 1
        NameLabel.Text = Player.Name
        NameLabel.TextSize = 16
        NameLabel.Font = Enum.Font.GothamBold
        NameLabel.TextStrokeTransparency = 0
        NameLabel.Parent = NameTag

        ESPObjects[Player] = {
            Highlight = Highlight,
            NameTag = NameTag,
            NameLabel = NameLabel
        }
    else
        ESPObjects[Player] = {
            Highlight = Highlight
        }
    end
end

local function RefreshESP()
    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer then
            if ESPEnabled or ESPNameEnabled then
                CreateESP(Player)
            else
                RemoveESP(Player)
            end
        end
    end
end

ESPTab:Toggle({
    Title = "ESP",
    Default = false,

    Callback = function(Value)
        ESPEnabled = Value
        RefreshESP()
    end
})

ESPTab:Toggle({
    Title = "Tên người chơi",
    Default = false,

    Callback = function(Value)
        ESPNameEnabled = Value
        RefreshESP()
    end
})

ESPTab:Slider({
    Title = "Nhìn bao xa",
    Step = 10,

    Value = {
        Min = 0,
        Max = 5000,
        Default = 0
    },

    Callback = function(Value)
        ESPDistance = Value

        for _, Data in pairs(ESPObjects) do
            if Data.NameTag then
                Data.NameTag.MaxDistance = Value
            end
        end
    end
})

Players.PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function()
        task.wait(0.5)

        if ESPEnabled or ESPNameEnabled then
            CreateESP(Player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(Player)
    RemoveESP(Player)
end)

RunService.RenderStepped:Connect(function(DeltaTime)
    ESPHue = (ESPHue + DeltaTime * 0.25) % 1

    local Rainbow = Color3.fromHSV(ESPHue, 1, 1)

    for _, Data in pairs(ESPObjects) do
        if Data.Highlight then
            Data.Highlight.FillColor = Rainbow
            Data.Highlight.OutlineColor = Rainbow
        end

        if Data.NameLabel then
            Data.NameLabel.TextColor3 = Rainbow
        end
    end
end)

--------------------------------------------------
-- TAB SETTING
--------------------------------------------------

local SettingTab = Window:Tab({
    Title = "Setting",
    Icon = "settings"
})

WindUI:AddTheme({
    Name = "Neon Blue",
    Accent = Color3.fromHex("#00BFFF"),
    Background = Color3.fromHex("#0A0A12"),
    Outline = Color3.fromHex("#00BFFF"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#888888"),
    Button = Color3.fromHex("#12304A"),
    Icon = Color3.fromHex("#00BFFF")
})

WindUI:AddTheme({
    Name = "Neon Purple",
    Accent = Color3.fromHex("#A855F7"),
    Background = Color3.fromHex("#0D0715"),
    Outline = Color3.fromHex("#A855F7"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#888888"),
    Button = Color3.fromHex("#35154D"),
    Icon = Color3.fromHex("#A855F7")
})

WindUI:AddTheme({
    Name = "Neon Red",
    Accent = Color3.fromHex("#FF1744"),
    Background = Color3.fromHex("#120709"),
    Outline = Color3.fromHex("#FF1744"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#888888"),
    Button = Color3.fromHex("#4A101A"),
    Icon = Color3.fromHex("#FF1744")
})

WindUI:AddTheme({
    Name = "Neon Green",
    Accent = Color3.fromHex("#00FF88"),
    Background = Color3.fromHex("#06120D"),
    Outline = Color3.fromHex("#00FF88"),
    Text = Color3.fromHex("#FFFFFF"),
    Placeholder = Color3.fromHex("#888888"),
    Button = Color3.fromHex("#0C4029"),
    Icon = Color3.fromHex("#00FF88")
})

local RainbowUIEnabled = false
local RainbowThemes = {
    "Neon Blue",
    "Neon Purple",
    "Neon Red",
    "Neon Green"
}

local RainbowIndex = 1

SettingTab:Dropdown({
    Title = "Màu giao diện",
    Values = {
        "Dark",
        "Light",
        "Neon Blue",
        "Neon Purple",
        "Neon Red",
        "Neon Green"
    },
    Value = "Dark",

    Callback = function(Value)
        if not RainbowUIEnabled then
            WindUI:SetTheme(Value)
        end
    end
})

SettingTab:Toggle({
    Title = "Viền UI cầu vồng",
    Default = false,

    Callback = function(Value)
        RainbowUIEnabled = Value

        if not Value then
            WindUI:SetTheme("Dark")
        end
    end
})

SettingTab:Paragraph({
    Title = "Code",
    Desc = "TikTok: thangtran050594",
    Icon = "code"
})

task.spawn(function()
    while task.wait(0.15) do
        if RainbowUIEnabled then
            WindUI:SetTheme(RainbowThemes[RainbowIndex])

            RainbowIndex = RainbowIndex + 1

            if RainbowIndex > #RainbowThemes then
                RainbowIndex = 1
            end
        end
    end
end) 
