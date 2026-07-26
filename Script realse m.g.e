local ok, BetterOrion = pcall(function()
    return loadstring(game:HttpGet("https://gitlab.com/m1kp0/BetterOrion/raw/main/Library.lua"))()
end)
if not ok or not BetterOrion then
    warn("Failed to load BetterOrion Library.")
    return
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LP = Players.LocalPlayer

local function notify(title, content, icon)
    BetterOrion:MakeNotification({ Name = title, Content = content, Image = icon or "bell", Time = 4 })
end

local S = {
    SpeedOn=false, Speed=100,
    InfJumpOn=false,
    NoclipOn=false,
    ThirdPersonOn=false,
    ESPOn=false,
    TaskESPOn=false,
    MonsterESPOn=false,
    BrightOn=false,
    HideMobsOn=false,
    ShadersOn=false,
    SelectedShader="Cinematic",
    Colors = {
        Player = Color3.fromRGB(60,200,100),
        Task = Color3.fromRGB(170,90,255),
        Monster = Color3.fromRGB(255,120,20),
    },
}

local function getHum() local c=LP.Character; return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot() local c=LP.Character; return c and c:FindFirstChild("HumanoidRootPart") end

local speedConns = {}
local function hookSpeed(hum)
    for _,c in ipairs(speedConns) do pcall(function() c:Disconnect() end) end
    speedConns = {}
    if not hum then return end
    table.insert(speedConns, hum:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if S.SpeedOn and hum.WalkSpeed ~= S.Speed then
            task.defer(function() pcall(function() if S.SpeedOn then hum.WalkSpeed = S.Speed end end) end)
        end
    end))
end
RunService.Heartbeat:Connect(function()
    local hum = getHum(); if not hum then return end
    if S.SpeedOn then pcall(function() hum.WalkSpeed = S.Speed end) end
end)
LP.CharacterAdded:Connect(function(c) task.wait(0.3); hookSpeed(c:FindFirstChildOfClass("Humanoid")) end)
pcall(function() hookSpeed(getHum()) end)

RunService.Stepped:Connect(function()
    if not S.NoclipOn then return end
    local c = LP.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
end)
local function restoreCollide()
    pcall(function()
        local c = LP.Character; if not c then return end
        for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end
    end)
end

UIS.JumpRequest:Connect(function()
    if not S.InfJumpOn then return end
    pcall(function() local h=getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end end)
end)

local function setThirdPerson(on)
    pcall(function()
        LP.CameraMode = on and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson
        LP.CameraMaxZoomDistance = on and 128 or 0.5
    end)
end

local origLighting = {
    Brightness=Lighting.Brightness, ClockTime=Lighting.ClockTime,
    FogEnd=Lighting.FogEnd, FogStart=Lighting.FogStart,
    GlobalShadows=Lighting.GlobalShadows, Ambient=Lighting.Ambient,
    OutdoorAmbient=Lighting.OutdoorAmbient,
}
local function setBright(on)
    if on then
        Lighting.Brightness=3; Lighting.ClockTime=14
        Lighting.FogEnd=100000; Lighting.FogStart=100000
        Lighting.GlobalShadows=false
        Lighting.Ambient=Color3.fromRGB(200,200,200)
        Lighting.OutdoorAmbient=Color3.fromRGB(200,200,200)
        for _,v in ipairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled=false end
        end
    else
        for k,v in pairs(origLighting) do pcall(function() Lighting[k]=v end) end
        for _,v in ipairs(Lighting:GetChildren()) do
            if v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") then v.Enabled=true end
        end
    end
end

local shaderEffects = {}
local function clearShaders()
    for _,eff in ipairs(shaderEffects) do pcall(function() eff:Destroy() end) end
    shaderEffects = {}
end

