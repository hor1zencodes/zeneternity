--[[
    
                 ETERNITY V1 SCRIPT           
             Premium Universal Script         
                                              
      Key: horizen                            
    
    
    Loaded via: loadstring(game:HttpGet(URL))()
]]

-- 
-- SERVICES
-- 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local lp = Players.LocalPlayer
local character = lp.Character or lp.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- reconnect on respawn
lp.CharacterAdded:Connect(function(char)
    -- Clear PhysicsRepRootPart on old rootPart before it gets destroyed
    pcall(function()
        if rootPart and typeof(sethiddenproperty) == "function" then
            sethiddenproperty(rootPart, "PhysicsRepRootPart", nil)
        end
    end)
    character = char
    humanoid = char:WaitForChild("Humanoid")
    rootPart = char:WaitForChild("HumanoidRootPart")
    
    if not IsKeyVerified then return end


    -- If facebang was active, the Stepped connection will re-call fbActivate()
    -- on next frame when it detects facebangSetupChar ~= character
end)

-- 
-- CONFIGURATION
-- 
local VALID_KEY = "zzzen"
local SCRIPT_VERSION = "v2.0"
local SCRIPT_NAME = "Eternity"
local IsKeyVerified = false

-- globals
local TargetPlayer = nil
local ctxTargetPlayer = nil
local FacebangTarget = nil
HeadsitTarget = nil
BackhugTarget = nil
ProposeTarget = nil
BagpackTarget = nil
GoonTarget = nil
HipbangTarget = nil
local PatTarget = nil
local FacebangSpeed = 2.5
local FacebangDistance = 2.0
HipbangSpeed = 2.5
HipbangDistance = 2.0
-- Global: selected Big Baseplate color (shared between page and engine)
_bigBPSelectedColor = Color3.fromRGB(128, 128, 128)
_bigBPGrid = {}

-- Global: selected UI Theme color
_themeColor = nil

-- feature toggle states
local FeatureStates = {
    ContextMenu = false,
    AdminDisabled = false,
    GlitchMoveEnabled = false,
    GlitchMoveActive = false,
    SupermanFlyEnabled = false,
    SupermanFlyActive = false,
    FacebangEnabled = false, -- UI toggle arms the keybind
    Facebang = false,        -- actual active state (keybind activates)
    PatEnabled = false,
    Pat = false,
    HeadsitEnabled = false,
    Headsit = false,
    BackhugEnabled = false,
    Backhug = false,
    FronthugEnabled = false,
    Fronthug = false,
    ProposeEnabled = false,
    Propose = false,
    HipbangEnabled = false,
    Hipbang = false,
    BagpackEnabled = false,
    Bagpack = false,
    GoonEnabled = false,
    Goon = false,
    ClickToTarget = false,
    ViewTarget = false,
    Noclip = false,
    ClickTeleport = false,
    AnimatedTeleport = false,
    Trip = false,
    Reverse = false,
    InfiniteJump = false,
    SpeedBoost = false,
    BigBaseplateActive = false,
    ESP = false,
    Fullbright = false,
    NoFog = false,
    ChatSpamActive = false,
    VCBypassActive = false,  -- VC bypass has been activated
    FakeoutEnabled = false,  -- Fakeout armed (toggle)
    GhostBaitEnabled = false, -- Ghost Bait armed (toggle)
    ExtremeGlitchDesyncEnabled = false,
    NormalGlitchDesyncEnabled = false,
    HiddenPlayers = {},
    
    -- Auto Execute Settings
    AutoFacebang = false,
    AutoInfiniteJump = false,
    AutoSpeedBoost = false,
    AutoNoclip = false,
    AutoClickTeleport = false,
    AutoAnimatedTeleport = false,

    AutoGlitch = false,
    AutoTrip = false,
    AutoReverse = false,
    AutoPat = false,
    SavedAnimations = {},
    FavoriteAnimations = {},
    ForceWalkAnimation = false,
    GoUnderground = false,
}

local ToggleRegistry = {}
local GridButtonVisuals = {}
local AttachFeatures = {"Facebang", "Hipbang", "Pat", "Headsit", "Backhug", "Propose", "Fronthug", "Bagpack", "Goon"}

local function SetAttachState(featureName, on)
    if on then
        for _, otherFeature in ipairs(AttachFeatures) do
            if otherFeature ~= featureName and FeatureStates[otherFeature] then
                FeatureStates[otherFeature] = false
                if GridButtonVisuals[otherFeature] then
                    GridButtonVisuals[otherFeature](false)
                end
                if otherFeature == "Facebang" then FacebangTarget = nil
                elseif otherFeature == "Hipbang" then HipbangTarget = nil
                elseif otherFeature == "Pat" then PatTarget = nil
                elseif otherFeature == "Headsit" then HeadsitTarget = nil
                elseif otherFeature == "Backhug" then BackhugTarget = nil
                elseif otherFeature == "Fronthug" then FronthugTarget = nil
                elseif otherFeature == "Propose" then ProposeTarget = nil
                elseif otherFeature == "Bagpack" then BagpackTarget = nil
                elseif otherFeature == "Goon" then GoonTarget = nil
                end
            end
        end
    end
    FeatureStates[featureName] = on
    if GridButtonVisuals[featureName] then
        GridButtonVisuals[featureName](on)
    end
    if _G.SetActiveFeature then
        _G.SetActiveFeature(on and featureName or nil)
    end
end

local CONFIG_FILE = "eternity_config.json"

local Keybinds = {
    GlitchMove = Enum.KeyCode.G,
    SupermanFly = Enum.KeyCode.H,
    ClickTeleport = Enum.KeyCode.F,
    AnimatedTeleport = Enum.KeyCode.F,
    Trip = Enum.KeyCode.T,
    Reverse = Enum.KeyCode.R,
    Facebang = Enum.KeyCode.Z,
    Pat = Enum.KeyCode.P,
    Headsit = Enum.KeyCode.X,
    Backhug = Enum.KeyCode.B,
    Fronthug = Enum.KeyCode.M,
    Propose = Enum.KeyCode.V,
    Hipbang = Enum.KeyCode.N,
    Bagpack = Enum.KeyCode.J,
    Goon = Enum.KeyCode.N,
    Fakeout = Enum.KeyCode.K,
    GhostBait = Enum.KeyCode.J,
    GlitchDesync = Enum.KeyCode.L,
    GoUnderground = Enum.KeyCode.U,
}

-- SpeedMultiplier declared here so both saveSettings and loadSettings
-- can read/write it as an upvalue (Lua closure capture is at definition time)
local SpeedMultiplier = 100

