TestBehaviour = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "TestBehaviour")
    self.inst = inst
    self.grabbing = false

    self.inst:ListenForEvent("noPathFound", function()
        self.inst.brain:Say("Oh shit how the fuck do I get there??? FUCK.")
    end)
end)

function TestBehaviour:OnStop()
    self.inst.components.locomotor:Stop()
end

function TestBehaviour:GetFlint()
    local flint = FindEntity(self.inst, 150, function(item) return item.prefab == "flint" end)

    if flint ~= nil then
        self.status = RUNNING
        --self.inst.brain:Say("I'm gonna get that flint!")
        print("Action being made.")
        self.grabbing = true
        local action = BufferedAction(self.inst, flint, ACTIONS.PICKUP)

        action:AddFailAction(function(a)
            print("Something failed. ", a)
            self.status = FAILED
        end)

        action:AddSuccessAction(function()
            print("Grabbed a flint!")
            self.grabbing = false
        end)

        self.inst.components.locomotor:PushAction(action, true, true)
        --self.inst.components.locomotor:RunInDirection(35)
    else
        self.status = FAILED
        print("Failed to find any flint :(")

        return
    end
end

function TestBehaviour:Visit()
    --[[if self.status == READY then
        self:GetFlint()
    elseif self.status == RUNNING then
            --print("Going!")
        else
            self.status = FAILED
        end
    end]]
    if self.status == READY or self.status == RUNNING and not self.grabbing then
        self:GetFlint()
    end
end