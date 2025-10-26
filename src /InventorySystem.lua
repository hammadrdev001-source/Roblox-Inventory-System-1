--========================================================--
--==                Inventory System v1.0               ==--
--==              Author: hammadrdev001/Zyntrax                 ==--
--==     Single-file inventory management system        ==--
--==   HiddenDevs-compliant (200+ lines, one file)      ==--
--========================================================--

--// Description:
-- This system manages player inventories in Roblox.
-- It supports adding, removing, saving, loading, and checking items.
-- It includes a simple demonstration script at the bottom.
--========================================================--

------------------------------
--== SERVICES & VARIABLES ==--
------------------------------
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local InventoryDataStore = DataStoreService:GetDataStore("PlayerInventoryData")

-- Storage for player inventories in runtime
local InventoryStore = {}

-----------------------------------
--== INVENTORY CLASS DEFINITION ==--
-----------------------------------
local InventorySystem = {}
InventorySystem.__index = InventorySystem

------------------------------------------------------------
-- Constructor
------------------------------------------------------------
function InventorySystem.new(player)
	local self = setmetatable({}, InventorySystem)
	self.Player = player
	self.Items = {}
	self.MaxSlots = 30
	self.AutoSave = true
	return self
end

------------------------------------------------------------
-- AddItem: adds an item to inventory
------------------------------------------------------------
function InventorySystem:AddItem(itemName, quantity)
	if not itemName then return end
	quantity = quantity or 1
	
	if #self:GetItemList() >= self.MaxSlots and not self.Items[itemName] then
		warn(self.Player.Name .. "'s inventory is full!")
		return false
	end

	self.Items[itemName] = (self.Items[itemName] or 0) + quantity
	print(string.format("[%s] +%dx %s", self.Player.Name, quantity, itemName))
	
	if self.AutoSave then
		self:Save()
	end
	return true
end

------------------------------------------------------------
-- RemoveItem: removes items from inventory
------------------------------------------------------------
function InventorySystem:RemoveItem(itemName, quantity)
	if not self.Items[itemName] then return false end
	quantity = quantity or 1
	self.Items[itemName] -= quantity
	if self.Items[itemName] <= 0 then
		self.Items[itemName] = nil
	end
	print(string.format("[%s] -%dx %s", self.Player.Name, quantity, itemName))
	
	if self.AutoSave then
		self:Save()
	end
	return true
end

------------------------------------------------------------
-- GetItems: returns table of all items
------------------------------------------------------------
function InventorySystem:GetItems()
	return self.Items
end

------------------------------------------------------------
-- GetItemList: returns an array of item names
------------------------------------------------------------
function InventorySystem:GetItemList()
	local list = {}
	for name in pairs(self.Items) do
		table.insert(list, name)
	end
	return list
end

------------------------------------------------------------
-- HasItem: checks if a player has a certain item
------------------------------------------------------------
function InventorySystem:HasItem(itemName, quantity)
	quantity = quantity or 1
	return (self.Items[itemName] or 0) >= quantity
end

------------------------------------------------------------
-- ClearInventory: removes all items
------------------------------------------------------------
function InventorySystem:ClearInventory()
	self.Items = {}
	print(self.Player.Name .. "'s inventory cleared.")
	if self.AutoSave then
		self:Save()
	end
end

------------------------------------------------------------
-- Save: saves current inventory to DataStore
------------------------------------------------------------
function InventorySystem:Save()
	local success, err = pcall(function()
		InventoryDataStore:SetAsync(self.Player.UserId, self.Items)
	end)
	if not success then
		warn("Failed to save inventory for " .. self.Player.Name .. ": " .. err)
	end
end

------------------------------------------------------------
-- Load: loads inventory from DataStore
------------------------------------------------------------
function InventorySystem:Load()
	local success, data = pcall(function()
		return InventoryDataStore:GetAsync(self.Player.UserId)
	end)
	if success and data then
		self.Items = data
		print("Loaded inventory for " .. self.Player.Name)
	else
		print("No previous inventory for " .. self.Player.Name)
	end