local function saveSettings()
    pcall(function()
        if writefile and typeof(writefile) == "function" then
            local data = {
                SpeedValue = SpeedMultiplier,
                Bind_GlitchMove = Keybinds.GlitchMove.Name,
                Bind_ClickTeleport = Keybinds.ClickTeleport.Name,
                Bind_AnimatedTeleport = Keybinds.AnimatedTeleport.Name,
                Bind_Trip = Keybinds.Trip.Name,
                Bind_Reverse = Keybinds.Reverse.Name,
                Bind_Facebang = Keybinds.Facebang.Name,
                Bind_Pat = Keybinds.Pat.Name,
                Bind_Headsit = Keybinds.Headsit.Name,
                Bind_Backhug = Keybinds.Backhug.Name,
                Bind_Fronthug = Keybinds.Fronthug.Name,
                Bind_Propose = Keybinds.Propose.Name,
                Bind_Hipbang = Keybinds.Hipbang.Name,
                Bind_Bagpack = Keybinds.Bagpack.Name,
                Bind_Goon = Keybinds.Goon.Name,
                Bind_Fakeout = Keybinds.Fakeout.Name,
                Bind_GhostBait = Keybinds.GhostBait.Name,
                Bind_GlitchDesync = Keybinds.GlitchDesync.Name,
                Bind_GoUnderground = Keybinds.GoUnderground.Name,
                SavedAnimations = FeatureStates.SavedAnimations,
                FavoriteAnimations = FeatureStates.FavoriteAnimations,
                BigBaseplateColorR = math.floor(_bigBPSelectedColor.R * 255 + 0.5),
                BigBaseplateColorG = math.floor(_bigBPSelectedColor.G * 255 + 0.5),
                BigBaseplateColorB = math.floor(_bigBPSelectedColor.B * 255 + 0.5),
                ThemeColorR = _themeColor and math.floor(_themeColor.R * 255 + 0.5) or nil,
                ThemeColorG = _themeColor and math.floor(_themeColor.G * 255 + 0.5) or nil,
                ThemeColorB = _themeColor and math.floor(_themeColor.B * 255 + 0.5) or nil,
                Toggles = {}
            }
            
            local featuresToSave = {
                Noclip = true, InfiniteJump = true, ClickTeleport = true, AnimatedTeleport = true, Trip = true, Reverse = true,
                GlitchMoveEnabled = true, SupermanFlyEnabled = true, SpeedBoost = true,
                ForceWalkAnimation = true,
                BigBaseplateActive = true,
                FacebangEnabled = true, PatEnabled = true, HeadsitEnabled = true, BackhugEnabled = true, FronthugEnabled = true, ProposeEnabled = true, HipbangEnabled = true, BagpackEnabled = true, GoonEnabled = true,
                FakeoutEnabled = true,
                GhostBaitEnabled = true,
                ExtremeGlitchDesyncEnabled = true, NormalGlitchDesyncEnabled = true,
                AntiHeadsit = true, AntiFacebang = true, AntiKidnap = true, AntiVoid = true, InfFallVoid = true
            }

            for k, _ in pairs(ToggleRegistry) do
                if featuresToSave[k] and FeatureStates[k] then
                    data.Toggles[k] = true
                end
            end
            local success, content = pcall(function()
                return game:GetService("HttpService"):JSONEncode(data)
            end)
            if success then
                writefile(CONFIG_FILE, content)
            end
        end
    end)
end

local function loadSettings()
    pcall(function()
        if readfile and typeof(readfile) == "function" then
            if isfile and typeof(isfile) == "function" and isfile(CONFIG_FILE) then
                local content = readfile(CONFIG_FILE)
                local success, data = pcall(function()
                    return game:GetService("HttpService"):JSONDecode(content)
                end)
                if success and typeof(data) == "table" then
                    if data.Toggles and typeof(data.Toggles) == "table" then
                        local allowedToggles = {
                            Noclip = true, InfiniteJump = true, ClickTeleport = true, AnimatedTeleport = true, Trip = true, Reverse = true,
                            GlitchMoveEnabled = true, SupermanFlyEnabled = true, SpeedBoost = true,
                            BigBaseplateActive = true,
                            FacebangEnabled = true, PatEnabled = true, HeadsitEnabled = true, BackhugEnabled = true, FronthugEnabled = true, ProposeEnabled = true, HipbangEnabled = true, BagpackEnabled = true, GoonEnabled = true,
                            FakeoutEnabled = true,
                            GhostBaitEnabled = true,
                            ExtremeGlitchDesyncEnabled = true, NormalGlitchDesyncEnabled = true,
                            AntiHeadsit = true, AntiFacebang = true, AntiKidnap = true, AntiVoid = true, InfFallVoid = true
                        }
                        for k, v in pairs(data.Toggles) do
                            if allowedToggles[k] then
                                FeatureStates[k] = v
                            end
                        end
                    end
                    -- fallback for old format auto executes
                    if data.AutoFacebang then FeatureStates.FacebangEnabled = true end
                    if data.AutoInfiniteJump then FeatureStates.InfiniteJump = true end
                    if data.AutoSpeedBoost then FeatureStates.SpeedBoost = true end
                    if data.AutoNoclip then FeatureStates.Noclip = true end
                    if data.AutoClickTeleport then FeatureStates.ClickTeleport = true end
                    if data.AutoAnimatedTeleport then FeatureStates.AnimatedTeleport = true end
                    if data.AutoGlitch then FeatureStates.GlitchMoveEnabled = true end
                    if data.AutoTrip then FeatureStates.Trip = true end
                    if data.AutoReverse then FeatureStates.Reverse = true end
                    if data.AutoPat then FeatureStates.PatEnabled = true end
                    if data.AutoHeadsit then FeatureStates.HeadsitEnabled = true end
                    if data.AutoBackhug then FeatureStates.BackhugEnabled = true end
                    if data.AutoFronthug then FeatureStates.FronthugEnabled = true end
                    if data.AutoPropose then FeatureStates.ProposeEnabled = true end
                    if data.AutoHipbang then FeatureStates.HipbangEnabled = true end
                    if data.AutoBagpack then FeatureStates.BagpackEnabled = true end
                    if data.AutoGoon then FeatureStates.GoonEnabled = true end

                    if data.SpeedValue and tonumber(data.SpeedValue) and tonumber(data.SpeedValue) > 0 then
                        SpeedMultiplier = tonumber(data.SpeedValue)
                    end
                    if data.FacebangSpeedValue and tonumber(data.FacebangSpeedValue) then
                        FacebangSpeed = tonumber(data.FacebangSpeedValue)
                    end
                    if data.FacebangDistanceValue and tonumber(data.FacebangDistanceValue) then
                        FacebangDistance = tonumber(data.FacebangDistanceValue)
                    end
                    if data.HipbangSpeedValue and tonumber(data.HipbangSpeedValue) then
                        HipbangSpeed = tonumber(data.HipbangSpeedValue)
                    end
                    if data.HipbangDistanceValue and tonumber(data.HipbangDistanceValue) then
                        HipbangDistance = tonumber(data.HipbangDistanceValue)
                    end
                    if data.BigBaseplateColorR and data.BigBaseplateColorG and data.BigBaseplateColorB then
                        pcall(function()
                            _bigBPSelectedColor = Color3.fromRGB(
                                tonumber(data.BigBaseplateColorR) or 128,
                                tonumber(data.BigBaseplateColorG) or 128,
                                tonumber(data.BigBaseplateColorB) or 128
                            )
                        end)
                    end
                    if data.ThemeColorR and data.ThemeColorG and data.ThemeColorB then
                        pcall(function()
                            _themeColor = Color3.fromRGB(
                                tonumber(data.ThemeColorR) or 245,
                                tonumber(data.ThemeColorG) or 190,
                                tonumber(data.ThemeColorB) or 75
                            )
                        end)
                    end
                    if data.Bind_GlitchMove then pcall(function() Keybinds.GlitchMove = Enum.KeyCode[data.Bind_GlitchMove] end) end
                    if data.Bind_ClickTeleport then pcall(function() Keybinds.ClickTeleport = Enum.KeyCode[data.Bind_ClickTeleport] end) end
                    if data.Bind_AnimatedTeleport then pcall(function() Keybinds.AnimatedTeleport = Enum.KeyCode[data.Bind_AnimatedTeleport] end) end
                    if data.Bind_Trip then pcall(function() Keybinds.Trip = Enum.KeyCode[data.Bind_Trip] end) end
                    if data.Bind_Reverse then pcall(function() Keybinds.Reverse = Enum.KeyCode[data.Bind_Reverse] end) end
                    if data.Bind_Facebang then pcall(function() Keybinds.Facebang = Enum.KeyCode[data.Bind_Facebang] end) end
                    if data.Bind_Pat then pcall(function() Keybinds.Pat = Enum.KeyCode[data.Bind_Pat] end) end
                    if data.Bind_Headsit then pcall(function() Keybinds.Headsit = Enum.KeyCode[data.Bind_Headsit] end) end
                    if data.Bind_Backhug then pcall(function() Keybinds.Backhug = Enum.KeyCode[data.Bind_Backhug] end) end
                    if data.Bind_Fronthug then pcall(function() Keybinds.Fronthug = Enum.KeyCode[data.Bind_Fronthug] end) end
                    if data.Bind_Propose then pcall(function() Keybinds.Propose = Enum.KeyCode[data.Bind_Propose] end) end
                    if data.Bind_Hipbang then pcall(function() Keybinds.Hipbang = Enum.KeyCode[data.Bind_Hipbang] end) end
                    if data.Bind_Bagpack then pcall(function() Keybinds.Bagpack = Enum.KeyCode[data.Bind_Bagpack] end) end
                    if data.Bind_Goon then pcall(function() Keybinds.Goon = Enum.KeyCode[data.Bind_Goon] end) end
                    if data.Bind_Fakeout then pcall(function() Keybinds.Fakeout = Enum.KeyCode[data.Bind_Fakeout] end) end
                    if data.Bind_GhostBait then pcall(function() Keybinds.GhostBait = Enum.KeyCode[data.Bind_GhostBait] end) end
                    if data.Bind_GlitchDesync then pcall(function() Keybinds.GlitchDesync = Enum.KeyCode[data.Bind_GlitchDesync] end) end
                    if data.Bind_GoUnderground then pcall(function() Keybinds.GoUnderground = Enum.KeyCode[data.Bind_GoUnderground] end) end
                    if data.SavedAnimations and typeof(data.SavedAnimations) == "table" then FeatureStates.SavedAnimations = data.SavedAnimations end
                    if data.FavoriteAnimations and typeof(data.FavoriteAnimations) == "table" then FeatureStates.FavoriteAnimations = data.FavoriteAnimations end
                end
            end
        end
    end)
