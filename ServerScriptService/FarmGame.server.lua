local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local CONFIG = {
    PlotCount = 12,
    PlotColumns = 4,
    PlotSpacing = 12,
    PlotSize = Vector3.new(10, 0.6, 10),
    GrowthSeconds = 45,
    WaterDuration = 18,
    HarvestReward = 15,
    StartingCoins = 25,
}

local farmFolder = Workspace:FindFirstChild("Farm") or Instance.new("Folder")
farmFolder.Name = "Farm"
farmFolder.Parent = Workspace

local remotes = ReplicatedStorage:FindFirstChild("FarmRemotes") or Instance.new("Folder")
remotes.Name = "FarmRemotes"
remotes.Parent = ReplicatedStorage

local statusEvent = remotes:FindFirstChild("Status") or Instance.new("RemoteEvent")
statusEvent.Name = "Status"
statusEvent.Parent = remotes

local plots = {}
local playerData = {}
local origin = Vector3.new(-(CONFIG.PlotColumns - 1) * CONFIG.PlotSpacing / 2, 0, 18)

local function sendStatus(player, message, color)
    statusEvent:FireClient(player, message, color or Color3.fromRGB(245, 245, 245))
end

local function createPart(name, size, position, color, parent)
    local part = Instance.new("Part")
    part.Name = name
    part.Size = size
    part.Position = position
    part.Anchored = true
    part.CanCollide = true
    part.Material = Enum.Material.Grass
    part.Color = color
    part.Parent = parent
    return part
end

local function updatePrompt(plot)
    local prompt = plot.Prompt
    if plot.State == "Empty" then
        prompt.ActionText = "Plant Seed"
        prompt.ObjectText = "Empty Plot"
    elseif plot.State == "Growing" then
        prompt.ActionText = "Water Crop"
        prompt.ObjectText = plot.WateredUntil > os.clock() and "Watered Crop" or "Dry Crop"
    else
        prompt.ActionText = "Harvest Crop"
        prompt.ObjectText = "Ready Crop"
    end
end

local function setCropVisual(plot, stage)
    if plot.Crop then
        plot.Crop:Destroy()
        plot.Crop = nil
    end
    if stage <= 0 then
        return
    end

    local height = stage == 1 and 1.2 or (stage == 2 and 2.5 or 4)
    local crop = Instance.new("Part")
    crop.Name = "Crop"
    crop.Size = Vector3.new(1.2, height, 1.2)
    crop.Position = plot.Part.Position + Vector3.new(0, plot.Part.Size.Y / 2 + height / 2, 0)
    crop.Anchored = true
    crop.CanCollide = false
    crop.Material = Enum.Material.Grass
    crop.Color = stage == 3 and Color3.fromRGB(255, 205, 65) or Color3.fromRGB(75, 170, 70)
    crop.Parent = plot.Model
    plot.Crop = crop
end

local function completeGrowth(plot)
    if plot.State ~= "Growing" or os.clock() < plot.ReadyAt then
        return
    end
    plot.State = "Ready"
    plot.Stage = 3
    setCropVisual(plot, plot.Stage)
    updatePrompt(plot)
end

local function plant(plot, player)
    plot.State = "Growing"
    plot.Stage = 1
    plot.ReadyAt = os.clock() + CONFIG.GrowthSeconds
    plot.WateredUntil = 0
    setCropVisual(plot, plot.Stage)
    updatePrompt(plot)
    sendStatus(player, "Seed planted. Water the crop to help it grow.", Color3.fromRGB(125, 220, 115))
end

local function water(plot, player)
    if plot.State ~= "Growing" then
        return
    end
    if plot.WateredUntil > os.clock() then
        sendStatus(player, "This crop is already watered.", Color3.fromRGB(120, 190, 245))
        return
    end
    plot.WateredUntil = os.clock() + CONFIG.WaterDuration
    plot.ReadyAt = math.max(os.clock() + 4, plot.ReadyAt - 8)
    plot.Stage = 2
    setCropVisual(plot, plot.Stage)
    updatePrompt(plot)
    sendStatus(player, "Crop watered. It will grow faster now.", Color3.fromRGB(120, 190, 245))
