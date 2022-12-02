require "behaviours/wander"

--- Iterate the given function over a list of elements in the table.
--- @param list table The list to iterate over
--- @param func function The function to call for each element
--- @return nil
local function Iterate(list, func)
	for _, v in pairs(list) do
		func(v)
	end
end

--- Generate a UUID
--- @return string UUID
local function UUID()
	local fn = function(x)
		local r = math.random(16) - 1
		r = (x == "x") and (r + 1) and (r % 4) + 9 or r
		return ("0123456789abcdef"):sub(r, r)
	end
	return (("xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"):gsub("[xy]", fn))
end


local LIGHT_TAGS = {"lightsource"}
local function GetNearestLightPos(inst)
	local light = GetClosestInstWithTag(LIGHT_TAGS, inst, 100)
	if light then return Vector3(light.Transform:GetWorldPosition()) end
	return nil
end




local AIAgent = Class(Brain, function(self, inst)
	Brain._ctor(self, inst)
	self.bills = {}
end)

--- Tell the talker component to say a phrase.
--- NOTE: This does not print a message into the game chat.
--- @param text string What to say?
function AIAgent:Say(text) self.inst.components.talker:Say(text) end

-- function AIAgent:GetFirstItem(prefab) return self.inst.components.inventory:FindItem(function(item) return tostring(item.prefab) == prefab end) end

--- Get the first item from the inventory that matches the given predicate.
--- @param predicate function The predicate to match
--- @return userdata item The first item that matches the predicate
function AIAgent:GetItem(predicate)
	return self.inst.components.inventory:FindItem(predicate)
end

--- Get the first item from the inventory if its name matches prefab.
--- @param prefab string The name of the item to find
--- @return userdata item The first item that matches the name
function AIAgent:GetItemByName(prefab)
	return self:GetItem(function(item) return tostring(item.prefab) == prefab end)
end

--- Equip an item from our inventory by name.
--- @param prefab string
--- @return nil
function AIAgent:EquipItemByName(prefab)
	local item = self:GetItemByName(prefab)

	if item then
		self.inst.components.inventory:Equip(item)
		return true
	end

	self:Say("I don't have a " .. prefab .. "!")
	return false
end

--- Get the currently equipped item in the inventory component, by its prefab name
--- @return userdata item The currently equipped item, or nil
function AIAgent:GetEquipped(prefab)
    local eslots = self.inst.components.inventory.equipslots
	for k, v in pairs(eslots) do
		if v and v.prefab == prefab then
			return v
		end
	end
end

--- Check if the agent has an item in their inventory.
--- @param prefab string The name of the item to check for
--- @return boolean hasItem True if the agent has the item, false otherwise
function AIAgent:HasItem(prefab)
	return self:GetItemByName(prefab) ~= nil
end

--- Check if the agent has an item equipped in their inventory.
--- @param prefab string The name of the item to check for
--- @return boolean hasItem True if the agent has the item equipped, false otherwise
function AIAgent:HasEquipped(prefab)
	return self:GetEquipped(prefab) ~= nil
end

--- Interface with botmemory and either set or get the value of a key.
--- @param key string The key to set or get
--- @param value any The value to set, or nil to get
--- @return any The value of the key, or nil if it doesn't exist
function AIAgent:Memory(key, value)
	if value then
		self.inst.components.botmemory:SetMemory(key, value)
	else
		return self.inst.components.botmemory:GetMemory(key)
	end
end

--- Set the bot's home position to the given location
--- @param pos Vector3 The position to set as home
function AIAgent:SetHome(pos)
	self.inst.components.botmemory:Set("home", pos)
end

--- Set the bot's home position to right here.
function AIAgent:SetHomeHere()
	self:SetHome(Vector3(self.inst.Transform:GetWorldPosition()))
end

--- Get the bot's home position
function AIAgent:GetHome()
	return self.inst.components.botmemory:Get("home")
end

--- Count all of the prefab in our inventory that match the given predicate.
--- @param predicate function The predicate to match
--- @return number count The number of items that match the predicate
function AIAgent:CountItems(predicate)
	local count = 0
	Iterate(self.inst.components.inventory.itemslots, function(item)
		if predicate(item) then
			count = count + 1
		end
	end)
	return count
end

--- Count all of the prefab in our inventory that match the given name.
--- @param prefab string The name of the item to count
--- @return number count The number of items that match the name
function AIAgent:CountItemsByName(prefab)
	return self:CountItems(function(item) return tostring(item.prefab) == prefab end)
end

--[[function AIAgent:GetPointNearPrefab(Prefab, dist)
    local pos = Vector3(Prefab.Transform:GetWorldPosition())

    if pos then
        local theta = math.random() * 2 * PI
        local radius = dist
        local offset = FindWalkableOffset(pos, theta, radius, 12, true)
        if offset then return pos + offset end
    end
end]]

--- Returns the time of day. Either "day", "dusk", or "night"
--- @return string timeofday The time of day
local function GetClockState() return (TheWorld.state.isday and "day" or TheWorld.state.isdusk and "dusk" or TheWorld.state.isnight and "night") end

--- Get position of this bot
--- @return Vector3 position The position of this bot
function AIAgent:GetPos() return Vector3(self.inst.Transform:GetWorldPosition()) end


function AIAgent:OnStart()

	self.inst.ghostenabled = false -- we won't turn into a ghost. unknown if this works as of writing.

	-- Do this because creating a new Player prefab adds us to the AllPlayers table. We are not a player.
	for i, v in ipairs(AllPlayers) do if v == self.inst then table.remove(AllPlayers, i) end end

	-- local satisfy_bills = PriorityNode {FetchItemBills(self.inst), FetchHarvestBills(self.inst), MineBills(self.inst)}
	local day_time = PriorityNode {
		Wander(self.inst, self:GetPos(), 100000),
	}
	--  IfNode(cond, name, node)
	local root = PriorityNode({
		IfNode(function() return GetClockState() == "day" or GetClockState() == "dusk" end, "day_node", day_time)
		-- pogu
	}, 0.25)

	self.bt = BT(self.inst, root)
end

return AIAgent