end

local function runAutoExecutes()
    task.spawn(function()
        task.wait(1.5) -- wait longer so humanoid/rootPart are ready

        for key, setToggle in pairs(ToggleRegistry) do
            if FeatureStates[key] then
                pcall(function() setToggle(true) end)
            end
        end
    end)
end

loadSettings()
local ChatSpamMessage = ""
local ChatSpamDelay = 1.0
local OriginalAmbient = Lighting.Ambient
local OriginalFogEnd = Lighting.FogEnd
local OriginalBrightness = Lighting.Brightness
local OriginalShadows = Lighting.GlobalShadows
local OriginalDiffuse = Lighting.EnvironmentDiffuseScale
local OriginalSpecular = Lighting.EnvironmentSpecularScale

-- 
-- COLOR PALETTE (Dark Glassmorphism)
-- 
local C = {
    bg              = Color3.fromRGB(8, 8, 8),
    bgCard          = Color3.fromRGB(14, 14, 14),
    surface         = Color3.fromRGB(20, 20, 20),
    surfaceHover    = Color3.fromRGB(28, 28, 28),
    input           = Color3.fromRGB(24, 24, 24),
    accent          = _themeColor or Color3.fromRGB(245, 190, 75),
    accentDim       = _themeColor and Color3.new(_themeColor.R * 0.75, _themeColor.G * 0.75, _themeColor.B * 0.75) or Color3.fromRGB(180, 140, 50),
    accentGlow      = _themeColor or Color3.fromRGB(245, 190, 75),
    danger          = Color3.fromRGB(230, 70, 70),
    dangerDim       = Color3.fromRGB(160, 50, 50),
    success         = Color3.fromRGB(80, 220, 140),
    warning         = Color3.fromRGB(240, 180, 60),
    text            = Color3.fromRGB(220, 220, 228),
    textMuted       = Color3.fromRGB(100, 100, 115),
    textDim         = Color3.fromRGB(60, 60, 72),
    white           = Color3.fromRGB(245, 245, 250),
    black           = Color3.fromRGB(6, 6, 8),
    toggleOn        = _themeColor or Color3.fromRGB(245, 190, 75),
    toggleOff       = Color3.fromRGB(50, 50, 60),
    toggleKnob      = Color3.fromRGB(240, 240, 245),
    divider         = Color3.fromRGB(35, 35, 45),
    sidebarBg       = Color3.fromRGB(12, 12, 16),
    sidebarIcon     = Color3.fromRGB(160, 160, 170),
    sidebarActive   = _themeColor or Color3.fromRGB(245, 190, 75),
    statsBg         = Color3.fromRGB(18, 18, 24),
}

local function getRGBString(c)
    return math.floor(c.R*255+0.5)..","..math.floor(c.G*255+0.5)..","..math.floor(c.B*255+0.5)
end
local accentRgbStr = getRGBString(C.accent)

-- 
-- UTILITY FUNCTIONS
-- 
local function tween(obj, props, dur, style, dir)
    if not obj or not obj.Parent then return end
    local info = TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function tweenWait(obj, props, dur, style, dir)
    if not obj or not obj.Parent then return end
    local info = TweenInfo.new(dur or 0.3, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out)
    local tw = TweenService:Create(obj, info, props)
    tw:Play()
    tw.Completed:Wait()
end

local function corner(parent, radius)
    local c = Instance.new("UICorner", parent)
    c.CornerRadius = UDim.new(0, radius or 8)
    return c
end

local function stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke", parent)
    s.Color = color or C.accent
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0.6
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function padding(parent, t, b, l, r)
    local p = Instance.new("UIPadding", parent)
    p.PaddingTop = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft = UDim.new(0, l or 0)
    p.PaddingRight = UDim.new(0, r or 0)
    return p
end

local function gradient(parent, c1, c2, rotation)
    local g = Instance.new("UIGradient", parent)
    g.Color = ColorSequence.new(c1, c2)
    g.Rotation = rotation or 90
    return g