end

------------------------------------------------------------
-- MergeInventories: merges another inventory table
------------------------------------------------------------
function InventorySystem:MergeInventories(otherItems)
	for item, count in pairs(otherItems) do
		self:AddItem(item, count)
	end
end

------------------------------------------------------------
-- PrintInventory: prints contents nicely
------------------------------------------------------------
function InventorySystem:PrintInventory()
	print("------ Inventory of " .. self.Player.Name .. " ------")
	for item, qty in pairs(self.Items) do
		print(string.format("Item: %s | Quantity: %d", item, qty))
	end
	print("--------------------------------------------")
end

------------------------------------------------------------
-- Helper: returns total number of items (not unique)
------------------------------------------------------------
function InventorySystem:GetTotalItemCount()
	local total = 0
	for _, qty in pairs(self.Items) do
		total += qty
	end
	return total
end

------------------------------------------------------------
-- Helper: returns number of unique items
------------------------------------------------------------
function InventorySystem:GetUniqueItemCount()
	local count = 0
	for _ in pairs(self.Items) do
		count += 1
	end
	return count
end

------------------------------------------------------------
-- Helper: checks if inventory is empty
------------------------------------------------------------
function InventorySystem:IsEmpty()
	return next(self.Items) == nil
end

------------------------------------------------------------
-- Example utility: give random item
------------------------------------------------------------
function InventorySystem:GiveRandomItem()
	local sampleItems = {"Wood", "Stone", "Iron", "Gold", "Apple"}
	local randomItem = sampleItems[math.random(1, #sampleItems)]
	local randomQty = math.random(1, 5)
	self:AddItem(randomItem, randomQty)
end

--========================================================--
--==                 SERVICE CONNECTIONS                 ==--
--========================================================--

Players.PlayerAdded:Connect(function(player)
	local inventory = InventorySystem.new(player)
	InventoryStore[player.UserId] = inventory
	inventory:Load()
end)

Players.PlayerRemoving:Connect(function(player)
	local inv = InventoryStore[player.UserId]
	if inv then
		inv:Save()
		InventoryStore[player.UserId] = nil
	end
end)

------------------------------------------------------------
-- GetInventory: fetch player inventory from store
------------------------------------------------------------
function InventorySystem:GetInventory(player)
	return InventoryStore[player.UserId]
end

--========================================================--
--==           DEMONSTRATION / EXAMPLE USAGE             ==--
--========================================================--

-- NOTE: This section runs on the client for demonstration only.
-- In production, comment or remove this part.

task.wait(2)
print("Running example inventory demonstration...")

-- Simulate LocalPlayer for testing
local testPlayer = {
	Name = "HammadTestPlayer",
	UserId = 9999
}

-- Create new inventory manually (for non-Players service tests)
local testInventory = InventorySystem.new(testPlayer)

-- Add items
testInventory:AddItem("Wood", 10)
testInventory:AddItem("Stone", 5)
testInventory:AddItem("Apple", 2)

-- Remove some items
testInventory:RemoveItem("Wood", 3)

-- Print inventory
testInventory:PrintInventory()

-- Check item existence
if testInventory:HasItem("Stone", 2) then
	print("✅ Has enough Stone!")
else
	print("❌ Not enough Stone!")
end

-- Give random item
testInventory:GiveRandomItem()

-- Show totals
print("Total items:", testInventory:GetTotalItemCount())
print("Unique items:", testInventory:GetUniqueItemCount())

-- Save / Load simulation
testInventory:Save()
testInventory:Load()

-- Clear inventory
testInventory:ClearInventory()

-- Print again to confirm empty
if testInventory:IsEmpty() then
	print("✅ Inventory is empty now!")
end

print("Demo finished successfully!")
--========================================================--
-- End of file (Approx. 240+ lines)
--========================================================--

return InventorySystem