end

local function harvest(plot, player)
    if plot.State ~= "Ready" then
        return
    end
    local data = playerData[player]
    if not data or not data.Coins then
        return
    end
    data.Coins.Value += CONFIG.HarvestReward
    plot.State = "Empty"
    plot.Stage = 0
    plot.ReadyAt = 0
    plot.WateredUntil = 0
    setCropVisual(plot, 0)
    updatePrompt(plot)
    sendStatus(player, "+" .. CONFIG.HarvestReward .. " coins! Plant another seed.", Color3.fromRGB(255, 220, 85))
end

local function handlePlot(plot, player)
    if plot.State == "Empty" then
        plant(plot, player)
    elseif plot.State == "Growing" then
        water(plot, player)
    elseif plot.State == "Ready" then
        harvest(plot, player)
    end
end

local function createPlot(index)
    local row = math.floor((index - 1) / CONFIG.PlotColumns)
    local column = (index - 1) % CONFIG.PlotColumns
    local position = origin + Vector3.new(column * CONFIG.PlotSpacing, 0, row * CONFIG.PlotSpacing)
    local model = Instance.new("Model")
    model.Name = "Plot" .. index
    model.Parent = farmFolder

    local part = createPart("Soil", CONFIG.PlotSize, position, Color3.fromRGB(115, 75, 42), model)
    part.Material = Enum.Material.Ground

    local prompt = Instance.new("ProximityPrompt")
    prompt.Name = "Prompt"
    prompt.ActionText = "Plant Seed"
    prompt.ObjectText = "Empty Plot"
    prompt.HoldDuration = 0.25
    prompt.MaxActivationDistance = 10
    prompt.RequiresLineOfSight = false
    prompt.Parent = part

    local plot = {
        Model = model,
        Part = part,
        Prompt = prompt,
        State = "Empty",
        Stage = 0,
        ReadyAt = 0,
        WateredUntil = 0,
        Crop = nil,
    }
    table.insert(plots, plot)
    prompt.Triggered:Connect(function(player)
        handlePlot(plot, player)
    end)
end

local function createFarmSign()
    local sign = createPart("FarmSign", Vector3.new(20, 5, 0.6), origin + Vector3.new(0, 3, -10), Color3.fromRGB(95, 58, 32), farmFolder)
    sign.Material = Enum.Material.Wood
    local gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.CanvasSize = Vector2.new(800, 200)
    gui.Parent = sign
    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundTransparency = 1
    label.Text = "RUN A FARM"
    label.TextColor3 = Color3.fromRGB(255, 235, 170)
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = gui
end

for index = 1, CONFIG.PlotCount do
    createPlot(index)
end
createFarmSign()

Players.PlayerAdded:Connect(function(player)
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player

    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Value = CONFIG.StartingCoins
    coins.Parent = leaderstats
    playerData[player] = { Coins = coins }

    player.CharacterAdded:Connect(function(character)
        local root = character:WaitForChild("HumanoidRootPart", 10)
        if root then
            root.CFrame = CFrame.new(origin + Vector3.new(0, 5, -18))
        end
    end)
    sendStatus(player, "Welcome! Plant, water, and harvest your crops.", Color3.fromRGB(255, 235, 170))
end)

Players.PlayerRemoving:Connect(function(player)
    playerData[player] = nil
end)

task.spawn(function()
    while true do
        for _, plot in ipairs(plots) do
            completeGrowth(plot)
            if plot.State == "Growing" and plot.WateredUntil > 0 and plot.WateredUntil <= os.clock() then
                plot.WateredUntil = 0
                plot.Stage = 1
                setCropVisual(plot, plot.Stage)
                updatePrompt(plot)
            end
        end
        task.wait(1)
    end
end)