end

local function sendChat(msg)
    task.spawn(function()
        pcall(function()
            if TextChatService.ChatVersion == Enum.ChatVersion.TextChatService then
                local channel = TextChatService.TextChannels:FindFirstChild("RBXGeneral")
                if channel then channel:SendAsync(msg) end
            else
                ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(msg, "All")
            end
        end)
    end)
end

local function getTimeGreeting()
    local hour = tonumber(os.date("%H"))
    if hour < 12 then return "Good morning"
    elseif hour < 17 then return "Good afternoon"
    elseif hour < 21 then return "Good evening"
    else return "Good night" end
end

local function getExecutorName()
    local name = "Unknown"
    pcall(function()
        if identifyexecutor then
            name = identifyexecutor()
        elseif getexecutorname then
            name = getexecutorname()
        end
    end)
    return name
end

local function getAccountAge()
    local days = lp.AccountAge
    if days >= 365 then
        return math.floor(days / 365) .. " Years"
    elseif days >= 30 then
        return math.floor(days / 30) .. " Months"
    else
        return days .. " Days"
    end
end

-- 
-- SCREEN GUI
-- 
-- cleanup any existing eternity gui (fixes lag from multiple executions)
if getgenv().EternityV1_UI then
    pcall(function() getgenv().EternityV1_UI:Destroy() end)
end
pcall(function()
    if gethui then
        local existing = gethui():FindFirstChild("EternityV1")
        if existing then existing:Destroy() end
    end
    local existing2 = game:GetService("CoreGui"):FindFirstChild("EternityV1")
    if existing2 then existing2:Destroy() end
    local existing3 = lp:WaitForChild("PlayerGui"):FindFirstChild("EternityV1")
    if existing3 then existing3:Destroy() end
end)

local sg = Instance.new("ScreenGui")
sg.Name = "EternityV1"
getgenv().EternityV1_UI = sg

-- 
-- ASSET LOADER (Images only)
-- 
local getasset = getcustomasset or getsynasset
local repoBase = "https://raw.githubusercontent.com/hor1zencodes/assets/main/"

local function getAssetUrl(fileName)
    if getasset and isfile and readfile and writefile then
        local filePath = "ZenV1_Media_v2/" .. fileName
        if not isfolder("ZenV1_Media_v2") then makefolder("ZenV1_Media_v2") end
        
        local needsDownload = true
        if isfile(filePath) then
            local success, content = pcall(function() return readfile(filePath) end)
            if success and content and string.len(content) > 100 then
                needsDownload = false
            end
        end

        if needsDownload then
            pcall(function()
                local data = game:HttpGet(repoBase .. fileName)
                if data and string.len(data) > 100 and not string.find(data, "404: Not Found") then
                    writefile(filePath, data)
                end
            end)
        end
        
        if isfile(filePath) then
            return getasset(filePath)
        end
    end
    return repoBase .. fileName
end

local LogoAssetUrl = "rbxassetid://139175707588865"
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- executor compatibility: try gethui > CoreGui > PlayerGui
local guiParent
pcall(function()
    if gethui then
        guiParent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(sg)
        guiParent = game:GetService("CoreGui")
    end
end)
sg.Parent = guiParent or lp:WaitForChild("PlayerGui")

-- 
-- SOUND EFFECTS
-- Parented to the ScreenGui so they are safe & non-blocking
-- 
local function makeSound(id, volume)
    local s = Instance.new("Sound")
    s.SoundId = id
    s.Volume = volume or 0.6
    s.RollOffMaxDistance = 0
    s.Parent = sg
    return s
end

local SFX_LAUNCH = makeSound("rbxassetid://123360185505109", 0.7)
local SFX_CLICK  = makeSound("rbxassetid://116271631941040", 0.5)

local function playClick()
    pcall(function()
        SFX_CLICK:Stop()
        SFX_CLICK.TimePosition = 0
        SFX_CLICK:Play()
    end)
end

-- 
-- KEY SYSTEM GUI  (Vanta-style split panel, Eternity theme)
-- Variables needed outside the do-block are pre-declared here
-- 
keyOverlay, keyCard, keyCardStroke, keyCardGradient = nil, nil, nil, nil
keyInput, keyBtn, keyStatus, keyInputLabel, leftGlowBlob, keyInputGradient = nil, nil, nil, nil, nil, nil

do -- scope block to stay under Lua's 200-local limit
keyOverlay = Instance.new("Frame", sg)
keyOverlay.Name = "KeyOverlay"
keyOverlay.Size = UDim2.new(1, 0, 1, 0)
keyOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
keyOverlay.BackgroundTransparency = 1
keyOverlay.BorderSizePixel = 0
keyOverlay.ZIndex = 100

-- Play launch SFX when verify screen appears
pcall(function()
    SFX_LAUNCH:Stop()
    SFX_LAUNCH.TimePosition = 0
    SFX_LAUNCH:Play()
end)

--  Outer wrapper (the full split card) 
keyCard = Instance.new("ImageLabel", keyOverlay)
keyCard.Name = "KeyCard"
keyCard.Size = UDim2.new(0, 580, 0, 320)
keyCard.Position = UDim2.new(0, 20, 1, 0) -- Starts offscreen bottom left
keyCard.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
keyCard.BorderSizePixel = 0
keyCard.BackgroundTransparency = 1
keyCard.ClipsDescendants = true
keyCard.ZIndex = 101
keyCard.Image = "rbxassetid://72660622902200"
keyCard.ImageColor3 = C.accent
keyCard.ImageTransparency = 0
keyCard.ScaleType = Enum.ScaleType.Crop
corner(keyCard, 14)
keyCardStroke = stroke(keyCard, C.accent, 1.5, 0)
keyCardStroke.ZIndex = 101
keyCardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

keyCardGradient = Instance.new("UIGradient", keyCardStroke)
keyCardGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.3, 1),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(0.7, 1),
    NumberSequenceKeypoint.new(1, 1)
})

--  LEFT PANEL 
local leftPanel = Instance.new("Frame", keyCard)
leftPanel.Name = "LeftPanel"
leftPanel.Size = UDim2.new(0, 210, 1, 0)
leftPanel.Position = UDim2.new(0, 0, 0, 0)
leftPanel.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
leftPanel.BackgroundTransparency = 1
leftPanel.BorderSizePixel = 0
leftPanel.ZIndex = 102
corner(leftPanel, 14)

-- mask the right corners of left panel so only left side is rounded
local leftMaskRight = Instance.new("Frame", leftPanel)
leftMaskRight.Size = UDim2.new(0, 16, 1, 0)
leftMaskRight.Position = UDim2.new(1, -16, 0, 0)
leftMaskRight.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
leftMaskRight.BackgroundTransparency = 1
leftMaskRight.BorderSizePixel = 0
leftMaskRight.ZIndex = 102

