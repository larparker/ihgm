local mod = RegisterMod("ighm", 1)

local Handler = { predicates = {} }
Handler.predicates[ModCallbacks.MC_POST_GAME_STARTED] = { [2] = false }
Handler.__index = Handler
function Handler.New()
    return setmetatable({ tasks = {} }, Handler)
end
function Handler:AddModule(mod)
    self.tasks[mod.callback] = self.tasks[mod.callback] or {}
    table.insert(self.tasks[mod.callback], mod:GetFunc())
    return self
end
function Handler:GetCallbackFunc(callback)
    return function(...)
        local args = {...}
        if Game():IsGreedMode() then
            local bad = false
            for i, v in pairs(self.predicates[callback] or {}) do
                if args[i] ~= v then bad = true break end
            end
            if not bad then
                for _, v in ipairs(self.tasks[callback]) do
                    v(args)
                end
            end
        end
    end
end
function Handler:DoCallbacks()
    for i, _ in pairs(self.tasks) do
        mod:AddCallback(i, self:GetCallbackFunc(i))
    end
end

local GiveD20 = { callback = ModCallbacks.MC_POST_GAME_STARTED }
GiveD20.__index = GiveD20
function GiveD20.New(slot)
    return setmetatable({ slot = slot }, GiveD20)
end
function GiveD20:GetFunc()
    return function()
        Isaac.GetPlayer():AddCollectible(166, 6, true, self.slot)
    end
end

local GiveChaos = { callback = ModCallbacks.MC_POST_GAME_STARTED }
GiveChaos.__index = GiveChaos
function GiveChaos.New()
    return setmetatable({}, GiveChaos)
end
function GiveChaos:GetFunc()
    return function()
        Isaac.GetPlayer():AddCollectible(402)
    end
end

local GiveCoinsOnUltraGreed = { callback = ModCallbacks.MC_POST_NEW_LEVEL }
GiveCoinsOnUltraGreed.__index = GiveCoinsOnUltraGreed
function GiveCoinsOnUltraGreed.New(coins)
    return setmetatable({ coins = coins }, GiveCoinsOnUltraGreed)
end
function GiveCoinsOnUltraGreed:GetFunc()
    return function()
        if Game():GetLevel():GetStage() == 7 then
            Isaac.GetPlayer():AddCoins(self.coins)
        end
    end
end

local GiveMomsKey = { callback = ModCallbacks.MC_POST_GAME_STARTED }
GiveMomsKey.__index = GiveMomsKey
function GiveMomsKey.New()
    return setmetatable({}, GiveMomsKey)
end
function GiveMomsKey:GetFunc()
    return function()
        Isaac.GetPlayer():AddCollectible(199)
    end
end

Handler.New()

-- #####################################################################################################

    :AddModule(GiveD20.New(ActiveSlot.SLOT_PRIMARY))
    :AddModule(GiveMomsKey.New())
     :AddModule(GiveChaos.New())
     :AddModule(GiveCoinsOnUltraGreed.New(40))

-- #####################################################################################################

    :DoCallbacks()