local shaderPresets = {
    ["Cinematic"] = function()
        local cc = Instance.new("ColorCorrectionEffect", Lighting)
        cc.Saturation = 0.05; cc.Contrast = 0.28; cc.TintColor = Color3.fromRGB(255,225,190)
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 0.4; bloom.Size = 18; bloom.Threshold = 0.85
        local dof = Instance.new("DepthOfFieldEffect", Lighting)
        dof.FarIntensity = 0.3; dof.FocusDistance = 20; dof.InFocusRadius = 25
        table.insert(shaderEffects, cc); table.insert(shaderEffects, bloom); table.insert(shaderEffects, dof)
    end,
    ["Realistic"] = function()
        local cc = Instance.new("ColorCorrectionEffect", Lighting)
        cc.Saturation = 0.1; cc.Contrast = 0.15
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 0.2; bloom.Size = 14; bloom.Threshold = 0.9
        local atm = Instance.new("Atmosphere", Lighting)
        atm.Density = 0.25; atm.Haze = 0.7; atm.Glare = 0.25
        table.insert(shaderEffects, cc); table.insert(shaderEffects, bloom); table.insert(shaderEffects, atm)
    end,
    ["Cyberpunk"] = function()
        local cc = Instance.new("ColorCorrectionEffect", Lighting)
        cc.Saturation = 0.6; cc.Contrast = 0.4; cc.TintColor = Color3.fromRGB(255,170,255)
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 2.5; bloom.Size = 40; bloom.Threshold = 0.15
        local atm = Instance.new("Atmosphere", Lighting)
        atm.Density = 0.35; atm.Haze = 1.3; atm.Color = Color3.fromRGB(255,0,128)
        table.insert(shaderEffects, cc); table.insert(shaderEffects, bloom); table.insert(shaderEffects, atm)
    end,
    ["Vintage VHS"] = function()
        local cc = Instance.new("ColorCorrectionEffect", Lighting)
        cc.Saturation = -0.3; cc.Contrast = 0.35; cc.TintColor = Color3.fromRGB(240,255,240)
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 0.7; bloom.Size = 22
        local blur = Instance.new("BlurEffect", Lighting)
        blur.Size = 1.2
        table.insert(shaderEffects, cc); table.insert(shaderEffects, bloom); table.insert(shaderEffects, blur)
    end,
    ["Dreamy Anime"] = function()
        local cc = Instance.new("ColorCorrectionEffect", Lighting)
        cc.Saturation = 0.5; cc.Contrast = 0.05; cc.TintColor = Color3.fromRGB(255,250,240)
        local bloom = Instance.new("BloomEffect", Lighting)
        bloom.Intensity = 0.35; bloom.Size = 10
        local atm = Instance.new("Atmosphere", Lighting)
        atm.Density = 0.15; atm.Haze = 0.35; atm.Color = Color3.fromRGB(255,220,255)
        table.insert(shaderEffects, cc); table.insert(shaderEffects, bloom); table.insert(shaderEffects, atm)
    end,
}

local function applyShader()
    clearShaders()
    if not S.ShadersOn then return end
    local fn = shaderPresets[S.SelectedShader]
    if fn then fn() end
end

local hiddenMobs = {}

local function hideMob(model)
    if hiddenMobs[model] then return end
    local parts = {}
    for _,d in ipairs(model:GetDescendants()) do
        if d:IsA("BasePart") then
            table.insert(parts, {part=d, transparency=d.Transparency, collide=d.CanCollide})
            d.Transparency = 1
            d.CanCollide = false
        elseif d:IsA("Decal") or d:IsA("Texture") then
            table.insert(parts, {part=d, transparency=d.Transparency})
            d.Transparency = 1
        end
    end
    hiddenMobs[model] = parts
end

local function restoreMob(model)
    local parts = hiddenMobs[model]
    if not parts then return end
    for _,entry in ipairs(parts) do
        pcall(function()
            entry.part.Transparency = entry.transparency
            if entry.collide ~= nil then entry.part.CanCollide = entry.collide end
        end)
    end
    hiddenMobs[model] = nil
end

local function isMob(m)
    if not m:IsA("Model") then return false end
    if Players:GetPlayerFromCharacter(m) then return false end
    return m:FindFirstChildOfClass("Humanoid") ~= nil
end

local function refreshHiddenMobs()
    if not S.HideMobsOn then return end
    for _,m in ipairs(workspace:GetDescendants()) do
        if isMob(m) then hideMob(m) end
    end
end

local function restoreAllMobs()
    for model,_ in pairs(hiddenMobs) do
        if model and model.Parent then restoreMob(model) end
    end
    hiddenMobs = {}
end

task.spawn(function() while true do task.wait(2); refreshHiddenMobs() end end)

local function clearTagESP(model, tag, tagBB)
    for _,v in ipairs(model:GetDescendants()) do
        if v.Name==tag or v.Name==tagBB then v:Destroy() end
    end
end