-- subtle gold gradient blob behind left panel (hidden)
leftGlowBlob = Instance.new("Frame", leftPanel)
leftGlowBlob.Size = UDim2.new(0, 160, 0, 160)
leftGlowBlob.Position = UDim2.new(0.5, -80, 0.2, -20)
leftGlowBlob.BackgroundColor3 = C.accent
leftGlowBlob.BackgroundTransparency = 1
leftGlowBlob.BorderSizePixel = 0
leftGlowBlob.ZIndex = 102
leftGlowBlob.Visible = false
corner(leftGlowBlob, 80)

-- circle frame behind avatar (dark)
local avatarRing = Instance.new("Frame", leftPanel)
avatarRing.Size = UDim2.new(0, 88, 0, 88)
avatarRing.Position = UDim2.new(0.5, -44, 0, 44)
avatarRing.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
avatarRing.BackgroundTransparency = 0
avatarRing.BorderSizePixel = 0
avatarRing.ZIndex = 103
corner(avatarRing, 44)

local verifyAvatarStroke = stroke(avatarRing, C.accent, 2.5, 0)
verifyAvatarGradient = Instance.new("UIGradient", verifyAvatarStroke)
verifyAvatarGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.45, 1),
    NumberSequenceKeypoint.new(0.5, 0), -- Static white line
    NumberSequenceKeypoint.new(0.55, 1),
    NumberSequenceKeypoint.new(1, 1)
})

-- inner dark circle (ring gap)
local avatarBg = Instance.new("Frame", avatarRing)
avatarBg.Size = UDim2.new(1, -4, 1, -4)
avatarBg.Position = UDim2.new(0, 2, 0, 2)
avatarBg.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
avatarBg.BackgroundTransparency = 0
avatarBg.BorderSizePixel = 0
avatarBg.ZIndex = 104
corner(avatarBg, 42)

-- avatar image (player thumbnail)
local avatarImg = Instance.new("ImageLabel", avatarBg)
avatarImg.Size = UDim2.new(1, 0, 1, 0)
avatarImg.Position = UDim2.new(0, 0, 0, 0)
avatarImg.BackgroundTransparency = 1
avatarImg.ZIndex = 105
avatarImg.ScaleType = Enum.ScaleType.Crop
corner(avatarImg, 40)
pcall(function()
    local uid = lp.UserId
    avatarImg.Image = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. uid .. "&width=150&height=150&format=png"
end)

-- username label
local keyUser = Instance.new("TextLabel", leftPanel)
keyUser.Size = UDim2.new(1, -16, 0, 20)
keyUser.Position = UDim2.new(0, 8, 0, 140)
keyUser.Text = lp.DisplayName
keyUser.Font = Enum.Font.GothamBold
keyUser.TextSize = 15
keyUser.TextColor3 = Color3.fromRGB(230, 230, 238)
keyUser.BackgroundTransparency = 1
keyUser.TextXAlignment = Enum.TextXAlignment.Center
keyUser.ZIndex = 103

-- @username sub-label
local keyUserSub = Instance.new("TextLabel", leftPanel)
keyUserSub.Size = UDim2.new(1, -16, 0, 16)
keyUserSub.Position = UDim2.new(0, 8, 0, 162)
keyUserSub.Text = "@" .. lp.Name
keyUserSub.Font = Enum.Font.Gotham
keyUserSub.TextSize = 11
keyUserSub.TextColor3 = Color3.fromRGB(100, 100, 115)
keyUserSub.BackgroundTransparency = 1
keyUserSub.TextXAlignment = Enum.TextXAlignment.Center
keyUserSub.ZIndex = 103

-- status badge  (  Working / Undetected )
statusBadge = Instance.new("Frame", leftPanel)
statusBadge.Size = UDim2.new(0, 160, 0, 26)
statusBadge.Position = UDim2.new(0.5, -80, 0, 186)
statusBadge.BackgroundColor3 = Color3.fromRGB(15, 28, 20)
statusBadge.BorderSizePixel = 0
statusBadge.ZIndex = 103
corner(statusBadge, 13)
stroke(statusBadge, Color3.fromRGB(60, 180, 100), 1.2, 0.5)

do
    local cw = Instance.new("Frame", statusBadge)
    cw.Size = UDim2.new(1, 0, 1, 0)
    cw.BackgroundTransparency = 1
    cw.ZIndex = 103

    local ll = Instance.new("UIListLayout", cw)
    ll.FillDirection = Enum.FillDirection.Horizontal
    ll.HorizontalAlignment = Enum.HorizontalAlignment.Center
    ll.VerticalAlignment = Enum.VerticalAlignment.Center
    ll.Padding = UDim.new(0, 6)
    ll.SortOrder = Enum.SortOrder.LayoutOrder

    local dc = Instance.new("Frame", cw)
    dc.Size = UDim2.new(0, 18, 0, 18)
    dc.BackgroundTransparency = 1
    dc.LayoutOrder = 1
    dc.ZIndex = 103

    statusGlow = Instance.new("Frame", dc)
    statusGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    statusGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    statusGlow.Size = UDim2.new(0, 15, 0, 15)
    statusGlow.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
    statusGlow.BackgroundTransparency = 1
    statusGlow.BorderSizePixel = 0
    statusGlow.ZIndex = 103
    corner(statusGlow, 8)

    statusDot = Instance.new("Frame", statusGlow)
    statusDot.AnchorPoint = Vector2.new(0.5, 0.5)
    statusDot.Position = UDim2.new(0.5, 0, 0.5, 0)
    statusDot.Size = UDim2.new(0, 8, 0, 8)
    statusDot.BackgroundColor3 = Color3.fromRGB(80, 220, 130)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 104
    corner(statusDot, 4)

    statusLbl = Instance.new("TextLabel", cw)
    statusLbl.AutomaticSize = Enum.AutomaticSize.X
    statusLbl.Size = UDim2.new(0, 0, 1, 0)
    statusLbl.Text = "<b>Working</b> <font color='rgb(100, 140, 110)'></font> <font color='rgb(180, 230, 190)'>Undetected</font>"
    statusLbl.RichText = true
    statusLbl.Font = Enum.Font.Gotham
    statusLbl.TextSize = 10
    statusLbl.TextColor3 = Color3.fromRGB(80, 220, 130)
    statusLbl.BackgroundTransparency = 1
    statusLbl.TextXAlignment = Enum.TextXAlignment.Center
    statusLbl.ZIndex = 104
    statusLbl.LayoutOrder = 2
end

