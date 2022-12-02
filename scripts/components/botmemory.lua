BotMemory = Class(function(self, inst)
	self.inst = inst
	self.memory = {}
end)

function BotMemory:GetMemory(key)
	return self.memory[key]
end

function BotMemory:SetMemory(key, value)
	self.memory[key] = value
end

function BotMemory:OnSave()
	local data = {}
	data.memory = self.memory

	return data
end

function BotMemory:OnLoad(data)
    self.memory = data and data.memory or {}
end

-- FYI: this function updates somewhere between 15-30 times per second.
function BotMemory:OnUpdate(dt) end


return BotMemory