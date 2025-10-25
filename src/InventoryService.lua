--[[
    InventoryService.lua
    Author: YourName
    Description:
        Manages all players' inventories.
]]

local Players = game:GetService("Players")
local InventoryModule = require(script.Parent.InventoryModule)

local InventoryService = {}
InventoryService.Inventories = {}

Players.PlayerAdded:Connect(function(player)
    InventoryService.Inventories[player] = InventoryModule.new(player)
    print("[InventoryService] Created inventory for " .. player.Name)
end)

Players.PlayerRemoving:Connect(function(player)
    InventoryService.Inventories[player] = nil
    print("[InventoryService] Removed inventory for " .. player.Name)
end)

function InventoryService:GetInventory(player)
    return InventoryService.Inventories[player]
end

return InventoryService