task.spawn(function()
    task.wait(2.5)
    while statusGlow and statusGlow.Parent do
        tweenWait(statusGlow, {Size = UDim2.new(0, 19, 0, 19), BackgroundTransparency = 0.5}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        tweenWait(statusGlow, {Size = UDim2.new(0, 13, 0, 13), BackgroundTransparency = 0.8}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        task.wait(0.05)
        tweenWait(statusGlow, {Size = UDim2.new(0, 17, 0, 17), BackgroundTransparency = 0.6}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
        tweenWait(statusGlow, {Size = UDim2.new(0, 15, 0, 15), BackgroundTransparency = 0.8}, 0.1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
        task.wait(1.0)
    end
end)

-- logo below status badge
leftLogo = Instance.new("ImageLabel", leftPanel)
leftLogo.Size = UDim2.new(0, 190, 0, 60)
leftLogo.Position = UDim2.new(0.5, -95, 0, 215)
leftLogo.Image = LogoAssetUrl
leftLogo.BackgroundTransparency = 1
leftLogo.ScaleType = Enum.ScaleType.Fit
leftLogo.ZIndex = 103


--  RIGHT PANEL 
local rightPanel = Instance.new("Frame", keyCard)
rightPanel.Name = "RightPanel"
rightPanel.Size = UDim2.new(1, -210, 1, 0)
rightPanel.Position = UDim2.new(0, 210, 0, 0)
rightPanel.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
rightPanel.BackgroundTransparency = 1
rightPanel.BorderSizePixel = 0
rightPanel.ZIndex = 102
corner(rightPanel, 14)

-- mask left corners of right panel
local rightMaskLeft = Instance.new("Frame", rightPanel)
rightMaskLeft.Size = UDim2.new(0, 16, 1, 0)
rightMaskLeft.Position = UDim2.new(0, 0, 0, 0)
rightMaskLeft.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
rightMaskLeft.BackgroundTransparency = 1
rightMaskLeft.BorderSizePixel = 0
rightMaskLeft.ZIndex = 102

-- title row: "Eternity"  +  [X] close
local keyTitle = Instance.new("TextLabel", rightPanel)
keyTitle.Size = UDim2.new(1, -50, 0, 28)
keyTitle.Position = UDim2.new(0, 18, 0, 14)
keyTitle.Text = "" -- Terminal typing effect applied later
keyTitle.Font = Enum.Font.GothamBold
keyTitle.TextSize = 18
keyTitle.TextColor3 = Color3.fromRGB(230, 230, 238)
keyTitle.BackgroundTransparency = 1
keyTitle.TextXAlignment = Enum.TextXAlignment.Left
keyTitle.ZIndex = 103

-- gold underline accent under title
local titleAccent = Instance.new("Frame", rightPanel)
titleAccent.Size = UDim2.new(0, 36, 0, 2)
titleAccent.Position = UDim2.new(0, 18, 0, 44)
titleAccent.BackgroundColor3 = C.accent
titleAccent.BorderSizePixel = 0
titleAccent.ZIndex = 103
corner(titleAccent, 1)

-- X close button (top-right)
local keyCloseBtn = Instance.new("TextButton", rightPanel)
keyCloseBtn.Size = UDim2.new(0, 30, 0, 30)
keyCloseBtn.Position = UDim2.new(1, -36, 0, 10)
keyCloseBtn.Text = ""
keyCloseBtn.Font = Enum.Font.GothamBold
keyCloseBtn.TextSize = 22
keyCloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
keyCloseBtn.BackgroundTransparency = 1
keyCloseBtn.BorderSizePixel = 0
keyCloseBtn.AutoButtonColor = false
keyCloseBtn.ZIndex = 103

keyCloseBtn.MouseEnter:Connect(function()
    tween(keyCloseBtn, {TextColor3 = C.danger}, 0.15)
end)
keyCloseBtn.MouseLeave:Connect(function()
    tween(keyCloseBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.15)
end)
keyCloseBtn.MouseButton1Click:Connect(function()
    sg:Destroy()
end)

--  INFO ROWS (Last Updated / Version / Type) 
local function makeInfoRow(parent, labelTxt, valueTxt, yPos)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1, -36, 0, 34)
    row.Position = UDim2.new(0, 18, 0, yPos)
    row.BackgroundColor3 = Color3.fromRGB(17, 17, 22)
    row.BorderSizePixel = 0
    row.ZIndex = 103
    corner(row, 7)
    padding(row, 0, 0, 14, 14)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 0, 0, 0)
    lbl.Text = labelTxt
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextColor3 = Color3.fromRGB(100, 100, 115)
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 104

    local val = Instance.new("TextLabel", row)
    val.Size = UDim2.new(0.5, 0, 1, 0)
    val.Position = UDim2.new(0.5, 0, 0, 0)
    val.Text = valueTxt
    val.Font = Enum.Font.GothamBold
    val.TextSize = 11
    val.TextColor3 = Color3.fromRGB(210, 210, 220)
    val.BackgroundTransparency = 1
    val.TextXAlignment = Enum.TextXAlignment.Right
    val.ZIndex = 104

    return row, lbl, val
end

local rowDiscord, lblDiscord, valDiscord = makeInfoRow(rightPanel, "Developer Discord", "@hor1zxn.", 58)
local discordIconVerify = Instance.new("ImageLabel", rowDiscord)
discordIconVerify.Size = UDim2.new(0, 14, 0, 14)
discordIconVerify.Position = UDim2.new(0, 0, 0.5, -7)
discordIconVerify.BackgroundTransparency = 1
discordIconVerify.Image = getAssetUrl("discord.png")
lblDiscord.Position = UDim2.new(0, 20, 0, 0)

local rowVersion, lblVersion, valVersion = makeInfoRow(rightPanel, "Version", SCRIPT_VERSION, 98)
local versionIconVerify = Instance.new("ImageLabel", rowVersion)
versionIconVerify.Size = UDim2.new(0, 14, 0, 14)
versionIconVerify.Position = UDim2.new(0, 0, 0.5, -7)
versionIconVerify.BackgroundTransparency = 1
versionIconVerify.Image = getAssetUrl("version.png")
lblVersion.Position = UDim2.new(0, 20, 0, 0)

local rowType, lblType, valType = makeInfoRow(rightPanel, "Type", "Universal", 138)
local typeIconVerify = Instance.new("ImageLabel", rowType)
typeIconVerify.Size = UDim2.new(0, 14, 0, 14)
typeIconVerify.Position = UDim2.new(0, 0, 0.5, -7)
typeIconVerify.BackgroundTransparency = 1
typeIconVerify.Image = getAssetUrl("type.png")
lblType.Position = UDim2.new(0, 20, 0, 0)

--  ACCESS KEY INPUT 
keyInputLabel = Instance.new("TextLabel", rightPanel)
keyInputLabel.Size = UDim2.new(1, -36, 0, 14)
keyInputLabel.Position = UDim2.new(0, 18, 0, 184)
keyInputLabel.Text = "ACCESS KEY"
keyInputLabel.Font = Enum.Font.GothamBold
keyInputLabel.TextSize = 9
keyInputLabel.TextColor3 = C.accent
keyInputLabel.TextXAlignment = Enum.TextXAlignment.Left
keyInputLabel.BackgroundTransparency = 1
keyInputLabel.ZIndex = 103

keyInput = Instance.new("TextBox", rightPanel)
keyInput.Size = UDim2.new(1, -36, 0, 36)
keyInput.Position = UDim2.new(0, 18, 0, 200)
keyInput.PlaceholderText = "Enter your access key..."
keyInput.PlaceholderColor3 = Color3.fromRGB(60, 60, 72)
keyInput.Text = ""
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 12
keyInput.TextColor3 = Color3.fromRGB(230, 230, 238)
keyInput.BackgroundColor3 = Color3.fromRGB(17, 17, 22)
keyInput.BorderSizePixel = 0
keyInput.ClearTextOnFocus = false
keyInput.ZIndex = 103
corner(keyInput, 7)

local keyInputStroke = stroke(keyInput, C.accent, 1.5, 0)
keyInputStroke.ZIndex = 103
keyInputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

keyInputGradient = Instance.new("UIGradient", keyInputStroke)
keyInputGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.3, 1),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(0.7, 1),
    NumberSequenceKeypoint.new(1, 1)
})