local function makeESP(model, tag, tagBB, color, displayName)
    clearTagESP(model, tag, tagBB)
    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChildWhichIsA("BasePart")
    if not root then return end

    local hl = Instance.new("Highlight")
    hl.Name=tag; hl.FillColor=color; hl.OutlineColor=color
    hl.FillTransparency=0.6; hl.OutlineTransparency=0; hl.Adornee=model; hl.Parent=model

    local bb = Instance.new("BillboardGui")
    bb.Name=tagBB; bb.AlwaysOnTop=true; bb.Size=UDim2.new(0,170,0,28)
    bb.StudsOffset=Vector3.new(0,3,0); bb.Adornee=root; bb.Parent=model

    local bg = Instance.new("Frame", bb)
    bg.Size=UDim2.new(1,0,1,0); bg.BackgroundColor3=Color3.fromRGB(0,0,0)
    bg.BackgroundTransparency=0.35; bg.BorderSizePixel=0
    Instance.new("UICorner", bg).CornerRadius=UDim.new(0,5)

    local nameLbl = Instance.new("TextLabel", bg)
    nameLbl.Size=UDim2.new(1,0,1,0); nameLbl.BackgroundTransparency=1
    nameLbl.Text=displayName; nameLbl.TextColor3=color
    nameLbl.TextStrokeTransparency=0.4; nameLbl.TextScaled=true; nameLbl.Font=Enum.Font.GothamBold

    return hl, nameLbl
end

local function updateESPColor(tag, color)
    for _,v in ipairs(workspace:GetDescendants()) do
        if v.Name == tag and v:IsA("Highlight") then
            v.FillColor = color
            v.OutlineColor = color
        end
    end
end

local function refreshPlayerESP()
    if not S.ESPOn then return end
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character then makeESP(p.Character, "_PESP", "_PESPBB", S.Colors.Player, p.Name) end
    end
end
local function clearAllPlayerESP()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v.Name=="_PESP" or v.Name=="_PESPBB" then v:Destroy() end
    end
end
task.spawn(function() while true do task.wait(3); refreshPlayerESP() end end)

-- Whole-word match to avoid false positives (e.g. "key" matching "Monkey", "point" matching "Checkpoint")
local taskKeywords = {"objective","task","goal","target","quest","item","key","pickup","chest","loot","flag"}
local function containsWord(str, word)
    return str:find("%f[%a]"..word.."%f[%A]") ~= nil
