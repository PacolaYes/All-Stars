
---@class SquigglepantsGametype: table
local gametypeDefault = {
    name = "UNDEFINED", ---@type string The gametype's name, shows up on the Player List & Voting Screen.
    identifier = "UNDEFINED", ---@type string The gametype's identifier, "spongebob" would make it so the gametype is identified as SGT_SPONGEBOB code-wise.
    description = nil, ---@type string? The gametype's description, shows up on the Voting Screen.
    color = SKINCOLOR_NONE, ---@type integer? The gametype name's color, active on the Player List & Voting Screen.
    typeoflevel = TOL_COOP|TOL_SQUIGGLEPANTS, ---@type integer? The gametype's TOL_ flags, chooses which type of levels the mode accepts :P

    thinker = nil, ---@type function? ThinkFrame, but only when the gametype is active.<br>- Function has a self argument, representing the gametype's definition.
    playerThink = nil, ---@type function? PlayerThink, but only when the gametype is active.<br>- Function has a self argument, representing the gametype's definition.
    gameHUD = nil, ---@type function? A normal "game" type HUD hook, but only when the gametype is active.<br><br>Check the [wiki's page](https://wiki.srb2.org/wiki/Lua/Functions#HUD_hooks) for more information.
    intermission = nil --- @type function? This mode's intermission HUD function, skips directly to vote if none is given.
}
-- not recommended to directly modify this, but do whatever u want
Squigglepants.gametypes = {} ---@type table<SquigglepantsGametype>

--- adds a gametype
---@param definition SquigglepantsGametype
function Squigglepants.addGametype(definition)
    if type(definition) ~= "table" then
        error("wheres the definition", 2)
        return
    end

    if type(definition.name) ~= "string"
    or type(definition.identifier) ~= "string" then
        error("Oops! It seems you've forgotten to specify some of the arguments!", 2)
        return
    end

    local idName = "SGT_" + definition.identifier:upper()
    local idNum = #Squigglepants.gametypes + 1
    if _G[idName] ~= nil then
        idNum = _G[idName]
    else
        rawset(_G, idName, idNum)
    end

    definition.color = $ or gametypeDefault.color
    definition.typeoflevel = $ or gametypeDefault.typeoflevel

    Squigglepants.gametypes[idNum] = definition
end

--- gets a gametype's identifier by gametype name; name is case-sensitive.
---@param name string
---@return SquigglepantsGametype?
function Squigglepants.getGametypeDef(name)
    if type(name) != "string" then
        error("Oops! It seems you've forgotten to specify a name!", 2)
        return
    end

    for _, value in ipairs(Squigglepants.gametypes) do
        if type(value) == "table"
        and value.name == name then
            return value
        end
    end
end

addHook("ThinkFrame", function()
    if gametype ~= GT_SQUIGGLEPANTS
    or not Squigglepants.sync.gametype then
        return
    end

    local gtDef = Squigglepants.gametypes[Squigglepants.sync.gametype] ---@type SquigglepantsGametype
    if not gtDef then
        return
    end

    if type(gtDef.thinker) == "function"
    and Squigglepants.sync.gamestate == SST_NONE then
        gtDef:thinker()
    end
end)

---@param p player_t
addHook("PlayerThink", function(p)
    if gametype ~= GT_SQUIGGLEPANTS
    or not Squigglepants.sync.gametype then
        return
    end

    local gtDef = Squigglepants.gametypes[Squigglepants.sync.gametype] ---@type SquigglepantsGametype
    if not gtDef then
        return
    end

    if type(gtDef.playerThink) == "function"
    and Squigglepants.sync.gamestate == SST_NONE then
        gtDef:playerThink(p)
    end
end)

local voteHUD = Squigglepants.dofile("Game/voting.lua") ---@type function
-- handle intermission/vote HUD stuff
customhud.SetupItem("Squigglepants_Intermission", "Squigglepants", function(v)
    if gametype ~= GT_SQUIGGLEPANTS
    or not Squigglepants.sync.gametype then return end

    local gtDef = Squigglepants.gametypes[Squigglepants.sync.gametype] ---@type SquigglepantsGametype?
    if not gtDef then return end

    local gamestate = Squigglepants.sync.gamestate

    if gamestate == SST_INTERMISSION
    and type(gtDef.intermission) == "function" then
        gtDef.intermission(v)
    elseif gamestate == SST_VOTE then
        voteHUD(v)
    end
end, "gameandscores")

-- handle gametype HUD stuff
customhud.SetupItem("Squigglepants_Main", "Squigglepants", function(v)
    if gametype ~= GT_SQUIGGLEPANTS
    or not Squigglepants.sync.gametype then return end

    local gtDef = Squigglepants.gametypes[Squigglepants.sync.gametype] ---@type SquigglepantsGametype?
    if not gtDef then return end

    local gamestate = Squigglepants.sync.gamestate

    if gamestate == SST_NONE
    and type(gtDef.gameHUD) == "function" then
        gtDef.gameHUD(v)
    end
end, "game")