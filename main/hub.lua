--[[
    orbisV Universal Hub v0.1.1
    Author: orbisV
    Keep this header. Don't be a skid.
]]

local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")

WindUI:Notify({
    Title = "orbisV Hub",
    Content = "Press Right Shift to toggle. God Mode is in Player tab.",
    Duration = 10,
    Icon = "rbxassetid://4483362458",
})

local function getHum()
    return LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
end

local GodModeEnabled = false
local godCons = {}

local function toggleGodMode(state)
    GodModeEnabled = state
    local hum = getHum()
    if not hum then return end

    if GodModeEnabled then
        hum.MaxHealth = math.huge
        hum.Health = math.huge
        if getconnections then
            for _, c in pairs(getconnections(hum.Died)) do
                table.insert(godCons, c)
                c:Disable()
            end
        end
        print("godmode on")
    else
        hum.MaxHealth = 100
        hum.Health = 100
        for _, c in pairs(godCons) do
            pcall(function() c:Enable() end)
        end
        godCons = {}
        print("godmode off")
    end
end

local FlyEnabled = false
local FlySpeed = 50
local flyConn, flyBV

local function toggleFly(state)
    FlyEnabled = state
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if FlyEnabled then
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = hrp

        flyConn = RunService.RenderStepped:Connect(function()
            if not FlyEnabled or not flyBV then return end
            local cam = Workspace.CurrentCamera
            local dir = cam.CFrame:VectorToWorldSpace(Vector3.new(
                (UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.A) and 1 or 0),
                0,
                (UserInputService:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0)
            ))
            flyBV.Velocity = dir * FlySpeed
        end)
    else
        if flyConn then flyConn:Disconnect() flyConn = nil end
        if flyBV then flyBV:Destroy() flyBV = nil end
    end
end

local noclipConn
local NoclipEnabled = false

local function toggleNoclip(state)
    NoclipEnabled = state
    if NoclipEnabled then
        noclipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then
                        p.CanCollide = false
                    end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
        if LocalPlayer.Character then
            for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end

local InfJumpEnabled = false
UserInputService.JumpRequest:Connect(function()
    if InfJumpEnabled then
        local hum = getHum()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local FullbrightEnabled = false
local oldAmbient, oldOutdoor, oldBrightness
local function toggleFullbright(state)
    FullbrightEnabled = state
    if FullbrightEnabled then
        oldAmbient = Lighting.Ambient
        oldOutdoor = Lighting.OutdoorAmbient
        oldBrightness = Lighting.Brightness
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
    else
        if oldAmbient then Lighting.Ambient = oldAmbient end
        if oldOutdoor then Lighting.OutdoorAmbient = oldOutdoor end
        if oldBrightness then Lighting.Brightness = oldBrightness end
    end
end

local ESPEnabled = false
local ESPObjects = {}
local espConn

local function createESP(player)
    if player == LocalPlayer then return end
    local h = Instance.new("Highlight")
    h.Name = "orbisV_ESP"
    h.FillColor = Color3.fromRGB(255, 100, 100)
    h.OutlineColor = Color3.fromRGB(255, 255, 255)
    if player.Character then h.Parent = player.Character end
    ESPObjects[player] = h
end

local function toggleESP(state)
    ESPEnabled = state
    if ESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character then createESP(p) end
        end
        espConn = Players.PlayerAdded:Connect(function(p) 
            p.CharacterAdded:Connect(function()
                if ESPEnabled then createESP(p) end
            end)
        end)
    else
        for _, h in pairs(ESPObjects) do
            if h then h:Destroy() end
        end
        ESPObjects = {}
        if espConn then espConn:Disconnect() espConn = nil end
    end
end

local function teleportToPlayer(targetName)
    local target = Players:FindFirstChild(targetName)
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            myHrp.CFrame = target.Character.HumanoidRootPart.CFrame
        end
    end
end

local function serverHop()
    local ok, res = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"))
    end)
    if ok and res and res.data then
        for _, v in pairs(res.data) do
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id, LocalPlayer)
                break
            end
        end
    end
end

local ClickTPEnabled = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not ClickTPEnabled then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local mouse = LocalPlayer:GetMouse()
        if mouse.Hit then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
            end
        end
    end
end)

local Window = WindUI:CreateWindow({
    Title = "orbisV Hub v0.1.1",
    Icon = "rbxassetid://4483362458",
    Author = "orbisV",
    Folder = "orbisVHub",
    Size = UDim2.fromOffset(580, 460),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = false,
})

local PlayerTab = Window:Tab({ Title = "Player", Icon = "user" })
PlayerTab:Section({ Title = "God Mode" })
PlayerTab:Toggle({ Title = "God Mode", Desc = "Makes you unkillable.", Value = false, Callback = toggleGodMode })
PlayerTab:Section({ Title = "Movement" })
PlayerTab:Slider({ Title = "WalkSpeed", Value = { Min = 16, Max = 200, Default = 16 }, Callback = function(v) 
    local hum = getHum()
    if hum then hum.WalkSpeed = v end
end })
PlayerTab:Slider({ Title = "JumpPower", Value = { Min = 50, Max = 500, Default = 50 }, Callback = function(v) 
    local hum = getHum()
    if hum then hum.JumpPower = v end
end })
PlayerTab:Toggle({ Title = "Fly", Value = false, Callback = toggleFly })
PlayerTab:Slider({ Title = "Fly Speed", Value = { Min = 10, Max = 200, Default = 50 }, Callback = function(v) FlySpeed = v end })
PlayerTab:Toggle({ Title = "Noclip", Value = false, Callback = toggleNoclip })
PlayerTab:Toggle({ Title = "Infinite Jump", Value = false, Callback = function(v) InfJumpEnabled = v end })

local VisualTab = Window:Tab({ Title = "Visuals", Icon = "eye" })
VisualTab:Section({ Title = "ESP" })
VisualTab:Toggle({ Title = "Player ESP", Value = false, Callback = toggleESP })
VisualTab:Section({ Title = "Environment" })
VisualTab:Toggle({ Title = "Fullbright", Value = false, Callback = toggleFullbright })

local TeleportTab = Window:Tab({ Title = "Teleport", Icon = "map-pin" })
TeleportTab:Section({ Title = "Click Teleport" })
TeleportTab:Toggle({ Title = "Ctrl + Click Teleport", Value = false, Callback = function(v) ClickTPEnabled = v end })
TeleportTab:Section({ Title = "Player Teleport" })
TeleportTab:Input({ Title = "Teleport to Player", Value = "", Placeholder = "Enter username...", Callback = teleportToPlayer })

local MiscTab = Window:Tab({ Title = "Misc", Icon = "wrench" })
MiscTab:Section({ Title = "Server" })
MiscTab:Button({ Title = "Rejoin Server", Callback = function() game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer) end })
MiscTab:Button({ Title = "Server Hop", Callback = serverHop })
MiscTab:Section({ Title = "Utility" })
MiscTab:Button({ Title = "Reset Character", Callback = function() 
    local hum = getHum()
    if hum then hum.Health = 0 end
end })

print("[orbisV] Hub v0.1.1 loaded.")