end
local function refreshTaskESP()
    if not S.TaskESPOn then return end
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local n = obj.Name:lower()
            for _,kw in ipairs(taskKeywords) do
                if containsWord(n, kw) then
                    if not obj:FindFirstChild("_TESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name="_TESP"; hl.FillColor=S.Colors.Task; hl.OutlineColor=S.Colors.Task
                        hl.FillTransparency=0.5; hl.OutlineTransparency=0; hl.Adornee=obj; hl.Parent=obj

                        local bb = Instance.new("BillboardGui")
                        bb.Name="_TESPBB"; bb.AlwaysOnTop=true; bb.Size=UDim2.new(0,150,0,24)
                        bb.StudsOffset=Vector3.new(0,2,0); bb.Adornee=obj; bb.Parent=obj

                        local lbl = Instance.new("TextLabel", bb)
                        lbl.Size=UDim2.new(1,0,1,0); lbl.BackgroundTransparency=1
                        lbl.Text=obj.Name; lbl.TextColor3=S.Colors.Task
                        lbl.TextStrokeTransparency=0.3; lbl.TextScaled=true; lbl.Font=Enum.Font.GothamBold
                    end
                    break
                end
            end
        end
    end
end
local function clearTaskESP()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v.Name=="_TESP" or v.Name=="_TESPBB" then v:Destroy() end
    end
end
task.spawn(function() while true do task.wait(4); refreshTaskESP() end end)

local function refreshMonsterESP()
    if not S.MonsterESPOn then return end
    for _,m in ipairs(workspace:GetDescendants()) do
        if isMob(m) and m ~= LP.Character then
            makeESP(m, "_MESP", "_MESPBB", S.Colors.Monster, m.Name)
        end
    end
end
local function clearMonsterESP()
    for _,v in ipairs(workspace:GetDescendants()) do
        if v.Name=="_MESP" or v.Name=="_MESPBB" then v:Destroy() end
    end
end
task.spawn(function() while true do task.wait(3); refreshMonsterESP() end end)

local function findLobby()
    local ok2, gate = pcall(function()
        return workspace.Gates:GetChildren()[2].Gate.Gate
    end)
    if ok2 and gate then return gate end

    local names = {"Lobby","lobby","Spawn","SpawnLocation","MainLobby","Hub","Queue","Matchmaking"}
    for _,n in ipairs(names) do
        local found = workspace:FindFirstChild(n, true)
        if found then return found end
    end
    for _,v in ipairs(workspace:GetDescendants()) do
        if v:IsA("SpawnLocation") then return v end
    end
    return nil
end
local function getPivot(obj)
    if obj:IsA("BasePart") then return obj.CFrame end
    if obj:IsA("Model") then return obj:GetPivot() end
    return nil
end
local function autoJoinLobby()
    local lobby = findLobby()
    local me = getRoot()
    if not lobby or not me then
        notify("Auto Join", "Lobby/Gate not found in this game.", "circle-x")
        return
    end
    local cf = getPivot(lobby)
    if not cf then return end
    me.CFrame = cf + Vector3.new(0, 5, 0)
    notify("Auto Join", "Teleported to Gate.", "log-in")
end

local Window = BetterOrion:MakeWindow({
    Name = "Paradox Hub",
    SubName = "v1.0.0",
    IntroEnabled = true,
    IntroIcon = "zap",
    IntroText = "Paradox Hub\nv1.0.0",
    Size = UDim2.new(0, 560, 0, 380),
    ToggleUIKey = Enum.KeyCode.RightShift,
    SearchBar = true,
    WatermarkConfig = {
        Enabled = true,
        Visible = true,
        ShowFPS = true,
        ShowPing = true,
        ShowName = true,
        Icon = "zap",
    },
})

pcall(function()
    Window:SetBackground("rbxassetid://14103269909")
    Window:SetBackgroundTransparency(0.5)
    Window:SetBackgroundVisibility(true)
end)

local FuncTab = Window:MakeTab({ Name = "Function", Icon = "sliders-horizontal" })
local MoveSection = FuncTab:AddSection({ Name = "Movement", Side = "Left" })
local MobSection = FuncTab:AddSection({ Name = "Creatures", Side = "Right" })

MoveSection:AddToggle({
    Name = "Speed Hack",
    Default = false,
    Flag = "SpeedHack",
    Callback = function(Value)
        S.SpeedOn = Value
        if Value then hookSpeed(getHum()) else pcall(function() getHum().WalkSpeed = 16 end) end
        notify("Speed Hack", Value and "Enabled" or "Disabled")
    end,
})

MoveSection:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 500,
    Increment = 1,
    Default = 100,
    ValueName = "Speed",
    Flag = "SpeedValue",
    Callback = function(Value)
        S.Speed = Value
        if S.SpeedOn then pcall(function() getHum().WalkSpeed = Value end) end
    end,
})

MoveSection:AddToggle({
    Name = "Infinite Jump",
    Default = false,
    Flag = "InfJump",
    Callback = function(Value)
        S.InfJumpOn = Value
        notify("Infinite Jump", Value and "Enabled" or "Disabled")
    end,
})

MoveSection:AddToggle({
    Name = "Noclip",
    Default = false,
    Flag = "Noclip",
    Callback = function(Value)
        S.NoclipOn = Value
        if not Value then restoreCollide() end
        notify("Noclip", Value and "Enabled" or "Disabled")
    end,
})

MoveSection:AddToggle({
    Name = "Unlock Third Person",
    Default = false,
    Flag = "ThirdPerson",
    Callback = function(Value)
        S.ThirdPersonOn = Value
        setThirdPerson(Value)
        notify("Third Person", Value and "Unlocked" or "Locked")
    end,
})

MoveSection:AddLabel("Hide menu: RightShift")

MobSection:AddToggle({
    Name = "Hide All",
    Default = false,
    Flag = "HideMobs",
    Callback = function(Value)
        S.HideMobsOn = Value
        if Value then refreshHiddenMobs() else restoreAllMobs() end
        notify("Hide All", Value and "Hidden from your view" or "Restored")
    end,
})
MobSection:AddLabel("Hide All hides every creature in the game (your screen only).")

local EspTab = Window:MakeTab({ Name = "ESP", Icon = "eye" })
local EspSection = EspTab:AddSection({ Name = "ESP", Side = "Left" })
local EspColorSection = EspTab:AddSection({ Name = "Colors", Side = "Right" })

