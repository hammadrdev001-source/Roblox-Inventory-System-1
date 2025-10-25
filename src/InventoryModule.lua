--[[
    InventoryModule.lua
    Author: YourName
    Description:
        Handles inventory data for a single player.
]]

local InventoryModule = {}
InventoryModule.__index = InventoryModule

function InventoryModule.new(player)
    local self = setmetatable({}, InventoryModule)
    self.Player = player
    self.Items = {}
    return self
end

function InventoryModule:AddItem(itemName, quantity)
    quantity = quantity or 1
    self.Items[itemName] = (self.Items[itemName] or 0) + quantity
    print(string.format("[%s] received %d x %s", self.Player.Name, quantity, itemName))
end

function InventoryModule:RemoveItem(itemName, quantity)
    if not self.Items[itemName] then return false end
    quantity = quantity or 1
    self.Items[itemName] -= quantity
    if self.Items[itemName] <= 0 then
        self.Items[itemName] = nil
    end
    print(string.format("[%s] lost %d x %s", self.Player.Name, quantity, itemName))
    return true
end

function InventoryModule:ListItems()
    print("--- " .. self.Player.Name .. "'s Inventory ---")
    for item, amount in pairs(self.Items) do
        print(item, "x" .. amount)
    end
end

return InventoryModule