-- removed text stroke on key input
padding(keyInput, 0, 0, 12, 12)

--  STATUS LABEL 
keyStatus = Instance.new("TextLabel", rightPanel)
keyStatus.Size = UDim2.new(1, -36, 0, 16)
keyStatus.Position = UDim2.new(0, 18, 0, 244)
keyStatus.Text = ""
keyStatus.Font = Enum.Font.Gotham
keyStatus.TextSize = 10
keyStatus.TextColor3 = C.danger
keyStatus.BackgroundTransparency = 1
keyStatus.TextXAlignment = Enum.TextXAlignment.Center
keyStatus.ZIndex = 103

--  VERIFY BUTTON 
keyBtn = Instance.new("TextButton", rightPanel)
keyBtn.Size = UDim2.new(1, -36, 0, 42)
keyBtn.Position = UDim2.new(0, 18, 0, 264)
keyBtn.Text = "Load Script"
keyBtn.Font = Enum.Font.GothamBold
keyBtn.TextSize = 13
keyBtn.TextColor3 = Color3.fromRGB(15, 12, 5)
keyBtn.BackgroundColor3 = C.accent
keyBtn.BorderSizePixel = 0
keyBtn.AutoButtonColor = false
keyBtn.ZIndex = 103
corner(keyBtn, 9)

local verifyIcon = Instance.new("ImageLabel", keyBtn)
verifyIcon.Name = "VerifyIcon"
verifyIcon.Size = UDim2.new(0, 16, 0, 16)
verifyIcon.Position = UDim2.new(0.5, 80, 0.5, -8) -- Positioned further right to avoid overlapping long text
verifyIcon.BackgroundTransparency = 1
verifyIcon.Image = "rbxthumb://type=Asset&id=100074368064051&w=150&h=150"
verifyIcon.Visible = false
verifyIcon.ZIndex = 104

local keyBtnStroke = stroke(keyBtn, C.accent, 2.5, 0)
keyBtnGradient = Instance.new("UIGradient", keyBtnStroke)
keyBtnGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.3, 1),
    NumberSequenceKeypoint.new(0.5, 0),
    NumberSequenceKeypoint.new(0.7, 1),
    NumberSequenceKeypoint.new(1, 1)
})

-- removed hardcoded keyBtnGrad to allow solid theme color
keyBtn.MouseEnter:Connect(function()
    tween(keyBtn, {Size = UDim2.new(1, -30, 0, 44)}, 0.2, Enum.EasingStyle.Quint)
    tween(keyBtn, {Position = UDim2.new(0, 15, 0, 263)}, 0.2, Enum.EasingStyle.Quint)
end)
keyBtn.MouseLeave:Connect(function()
    tween(keyBtn, {BackgroundColor3 = C.accent}, 0.25, Enum.EasingStyle.Quint)
    tween(keyBtn, {Size = UDim2.new(1, -36, 0, 42)}, 0.25, Enum.EasingStyle.Quint)
    tween(keyBtn, {Position = UDim2.new(0, 18, 0, 264)}, 0.25, Enum.EasingStyle.Quint)
end)

--  ENTRANCE ANIMATION 
-- start transparent & shifted up
keyCard.BackgroundTransparency = 1
leftPanel.BackgroundTransparency = 1
leftMaskRight.BackgroundTransparency = 1
rightPanel.BackgroundTransparency = 1
keyOverlay.BackgroundTransparency = 1
keyCard.Position = UDim2.new(0, 20, 1, 50)

-- hide all children initially
for _, obj in ipairs({keyTitle, titleAccent, keyCloseBtn, keyInputLabel, keyInput, keyStatus, keyBtn, keyUser, keyUserSub, statusBadge, avatarRing}) do
    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
        obj.TextTransparency = 1
    end
    if obj:IsA("Frame") or obj:IsA("TextBox") or obj:IsA("TextButton") then
        obj.BackgroundTransparency = 1
    end
    if obj:IsA("ImageLabel") then
        obj.ImageTransparency = 1
    end
end
avatarImg.ImageTransparency = 1
leftGlowBlob.BackgroundTransparency = 1
titleAccent.BackgroundTransparency = 1
statusDot.BackgroundTransparency = 1
statusGlow.BackgroundTransparency = 1

