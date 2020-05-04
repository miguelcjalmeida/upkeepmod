local Events = require "initialized/events"
local Wargroove = require "wargroove/wargroove"
local Constants = require "constants"

local Actions = {}
local globalUpkeepEnabled = true

function Actions.init()
  Events.addToActionsList(Actions)
end

function Actions.populate(dst)
    dst["apply_upkeep"] = Actions.applyUpkeep
    dst["pay_upkeep_action"] = Actions.payUpkeepAction
    dst["enable_global_upkeep"] = Actions.enableGlobalUpkeep
    dst["disable_global_upkeep"] = Actions.disableGlobalUpkeep
end

function Actions.applyUpkeep(context)
    if (globalUpkeepEnabled ~= true) then return end

    local playerId = context:getPlayerId(0)
    local unitClass = Constants.unitClass
    local location = Constants.location
    local rate = Constants.upkeepRate
    local allowBeingInDebt = Constants.allowBeingInDebt
    local chargeCommanders = Constants.chargeCommanders
    local units = context:doGatherUnits(playerId, unitClass, location)
 
    for i, unit in ipairs(units) do
        Actions.payUpkeep(playerId, unit, rate, allowBeingInDebt, chargeCommanders)
    end
end

function Actions.payUpkeepAction(context)     
    local playerId = context:getPlayerId(0)
    local unitClass = context:getUnitClass(1)
    local location = context:getLocation(2)
    local rate = context:getInteger(3)
    local allowBeingInDebt = context:getBoolean(4)
    local chargeCommanders = context:getBoolean(5)
    local units = context:gatherUnits(0, 1, 2)

    for i, unit in ipairs(units) do
        Actions.payUpkeep(playerId, unit, rate, allowBeingInDebt, chargeCommanders)
    end
end

function Actions.disableGlobalUpkeep(context)     
    globalUpkeepEnabled = false
end

function Actions.enableGlobalUpkeep(context)     
    globalUpkeepEnabled = true
end

function Actions.payUpkeep(playerId, unit, rate, allowBeingInDebt, chargeCommanders)
    if (unit == nil) then return end
    if (unit.unitClass == nil) then return end
    if (chargeCommanders == false and unit.unitClass.isCommander) then return end
    if (unit.unitClass.cost == nil) then return end

    local upkeepCost = math.abs(unit.unitClass.cost) * rate * 0.01
    local money = Actions.calculateMoneyAfterDebt(playerId, upkeepCost, allowBeingInDebt)

    Wargroove.setMoney(playerId, math.floor(money))
end

function Actions.calculateMoneyAfterDebt(playerId, upkeepCost, allowBeingInDebt) 
    local currentMoney = Wargroove.getMoney(playerId)
    currentMoney = currentMoney - upkeepCost

    if (allowBeingInDebt) then return currentMoney end
    if (currentMoney < 0) then currentMoney = 0 end
    return currentMoney   
end


return Actions
