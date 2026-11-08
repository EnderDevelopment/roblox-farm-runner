local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local statusEvent = ReplicatedStorage:WaitForChild("FarmRemotes"):WaitForChild("Status")

local gui = Instance.new("ScreenGui")
gui.Name = "FarmHUD"
gui.ResetOnSpawn = false
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Name = "InfoPanel"
panel.Position = UDim2.fromOffset(18, 18)
panel.Size = UDim2.fromOffset(290, 92)
panel.BackgroundColor3 = Color3.fromRGB(36, 49, 38)
panel.BackgroundTransparency = 0.08
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = panel

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -24, 0, 28)
title.Position = UDim2.fromOffset(12, 8)
title.BackgroundTransparency = 1
title.Text = "RUN A FARM"
title.TextColor3 = Color3.fromRGB(255, 232, 160)
title.TextXAlignment = Enum.TextXAlignment.Left
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.Parent = panel

local coins = Instance.new("TextLabel")
coins.Size = UDim2.new(1, -24, 0, 22)
coins.Position = UDim2.fromOffset(12, 38)
coins.BackgroundTransparency = 1
coins.TextColor3 = Color3.fromRGB(255, 220, 85)
coins.TextXAlignment = Enum.TextXAlignment.Left
coins.Font = Enum.Font.GothamSemibold
coins.TextSize = 16
coins.Parent = panel

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, -24, 0, 24)
status.Position = UDim2.fromOffset(12, 62)
status.BackgroundTransparency = 1
status.Text = "Use the prompts on each plot."
status.TextColor3 = Color3.fromRGB(230, 240, 230)
status.TextXAlignment = Enum.TextXAlignment.Left
status.Font = Enum.Font.Gotham
status.TextSize = 13
status.TextTruncate = Enum.TextTruncate.AtEnd
status.Parent = panel

local function refreshCoins()
    local leaderstats = player:FindFirstChild("leaderstats")
    local value = leaderstats and leaderstats:FindFirstChild("Coins")
    if value then
        coins.Text = "Coins: " .. value.Value
    end
end

local function connectCoins()
    local leaderstats = player:WaitForChild("leaderstats")
    local value = leaderstats:WaitForChild("Coins")
    value:GetPropertyChangedSignal("Value"):Connect(refreshCoins)
    refreshCoins()
end

task.spawn(connectCoins)

statusEvent.OnClientEvent:Connect(function(message, color)
    status.Text = message
    status.TextColor3 = color or Color3.fromRGB(230, 240, 230)
end)
