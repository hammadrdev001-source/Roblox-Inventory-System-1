--[[
    ExampleLocalScript.lua
    Description:
        Demonstrates basic inventory actions.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local InventoryService = require(ReplicatedStorage:WaitForChild("InventoryService"))

local player = game.Players.LocalPlayer
task.wait(2) -- give service time to initialize

local inventory = InventoryService:GetInventory(player)
if inventory then
    inventory:AddItem("Health Potion", 3)
    inventory:AddItem("Sword", 1)
    inventory:ListItems()

    task.wait(1)
    inventory:RemoveItem("Health Potion", 1)
    inventory:ListItems()
end
