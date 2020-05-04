local Events = require "wargroove/events"
local Wargroove = require "wargroove/wargroove"
local Constants = require "constants"

local Triggers = {}

function Triggers.getApplyUpkeepTrigger(referenceTrigger)
    local trigger = {}
    trigger.id =  "applyUpkeepTrigger"
    trigger.recurring = "repeat"
    trigger.players = referenceTrigger.players
    trigger.conditions = {}
    trigger.actions = {}
    
    table.insert(trigger.conditions, { id = "player_turn", parameters = { "current" } })
    table.insert(trigger.conditions, { id = "start_of_turn", parameters = { } })
    table.insert(trigger.actions, { id = "apply_upkeep", parameters = { "current" }  })
    
    return trigger
end

return Triggers