EspSection:AddToggle({
    Name = "Player ESP (name + HP)",
    Default = false,
    Flag = "PlayerESP",
    Callback = function(Value)
        S.ESPOn = Value
        if Value then refreshPlayerESP() else clearAllPlayerESP() end
        notify("Player ESP", Value and "Enabled" or "Disabled")
    end,
})

EspSection:AddToggle({
    Name = "Task ESP",
    Default = false,
    Flag = "TaskESP",
    Callback = function(Value)
        S.TaskESPOn = Value
        if Value then refreshTaskESP() else clearTaskESP() end
        notify("Task ESP", Value and "Enabled" or "Disabled")
    end,
})

EspSection:AddToggle({
    Name = "Monster ESP",
    Default = false,
    Flag = "MonsterESP",
    Callback = function(Value)
        S.MonsterESPOn = Value
        if Value then refreshMonsterESP() else clearMonsterESP() end
        notify("Monster ESP", Value and "Enabled" or "Disabled")
    end,
})

EspColorSection:AddColorpicker({
    Name = "Player color",
    Default = S.Colors.Player,
    Flag = "PlayerESPColor",
    Callback = function(color)
        S.Colors.Player = color
        updateESPColor("_PESP", color)
    end,
})

EspColorSection:AddColorpicker({
    Name = "Task color",
    Default = S.Colors.Task,
    Flag = "TaskESPColor",
    Callback = function(color)
        S.Colors.Task = color
        updateESPColor("_TESP", color)
    end,
})

EspColorSection:AddColorpicker({
    Name = "Monster color",
    Default = S.Colors.Monster,
    Flag = "MonsterESPColor",
    Callback = function(color)
        S.Colors.Monster = color
        updateESPColor("_MESP", color)
    end,
})

local ShaderTab = Window:MakeTab({ Name = "Shaders", Icon = "palette" })
local ShaderSection = ShaderTab:AddSection({ Name = "Visual Shaders", Side = "Left" })

ShaderSection:AddDropdown({
    Name = "Shader preset",
    Options = { "Cinematic", "Realistic", "Cyberpunk", "Vintage VHS", "Dreamy Anime" },
    Multi = false,
    Default = "Cinematic",
    Flag = "ShaderSelect",
    Callback = function(Value)
        S.SelectedShader = Value
        if S.ShadersOn then applyShader() end
    end,
})

ShaderSection:AddToggle({
    Name = "Enable Shaders",
    Default = false,
    Flag = "ShadersToggle",
    Callback = function(Value)
        S.ShadersOn = Value
        applyShader()
        notify("Shaders", Value and (S.SelectedShader.." enabled") or "Disabled")
    end,
})

local WorldTab = Window:MakeTab({ Name = "World", Icon = "sun" })
local WorldSection = WorldTab:AddSection({ Name = "Lighting", Side = "Left" })

WorldSection:AddToggle({
    Name = "Remove darkness / fog",
    Default = false,
    Flag = "Bright",
    Callback = function(Value)
        S.BrightOn = Value
        setBright(Value)
        notify("Brightness", Value and "Enabled" or "Disabled")
    end,
})

local JoinTab = Window:MakeTab({ Name = "Auto Join", Icon = "log-in" })
local JoinSection = JoinTab:AddSection({ Name = "Auto Join", Side = "Left" })
JoinSection:AddLabel("Teleports you straight to the Gate.")
JoinSection:AddButton({
    Name = "Teleport to Gate",
    Callback = function() autoJoinLobby() end,
})

local SupportTab = Window:MakeTab({ Name = "Support", Icon = "info" })
local AboutSection = SupportTab:AddSection({ Name = "About", Side = "Left" })
AboutSection:AddLabel("Version: v1.0.0")
AboutSection:AddLabel("UI: BetterOrion")

local MenuSection = SupportTab:AddSection({ Name = "Menu", Side = "Right" })
MenuSection:AddButton({
    Name = "Destroy Hub",
    Callback = function()
        restoreAllMobs()
        clearShaders()
        clearAllPlayerESP()
        clearTaskESP()
        clearMonsterESP()
        setBright(false)
        BetterOrion:Destroy()
    end,
})

BetterOrion:Init()
notify("Paradox Hub", "v1.0.0 loaded", "rocket")
