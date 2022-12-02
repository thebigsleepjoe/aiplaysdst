local Vector3 = GLOBAL.Vector3

-- return GLOBAL.TheWorld.components.clock


--- Function ripped from the game's code, found in player_common.lua on 12/1/2022
--- @param inst userdata The player's instance
local function RemovePlayerComponents(inst)
    inst:PushEvent("enableboatcamera", false)
    inst:RemoveComponent("playeractionpicker")
    inst:RemoveComponent("playercontroller")
    inst:RemoveComponent("playervoter")
    inst:RemoveComponent("playermetrics")
    inst:RemoveEventCallback("serverpauseddirty", inst._serverpauseddirtyfn, TheWorld)
    inst._serverpauseddirtyfn = nil
end



--- Initialize an instance as a bot
--- @param inst userdata The instance to initialize
--- @return nil
local function InitializeAsBot(inst)
    inst:AddComponent("botmemory")
    inst:AddTag("jojobot")
    inst.entity:SetCanSleep(false) -- Don't let the bot sleep, it's a bot!

    RemovePlayerComponents(inst)

    local brain = GLOBAL.require "brains/aiplayerbrain"
    inst:SetBrain(brain)
end

function GLOBAL.SpawnAI()
    print("Spawning an agent")
    local agent = GLOBAL.SpawnPrefab("wilson")
    local pos = Vector3(GLOBAL.AllPlayers[1].Transform:GetWorldPosition())

    agent.Transform:SetPosition(pos:Get())
    InitializeAsBot(agent)

    agent:GetBrain():Say("I'm alive!")

    return agent
end


function GLOBAL.ControlMe()
    print("Attempting to control player 1")
    local player = AllPlayers[1]
    InitializeAsBot(player)
    player.components.talker:Say("I am a bot now!")
end