task.spawn(function()
    task.wait(0.08)

    -- fade in backdrop
    -- overlay stays fully transparent (no background shade)

    -- slide card in
    tween(keyCard, {BackgroundTransparency = 1, Position = UDim2.new(0, 20, 1, -340)}, 0.5, Enum.EasingStyle.Back)
    task.wait(0.35)

    -- left panel contents
    tween(leftGlowBlob, {BackgroundTransparency = 0.88}, 0.4)
    tween(avatarRing, {BackgroundTransparency = 0}, 0.4)
    task.wait(0.1)
    tween(avatarImg, {ImageTransparency = 0}, 0.4)
    task.wait(0.1)
    tween(keyUser, {TextTransparency = 0, BackgroundTransparency = 1}, 0.3)
    task.wait(0.07)
    tween(keyUserSub, {TextTransparency = 0, BackgroundTransparency = 1}, 0.3)
    task.wait(0.07)
    tween(statusBadge, {BackgroundTransparency = 0}, 0.3)
    tween(statusDot, {BackgroundTransparency = 0}, 0.3)
    tween(statusLbl, {TextTransparency = 0}, 0.3)
    task.wait(0.1)
    -- right panel contents
    tween(keyTitle, {TextTransparency = 0, BackgroundTransparency = 1}, 0.3)
    task.spawn(function()
        local textToType = "PROJECT ETERNITY"
        for i = 1, #textToType do
            keyTitle.Text = string.sub(textToType, 1, i)
            task.wait(0.04)
        end
    end)
    task.wait(0.07)
    titleAccent.Size = UDim2.new(0, 0, 0, 2)
    titleAccent.BackgroundTransparency = 0
    tween(titleAccent, {Size = UDim2.new(0, 36, 0, 2)}, 0.5, Enum.EasingStyle.Quint)
    tween(keyCloseBtn, {TextTransparency = 0, BackgroundTransparency = 1}, 0.3)
    task.wait(0.1)
    tween(keyInputLabel, {TextTransparency = 0, BackgroundTransparency = 1}, 0.25)
    tween(keyInput, {BackgroundTransparency = 0, TextTransparency = 0}, 0.25)
    task.wait(0.1)
    tween(keyStatus, {TextTransparency = 0, BackgroundTransparency = 1}, 0.25)
    task.wait(0.05)
    tween(keyBtn, {BackgroundTransparency = 0, TextTransparency = 0}, 0.3)

    -- breathing glow on border
    task.spawn(function()
        while keyCard.Parent do
            tween(keyCardStroke, {Transparency = 0.1, Color = Color3.fromRGB(255, 200, 80)}, 2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(leftGlowBlob, {BackgroundTransparency = 0.82}, 2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2.5)
            tween(keyCardStroke, {Transparency = 0.55, Color = C.accent}, 2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            tween(leftGlowBlob, {BackgroundTransparency = 0.92}, 2.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(2.5)
        end
    end)
end) -- end task.spawn

    task.spawn(function()
        while keyCard.Parent do
            task.wait(0.02)
            if keyBtnGradient and keyBtnGradient.Parent then
                keyBtnGradient.Rotation = (keyBtnGradient.Rotation + 3) % 360
            end
            if verifyAvatarGradient and verifyAvatarGradient.Parent then
                verifyAvatarGradient.Rotation = (verifyAvatarGradient.Rotation + 2.5) % 360
            end
            if keyCardGradient and keyCardGradient.Parent then
                keyCardGradient.Rotation = (keyCardGradient.Rotation + 1.5) % 360
            end
            if keyInputGradient and keyInputGradient.Parent then
                keyInputGradient.Rotation = (keyInputGradient.Rotation + 2) % 360
            end
        end
    end)
end -- end do-scope

-- KEY BUTTON HANDLER
keyBtn.MouseButton1Click:Connect(function()
    local entered = keyInput.Text
    if entered == VALID_KEY then
        if verifyIcon then verifyIcon.Visible = true end
        keyStatus.Text = "Checking whitelist..."
        keyStatus.TextColor3 = C.accent
        tween(keyBtn, {BackgroundColor3 = C.accent}, 0.2)
        keyBtn.Text = "Verifying..."

        task.spawn(function()
            local success, response = pcall(function()
                return game:HttpGetAsync("https://raw.githubusercontent.com/hor1zencodes/patanahi/main/whitelist.json?t=" .. tostring(tick()))
            end)

            if success then
                local isWhitelisted = false
                pcall(function()
                    local HttpService = game:GetService("HttpService")
                    local whitelist = HttpService:JSONDecode(response)
                    local myName = game:GetService("Players").LocalPlayer.Name

                    WhitelistedUsers = {}
                    for _, name in ipairs(whitelist) do
                        WhitelistedUsers[string.lower(name)] = true
                        if string.lower(name) == string.lower(myName) then
                            isWhitelisted = true
                        end
                    end
                end)

                -- Fetch custom tags for overhead logos
                pcall(function()
                    local HttpService = game:GetService("HttpService")
                    local tagsResp = game:HttpGetAsync("https://raw.githubusercontent.com/hor1zencodes/patanahi/main/tags.json?t=" .. tostring(tick()))
                    getgenv().EternityCustomTags = HttpService:JSONDecode(tagsResp)
                end)

                if isWhitelisted then
                    keyStatus.Text = "Verified & Whitelisted! Loading..."
                    keyStatus.TextColor3 = C.success
                    tween(keyBtn, {BackgroundColor3 = C.success}, 0.2)
                    keyBtn.Text = " Verified!"

                    if verifyIcon then
                        verifyIcon.Visible = true
                    end

                    task.wait(0.8)

                    -- Fade out key system UI
                    tween(keyInputLabel, {TextTransparency = 1}, 0.15)
                    tween(keyInput, {BackgroundTransparency = 1, TextTransparency = 1}, 0.15)
                    tween(keyBtn, {BackgroundTransparency = 1, TextTransparency = 1}, 0.15)
                    tween(keyCardStroke, {Transparency = 1}, 0.2)
                    tween(leftGlowBlob, {BackgroundTransparency = 1}, 0.2)
                    tween(keyCard, {BackgroundTransparency = 1}, 0.4, Enum.EasingStyle.Quint)
                    tween(keyOverlay, {BackgroundTransparency = 1}, 0.5)
                    task.wait(0.5)
                    keyOverlay.Visible = false

                    -- LOAD MAIN GUI SCRIPT
                    local mainUrl = "https://raw.githubusercontent.com/hor1zencodes/assets/main/main.lua"
                    local mainCode = game:HttpGet(mainUrl)
                    local fn = loadstring(mainCode)
                    if fn then
                        fn()
                    else
                        warn("[Eternity] Failed to load main script!")
                    end
                else
                    keyStatus.Text = "Username not whitelisted."
                    keyStatus.TextColor3 = C.danger
                    tween(keyBtn, {BackgroundColor3 = C.danger}, 0.15)
                    keyBtn.Text = "ACCESS DENIED"

                    -- Shake and Flash Error Effect
                    tween(keyInput, {BackgroundColor3 = Color3.fromRGB(80, 20, 20)}, 0.1)
                    local origPos = UDim2.new(0, 18, 0, 200)
                    tween(keyInput, {Position = origPos + UDim2.new(0, -6, 0, 0)}, 0.05)
                    task.wait(0.05)
                    tween(keyInput, {Position = origPos + UDim2.new(0, 6, 0, 0)}, 0.05)
                    task.wait(0.05)
                    tween(keyInput, {Position = origPos + UDim2.new(0, -4, 0, 0)}, 0.05)
                    task.wait(0.05)
                    tween(keyInput, {Position = origPos + UDim2.new(0, 4, 0, 0)}, 0.05)
                    task.wait(0.05)
                    tween(keyInput, {Position = origPos}, 0.05)
                    tween(keyInput, {BackgroundColor3 = Color3.fromRGB(17, 17, 22)}, 0.3)
                end
            else
                keyStatus.Text = "Failed to fetch whitelist database."
                keyStatus.TextColor3 = C.danger
                tween(keyBtn, {BackgroundColor3 = C.danger}, 0.15)
                keyBtn.Text = "NETWORK ERROR"
            end
        end)
    else
        keyStatus.Text = " Invalid key. Try again."
        keyStatus.TextColor3 = C.danger
        tween(keyBtn, {BackgroundColor3 = C.danger}, 0.15)

        -- Shake and Flash Error Effect
        tween(keyInput, {BackgroundColor3 = Color3.fromRGB(80, 20, 20)}, 0.1)
        local origPos = UDim2.new(0, 18, 0, 200)
        tween(keyInput, {Position = origPos + UDim2.new(0, -6, 0, 0)}, 0.05)
        task.wait(0.05)
        tween(keyInput, {Position = origPos + UDim2.new(0, 6, 0, 0)}, 0.05)
        task.wait(0.05)
        tween(keyInput, {Position = origPos + UDim2.new(0, -4, 0, 0)}, 0.05)
        task.wait(0.05)
        tween(keyInput, {Position = origPos + UDim2.new(0, 4, 0, 0)}, 0.05)
        task.wait(0.05)
        tween(keyInput, {Position = origPos}, 0.05)
        tween(keyInput, {BackgroundColor3 = Color3.fromRGB(17, 17, 22)}, 0.3)

        task.wait(0.5)
        tween(keyBtn, {BackgroundColor3 = C.accentDim}, 0.3)
    end
end)

-- also verify on Enter key
keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        keyBtn.MouseButton1Click:Fire()
    end
end)